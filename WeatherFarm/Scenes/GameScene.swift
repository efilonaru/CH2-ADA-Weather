//
//  GameScene.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 19/04/26.
//


import SpriteKit
import UIKit
import Combine

class GameScene: SKScene, UIGestureRecognizerDelegate {

    // Base tile metrics are derived from the tile texture once loaded.
    // These are the visible diamond width/height (in scene points after applying renderScale).
    private var diamondWidth: CGFloat = 0
    private var diamondHeight: CGFloat = 0

    // Desired render scale (how many screen points per tileWidth). Use 2.0 to match previous visual size.
    let renderScale: CGFloat = 2.0
    // Extra spacing (pixels) added between diamonds to avoid clumping. Adjust to taste (0..16)
    let tileGap: CGFloat = 4.0

    // camera node for panning/zoom
    private var sceneCamera: SKCameraNode?
    // zoom limits (will be adjusted dynamically in didMove to ensure full-grid fit)
    private var minCameraScale: CGFloat = 0.5
    private var maxCameraScale: CGFloat = 3.0
    private var cameraDefaultScale: CGFloat = 1.0

    // padding around the grid for camera fitting (in scene points)
    private let cameraPadding: CGFloat = 64.0

    // cached grid bounding box (in scene coordinates)
    private var gridBounds: CGRect = .zero

    // cached grid origin used to map iso coords to scene coords for dynamic adds
    private var gridOrigin: CGPoint = .zero

    // quick lookup map from (x,y) to tile for fast checks
    private var tileMap: [String: TileNode] = [:]

    class TileNode: SKSpriteNode {
        var gridX: Int = 0
        var gridY: Int = 0

        // Selection / crop placeholders
        var hasCrop: Bool = false
        var plantedAt: TimeInterval? = nil
        var baseGrowthDuration: TimeInterval = 60
        var harvested: Bool = false

        // Track CropModel for this tile
        var crop: CropModel? = nil

        // Cache textures (optional)
        var baseTexture: SKTexture?
        var highlightTexture: SKTexture?

        // Scene-space diamond hit-test. Uses the tile's scene position and the node's size.
        func containsScenePoint(_ scenePoint: CGPoint) -> Bool {
            // For anchorPoint = (0.5, 0.0) (bottom-center): bottom is self.position
            let bw = self.size.width
            let bh = self.size.height

            let bottom = CGPoint(x: self.position.x, y: self.position.y)
            let top = CGPoint(x: self.position.x, y: self.position.y + bh)
            let left = CGPoint(x: self.position.x - bw / 2.0, y: self.position.y + bh / 2.0)
            let right = CGPoint(x: self.position.x + bw / 2.0, y: self.position.y + bh / 2.0)

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
                if let base = baseTexture {
                    self.texture = base
                }
                self.colorBlendFactor = 0.0
            }
        }

        // Compute growth progress based on plantedAt and baseGrowthDuration. Uses wall clock so growth continues while app is closed.
        func growthProgress(currentTime: TimeInterval = Date().timeIntervalSince1970, weatherMultiplier: Double = 1.0) -> Double {
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
    }
    
    let ghostTexture = SKTexture(imageNamed: "tile_grass")
//    ghostTexture.filteringMode = .nearest

    var tiles: [TileNode] = []

    // cached textures for performance
    private var baseTileTexture: SKTexture?
    private var highlightTileTexture: SKTexture?

    // Combine cancellables for view model subscriptions
    private var cancellables = Set<AnyCancellable>()

    // Reference to the SwiftUI view model for selection / UI wiring
    weak var gameViewModel: GameViewModel? = nil {
        didSet {
            cancellables.removeAll()

            gameViewModel?.plantRequest
                .receive(on: DispatchQueue.main)
                .sink { [weak self] req in
                    self?.plantCrop(req)
                }
                .store(in: &cancellables)

            gameViewModel?.harvestRequest
                .receive(on: DispatchQueue.main)
                .sink { [weak self] req in
                    self?.performHarvestAt(x: req.gridX, y: req.gridY)
                }
                .store(in: &cancellables)

            gameViewModel?.$selectedTile
                .receive(on: DispatchQueue.main)
                .sink { [weak self] sel in
                    guard let self = self else { return }
                    if sel == nil {
                        for t in self.tiles { t.setSelected(false) }
                    } else if let s = sel {
                        for t in self.tiles { t.setSelected(t.gridX == s.gridX && t.gridY == s.gridY) }
                    }
                }
                .store(in: &cancellables)
        }
    }

    // whether the scene should auto-harvest and immediately replant the same crop
    private let autoReplant: Bool = true

    override func didMove(to view: SKView) {
        backgroundColor = .clear

        // Setup camera
        let cam = SKCameraNode()
        cam.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        self.camera = cam
        addChild(cam)
        self.sceneCamera = cam

        // gesture recognizers
        let skView = view
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        pan.maximumNumberOfTouches = 2
        pan.minimumNumberOfTouches = 1
        pan.cancelsTouchesInView = false
        skView.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        skView.addGestureRecognizer(pinch)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        skView.addGestureRecognizer(doubleTap)

        // Start with a 3x3 base land
        drawGrid(rows: 3, cols: 3)

        // After drawing the grid, compute bounds and adjust camera zoom limits so the whole farm can be shown.
        self.gridBounds = computeGridBounds()

        if let v = self.view {
            let viewSize = v.bounds.size
            let paddedWidth = max(1.0, gridBounds.width + cameraPadding * 2.0)
            let paddedHeight = max(1.0, gridBounds.height + cameraPadding * 2.0)
            let scaleFit = max(paddedWidth / viewSize.width, paddedHeight / viewSize.height)

            cameraDefaultScale = max(1.0, scaleFit)
            maxCameraScale = max(cameraDefaultScale, 3.0)
            minCameraScale = max(0.25, cameraDefaultScale / 4.0)

            cam.setScale(cameraDefaultScale)
            cam.position = CGPoint(x: gridBounds.midX, y: gridBounds.midY)
        }
    }

    func handleTileTap(_ tile: TileNode) {
        for t in tiles { t.setSelected(false) }
        tile.setSelected(true)
        gameViewModel?.selectTile(x: tile.gridX, y: tile.gridY)
        print("Tapped tile: \(tile.gridX), \(tile.gridY)")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 1. Check for ghost tiles first (priority for expansion)
        let hitNodes = nodes(at: location)
        for node in hitNodes {
            if let ghost = node as? GhostTileNode {
                addTileAt(x: ghost.targetX, y: ghost.targetY)
                return
            }
        }

        // 2. Iterate tiles in descending zPosition (top-most first) to pick the front-most tile on overlap
        let sortedTiles = tiles.sorted { $0.zPosition > $1.zPosition }

        var hitTile: TileNode? = nil
        for tile in sortedTiles {
            if tile.containsScenePoint(location) {
                hitTile = tile
                break
            }
        }

        if let tile = hitTile {
            handleTileTap(tile)
        } else {
            for t in tiles { t.setSelected(false) }
            gameViewModel?.deselectTile()
        }
    }

    // Gesture handlers
    @objc func handlePan(_ g: UIPanGestureRecognizer) {
        guard let cam = self.camera, let view = self.view else { return }
        let translation = g.translation(in: view)
        let dx = -translation.x * cam.xScale
        let dy = translation.y * cam.yScale
        cam.position = CGPoint(x: cam.position.x + dx, y: cam.position.y + dy)
        clampCameraPosition()
        g.setTranslation(.zero, in: view)
    }

    @objc func handlePinch(_ g: UIPinchGestureRecognizer) {
        guard let cam = self.camera, let view = self.view else { return }
        if g.state == .began || g.state == .changed {
            let locationInView = g.location(in: view)
            let locationInScene = convertPoint(fromView: locationInView)
            let oldScale = cam.xScale
            var newScale = oldScale / g.scale
            newScale = min(max(newScale, minCameraScale), maxCameraScale)
            let scaleRatio = newScale / oldScale
            let camPos = cam.position
            let translated = CGPoint(x: locationInScene.x - camPos.x, y: locationInScene.y - camPos.y)
            let newCamPos = CGPoint(x: locationInScene.x - translated.x * scaleRatio, y: locationInScene.y - translated.y * scaleRatio)
            cam.setScale(newScale)
            cam.position = newCamPos
            clampCameraPosition()
            g.scale = 1.0
        }
    }

    @objc func handleDoubleTap(_ g: UITapGestureRecognizer) {
        guard let cam = self.camera else { return }
        let move = SKAction.move(to: CGPoint(x: gridBounds.midX, y: gridBounds.midY), duration: 0.25)
        let scale = SKAction.scale(to: cameraDefaultScale, duration: 0.25)
        cam.run(SKAction.group([move, scale]))
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    private func clampCameraPosition() {
        guard let cam = self.camera, let v = self.view else { return }
        let halfW = (v.bounds.size.width * 0.5) * cam.xScale
        let halfH = (v.bounds.size.height * 0.5) * cam.xScale
        let minX = gridBounds.minX - cameraPadding + halfW
        let maxX = gridBounds.maxX + cameraPadding - halfW
        let minY = gridBounds.minY - cameraPadding + halfH
        let maxY = gridBounds.maxY + cameraPadding - halfH
        var newX = cam.position.x
        var newY = cam.position.y
        if minX > maxX { newX = gridBounds.midX } else { newX = min(max(newX, minX), maxX) }
        if minY > maxY { newY = gridBounds.midY } else { newY = min(max(newY, minY), maxY) }
        cam.position = CGPoint(x: newX, y: newY)
    }

    // Compute grid bounding box from current tiles
    private func computeGridBounds() -> CGRect {
        guard !tiles.isEmpty else { return CGRect(x: 0, y: 0, width: size.width, height: size.height) }
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude
        for t in tiles {
            let left = t.position.x - t.size.width / 2.0
            let right = t.position.x + t.size.width / 2.0
            let bottom = t.position.y
            let top = t.position.y + t.size.height
            minX = min(minX, left); maxX = max(maxX, right)
            minY = min(minY, bottom); maxY = max(maxY, top)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    func drawGrid(rows: Int, cols: Int) {
        // Cache textures once for performance
        baseTileTexture = SKTexture(imageNamed: "tile_grass")
        baseTileTexture?.filteringMode = .nearest
        highlightTileTexture = SKTexture(imageNamed: "_highlight")
        highlightTileTexture?.filteringMode = .nearest

        // compute explicit render size for tiles from the texture size
        let texW = baseTileTexture?.size().width ?? 32
        let texH = baseTileTexture?.size().height ?? 32

        // Compute diamond spacing from texture: diamond width = texture width; diamond height = texture height / 2
        diamondWidth = texW * renderScale
        diamondHeight = (texH / 2.0) * renderScale

        // Add tileGap to effective diamond spacing
        let effDiamondW = diamondWidth + tileGap
        let effDiamondH = diamondHeight + tileGap

        let renderSize = CGSize(width: texW * renderScale, height: texH * renderScale)

        // First pass: compute raw scene positions for each tile (relative to an origin of (0,0)).
        var rawPositions: [CGPoint] = []
        rawPositions.reserveCapacity(rows * cols)
        for row in 0..<rows {
            for col in 0..<cols {
                let posX = CGFloat(col - row) * (effDiamondW / 2.0)
                let posY = CGFloat(col + row) * (effDiamondH / 2.0)
                rawPositions.append(CGPoint(x: posX, y: -posY))
            }
        }

        // Compute bounding box of raw positions and determine center so we can center the grid in the scene
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude
        for p in rawPositions { minX = min(minX, p.x); maxX = max(maxX, p.x); minY = min(minY, p.y); maxY = max(maxY, p.y) }
        let centerRaw = CGPoint(x: (minX + maxX) / 2.0, y: (minY + maxY) / 2.0)

        // origin is chosen so centerRaw maps to the scene center
        let origin = CGPoint(x: size.width / 2.0 - centerRaw.x, y: size.height / 2.0 - centerRaw.y)
        self.gridOrigin = origin

        // create tiles
        tiles.removeAll()
        tileMap.removeAll()
        var idx = 0
        for row in 0..<rows {
            for col in 0..<cols {
                let pos = rawPositions[idx]; idx += 1
                let tile = TileNode(texture: baseTileTexture)
                tile.baseTexture = baseTileTexture
                tile.highlightTexture = highlightTileTexture
                tile.size = renderSize
                tile.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                tile.gridX = col
                tile.gridY = row
                tile.position = CGPoint(x: origin.x + pos.x, y: origin.y + pos.y)
                tile.zPosition = -tile.position.y
                tiles.append(tile)
                addChild(tile)
                tileMap["\(col):\(row)"] = tile
            }
        }

        // create add-buttons for expansion on edges
        updateAddButtons()
    }

    // Convert grid coordinates to scene position using the stored gridOrigin and iso math
    private func positionForGrid(x: Int, y: Int) -> CGPoint {
        let effDiamondW = diamondWidth + tileGap
        let effDiamondH = diamondHeight + tileGap
        let posX = CGFloat(x - y) * (effDiamondW / 2.0)
        let posY = CGFloat(x + y) * (effDiamondH / 2.0)
        return CGPoint(x: gridOrigin.x + posX, y: gridOrigin.y - posY)
    }

    private func tileExistsAt(x: Int, y: Int) -> Bool {
        return tileMap["\(x):\(y)"] != nil
    }

    // Compute the cost to add a new tile. Base starts at 20 and increases by 5 for each tile beyond the initial baseCount.
    private func costToAddTile() -> Int {
        let baseCost = 20
        let increment = 5
        let initialCount = 9 // 3x3 base
        let extra = max(0, tiles.count - initialCount)
        return baseCost + increment * extra
    }

    private func addTileAt(x: Int, y: Int) {
        guard !tileExistsAt(x: x, y: y) else { return }
        
        let cost = costToAddTile()
        if let vm = gameViewModel {
            if !vm.spendGold(cost) {
                // Find and flash the specific ghost tile
                if let ghost = self.children.first(where: { ($0 as? GhostTileNode)?.targetX == x && ($0 as? GhostTileNode)?.targetY == y }) as? GhostTileNode {
                    flashGhostRed(ghost)
                }
                return
            }
        }
        
        let tile = TileNode(texture: baseTileTexture)
        tile.baseTexture = baseTileTexture
        tile.highlightTexture = highlightTileTexture
        tile.size = tiles.first?.size ?? CGSize(width: 64, height: 64)
        tile.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        tile.gridX = x
        tile.gridY = y
        tile.position = positionForGrid(x: x, y: y)
        tile.zPosition = -tile.position.y
        tiles.append(tile)
        addChild(tile)
        tileMap["\(x):\(y)"] = tile
        self.gridBounds = computeGridBounds()
        clampCameraPosition()
        updateAddButtons()
    }

    private func flashGhostRed(_ ghost: GhostTileNode) {
        let tint = SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.3)
        let untint = SKAction.colorize(with: .white, colorBlendFactor: 0.3, duration: 0.1)
        ghost.run(SKAction.sequence([tint, wait, untint]))
    }

    private func updateAddButtons() {
        // remove existing ghost tiles
        self.children.filter { $0 is GhostTileNode }.forEach { $0.removeFromParent() }

        func keyFor(_ x: Int, _ y: Int) -> String { "\(x):\(y)" }
        let directions: [(dx: Int, dy: Int)] = [(1,0), (-1,0), (0,1), (0,-1)]

        var occupiedSet = Set<String>()
        for t in tiles { occupiedSet.insert(keyFor(t.gridX, t.gridY)) }

        // Use a set to track where we've already placed a ghost tile
        var ghostPositions = Set<String>()
        
        for tile in tiles {
            let tx = tile.gridX, ty = tile.gridY
            
            for dir in directions {
                let nx = tx + dir.dx
                let ny = ty + dir.dy
                let k = keyFor(nx, ny)
                
                if !occupiedSet.contains(k) && !ghostPositions.contains(k) {
                    ghostPositions.insert(k)
                    
                    let basePos = positionForGrid(x: nx, y: ny)
                    let ghost = GhostTileNode(texture: baseTileTexture)
                    ghost.size = tiles.first?.size ?? CGSize(width: 64, height: 64)
                    ghost.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                    ghost.targetX = nx
                    ghost.targetY = ny
                    ghost.position = basePos
                    
                    // Visual style: faint, tinted ghost
                    ghost.alpha = 0.4
                    ghost.color = .white
                    ghost.colorBlendFactor = 0.3
                    
                    // Sort behind real tiles at same position, but clickable
                    ghost.zPosition = -basePos.y - 1 
                    ghost.name = "ghost_tile"

                    addChild(ghost)
                }
            }
        }
    }

    func isoToScreen(x: Int, y: Int) -> CGPoint {
        let screenX = CGFloat(x - y) * (diamondWidth / 2.0)
        let screenY = CGFloat(x + y) * (diamondHeight / 2.0)
        return CGPoint(x: screenX, y: screenY)
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let weatherMultiplier: Double = 1.0
        for tile in tiles {
            guard tile.hasCrop else { continue }
            let progress = tile.growthProgress(currentTime: Date().timeIntervalSince1970, weatherMultiplier: weatherMultiplier)
            if let crop = tile.crop, let baseName = crop.textureName, !baseName.isEmpty {
                let stageName: String
                if progress < 0.33 { stageName = "\(baseName)_seed" }
                else if progress < 0.66 { stageName = "\(baseName)_early" }
                else { stageName = "\(baseName)_ripe" }
                let tex = SKTexture(imageNamed: stageName)
                tex.filteringMode = .nearest
                tile.texture = tex
            } else {
                if progress < 0.33 {
                    tile.color = UIColor.systemGreen.withAlphaComponent(0.25)
                    tile.colorBlendFactor = 0.25
                } else if progress < 0.66 {
                    tile.color = UIColor.systemGreen.withAlphaComponent(0.45)
                    tile.colorBlendFactor = 0.45
                } else if progress < 1.0 {
                    tile.color = UIColor.systemOrange.withAlphaComponent(0.45)
                    tile.colorBlendFactor = 0.45
                } else {
                    tile.color = UIColor.systemYellow.withAlphaComponent(0.6)
                    tile.colorBlendFactor = 0.6
                }
            }
            if progress >= 1.0 {
                performAutoHarvestAndReplant(tile: tile)
            }
        }
    }

    private func performAutoHarvestAndReplant(tile: TileNode) {
        guard tile.hasCrop, let crop = tile.crop else { return }
        gameViewModel?.awardGold(crop.value)
        if autoReplant {
            tile.plantedAt = Date().timeIntervalSince1970
            tile.baseGrowthDuration = crop.baseGrowthDuration
            tile.harvested = false
            if let baseName = crop.textureName, !baseName.isEmpty {
                let seedName = "\(baseName)_seed"
                let seedTex = SKTexture(imageNamed: seedName)
                seedTex.filteringMode = .nearest
                tile.texture = seedTex
                tile.baseTexture = seedTex
                tile.colorBlendFactor = 0.0
            } else {
                tile.color = .green
                tile.colorBlendFactor = 0.35
            }
        } else {
            tile.hasCrop = false
            tile.plantedAt = nil
            tile.baseGrowthDuration = 60
            tile.harvested = true
            tile.crop = nil
            tile.baseTexture = baseTileTexture
            tile.texture = baseTileTexture
            tile.colorBlendFactor = 0.0
        }
    }

    private func plantCrop(_ req: PlantRequest) {
        guard let tile = tiles.first(where: { $0.gridX == req.gridX && $0.gridY == req.gridY }) else { return }
        guard !tile.hasCrop else { return }
        tile.hasCrop = true
        tile.crop = req.crop
        tile.plantedAt = Date().timeIntervalSince1970
        tile.baseGrowthDuration = req.crop.baseGrowthDuration
        tile.harvested = false
        if let texName = req.crop.textureName, !texName.isEmpty {
            let seedName = "\(texName)_seed"
            let seedTex = SKTexture(imageNamed: seedName)
            seedTex.filteringMode = .nearest
            tile.baseTexture = seedTex
            tile.texture = seedTex
        } else {
            tile.color = .green
            tile.colorBlendFactor = 0.35
        }
    }

    private func performHarvestAt(x: Int, y: Int) {
        guard let tile = tiles.first(where: { $0.gridX == x && $0.gridY == y }) else { return }
        guard tile.isReadyForHarvest else { return }
        if let crop = tile.crop { gameViewModel?.awardGold(crop.value) }
        tile.hasCrop = false
        tile.plantedAt = nil
        tile.baseGrowthDuration = 60
        tile.harvested = true
        tile.crop = nil
        tile.baseTexture = baseTileTexture
        tile.texture = baseTileTexture
        tile.colorBlendFactor = 0.0
    }
}
