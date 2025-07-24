//
//  GameScene.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 15/07/25.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // player
    var player: PlayerRevised!

    // platforms
    var platforms: [SKSpriteNode] = []
    let platformCategory = PhysicsCategory.platform.rawValue
    var lastPlatformX: CGFloat = 0

    // launch
    var jumpDirection: CGFloat = 0
    var lastTapTime: TimeInterval = 0
    var dragStartPos: CGPoint?
    var dragCurrentPos: CGPoint?

    // trajectory
    let maxTrajectoryPoints = 20
    var trajectoryNodes: [SKShapeNode] = []

    // misc
    var restartButton: SKLabelNode!
    var startJumpPosition: CGPoint?
    
    //background and asset
    var backgroundManager: BackgroundManager!
    var decorationSpawner: DecorationSpawner!
    
    //scoring
    var lastPlatform: SKSpriteNode!
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    var highscoreLabel: SKLabelNode!
    let highscore = UserDefaults.standard.integer(forKey: "highscore")
    
    // debug
    var detectedContact: Int = 0
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        backgroundManager = BackgroundManager(in: self)
        decorationSpawner = DecorationSpawner(in: self)
        
        camera = Camera.createCamera(for: self)
        player = PlayerRevised(in: self)
        platforms = Platform.createInitialPlatforms(in: self)
        if let firstPlatform = platforms.first {
            EnvironmentFactory.addInitialEnvironment(below: firstPlatform, in: self)
        }
        
        restartButton = RestartButton.create(in: self)
        Wall.createWalls(in: self)
        createScoreLabel()
        createHighscoreLabel()
    }

//    func didBegin(_ contact: SKPhysicsContact) {
//        guard let nodeA = contact.bodyA.node,
//              let nodeB = contact.bodyB.node else { return }
//
//        let categoryA = PhysicsCategory(rawValue: contact.bodyA.categoryBitMask)
//        let categoryB = PhysicsCategory(rawValue: contact.bodyB.categoryBitMask)
//
//        // Handle Player <-> Platform
//        if categoryA.contains(.player) && categoryB.contains(.platform),
//           let platform = nodeB as? SKSpriteNode {
//            handlePlatformContact(playerNode: nodeA, platform: platform, contact: contact)
//        } else if categoryB.contains(.player) && categoryA.contains(.platform),
//                  let platform = nodeA as? SKSpriteNode {
//            handlePlatformContact(playerNode: nodeB, platform: platform, contact: contact)
//        }
//    }
//
//    private func handlePlatformContact(playerNode: SKNode, platform: SKSpriteNode, contact: SKPhysicsContact) {
//        // Convert the contact point to the platform's local space
//        let contactInPlatform = platform.convert(contact.contactPoint, from: scene!)
//        let topThreshold: CGFloat = 10.0
//
//        if contactInPlatform.y >= platform.frame.size.height / 2 - topThreshold {
//            print("Player landed on top of platform")
//            player.dampenLandingVelocity()
//
//            // Main score (for landing at all)
//            if platform.userData?["hasBeenLandedOn"] as? Bool != true {
//                updateScore()
//                platform.userData?["hasBeenLandedOn"] = true
//            }
//
//            // Bonus: only give if bottleCap or bottomSensor made contact
//            let contactNodes = [contact.bodyA.node, contact.bodyB.node].compactMap { $0 }
//
//            if contactNodes.contains(where: { $0.name == "bottomSensor" })
////                ,platform.userData?["hasBeenLandedOn"] as? Bool != true
//            {
//                print("BOTTOM: TOUCHED")
//                updateScore(by: 2)
//                platform.userData?["hasBeenLandedOn"] = true
//                print("Bonus +1 for bottom sensor (on valid landing)")
//            } else {
//                print("BOTTOM: UNTOUCHED")
//            }
//
//            if contactNodes.contains(where: { $0.name == "bottleCap" })
////                ,platform.userData?["hasBeenLandedOn"] as? Bool != true
//            {
//                print("TOP: TOUCHED")
//                updateScore(by: 3)
//                platform.userData?["hasBeenLandedOn"] = true
//                print("Bonus +2 for bottle cap (on valid landing)")
//            } else {
//                print("TOP: UNTOUCHED")
//            }
//
//            // Platform behavior triggers
//            if let type = platform.userData?["type"] as? PlatformType {
//                switch type {
//                case .collapsed:
//                    if platform.userData?["collapseStarted"] == nil {
//                        platform.userData?["collapseStarted"] = true
//                        Platform.collapse(platform)
//                    }
//                case .moving:
//                    platform.userData?["isStopped"] = true
//                default:
//                    break
//                }
//            }
//        }
//
//    }
    
    /// Utility to sort physics bodies based on bit mask
    private func sortBodies(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) -> (SKPhysicsBody, SKPhysicsBody) {
        return bodyA.categoryBitMask < bodyB.categoryBitMask ? (bodyA, bodyB) : (bodyB, bodyA)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Optional: Sort them for easier comparison
        let (first, second) = sortBodies(bodyA, bodyB)
        
        print("=== Contact Detected \(detectedContact) ===")
        print("Body A: \(String(describing: nodeA.name))")
        print(" - Category: \(bodyA.categoryBitMask)")
        print("Body B: \(String(describing: nodeB.name))")
        print(" - Category: \(bodyB.categoryBitMask)")

//        let playerNode: SKNode = {
//            if categoryA.contains(.player) || categoryA.contains(.topSensor) || categoryA.contains(.bottomSensor) {
//                return nodeA
//            } else {
//                return nodeB
//            }
//        }()
//        let platformNode = categoryA.contains(.platform) ? nodeA : nodeB
//
//        guard let platform = platformNode as? SKSpriteNode else { return }
//
//        // Determine which part hit the platform
//        if playerNode.name == "bottomSensor" {
//            print("If else bottom sensor")
//            handleLanding(playerNode: playerNode, platform: platform, contact: contact, landingType: .bottomSensor)
//        } else if playerNode.name == "bottleCap" {
//            print("If else top sensor")
//            handleLanding(playerNode: playerNode, platform: platform, contact: contact, landingType: .bottleCap)
//        } else {
//            print("If else normal sensor")
//            // Fallback: assume generic body
//            // Optional: add threshold check for top of platform
//            let contactInPlatform = platform.convert(contact.contactPoint, from: scene!)
//            let topThreshold: CGFloat = 10.0
//            if contactInPlatform.y >= platform.size.height / 2 - topThreshold {
//                handleLanding(playerNode: playerNode, platform: platform, contact: contact, landingType: .normal)
//            }
//        }
        
        detectedContact += 1
    }

    
    private func handleLanding(playerNode: SKNode, platform: SKSpriteNode, contact: SKPhysicsContact, landingType: LandingType) {
        print("\(landingType.rawValue): TOUCHED")

        let userData = platform.userData ?? NSMutableDictionary()
        platform.userData = userData

        if userData["hasBeenLandedOn"] as? Bool != true {
            // Base score for any valid landing
            updateScore()

            // Bonus based on type
            switch landingType {
            case .bottomSensor:
                updateScore(by: 2)
            case .bottleCap:
                updateScore(by: 3)
            default:
                break
            }

            print("Bonus +\(landingType == .bottomSensor ? 2 : landingType == .bottleCap ? 3 : 0) for \(landingType.rawValue.lowercased()) landing")
            userData["hasBeenLandedOn"] = true
        }

        // Trigger platform behavior (once per landing)
        if let type = userData["type"] as? PlatformType {
            switch type {
            case .collapsed:
                if userData["collapseStarted"] == nil {
                    userData["collapseStarted"] = true
                    Platform.collapse(platform)
                }
            case .moving:
                userData["isStopped"] = true
            default:
                break
            }
        }

        player.dampenLandingVelocity()
    }

    
    func didEnd(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node

        if let platform = bodyA as? SKSpriteNode, platform.name == "moving" {
            platform.userData?["isStopped"] = false
        } else if let platform = bodyB as? SKSpriteNode,
            platform.name == "moving"
        {
            platform.userData?["isStopped"] = false
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        jumpDirection = location.x < frame.midX ? -1 : 1
        dragStartPos = location

        if player.isIdle(), let start = dragStartPos, let current = dragCurrentPos {
            TrajectoryHelper.show(
                from: start,
                to: current,
                in: self
            )
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        dragCurrentPos = touch.location(in: self)
        if player.isIdle() {
            TrajectoryHelper.show(
                from: dragStartPos!,
                to: dragCurrentPos!,
                in: self
            )
        }
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let start = dragStartPos else { return }
//        let location = touch.location(in: self)
//        
//        if nodes(at: location).contains(where: { $0.name == "restartButton" }) {
//            SceneRestarter.restart(scene: self)
//            return
//        }
//        
//        player.handleJump(from: start, to: location)
//        TrajectoryHelper.clear(in: self)
//        jumpDirection = 0
//        dragStartPos = nil
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = dragStartPos else {
            return
        }
        let location = touch.location(in: self)

        // Restart button check
        if nodes(at: location).contains(where: { $0.name == "restartButton" }) {
            updateHighscore()
            SceneRestarter.restart(scene: self)
            return
        }

        if player.isIdle() {
            player.handleJump(from: start, to: location)
        } else {
            player.handleSpin(from: start, to: location)
        }

        // Single-tap drag jump
        player.handleJump(from: start, to: location)
        TrajectoryHelper.clear(in: self)
        jumpDirection = 0
        dragStartPos = nil
    }

    
    override func update(_ currentTime: TimeInterval) {
        Camera.follow(player: player, camera: camera, scene: self)
        Wall.updateWalls(in: self)
        platforms = Platform.cleanupAndGenerate(
            platforms: platforms,
            in: self,
            lastPlatformX: &lastPlatformX
        )

        let velocity = player.physicsBody?.velocity ?? .zero
        if abs(velocity.dy) == 0.0 && isPlayerOnPlatform() {
            guard let startY = startJumpPosition?.y else {
                startJumpPosition = player.position
                return
            }
            
            if (player.position.y - startY) > 20 {
                score += 1
                scoreLabel.text = "\(score)"
                startJumpPosition = player.position
            }
        }

        Platform.updateMovingPlatforms(in: self)
        backgroundManager.update(playerY: player.position.y)
        decorationSpawner.update(playerY: player.position.y)
    }
    
    func createScoreLabel() {
        scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 45
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(
            x: frame.midX - 200,
            y: camera!.position.y - 300
        )
        
        camera?.addChild(scoreLabel)
    }
    
    func createHighscoreLabel() {
        highscoreLabel = SKLabelNode(text: "\(highscore)")
        highscoreLabel.fontName = "AvenirNext-Bold"
        highscoreLabel.fontSize = 45
        highscoreLabel.fontColor = .white
        highscoreLabel.position = CGPoint(
            x: frame.midX * 0.1,
            y: camera!.position.y - 100
        )
        
        camera?.addChild(highscoreLabel)
    }
    
    func updateScore(by points: Int = 1) {
        score += points
        scoreLabel.text = "\(score)"
    }
    
    func updateHighscore(){
        if score > highscore {
            UserDefaults.standard.set(score, forKey: "highscore")
        }
    }
    
    func isPlayerOnPlatform() -> Bool {
        let verticalTolerance: CGFloat = 2.0
        
        for platform in platforms {
            let playerBottomY = player.frame.minY
            let platformTopY = platform.frame.maxY
            
            let isHorizontallyAligned =
            player.frame.maxX > platform.frame.minX
            && player.frame.minX < platform.frame.maxX
            
            let isVerticallyOnTop =
            abs(playerBottomY - platformTopY) <= verticalTolerance
            
            if isHorizontallyAligned && isVerticallyOnTop {
                return true
            }
        }
        return false
    }
}
