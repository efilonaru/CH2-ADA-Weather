//
//  GameScene.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 19/04/26.
//

import Combine
import SpriteKit
import UIKit
import SwiftData

class GameScene: SKScene, UIGestureRecognizerDelegate {


    private var diamondWidth: CGFloat = 0
    private var diamondHeight: CGFloat = 0

    let renderScale: CGFloat = 2.0
    let tileGap: CGFloat = 4.0

    private var sceneCamera: SKCameraNode?
    private var minCameraScale: CGFloat = 0.5
    private var maxCameraScale: CGFloat = 3.0
    private var cameraDefaultScale: CGFloat = 1.0

    private let cameraPadding: CGFloat = 64.0
    private var gridBounds: CGRect = .zero
    private var gridOrigin: CGPoint = .zero
    private var tileMap: [String: TileNode] = [:]

    private var currentWeather: WeatherCondition = .sunny

    class TileNode: SKSpriteNode {
        var gridX: Int = 0
        var gridY: Int = 0
        var hasCrop: Bool = false
        var plantedAt: TimeInterval? = nil
        var baseGrowthDuration: TimeInterval = 60
        var harvested: Bool = false
        var crop: CropModel? = nil
        var baseTexture: SKTexture?
        var highlightTexture: SKTexture?

        func containsScenePoint(_ scenePoint: CGPoint) -> Bool {
            let bw = self.size.width
            let bh = self.size.height
            let bottom = CGPoint(x: self.position.x, y: self.position.y)
            let top = CGPoint(x: self.position.x, y: self.position.y + bh)
            let left = CGPoint(
                x: self.position.x - bw / 2.0,
                y: self.position.y + bh / 2.0
            )
            let right = CGPoint(
                x: self.position.x + bw / 2.0,
                y: self.position.y + bh / 2.0
            )
            let path = CGMutablePath()
            path.move(to: top)
            path.addLine(to: right)
            path.addLine(to: bottom)
            path.addLine(to: left)
            path.closeSubpath()
            return path.contains(scenePoint)
        }

        func setSelected(_ selected: Bool) {
            if selected {
                if let hl = highlightTexture {
                    self.texture = hl
                } else if let base = baseTexture {
                    self.texture = base
                    self.color = .yellow
                    self.colorBlendFactor = 0.35
                }
            } else {
                if let base = baseTexture { self.texture = base }
                self.colorBlendFactor = 0.0
            }
        }

        func growthProgress(
            currentTime: TimeInterval = Date().timeIntervalSince1970,
            weatherMultiplier: Double = 1.0
        ) -> Double {
            guard hasCrop, let planted = plantedAt else { return 0.0 }
            let elapsed = currentTime - planted
            let effective = elapsed * weatherMultiplier
            if baseGrowthDuration <= 0 { return 1.0 }
            return min(1.0, effective / baseGrowthDuration)
        }

        var isReadyForHarvest: Bool {
            return hasCrop && !harvested && (growthProgress() >= 1.0)
        }
    }

    class GhostTileNode: SKSpriteNode {
        var targetX: Int = 0
        var targetY: Int = 0

        func containsScenePoint(_ scenePoint: CGPoint) -> Bool {
            let bw = self.size.width
            let bh = self.size.height
            let bottom = CGPoint(x: self.position.x, y: self.position.y)
            let top = CGPoint(x: self.position.x, y: self.position.y + bh)
            let left = CGPoint(
                x: self.position.x - bw / 2.0,
                y: self.position.y + bh / 2.0
            )
            let right = CGPoint(
                x: self.position.x + bw / 2.0,
                y: self.position.y + bh / 2.0
            )
            let path = CGMutablePath()
            path.move(to: top)
            path.addLine(to: right)
            path.addLine(to: bottom)
            path.addLine(to: left)
            path.closeSubpath()
            return path.contains(scenePoint)
        }
    }

    var tiles: [TileNode] = []
    private var baseTileTexture: SKTexture?
    private var highlightTileTexture: SKTexture?
    private var cancellables = Set<AnyCancellable>()

    weak var gameViewModel: GameViewModel? = nil {
        didSet {
            cancellables.removeAll()
            gameViewModel?.plantRequest.receive(on: DispatchQueue.main).sink {
                [weak self] req in self?.plantCrop(req)
            }.store(in: &cancellables)
            gameViewModel?.harvestRequest.receive(on: DispatchQueue.main).sink {
                [weak self] req in
                self?.performHarvestAt(x: req.gridX, y: req.gridY)
            }.store(in: &cancellables)
            gameViewModel?.$isEditMode.receive(on: DispatchQueue.main).sink {
                [weak self] _ in self?.updateAddButtons()
            }.store(in: &cancellables)
            //            gameViewModel?.$currentWeather.receive(on: DispatchQueue.main).sink { [weak self] weather in self?.currentWeather = weather }.store(in: &cancellables)
            gameViewModel?.$selectedTile.receive(on: DispatchQueue.main).sink {
                [weak self] sel in
                guard let self = self else { return }
                for t in self.tiles {
                    t.setSelected(
                        t.gridX == sel?.gridX && t.gridY == sel?.gridY
                    )
                }
            }.store(in: &cancellables)

            // Auto-restore if tiles are already drawn
            if !tiles.isEmpty, let context = gameViewModel?.modelContext {
                restoreSavedTiles(modelContext: context, availableCrops: gameViewModel?.crops ?? [])
            }
        }
    }

    weak var worldManager: WorldEnvironmentManager? = nil {
        didSet {
            // Listen to the global weather state
            worldManager?.$currentWeather
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newWeather in
                    guard let self = self else { return }
                    
                    self.currentWeather = newWeather
                    
                    if newWeather == .rain {
                        startWeatherSystem {
                            self.spawnRainDrop()
                        }
                    } else if newWeather == .snow {
                        startWeatherSystem {
                            self.spawnSnow()
                        }
                    } else {
                        removeAction(forKey: "weather_system")
                    }
                }
                .store(in: &cancellables)
        }
    }

    private let autoReplant: Bool = true

    override func didMove(to view: SKView) {
        self.backgroundColor = .clear

        // Setup camera
        let cam = SKCameraNode()
        cam.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        self.camera = cam
        addChild(cam)
        self.sceneCamera = cam

        let skView = view
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        pan.delegate = self
        skView.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinch(_:))
        )
        pinch.delegate = self
        skView.addGestureRecognizer(pinch)

        let doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        skView.addGestureRecognizer(doubleTap)

        drawGrid(rows: 3, cols: 3)
        self.gridBounds = computeGridBounds()

        // Restore tiles after grid is ready
        if let context = gameViewModel?.modelContext {
            restoreSavedTiles(modelContext: context, availableCrops: gameViewModel?.crops ?? [])
        }

        if let v = self.view {
            let viewSize = v.bounds.size
            let paddedWidth = max(1.0, gridBounds.width + cameraPadding * 2.0)
            let paddedHeight = max(1.0, gridBounds.height + cameraPadding * 2.0)
            let scaleFit = max(
                paddedWidth / viewSize.width,
                paddedHeight / viewSize.height
            )
            cameraDefaultScale = max(1.0, scaleFit)
            maxCameraScale = max(cameraDefaultScale, 3.0)
            minCameraScale = max(0.25, cameraDefaultScale / 4.0)
            cam.setScale(cameraDefaultScale)
            cam.position = CGPoint(x: gridBounds.midX, y: gridBounds.midY)
        }
    }

    @objc func handlePan(_ g: UIPanGestureRecognizer) {
        guard let cam = self.camera, let view = self.view else { return }
        let translation = g.translation(in: view)
        cam.position = CGPoint(
            x: cam.position.x - translation.x * cam.xScale,
            y: cam.position.y + translation.y * cam.yScale
        )
        clampCameraPosition()
        g.setTranslation(.zero, in: view)
    }

    @objc func handlePinch(_ g: UIPinchGestureRecognizer) {
        guard let cam = self.camera, let view = self.view else { return }
        if g.state == .began || g.state == .changed {
            let locationInView = g.location(in: view)
            let locationInScene = convertPoint(fromView: locationInView)
            let oldScale = cam.xScale
            let newScale = min(
                max(oldScale / g.scale, minCameraScale),
                maxCameraScale
            )
            let scaleRatio = newScale / oldScale
            cam.position = CGPoint(
                x: locationInScene.x - (locationInScene.x - cam.position.x)
                    * scaleRatio,
                y: locationInScene.y - (locationInScene.y - cam.position.y)
                    * scaleRatio
            )
            cam.setScale(newScale)
            clampCameraPosition()
            g.scale = 1.0
        }
    }

    @objc func handleDoubleTap(_ g: UITapGestureRecognizer) {
        guard let cam = self.camera else { return }
        cam.run(
            SKAction.group([
                SKAction.move(
                    to: CGPoint(x: gridBounds.midX, y: gridBounds.midY),
                    duration: 0.25
                ), SKAction.scale(to: cameraDefaultScale, duration: 0.25),
            ])
        )
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer:
            UIGestureRecognizer
    ) -> Bool { return true }

    private func clampCameraPosition() {
        guard let cam = self.camera, let v = self.view else { return }
        let halfW = (v.bounds.size.width * 0.5) * cam.xScale
        let halfH = (v.bounds.size.height * 0.5) * cam.xScale
        let minX = gridBounds.minX - cameraPadding + halfW
        let maxX = gridBounds.maxX + cameraPadding - halfW
        let minY = gridBounds.minY - cameraPadding + halfH
        let maxY = gridBounds.maxY + cameraPadding - halfH
        cam.position = CGPoint(
            x: minX > maxX
                ? gridBounds.midX : min(max(cam.position.x, minX), maxX),
            y: minY > maxY
                ? gridBounds.midY : min(max(cam.position.y, minY), maxY)
        )
    }

    private func computeGridBounds() -> CGRect {
        guard !tiles.isEmpty else {
            return CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude
        for t in tiles {
            minX = min(minX, t.position.x - t.size.width / 2.0)
            maxX = max(maxX, t.position.x + t.size.width / 2.0)
            minY = min(minY, t.position.y)
            maxY = max(maxY, t.position.y + t.size.height)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    func drawGrid(rows: Int, cols: Int) {
        baseTileTexture = SKTexture(imageNamed: "tile_grass")
        baseTileTexture?.filteringMode = .nearest
        highlightTileTexture = SKTexture(imageNamed: "_highlight")
        highlightTileTexture?.filteringMode = .nearest
        let texW = baseTileTexture?.size().width ?? 32
        let texH = baseTileTexture?.size().height ?? 32
        diamondWidth = texW * renderScale
        diamondHeight = (texH / 2.0) * renderScale
        let effDiamondW = diamondWidth + tileGap
        let effDiamondH = diamondHeight + tileGap
        let renderSize = CGSize(
            width: texW * renderScale,
            height: texH * renderScale
        )
        var rawPositions: [CGPoint] = []
        for row in 0..<rows {
            for col in 0..<cols {
                rawPositions.append(
                    CGPoint(
                        x: CGFloat(col - row) * (effDiamondW / 2.0),
                        y: -CGFloat(col + row) * (effDiamondH / 2.0)
                    )
                )
            }
        }
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude
        for p in rawPositions {
            minX = min(minX, p.x)
            maxX = max(maxX, p.x)
            minY = min(minY, p.y)
            maxY = max(maxY, p.y)
        }
        let centerRaw = CGPoint(x: (minX + maxX) / 2.0, y: (minY + maxY) / 2.0)
        let origin = CGPoint(
            x: size.width / 2.0 - centerRaw.x,
            y: size.height / 2.0 - centerRaw.y
        )
        self.gridOrigin = origin
        tiles.removeAll()
        tileMap.removeAll()
        var idx = 0
        for row in 0..<rows {
            for col in 0..<cols {
                let pos = rawPositions[idx]
                idx += 1
                let tile = TileNode(texture: baseTileTexture)
                tile.baseTexture = baseTileTexture
                tile.highlightTexture = highlightTileTexture
                tile.size = renderSize
                tile.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                tile.gridX = col
                tile.gridY = row
                tile.position = CGPoint(
                    x: origin.x + pos.x,
                    y: origin.y + pos.y
                )
                tile.zPosition = -tile.position.y
                tiles.append(tile)
                addChild(tile)
                tileMap["\(col):\(row)"] = tile
            }
        }
        updateAddButtons()
    }

    private func positionForGrid(x: Int, y: Int) -> CGPoint {
        let effW = diamondWidth + tileGap
        let effH = diamondHeight + tileGap
        return CGPoint(
            x: gridOrigin.x + CGFloat(x - y) * (effW / 2.0),
            y: gridOrigin.y - CGFloat(x + y) * (effH / 2.0)
        )
    }

    private func costToAddTile() -> Int { 20 + 5 * max(0, tiles.count - 9) }

    private func addTileAt(x: Int, y: Int) {
        guard tileMap["\(x):\(y)"] == nil else { return }
        let cost = costToAddTile()
        gameViewModel?.requestConfirmation(
            message: "Buy new land for $\(cost)?"
        ) { [weak self] in
            guard let self = self else { return }
            if self.gameViewModel?.spendGold(cost) == true {
                let tile = TileNode(texture: self.baseTileTexture)
                tile.baseTexture = self.baseTileTexture
                tile.highlightTexture = self.highlightTileTexture
                tile.size =
                    self.tiles.first?.size ?? CGSize(width: 64, height: 64)
                tile.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                tile.gridX = x
                tile.gridY = y
                tile.position = self.positionForGrid(x: x, y: y)
                tile.zPosition = -tile.position.y
                self.tiles.append(tile)
                self.addChild(tile)
                self.tileMap["\(x):\(y)"] = tile
                self.gridBounds = self.computeGridBounds()
                self.clampCameraPosition()
                self.updateAddButtons()
            }
        }
    }
    private func updateAddButtons() {
            self.children.filter { $0 is GhostTileNode }.forEach {
                $0.removeFromParent()
            }
            guard gameViewModel?.isEditMode == true else { return }
            
            let directions: [(dx: Int, dy: Int)] = [
                (1, 0), (-1, 0), (0, 1), (0, -1),
            ]
            var ghostPositions = Set<String>()
            
            let plusTexture = SKTexture.fromSymbol(
                "plus.circle.fill",
                pointSize: 28,
                color: .systemGreen
            )
            
            let tileSize = tiles.first?.size ?? CGSize(width: 64, height: 64)
            
            for tile in tiles {
                for dir in directions {
                    let nx = tile.gridX + dir.dx
                    let ny = tile.gridY + dir.dy
                    let k = "\(nx):\(ny)"
                    
                    if tileMap[k] == nil && !ghostPositions.contains(k) {
                        ghostPositions.insert(k)
                        let ghost = GhostTileNode(texture: nil)
                        ghost.color = .clear
                        ghost.size = tileSize
                        ghost.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                        ghost.targetX = nx
                        ghost.targetY = ny
                        ghost.position = positionForGrid(x: nx, y: ny)
                        ghost.zPosition = -ghost.position.y - 1
                        ghost.name = "ghost_tile"
                        ghost.alpha = 1.0
                        
                        let visualGrass = SKSpriteNode(texture: baseTileTexture)
                        visualGrass.size = ghost.size
                        visualGrass.anchorPoint = ghost.anchorPoint
                        visualGrass.position = .zero
                        visualGrass.color = .white
                        visualGrass.colorBlendFactor = 0.3
                        visualGrass.alpha = 0.1
                        ghost.addChild(visualGrass)
                        
                        if let tex = plusTexture {
                            let plusIcon = SKSpriteNode(texture: tex)
                            plusIcon.position = CGPoint(x: 0, y: ghost.size.height / 2.0)
                            plusIcon.zPosition = 1
                            plusIcon.alpha = 1.0
                            ghost.addChild(plusIcon)
                        }
                        
                        addChild(ghost)
                    }
                }
            }
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let ghosts = self.children.compactMap { $0 as? GhostTileNode }.sorted {
            $0.zPosition > $1.zPosition
        }
        for g in ghosts {
            if g.containsScenePoint(loc) {
                addTileAt(x: g.targetX, y: g.targetY)
                return
            }
        }
        let sorted = tiles.sorted { $0.zPosition > $1.zPosition }
        for t in sorted {
            if t.containsScenePoint(loc) {
                for tile in tiles { tile.setSelected(false) }
                t.setSelected(true)
                gameViewModel?.selectTile(x: t.gridX, y: t.gridY)
                return
            }
        }
        for t in tiles { t.setSelected(false) }
        gameViewModel?.deselectTile()
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        for tile in tiles {
            guard tile.hasCrop, let crop = tile.crop else { continue }
            let multiplier: Double =
                (crop.preferredWeather == currentWeather) ? 1.5 : 1.0
            let progress = tile.growthProgress(
                currentTime: Date().timeIntervalSince1970,
                weatherMultiplier: multiplier
            )
            if let base = crop.textureName, !base.isEmpty {
                let stage =
                    progress < 0.33
                    ? "_seed" : (progress < 0.66 ? "_seedling" : "_harvest")
                let tex = SKTexture(imageNamed: "\(base)\(stage)")
                tex.filteringMode = .nearest
                tile.texture = tex
//                let name = "\(base)\(stage)"
            } else {
                tile.color =
                    progress < 0.33
                    ? UIColor.systemGreen.withAlphaComponent(0.25)
                    : (progress < 0.66
                        ? UIColor.systemGreen.withAlphaComponent(0.45)
                        : (progress < 1.0
                            ? UIColor.systemOrange.withAlphaComponent(0.45)
                            : UIColor.systemYellow.withAlphaComponent(0.6)))
                tile.colorBlendFactor =
                    progress < 0.33
                    ? 0.25
                    : (progress < 0.66 ? 0.45 : (progress < 1.0 ? 0.45 : 0.6))
            }
            if progress >= 1.0 { performAutoHarvestAndReplant(tile: tile) }
        }
    }

    private func performAutoHarvestAndReplant(tile: TileNode) {
        guard tile.hasCrop, let crop = tile.crop else { return }

        let isPreferred = (crop.preferredWeather == currentWeather)
        let bonus = isPreferred ? Int(Double(crop.value) * 0.2) : 0
        let totalAward = crop.value + bonus

        let newPlantedDate = autoReplant ? Date() : nil
        
        gameViewModel?.notifyAutoHarvest(
            x: tile.gridX,
            y: tile.gridY,
            goldAwarded: totalAward,
            newPlantedDate: newPlantedDate
        )
        showFloatingGold(at: tile.position, amount: totalAward)
        
        if autoReplant {
            tile.plantedAt = newPlantedDate?.timeIntervalSince1970
            tile.harvested = false

            if let baseName = crop.textureName, !baseName.isEmpty {
                let seedTex = SKTexture(imageNamed: "\(baseName)_seed")
                seedTex.filteringMode = .nearest
                tile.texture = seedTex
            }
        } else {
            tile.hasCrop = false
            tile.plantedAt = nil
            tile.harvested = true
            tile.crop = nil
            tile.texture = baseTileTexture
            tile.colorBlendFactor = 0.0
        }
    }

    private func plantCrop(_ req: PlantRequest) {
        guard
            let t = tiles.first(where: {
                $0.gridX == req.gridX && $0.gridY == req.gridY
            }), !t.hasCrop
        else { return }
        t.hasCrop = true
        t.crop = req.crop
        t.plantedAt = Date().timeIntervalSince1970
        t.baseGrowthDuration = req.crop.baseGrowthDuration
        t.harvested = false
        if let tex = req.crop.textureName, !tex.isEmpty {
            t.texture = SKTexture(imageNamed: "\(tex)_seed")
        } else {
            t.color = .green
            t.colorBlendFactor = 0.35
        }
    }

    private func performHarvestAt(x: Int, y: Int) {
        guard let t = tiles.first(where: { $0.gridX == x && $0.gridY == y }),
            t.isReadyForHarvest
        else { return }

        if let crop = t.crop {
            let isPreferred = (crop.preferredWeather == currentWeather)
            let bonus = isPreferred ? Int(Double(crop.value) * 0.2) : 0
            let totalAward = crop.value + bonus
            gameViewModel?.notifyAutoHarvest(
                x: x,
                y: y,
                goldAwarded: totalAward,
                newPlantedDate: nil
            )
            showFloatingGold(at: t.position, amount: totalAward)
        }

        t.hasCrop = false
        t.plantedAt = nil
        t.harvested = true
        t.crop = nil
        t.texture = baseTileTexture
        t.colorBlendFactor = 0.0
    }
    
    private func spawnWeatherParticle(
        imageName: String,
        zRotation: CGFloat,
        alphaRange: ClosedRange<CGFloat>,
        scaleRange: ClosedRange<CGFloat>,
        moveX: CGFloat,
        moveY: CGFloat,
        duration: TimeInterval
    ) {
        let node = SKSpriteNode(imageNamed: imageName)
        node.name = "weather_particle"
        node.zPosition = 1000
        
        // Camera-based spawn area
        let camX = camera?.position.x ?? size.width / 2
        let camY = camera?.position.y ?? size.height / 2
        
        let screenWidth = size.width * (camera?.xScale ?? 1.0)
        let screenHeight = size.height * (camera?.yScale ?? 1.0)
        
        let spawnOffset: CGFloat = 300
        let randomX = CGFloat.random(
            in: (camX - screenWidth/2)...(camX + screenWidth/2 + spawnOffset)
        )
        let startY = camY + screenHeight/2 + 50
        
        node.position = CGPoint(x: randomX, y: startY)
        
        // Appearance
        node.zRotation = zRotation
        node.alpha = CGFloat.random(in: alphaRange)
        node.setScale(CGFloat.random(in: scaleRange))
        
        addChild(node)
        
        // Movement
        let move = SKAction.moveBy(x: moveX, y: moveY, duration: duration)
        let remove = SKAction.removeFromParent()
        
        node.run(.sequence([move, remove]))
    }
    
    private func spawnRainDrop() {
        let screenHeight = size.height * (camera?.yScale ?? 1.0)
        
        spawnWeatherParticle(
            imageName: "raindrop",
            zRotation: 0.4,
            alphaRange: 0.5...1.0,
            scaleRange: 0.8...1.2,
            moveX: -500,
            moveY: -screenHeight - 150,
            duration: 0.8
        )
    }
    
    private func spawnSnow() {
        let screenHeight = size.height * (camera?.yScale ?? 1.0)
        
        spawnWeatherParticle(
            imageName: "snow",
            zRotation: 0,
            alphaRange: 0.7...1.0,
            scaleRange: 0.5...1.0,
            moveX: CGFloat.random(in: -50...50),
            moveY: -screenHeight - 150,
            duration: 3.0
        )
    }
    
    private func startWeatherSystem(
        interval: TimeInterval = 0.02,
        spawn: @escaping () -> Void
    ) {
        removeAction(forKey: "weather_system")
        
        let spawnAction = SKAction.run { spawn() }
        let delay = SKAction.wait(forDuration: interval)
        let loop = SKAction.repeatForever(.sequence([spawnAction, delay]))
        
        run(loop, withKey: "weather_system")
    }
    
    private func showFloatingGold(at position: CGPoint, amount: Int) {
        let label = SKLabelNode(fontNamed: "Minecraft")
        label.text = "+\(amount)"
        label.fontSize = 16
        label.fontColor = .yellow
        
        label.position = CGPoint(x: position.x, y: position.y + 40)
        
        label.zPosition = 2000
        label.alpha = 0.0
        
        addChild(label)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.6)
        
        let group = SKAction.group([moveUp, fadeOut])
        let sequence = SKAction.sequence([
            fadeIn,
            group,
            .removeFromParent()
        ])
        
        label.run(sequence)
    }
    
    func restoreSavedTiles(modelContext: ModelContext, availableCrops: [CropModel]) {
        let descriptor = FetchDescriptor<TileSaveData>()
        guard let savedTiles = try? modelContext.fetch(descriptor) else { return }
        
        for data in savedTiles {
            guard let targetTile = tiles.first(where: { $0.gridX == data.gridX && $0.gridY == data.gridY }) else { continue }
            
            targetTile.hasCrop = data.hasCrop
            targetTile.harvested = data.harvested
            targetTile.plantedAt = data.plantedAt?.timeIntervalSince1970
            
            if data.hasCrop, let cropName = data.cropTextureName,
               let cropModel = availableCrops.first(where: { $0.textureName == cropName }) {
                targetTile.crop = cropModel
                targetTile.baseGrowthDuration = cropModel.baseGrowthDuration
                
                let progress = targetTile.growthProgress()
                let stage = progress < 0.33 ? "_seed" : (progress < 0.66 ? "_seedling" : "_harvest")
                if let texName = cropModel.textureName {
                    let tex = SKTexture(imageNamed: "\(texName)\(stage)")
                    tex.filteringMode = .nearest
                    targetTile.texture = tex
                }
            } else {
                targetTile.crop = nil
                targetTile.texture = baseTileTexture
                targetTile.colorBlendFactor = 0.0
            }
        }
    }

    func syncToSwiftData(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<TileSaveData>()
        let savedTiles = (try? modelContext.fetch(descriptor)) ?? []
        
        for tile in tiles {
            if let existing = savedTiles.first(where: { $0.gridX == tile.gridX && $0.gridY == tile.gridY }) {
                existing.hasCrop = tile.hasCrop
                existing.cropTextureName = tile.crop?.textureName
                existing.plantedAt = tile.plantedAt != nil ? Date(timeIntervalSince1970: tile.plantedAt!) : nil
                existing.harvested = tile.harvested
            } else {
                let newData = TileSaveData(
                    gridX: tile.gridX,
                    gridY: tile.gridY,
                    hasCrop: tile.hasCrop,
                    cropTextureName: tile.crop?.textureName,
                    plantedAt: tile.plantedAt != nil ? Date(timeIntervalSince1970: tile.plantedAt!) : nil,
                    harvested: tile.harvested
                )
                modelContext.insert(newData)
            }
        }
        try? modelContext.save()
    }

}
