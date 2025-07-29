//
//  Obstacle.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 22/07/25.
//

import SpriteKit

enum Obstacle {
    // MARK: Generate Wall Obstacle
    static func createWall(near targetPlatformPos: SKSpriteNode, currentPlatform: SKSpriteNode, scene: GameScene) -> SKSpriteNode? {
        if let type = targetPlatformPos.userData?["type"] as? PlatformType,
           (type == .moving || type == .collapsed) {
            return nil
        }
        
        let wallTexture = SKTexture(imageNamed: "wall_obstacle")
        let wall = SKSpriteNode(texture: wallTexture)
        
        let targetPlatformWidth = targetPlatformPos.size.width
        let targetPlatformX = targetPlatformPos.position.x
        let targetPlatformY = targetPlatformPos.position.y
        
        let isLeft = targetPlatformX < currentPlatform.position.x
        
        let offsetX: CGFloat = targetPlatformX + (isLeft ? (targetPlatformWidth / 2) : -(targetPlatformWidth / 2))
        let offsetY: CGFloat = targetPlatformY
        
        wall.position = CGPoint(x: offsetX, y: offsetY)
        wall.name = "wall"
        
        wall.xScale = 0.4
        wall.yScale = 0.4
        
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.restitution = 0.8
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall.rawValue
        wall.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        
        return wall
    }
}
