
//
//  CameraFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum Camera {
    static func createCamera(for scene: SKScene) -> SKCameraNode {
        let camera = SKCameraNode()
        camera.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(camera)
        return camera
    }

    static func follow(player: SKNode, camera: SKCameraNode?, scene: GameScene) {
        guard let camera = camera else { return }

        let lowestPlatformY = scene.platforms.map { $0.position.y }.min() ?? 0
        let minCameraY = lowestPlatformY + 200

        if player.position.y > camera.position.y {
            camera.position.y = player.position.y
        } else if player.position.y < camera.position.y {
            camera.position.y = max(player.position.y, minCameraY)
        }
    }
}
