//
//  PlatformFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum PlatformFactory {
    static func createPlatform(at position: CGPoint, in scene: SKScene) -> SKSpriteNode {
        let platform = SKSpriteNode(color: .brown, size: CGSize(width: 100, height: 20))
        platform.position = position

        let body = SKPhysicsBody(rectangleOf: platform.size)
        body.isDynamic = false
        body.categoryBitMask = 0x1 << 1
        body.contactTestBitMask = 0x1 << 0
        body.collisionBitMask = 0x1 << 0
        body.friction = 1.0

        platform.physicsBody = body
        scene.addChild(platform)
        return platform
    }

    static func createInitialPlatforms(in scene: SKScene) -> [SKSpriteNode] {
        var platforms: [SKSpriteNode] = []
        var lastX = scene.frame.midX

        for i in 0..<10 {
            let y = CGFloat(i) * 200 + 50
            var x: CGFloat = scene.frame.midX

            if i != 0 {
                repeat {
                    x = CGFloat.random(in: 50...scene.frame.width - 50)
                } while abs(x - lastX) < 80
            }

            platforms.append(createPlatform(at: CGPoint(x: x, y: y), in: scene))
            lastX = x
        }

        return platforms
    }

    static func cleanupAndGenerate(platforms: [SKSpriteNode], in scene: GameScene, lastPlatformX: inout CGFloat) -> [SKSpriteNode] {
        var newPlatforms = platforms.filter {
            if $0.position.y > (scene.camera?.position.y ?? 0) - scene.frame.height - 200 {
                return true
            } else {
                $0.removeFromParent()
                return false
            }
        }

        while newPlatforms.count < 10 {
            var x: CGFloat
            repeat {
                x = CGFloat.random(in: 50...scene.frame.width - 50)
            } while abs(x - lastPlatformX) < 80

            let y = (newPlatforms.last?.position.y ?? 0) + 200
            let newPlatform = createPlatform(at: CGPoint(x: x, y: y), in: scene)
            newPlatforms.append(newPlatform)
            lastPlatformX = x
        }

        return newPlatforms
    }
}
