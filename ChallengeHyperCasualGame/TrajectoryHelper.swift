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
        var velocity = CGVector(dx: (currentPos.x - startPos.x) * 4, dy: 800)
        let gravity = scene.physicsWorld.gravity
        let timeStep: CGFloat = 0.1
        let damping: CGFloat = 0.8

        for i in 0..<scene.maxTrajectoryPoints {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0 - CGFloat(i)/CGFloat(scene.maxTrajectoryPoints))
            dot.strokeColor = .clear
            dot.zPosition = 5
            dot.position = position

            dot.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])))

            scene.addChild(dot)
            scene.trajectoryNodes.append(dot)

            velocity.dx += gravity.dx * timeStep
            velocity.dy += gravity.dy * timeStep
            position.x += velocity.dx * timeStep
            position.y += velocity.dy * timeStep

            if position.x <= scene.frame.minX || position.x >= scene.frame.maxX {
                velocity.dx = -velocity.dx * damping
            }

            if position.y < scene.frame.minY { break }
        }
    }

    static func clear(in scene: GameScene) {
        scene.trajectoryNodes.forEach { $0.removeFromParent() }
        scene.trajectoryNodes.removeAll()
    }
}
