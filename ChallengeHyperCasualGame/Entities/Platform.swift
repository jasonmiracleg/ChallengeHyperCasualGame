//
//  PlatformFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum PlatformType {
    case collapsed
    case normal
    case moving
}

enum Platform {
    private static var platformCounts: Int = 0
    private static let platformWidths = [100, 120, 140]
    
    static func createPlatform(at position: CGPoint, type: PlatformType = .normal, width: CGFloat = 100, in scene: GameScene) -> SKSpriteNode {
        let platform = SKSpriteNode(color: .brown, size: CGSize(width: width, height: 20))
        platform.position = position

        switch type {
        case .normal :
            platform.color = .brown
            
        case .moving:
            platform.color = .blue
            configureMovingPlatform(platform, width: width, in: scene)
            
        case .collapsed:
            platform.color = .red
        }
        
        let body = SKPhysicsBody(rectangleOf: platform.size)
        body.isDynamic = false
        body.categoryBitMask = scene.platformCategory
        body.contactTestBitMask = scene.playerCategory
        body.collisionBitMask = scene.playerCategory
        body.friction = 1.0

        platform.physicsBody = body
        scene.addChild(platform)
        return platform
    }

    static func createInitialPlatforms(in scene: GameScene) -> [SKSpriteNode] {
        var platforms: [SKSpriteNode] = []
        var lastX = scene.frame.midX
        let baseY = scene.frame.minY

        for i in 0..<10 {
            var y = CGFloat(i) * 200 + 50
            let randomWidth = platformWidths.randomElement()!
            let halfWidth = CGFloat(randomWidth) / 2
            var x: CGFloat

            if i == 0 {
                // First platform is centered at minY
                x = scene.frame.midX
                y = baseY
            } else {
                repeat {
                    // Ensure the entire platform fits within screen width
                    x = CGFloat.random(in: halfWidth...(scene.frame.width - halfWidth))
                } while abs(x - lastX) < max(80, CGFloat(randomWidth))
            }

            let type: PlatformType = {
                if platformCounts < 10 {
                    platformCounts += 1
                    return .normal
                } else {
                    return getPlatformType(for: scene.player.position.y)
                }
            }()

            let platform = createPlatform(
                at: CGPoint(x: x, y: y),
                type: type,
                width: CGFloat(randomWidth),
                in: scene
            )

            platforms.append(platform)
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
            let randomWidth = platformWidths.randomElement()!
            let halfWidth = CGFloat(randomWidth) / 2

            var x: CGFloat
            repeat {
                x = CGFloat.random(in: halfWidth...(scene.frame.width - halfWidth))
            } while abs(x - lastPlatformX) < max(80, CGFloat(randomWidth))
            
            let y = (newPlatforms.last?.position.y ?? 0) + 200
            
            let type: PlatformType = {
                if platformCounts < 10 {
                    platformCounts += 1
                    return .normal
                } else {
                    return getPlatformType(for: scene.player.position.y)
                }
            }()
            
            let newPlatform = createPlatform(at: CGPoint(x: x, y: y), type: type, width: CGFloat(randomWidth), in: scene)
            newPlatforms.append(newPlatform)
            lastPlatformX = x
        }

        return newPlatforms
    }
    
    static func configureMovingPlatform(_ platform: SKSpriteNode, width: CGFloat, in scene: GameScene) {
        let halfWidth = width / 2
        let leftLimit = halfWidth
        let rightLimit = scene.frame.width - halfWidth

        // Calculate max safe movement distance
        let maxMoveLeft = platform.position.x - leftLimit
        let maxMoveRight = rightLimit - platform.position.x
        let moveDistance = min(200, min(maxMoveLeft, maxMoveRight))  // cap at 100 but adjust if close to edges

        // Movement actions
        let moveLeft = SKAction.moveBy(x: -moveDistance, y: 0, duration: 1)
        let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: 1)
        let sequence = SKAction.sequence([moveLeft, moveRight])
        let forever = SKAction.repeatForever(sequence)
        platform.run(forever)

        // Track direction
        platform.userData = ["direction": 1.0]

        // Manual direction toggle
        platform.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run { platform.userData?["direction"] = -1.0 },
                    SKAction.wait(forDuration: 2),
                    SKAction.run { platform.userData?["direction"] = 1.0 },
                    SKAction.wait(forDuration: 2),
                ])
            )
        )
    }
    
    static func collapse(_ platform: SKNode) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 15, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 15, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 15, y: 0, duration: 0.05),
        ])

        let collapseSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.7),  // delay before collapse
            shake,
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent(),
        ])

        platform.run(collapseSequence)

        // Optional: disable its physics after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            platform.physicsBody?.categoryBitMask = 0
            platform.physicsBody?.collisionBitMask = 0
            platform.physicsBody?.contactTestBitMask = 0
            platform.physicsBody?.isDynamic = false
        }
    }
    
    static func resetPlatformCounts() {
        platformCounts = 0
    }
    
    private static func getPlatformType(for height: CGFloat) -> PlatformType {
        let maxHeight: CGFloat = 2500
        let difficulty = min(height / maxHeight, 1.0)
        
        // Control the Probabilities
        var normalProb = 0.7 - 0.1 * difficulty // 70% -> 60%
        var movingProb = 0.2 + 0.05 * difficulty // 20% -> 25%
        var collapsedProb = 0.1 + 0.15 * difficulty // 10% -> 15%
        
        let total = normalProb + movingProb + collapsedProb
        normalProb /= total
        movingProb /= total
        collapsedProb /= total
        
        let rand = CGFloat.random(in: 0...1)
        if rand < normalProb {
            return .normal
        } else if rand < normalProb + movingProb {
            return .moving
        } else {
            return .collapsed
        }
    }
}
