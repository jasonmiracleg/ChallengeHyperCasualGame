//
//  PlayerFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum PlayerFactory {
    static func createPlayer(in scene: SKScene) -> SKShapeNode {
        let player = SKShapeNode(
            rectOf: CGSize(width: 20, height: 40),
            cornerRadius: 8
        )
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

    static func handleJumpOrSpin(
        player: SKShapeNode,
        startPos: CGPoint,
        endPos: CGPoint
    ) {
        let velocity = player.physicsBody?.velocity ?? .zero
        let speedThreshold: CGFloat = 1
        let isIdle = abs(velocity.dy) < speedThreshold

        if isIdle {
            let dx = endPos.x - startPos.x
            let dy = endPos.y - startPos.y
            let length = sqrt(dx * dx + dy * dy)
            let jumpStrengthX = dx * 55
            let jumpStrengthY = dy * 45

            player.physicsBody?.velocity = CGVector(
                dx: -jumpStrengthX,
                dy: jumpStrengthY
            )

            var spin = 0.0
            if dx > 0 {
                spin = -length * 0.5
            } else {
                spin = length * 0.5
            }
            player.physicsBody?.angularVelocity = spin
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
