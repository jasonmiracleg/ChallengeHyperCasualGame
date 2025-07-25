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
    // Tracking Platform Counts
    private static var platformCounts: Int = 0
    
    // Platform Size & Distribution
    private static let platformWidths = [100, 120, 140]
    private static let platformWeights = [0.25, 0.5, 0.25]
    
    // MARK: - Create Single Platform
    static func createPlatform(
        at position: CGPoint,
        type: PlatformType = .normal,
        width: CGFloat = 100,
        height: CGFloat = 20,
        in scene: GameScene,
        index: Int = -1
    ) -> SKSpriteNode {
        
        let platform: SKSpriteNode
        
        if index == 0 {
            platform = SKSpriteNode(color: .brown, size: CGSize(width: width, height: CGFloat(height)))
            platform.alpha = 0
            platform.zPosition = -10
        } else {
            let textureName: String
            let widthInt = Int(width)
            
            switch type {
            case .collapsed:
                switch widthInt {
                case 100:
                    textureName = "small_crack_platform"
                case 120:
                    textureName = "normal_crack_platform"
                case 140:
                    textureName = "long_crack_platform"
                default:
                    textureName = "normal_platform_cracked"
                }
                
            default:
                switch widthInt {
                case 100:
                    textureName = "small_platform"
                case 120:
                    textureName = "normal_platform"
                case 140:
                    textureName = "long_platform"
                default:
                    textureName = "normal_platform"
                }
            }
            
            let texture = SKTexture(imageNamed: textureName)
            let originalSize = texture.size()
            
            // Determine scale factor depending on type
            let scale: CGFloat
            switch type {
            case .collapsed:
                scale = 0.1
            default:
                scale = 0.1
            }
            
            let scaledSize = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
            
            platform = SKSpriteNode(texture: texture)
            platform.size = scaledSize
            
        }
        
        platform.position = position
        platform.zPosition = 9
        
        if platform.userData == nil {
            platform.userData = NSMutableDictionary()
        }
        platform.userData?["type"] = type
        platform.userData?["hasBeenLanded"] = false
        
        switch type {
        case .normal:
            platform.name = "normal"
        case .moving:
            platform.name = "moving"
            configureMovingPlatform(platform, width: platform.size.width, in: scene)
        case .collapsed:
            platform.name = "collapsed"
        }
        
        let body: SKPhysicsBody
        if index == 0 {
            body = SKPhysicsBody(rectangleOf: platform.size)
        } else {
            let hitboxSize = CGSize(
                width: platform.size.width * 0.65,
                height: platform.size.height * 0.3
            )
            let hitboxOffset = CGPoint(x: 0, y: -platform.size.height * 0.05)
            body = SKPhysicsBody(rectangleOf: hitboxSize, center: hitboxOffset)
        }
        
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.platform.rawValue
        body.contactTestBitMask = PhysicsCategory.player.rawValue | PhysicsCategory.topSensor.rawValue | PhysicsCategory.bottomSensor.rawValue
        body.collisionBitMask = PhysicsCategory.player.rawValue | PhysicsCategory.topSensor.rawValue | PhysicsCategory.bottomSensor.rawValue
        body.friction = 1.0
        
        platform.physicsBody = body
        scene.addChild(platform)
        
        return platform
    }
    
    // MARK: - Initial Platforms
    static func createInitialPlatforms(in scene: GameScene) -> [SKSpriteNode] {
        var platforms: [SKSpriteNode] = []
        var lastX = scene.frame.midX
        
        let fixedPlatformPositions: [CGPoint] = [
            CGPoint(x: scene.frame.midX + 100, y: 200),
            CGPoint(x: scene.frame.midX - 100, y: 200),
            CGPoint(x: scene.frame.midX + 100, y: 200),
            CGPoint(x: scene.frame.midX - 100, y: 200)
        ]
        
        for i in 0..<10 {
            var y = CGFloat(i) * 200 + 100
            var randomWidth = getRandomPlatformWidth()
            var height = 20
            var x: CGFloat
            
            if i == 0 {
                x = scene.frame.midX
                y = scene.frame.minY + (20 / 2)
                randomWidth = scene.frame.width
                height = 100
            } else if i <= fixedPlatformPositions.count {
                let fixedPosition = fixedPlatformPositions[i-1]
                x = fixedPosition.x
                y = fixedPosition.y * CGFloat(i) + 100
                randomWidth = i < fixedPlatformPositions.count ? CGFloat(platformWidths[i-1]) : CGFloat(platformWidths[2])
            } else {
                // Random placement
                let halfWidth = CGFloat(randomWidth) / 2
                x = platformPlacement(scene: scene, lastX: lastX, halfWidth: halfWidth)
            }
            
            let previousPlatform = platforms.last
            
            // --- Prevent consecutive moving/collapsed ---
            let type: PlatformType = {
                if platformCounts < 10 {
                    platformCounts += 1
                    return .normal
                } else {
                    if let last = previousPlatform,
                       let lastType = last.userData?["type"] as? PlatformType,
                       (lastType == .moving || lastType == .collapsed) {
                        return .normal
                    }
                    return getPlatformType(for: scene.player.position.y)
                }
            }()
            
            let platform = createPlatform(
                at: CGPoint(x: x, y: y),
                type: type,
                width: CGFloat(randomWidth),
                height: CGFloat(height),
                in: scene,
                index: i
            )
            
            if i == 0 {
                platform.userData?["hasBeenLandedOn"] = true
            } else {
                platform.userData?["hasBeenLandedOn"] = false
            }
            
            // --- Wall spawning ---
            if let previous = previousPlatform {
                spawnWall(
                    type: type,
                    for: platform.position.y,
                    targetPlatform: platform,
                    currentPlatform: previous.position,
                    scene: scene
                )
            }
            
            platforms.append(platform)
            lastX = x
        }
        
        return platforms
    }
    
    
    // MARK: - Cleanup & Generate New Platforms
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
            let x = platformPlacement(scene: scene, lastX: lastPlatformX, halfWidth: halfWidth)
            let y = (newPlatforms.last?.position.y ?? 0) + 200
            
            let previousPlatform = newPlatforms.last
            
            let type: PlatformType = {
                if platformCounts < 10 {
                    platformCounts += 1
                    return .normal
                } else {
                    if let last = previousPlatform,
                       let lastType = last.userData?["type"] as? PlatformType,
                       (lastType == .moving || lastType == .collapsed) {
                        return .normal
                    }
                    return getPlatformType(for: scene.player.position.y)
                }
            }()
            
            let newPlatform = createPlatform(
                at: CGPoint(x: x, y: y),
                type: type,
                width: CGFloat(randomWidth),
                in: scene
            )
            
            if let previous = previousPlatform {
                spawnWall(
                    type: type,
                    for: newPlatform.position.y,
                    targetPlatform: newPlatform,
                    currentPlatform: previous.position,
                    scene: scene
                )
            }
            
            newPlatforms.append(newPlatform)
            lastPlatformX = x
        }
        
        return newPlatforms
    }
    
    
    // MARK: - Moving Platform Logic
    static func configureMovingPlatform(_ platform: SKSpriteNode, width: CGFloat, in scene: GameScene) {
        let halfWidth = width / 2
        let leftLimit = halfWidth
        let rightLimit = scene.frame.width - halfWidth
        
        let speed: CGFloat = 150  // points per second
        
        if platform.userData == nil {
            platform.userData = NSMutableDictionary()
        }
        platform.userData?["direction"] = 1.0
        platform.userData?["speed"] = speed
        platform.userData?["leftLimit"] = leftLimit
        platform.userData?["rightLimit"] = rightLimit
        platform.userData?["isStopped"] = false
    }
    
    
    // MARK: - Collapsing Platform Logic
    static func collapse(_ platform: SKNode) {
        guard let platform = platform as? SKSpriteNode else {
            return
        }
        
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 15, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        
        let collapseSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            shake,
            fadeOut
        ])
        
        platform.run(collapseSequence) {
            platform.physicsBody?.categoryBitMask = 0
            platform.physicsBody?.collisionBitMask = 0
            platform.physicsBody?.contactTestBitMask = 0
            platform.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                platform.physicsBody?.categoryBitMask = PhysicsCategory.platform.rawValue
                platform.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue | PhysicsCategory.topSensor.rawValue
                platform.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue | PhysicsCategory.topSensor.rawValue
                
                platform.alpha = 1.0
                platform.isHidden = false
                
                let type = platform.userData?["type"] as? PlatformType
                let width = Int(platform.size.width / 0.3)
                let textureName: String
                
                switch type {
                case .collapsed:
                    switch width {
                    case 100:
                        textureName = "small_crack_platform"
                    case 120:
                        textureName = "normal_crack_platform"
                    case 140:
                        textureName = "long_crack_platform"
                    default:
                        textureName = "normal_crack_platform"
                    }
                    platform.texture = SKTexture(imageNamed: textureName)
                default:
                    break
                }
                
                platform.userData?["collapseStarted"] = nil
            }
        }
    }
    
    
    
    // MARK: - Helpers
    static func resetPlatformCounts() {
        platformCounts = 0
    }
    
    private static func getPlatformType(for height: CGFloat) -> PlatformType {
        let maxHeight: CGFloat = 2500
        let difficulty = min(height / maxHeight, 1.0)
        
        var normalProb = 0.75 - 0.05 * difficulty // 75% - 70%
        var movingProb = 0.15 + 0.05 * difficulty // 15% - 20%
        var collapsedProb = 0.05 + 0.05 * difficulty // 5% - 10%
        
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
    
    private static func platformPlacement(
        scene: GameScene,
        lastX: CGFloat,
        halfWidth: CGFloat
    ) -> CGFloat {
        let wallWidth: CGFloat = 10
        let safeGap: CGFloat = 100
        
        let minX = scene.frame.minX + wallWidth + halfWidth
        let maxX = scene.frame.maxX - wallWidth - halfWidth
        
        let forbiddenMin = max(minX, lastX - safeGap)
        let forbiddenMax = min(maxX, lastX + safeGap)
        
        var xCandidates = [CGFloat]()
        if forbiddenMin > minX {
            xCandidates.append(CGFloat.random(in: minX..<forbiddenMin))
        }
        if forbiddenMax < maxX {
            xCandidates.append(CGFloat.random(in: forbiddenMax...maxX))
        }
        
        return xCandidates.randomElement() ?? scene.frame.midX
    }
    
    
    private static func spawnWall(type: PlatformType, for height:CGFloat, targetPlatform: SKSpriteNode, currentPlatform: CGPoint, scene: GameScene){
        if let type = targetPlatform.userData?["type"] as? PlatformType,
           type == .normal,
           platformCounts >= 10
        {
            let difficulty = min(height / 2500, 1.0)
            let wallChance = 0.15 + 0.05 * difficulty
            if CGFloat.random(in: 0...1) < wallChance {
                let wall = Obstacle.createWall(near: targetPlatform, currentPlatformPos: currentPlatform, scene: scene)
                scene.addChild(wall)
            }
        }
    }
    
    // MARK: Randomize Platform Width
    private static func getRandomPlatformWidth() -> CGFloat {
        let random = Double.random(in: 0..<1)
        var cumulativeProbability: Double = 0
        
        for (index, weight) in platformWeights.enumerated() {
            cumulativeProbability += weight
            if random < cumulativeProbability {
                return CGFloat(platformWidths[index])
            }
        }
        return CGFloat(platformWidths.last!)
    }
    
    // MARK: - Update Moving Platforms
    static func updateMovingPlatforms(in scene: GameScene) {
        
        let deltaTime: CGFloat = 1.0 / 60.0 // Assuming 60 FPS
        for node in scene.children where node.name == "moving" {
            guard let platform = node as? SKSpriteNode,
                  let direction = platform.userData?["direction"] as? CGFloat,
                  let speed = platform.userData?["speed"] as? CGFloat,
                  let leftLimit = platform.userData?["leftLimit"] as? CGFloat,
                  let rightLimit = platform.userData?["rightLimit"] as? CGFloat,
                  (platform.userData?["isStopped"] as? Bool) != true
            else { continue }
            
            platform.position.x += direction * speed * deltaTime
            
            if platform.position.x <= leftLimit || platform.position.x >= rightLimit {
                platform.userData?["direction"] = -direction
            }
        }
    }
}
