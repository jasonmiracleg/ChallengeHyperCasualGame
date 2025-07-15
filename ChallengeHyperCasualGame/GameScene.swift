//
//  GameScene.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 15/07/25.
//

import SpriteKit
import GameplayKit
import CoreGraphics

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKShapeNode!
    var platforms: [SKSpriteNode] = []
    var jumpDirection: CGFloat = 0
    var jumpGuide: SKShapeNode?
    var restartButton: SKLabelNode!
    var lastTapTime: TimeInterval = 0
    var leftWall: SKNode!
    var rightWall: SKNode!
    var lastPlatformX: CGFloat = 0
    var trajectoryNodes: [SKShapeNode] = []
    
    var startPos: CGPoint?
    var currentPos: CGPoint?

    let maxTrajectoryPoints = 20
    let playerCategory: UInt32 = 0x1 << 0
    let platformCategory: UInt32 = 0x1 << 1

    // MARK: Override Functions
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        backgroundColor = .cyan

        let cam = SKCameraNode()
        cam.position = CGPoint(x: frame.midX, y: frame.midY)
        camera = cam
        addChild(cam)

        createPlayer()
        createInitialPlatforms()
        createRestartButton()
        createInitialBounceWalls()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        jumpDirection = location.x < frame.midX ? -1 : 1
        
        startPos = touch.location(in: self)
        
        showTrajectory(with: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        jumpDirection = location.x < frame.midX ? -1 : 1
        
        currentPos = touch.location(in: self)
        
        showTrajectory(with: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = startPos else { return }
        let location = touch.location(in: self)

        // Restart button logic
        let nodesAtPoint = nodes(at: location)
        if nodesAtPoint.contains(where: { $0.name == "restartButton" }) {
            print("Restart tapped!")
            restartScene()
            return
        }

        // Measure velocity and check if player is idle enough to jump
        let velocity = player.physicsBody?.velocity ?? .zero
        print("Velocity: \(velocity)")

        let speedThreshold: CGFloat = 1
        let isIdle = abs(velocity.dy) < speedThreshold

        // Time since last tap for spin boost
        let currentTime = CACurrentMediaTime()
        let timeSinceLastTap = currentTime - lastTapTime
        lastTapTime = currentTime

        // Calculate jump strength from horizontal drag distance
        let dx = location.x - start.x
        let jumpStrengthX = dx * 4  // Adjust the multiplier as needed
        let jumpStrengthY: CGFloat = 1200

        if isIdle {
            // Apply jump
            player.physicsBody?.velocity = CGVector(dx: jumpStrengthX, dy: jumpStrengthY)
        } else {
            // Apply mid-air spin
            let spinBoost = max(1.0, 10.0 - timeSinceLastTap)
            player.physicsBody?.angularVelocity = spinBoost
        }

        // Cleanup
        jumpDirection = 0
        startPos = nil
        clearTrajectory()
    }

    override func update(_ currentTime: TimeInterval) {
        if player.position.y > frame.midY {
            
            if let camera = camera {
                // 1. Determine the lowest visible platform Y
                let lowestPlatformY = platforms.map { $0.position.y }.min() ?? 0

                // 2. Set a minimum camera Y position — e.g., just below the lowest platform
                let minCameraY = lowestPlatformY + 200

                if player.position.y > camera.position.y {
                    camera.position.y = player.position.y
                } else if player.position.y < camera.position.y {
                    // But don't let camera fall below minCameraY
                    camera.position.y = max(player.position.y, minCameraY)
                }
            }
            
            updateBounceWalls()
            
            if let camY = camera?.position.y {
                platforms = platforms.filter { platform in
                    if platform.position.y > camY - frame.height - 200 {
                        return true // keep this platform
                    } else {
                        platform.removeFromParent() // remove from the scene
                        return false // filter it out of the array
                    }
                }
            }
            
            while platforms.count < 10 {
                var x: CGFloat
                repeat {
                    x = CGFloat.random(in: 50...frame.width - 50)
                } while abs(x - lastPlatformX) < 80

                let y = (platforms.last?.position.y ?? 0) + 200
                let newPlatform = createPlatform(at: CGPoint(x: x, y: y))
                platforms.append(newPlatform)
                lastPlatformX = x // ✅ keep track for next
            }
        }

        if player.position.x < -50 {
            player.position.x = frame.width + 50
        } else if player.position.x > frame.width + 50 {
            player.position.x = -50
        }
    }

    // MARK: Trajectory
    func showTrajectory(with currentPos: CGPoint) {
        clearTrajectory()
        guard let startPos = startPos else { return }
        
        var position = player.position
        var velocity = CGVector(dx: (currentPos.x-startPos.x) * 4, dy: 800)
        let gravity = physicsWorld.gravity
        let timeStep: CGFloat = 0.1
        let bounceDamping: CGFloat = 0.8

        for i in 0..<maxTrajectoryPoints {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0 - (CGFloat(i) / CGFloat(maxTrajectoryPoints)))
            dot.strokeColor = .clear
            dot.zPosition = 5
            dot.position = position

            let pulseAction = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ]))
            dot.run(pulseAction)
            addChild(dot)
            trajectoryNodes.append(dot)

            // Apply gravity
            velocity.dx += gravity.dx * timeStep
            velocity.dy += gravity.dy * timeStep
            position.x += velocity.dx * timeStep
            position.y += velocity.dy * timeStep

            // Existing bounce logic in showTrajectory …
            if position.x <= frame.minX {
                position.x = frame.minX
                velocity.dx = -velocity.dx * bounceDamping

                // ⬇️  Add this right here
                dot.run(SKAction.sequence([
                    SKAction.scale(to: 1.5, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ]))
            } else if position.x >= frame.maxX {
                position.x = frame.maxX
                velocity.dx = -velocity.dx * bounceDamping

                // ⬇️  And here for the right wall
                dot.run(SKAction.sequence([
                    SKAction.scale(to: 1.5, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ]))
            }

            // Stop drawing if out of vertical bounds
            if position.y < frame.minY {
                break
            }
        }
        
    }

    func clearTrajectory() {
        trajectoryNodes.forEach { $0.removeFromParent() }
        trajectoryNodes.removeAll()
    }

    // MARK: Player
    func createPlayer() {
        player = SKShapeNode(rectOf: CGSize(width: 20, height: 40), cornerRadius: 8)
        player.fillColor = .gray
        player.position = CGPoint(x: frame.midX, y: 100)

        let body = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 40))
        body.linearDamping = 1.0
        body.friction = 1.0
        body.restitution = 0.0
        body.allowsRotation = true
        body.categoryBitMask = playerCategory
        body.contactTestBitMask = platformCategory
        body.collisionBitMask = platformCategory

        player.physicsBody = body
        addChild(player)
    }

    // MARK: Platforms
    func createPlatform(at position: CGPoint) -> SKSpriteNode {
        let platform = SKSpriteNode(color: .brown, size: CGSize(width: 100, height: 20))
        platform.position = position

        let body = SKPhysicsBody(rectangleOf: platform.size)
        body.isDynamic = false
        body.contactTestBitMask = playerCategory
        body.collisionBitMask = playerCategory
        body.categoryBitMask = platformCategory
        body.friction = 1.0

        platform.physicsBody = body
        addChild(platform)

        return platform
    }

    func createInitialPlatforms() {
        lastPlatformX = frame.midX

        for i in 0..<10 {
            let y = CGFloat(i) * 200 + 50
            var x: CGFloat

            if i == 0 {
                // First platform is centered
                x = frame.midX
            } else {
                repeat {
                    x = CGFloat.random(in: 50...frame.width - 50)
                } while abs(x - lastPlatformX) < 80  // Avoid too-similar x values
            }

            let platform = createPlatform(at: CGPoint(x: x, y: y))
            platforms.append(platform)
            lastPlatformX = x
        }
    }

    // MARK: Invisible Walls
    func createInitialBounceWalls() {
        let wallThickness: CGFloat = 1
        
        leftWall = SKNode()
        leftWall.position = CGPoint(x : 0, y: frame.minY)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: frame.height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.restitution = 1
        addChild(leftWall)
        
        rightWall = SKNode()
        rightWall.position = CGPoint(x : frame.width, y: frame.minY)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: frame.height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.restitution = 1
        addChild(rightWall)
        
        updateBounceWalls()
    }
    
    func updateBounceWalls() {
        guard let camY = camera?.position.y else { return }
        let wallHeight : CGFloat = frame.height
        let wallThickness: CGFloat = 1
        
        leftWall.position = CGPoint(x : 0, y: camY)
        rightWall.position = CGPoint(x : frame.width, y: camY)
        
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: wallHeight))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.restitution = 1.0

        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: wallHeight))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.restitution = 1.0
    }
    
    // MARK: Restart Button
    func createRestartButton() {
        restartButton = SKLabelNode(text: "Restart")
        restartButton.fontName = "AvenirNext-Bold"
        restartButton.fontSize = 32
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: frame.midX, y: camera!.position.y - 200)
        restartButton.zPosition = 1000
        restartButton.name = "restartButton"

        camera?.addChild(restartButton)
    }

    func restartScene() {
        if let currentScene = self.scene {
            let newScene = GameScene(size: currentScene.size)
            newScene.scaleMode = currentScene.scaleMode
            let transition = SKTransition.fade(withDuration: 0.5)
            view?.presentScene(newScene, transition: transition)
        }
    }
}
