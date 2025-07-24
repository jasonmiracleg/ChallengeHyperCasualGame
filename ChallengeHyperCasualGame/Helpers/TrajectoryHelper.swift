//
//  TrajectoryHelper.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum TrajectoryHelper {
    static func show(from startPos: CGPoint, to currentPos: CGPoint, in scene: GameScene) {
        clear(in: scene)

        var position = scene.player.position

        // Simulated initial velocity (based on drag)
        var velocity = CGVector(
            dx: (startPos.x - currentPos.x),
            dy: min((startPos.y - currentPos.y), 200)
        )

        let gravity = scene.physicsWorld.gravity
        let timeStep: CGFloat = 0.1
        let restitution: CGFloat = 0.3

        var collide: Bool = false
        for i in 0..<scene.maxTrajectoryPoints {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.fillColor = SKColor(
                red: 1.0,
                green: 0.8,
                blue: 0.2,
                alpha: 1.0 - CGFloat(i) / CGFloat(scene.maxTrajectoryPoints)
            )
            dot.strokeColor = .clear
            dot.zPosition = 5
            dot.position = position

            dot.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])))

            scene.addChild(dot)
            scene.trajectoryNodes.append(dot)

            // Apply gravity
            velocity.dy += gravity.dy * timeStep

            // Predict next position
            var nextPosition = CGPoint(
                x: position.x + velocity.dx * timeStep,
                y: position.y + velocity.dy * timeStep
            )

            // --- Collision with left/right edges ---
            if nextPosition.x <= scene.frame.minX && !collide{
                nextPosition.x = scene.frame.minX
                velocity.dx *= -restitution
                velocity.dy *= restitution
                collide = true
            } else if nextPosition.x >= scene.frame.maxX && !collide{
                nextPosition.x = scene.frame.maxX
                velocity.dx *= -restitution
                velocity.dy *= restitution
                collide = true
            }

            position = nextPosition
        }
    }


    static func clear(in scene: GameScene) {
        scene.trajectoryNodes.forEach { $0.removeFromParent() }
        scene.trajectoryNodes.removeAll()
    }
}
