//
//  WallManager.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum Wall {
    static func createWalls(in scene: GameScene) {
        let leftWall = SKNode()
        leftWall.name = "leftWall"
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: .zero,
                                             to: CGPoint(x: 0, y: scene.frame.height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.restitution = 0.7
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall.rawValue
        leftWall.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
        leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        scene.addChild(leftWall)

        let rightWall = SKNode()
        rightWall.name = "rightWall"
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: .zero,
                                              to: CGPoint(x: 0, y: scene.frame.height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.restitution = 0.7
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.wall.rawValue
        rightWall.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
        rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        scene.addChild(rightWall)

        // Initial placement
        positionWalls(in: scene)
    }

    static func updateWalls(in scene: GameScene) {
        positionWalls(in: scene)
    }

    private static func positionWalls(in scene: GameScene) {
        guard let camY = scene.camera?.position.y else { return }

        // These are static X edges, but Y follows the camera
        if let leftWall = scene.childNode(withName: "leftWall") {
            leftWall.position = CGPoint(x: 0, y: camY - scene.frame.height / 2)
        }

        if let rightWall = scene.childNode(withName: "rightWall") {
            rightWall.position = CGPoint(x: scene.frame.width, y: camY - scene.frame.height / 2)
        }
    }
}
