//
//  Obstacle.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 22/07/25.
//

import SpriteKit

enum Obstacle {
    // MARK: Generate Wall Obstacle
    static func createWall(near targetPlatformPos: SKSpriteNode, currentPlatformPos: CGPoint, scene: GameScene) -> SKSpriteNode {
        let wall = SKSpriteNode(color: .lightGray, size: CGSize(width: 10, height: 120))
        
        let targetPlatformWidth = targetPlatformPos.size.width
        let targetPlatformX = targetPlatformPos.position.x
        let targetPlatformY = targetPlatformPos.position.y
        
        let isLeft = targetPlatformX < currentPlatformPos.x
        
        // Determining the Wall Position
        let offsetX: CGFloat = targetPlatformX + (isLeft ? -(targetPlatformWidth / 2 + 10) : (targetPlatformWidth / 2 + 10))
        let offsetY: CGFloat = targetPlatformY + 100
        
        wall.position = CGPoint(x: offsetX, y: offsetY)
        wall.name = "wall"
        
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.restitution = 0.8
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall.rawValue
        wall.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        
        return wall
    }
}
