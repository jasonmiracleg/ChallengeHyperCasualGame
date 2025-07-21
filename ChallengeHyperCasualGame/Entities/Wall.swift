//
//  WallManager.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum Wall {
    static func createWalls(in scene: GameScene) -> (SKNode, SKNode) {
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: scene.frame.height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.restitution = 1
        scene.addChild(leftWall)

        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: scene.frame.width, y: 0), to: CGPoint(x: scene.frame.width, y: scene.frame.height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.restitution = 1
        scene.addChild(rightWall)

        return (leftWall, rightWall)
    }

    static func updateWalls(in scene: GameScene) {
        guard let camY = scene.camera?.position.y else { return }
        scene.leftWall.position.y = camY
        scene.rightWall.position.y = camY
    }
}
