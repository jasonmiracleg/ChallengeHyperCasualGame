//
//  PlayerFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum PlayerFactory {
    static func createPlayer(in scene: SKScene) -> SKShapeNode {
        let player = SKShapeNode(rectOf: CGSize(width: 20, height: 40), cornerRadius: 8)
        player.fillColor = .gray
        player.position = CGPoint(x: scene.frame.midX, y: 100)

        let body = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 40))
        body.linearDamping = 1.0
        body.friction = 1.0
        body.restitution = 0.0
        body.allowsRotation = true
        body.categoryBitMask = 0x1 << 0
        body.contactTestBitMask = 0x1 << 1
        body.collisionBitMask = 0x1 << 1

        player.physicsBody = body
        scene.addChild(player)
        return player
    }

    static func handleJumpOrSpin(player: SKShapeNode, startPos: CGPoint, endPos: CGPoint, lastTapTime: inout TimeInterval) {
        let velocity = player.physicsBody?.velocity ?? .zero
        let speedThreshold: CGFloat = 1
        let isIdle = abs(velocity.dy) < speedThreshold

        let currentTime = CACurrentMediaTime()
        let timeSinceLastTap = currentTime - lastTapTime
        lastTapTime = currentTime

        let dx = endPos.x - startPos.x
        let jumpStrengthX = dx * 4
        let jumpStrengthY: CGFloat = 1000

        if isIdle {
            player.physicsBody?.velocity = CGVector(dx: jumpStrengthX, dy: jumpStrengthY)
        } else {
            let spinBoost = max(1.0, 10.0 - timeSinceLastTap)
            player.physicsBody?.angularVelocity = spinBoost
        }
    }

    static func wrapAroundEdges(player: SKNode, in scene: SKScene) {
        if player.position.x < -50 {
            player.position.x = scene.frame.width + 50
        } else if player.position.x > scene.frame.width + 50 {
            player.position.x = -50
        }
    }
}
