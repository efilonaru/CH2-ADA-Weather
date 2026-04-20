//
//  GameScene.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 19/04/26.
//


import SpriteKit

class GameScene: SKScene {

    let tileWidth: CGFloat = 32
    let tileHeight: CGFloat = 16
    
    class TileNode: SKSpriteNode {
        var gridX: Int = 0
        var gridY: Int = 0
    }
    
    var tiles: [TileNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = .black
        drawGrid(rows: 2, cols: 2)
    }
    
    func handleTileTap(_ tile: TileNode) {
        for t in tiles {
            t.colorBlendFactor = 0
        }

        tile.color = .yellow
        tile.colorBlendFactor = 0.4

        print("Tapped tile: \(tile.gridX), \(tile.gridY)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let nodes = self.nodes(at: location)

        for node in nodes {
            if let tile = node as? TileNode {
                handleTileTap(tile)
                break
            }
        }
    }

    func drawGrid(rows: Int, cols: Int) {
        let origin = CGPoint(x: size.width / 2, y: size.height / 2)

        for row in 0..<rows {
            for col in 0..<cols {

                let pos = isoToScreen(x: col, y: row)

//                let texture = SKTexture(imageNamed: "tile_grass")
//                texture.filteringMode = .nearest
//
//                let tile = SKSpriteNode(texture: texture)
//                tile.setScale(2.0)
                
                let texture = SKTexture(imageNamed: "tile_grass")
                texture.filteringMode = .nearest

                let tile = TileNode(texture: texture)
                tile.setScale(2.0)

                tile.gridX = col
                tile.gridY = row

                tile.position = CGPoint(
                    x: origin.x + pos.x,
                    y: origin.y - pos.y
                )

//                addChild(tile)
                tiles.append(tile)

                tile.position = CGPoint(
                    x: origin.x + pos.x,
                    y: origin.y - pos.y
                )

                addChild(tile)
            }
        }
    }

    func isoToScreen(x: Int, y: Int) -> CGPoint {
        let screenX = CGFloat(x - y) * (tileWidth / 2)
        let screenY = CGFloat(x + y) * (tileHeight / 2)
        return CGPoint(x: screenX, y: screenY)
    }
}
