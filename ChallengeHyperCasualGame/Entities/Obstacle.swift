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
            return nil  // Don't create wall for moving/collapsed platforms
        }
        
        let wall = SKSpriteNode(color: .lightGray, size: CGSize(width: 10, height: 60))
        
        let targetPlatformWidth = targetPlatformPos.size.width
        let targetPlatformX = targetPlatformPos.position.x
        let targetPlatformY = targetPlatformPos.position.y
        
        let isLeft = targetPlatformX < currentPlatform.position.x
        
        // Determining the Wall Position
        let offsetX: CGFloat = targetPlatformX + (isLeft ? (targetPlatformWidth / 2) : -(targetPlatformWidth / 2))
        let offsetY: CGFloat = targetPlatformY
        
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
