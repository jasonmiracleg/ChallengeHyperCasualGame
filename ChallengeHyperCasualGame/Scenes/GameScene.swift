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
    var player: Player!
    
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
    var startOverlay: SKNode?

    //background and asset
    var backgroundManager: BackgroundManager!
    var decorationSpawner: DecorationSpawner!
    
    var lastWallContactTime: CFTimeInterval = 0.0

    //scoring
    var lastPlatform: SKSpriteNode!
    var candidateLandingPlatform: SKSpriteNode!
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    var highscoreLabel: SKLabelNode!
    var dynamicScoreLabel: SKLabelNode!
    let highscore = UserDefaults.standard.integer(forKey: "highscore")
    var scoreMultiplier = 1
    var checkMultiplier: Bool = false
    var keepScoreMultiplier: Bool = true
    
    // debug
    var detectedContact: Int = 0
    
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        setupGame()
        showStartOverlay()
        showTutorial()
        createScoreLabel()
        createDynamicScoreLabel()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }
        
        let categoryA = PhysicsCategory(rawValue: contact.bodyA.categoryBitMask)
        let categoryB = PhysicsCategory(rawValue: contact.bodyB.categoryBitMask)
        
        // Handle Player <-> Platform
        if categoryA.contains(.player) && categoryB.contains(.platform),
           let platform = nodeB as? SKSpriteNode {
            handlePlatformContact(playerNode: nodeA, platform: platform, contact: contact)
        } else if categoryB.contains(.player) && categoryA.contains(.platform),
                  let platform = nodeA as? SKSpriteNode {
            handlePlatformContact(playerNode: nodeB, platform: platform, contact: contact)
        }
        
        // Handle Player <-> Wall
        if (categoryA.contains(.player) && categoryB.contains(.wall)) ||
           (categoryB.contains(.player) && categoryA.contains(.wall)) {
            
            let currentTime = CACurrentMediaTime()
            if currentTime - lastWallContactTime > 0.2 {
                lastWallContactTime = currentTime
                
                DispatchQueue.main.async {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.prepare()
                    impact.impactOccurred()
                }
            }
        }

    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        
        if let platform = bodyA as? SKSpriteNode, platform.name == "moving" {
            platform.userData?["isStopped"] = false
        } else if let platform = bodyB as? SKSpriteNode, platform.name == "moving" {
            platform.userData?["isStopped"] = false
        }
    }
    
    private func handlePlatformContact(playerNode: SKNode, platform: SKSpriteNode, contact: SKPhysicsContact) {
        let contactNormal = contact.contactNormal
        let isTopContactByNormal = contactNormal.dy < -0.5
        
        let contactPoint = contact.contactPoint
        let platformTop = platform.position.y + (platform.frame.height / 2)
        let isTopContactByPosition = contactPoint.y >= (platformTop - 20.0)
        
        if isTopContactByNormal || isTopContactByPosition {
            // Convert the contact point to the platform's local space
            let contactInPlatform = platform.convert(contact.contactPoint, from: scene!)
            
            let topThreshold: CGFloat = 10.0
            
            // Check if player landed on top of the platform
            if contactInPlatform.y >= platform.frame.size.height / 2 - topThreshold {
                
                print("Player landed on top of platform")
                
                platform.userData?["hasBeenLandedOn"] = true
                
                if let type = platform.userData?["type"] as? PlatformType {
                    switch type {
                    case .collapsed:
                        if platform.userData?["collapseStarted"] == nil {
                            platform.userData?["collapseStarted"] = true
                            Platform.collapse(platform)
                        } else {
                        }
                    case .moving:
                        platform.userData?["isStopped"] = true
                    default:
                        let dustParticle = Particles.createDustEmitter()
                        applyParticles(particle: dustParticle, object: playerNode)
                    }
                }
            }
        }
        let contactInPlatform = platform.convert(contact.contactPoint, from: scene!)
        let topThreshold: CGFloat = 10.0

        if contactInPlatform.y >= platform.frame.size.height / 2 - topThreshold {
            player.dampenLandingVelocity()
            candidateLandingPlatform = platform
            checkMultiplier = true

            // Platform behavior triggers
            if let type = platform.userData?["type"] as? PlatformType {
                switch type {
                case .collapsed:
                    if platform.userData?["collapseStarted"] == nil {
                        platform.userData?["collapseStarted"] = true
                        Platform.collapse(platform)
                    }
                case .moving:
                    platform.userData?["isStopped"] = true
                default:
                    break
                }
                
                SoundManager.playEffect(fileName: "land.mp3")
            } else {
                print("Player hit side or bottom of platform – no special logic triggered")
            }
        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // If overlay is visible, start the game and show trajectory
        if startOverlay != nil {
            hideStartOverlay()  // fade out and remove start overlay
            dragStartPos = location
            return
        }

        // Normal game touch logic
        jumpDirection = location.x < frame.midX ? -1 : 1
        dragStartPos = location

        if player.isIdle(), let start = dragStartPos, let current = dragCurrentPos {
            TrajectoryHelper.show(from: start, to: current, in: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        dragCurrentPos = touch.location(in: self)

        // Start overlay drag logic
        if startOverlay != nil {
            // Immediately hide start screen if user drags
            hideStartOverlay()
        }

        if player.isIdle(), let start = dragStartPos, let current = dragCurrentPos {
            TrajectoryHelper.show(from: start, to: current, in: self)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = dragStartPos else { return }
        let location = touch.location(in: self)
        
        // Restart button check
        if nodes(at: location).contains(where: { $0.name == "restartButton" }) {
            updateHighscore()
            SceneRestarter.restart(scene: self)
            return
        }
        
        if player.isIdle() {
            player.handleJump(from: start, to: location)
            SoundManager.playEffect(fileName: "launch.mp3")
            keepScoreMultiplier = false
        } else {
            player.handleSpin(from: start, to: location)
        }
        
        // Single-tap drag jump
        player.handleJump(from: start, to: location)
        TrajectoryHelper.clear(in: self)
        jumpDirection = 0
        dragStartPos = nil
        dragCurrentPos = nil
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
        
//        scoring purposes
        if abs(velocity.dy) == 0.0 && abs (velocity.dx) == 0.0 && checkMultiplier {
            checkMultiplier = false
            
            if let candidate = candidateLandingPlatform{
                if candidate.userData?["hasBeenLandedOn"] as? Bool != true{
                    candidate.userData?["hasBeenLandedOn"] = true
                    
                    switch player.checkRotation(){
                    case .bottleCap:
                        updateScore(by: scoreMultiplier * 3)
                        print("Player landed A CAP FLIP")
                        break
                    case .standing:
                        updateScore(by: scoreMultiplier * 2)
                        print("Player landed A FLIP")
                        break
                    default:
                        updateScore(by: scoreMultiplier)
                        print("Player landed")
                        break
                    }
                    
                    keepScoreMultiplier = true
                    lastPlatform = candidate
                } else {
                    if !keepScoreMultiplier {
                        scoreMultiplier = 1
                    }
                    keepScoreMultiplier = true
                }
            }
            
            candidateLandingPlatform = nil
        }
        
        updateDynamicScoreLabel(points: scoreMultiplier)
//        ==> until here

        Platform.updateMovingPlatforms(in: self)
        backgroundManager.update(playerY: player.position.y)
        decorationSpawner.update(playerY: player.position.y)
        
        if player.position.y < camera!.position.y - 400 {
            print("Game Over")
        }
    }

    func createScoreLabel() {
        scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 45
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(
            x: frame.midX - 200,
            y: camera?.position.y ?? 0 - 300
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
    
    func createDynamicScoreLabel(){
        dynamicScoreLabel = SKLabelNode(text: "+0")
        dynamicScoreLabel.fontName = "AvenirNext-Bold"
        dynamicScoreLabel.fontSize = 16
        dynamicScoreLabel.fontColor = .white
        dynamicScoreLabel.position = CGPoint(
            x: player.position.x,
            y: player.position.y
        )
        
        camera?.addChild(dynamicScoreLabel)
    }
    
    func updateDynamicScoreLabel(points: Int){
        dynamicScoreLabel.text = "+\(points)"
        dynamicScoreLabel.position = CGPoint(
            // WHAT IS PLAYER POSITION?????
            x: player.position.x - 30,
            y: player.position.y - 30 - Camera.minCameraY
        )
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
    
    func isPlayer(on platform: SKSpriteNode) -> Bool {
        let verticalTolerance: CGFloat = 2.0
        let playerBottomY = player.frame.minY
        let platformTopY = platform.frame.maxY
        
        let isHorizontallyAligned =
        player.frame.maxX > platform.frame.minX &&
        player.frame.minX < platform.frame.maxX
        
        let isVerticallyOnTop =
        abs(playerBottomY - platformTopY) <= verticalTolerance
        
        return isHorizontallyAligned && isVerticallyOnTop
    }
    
    private func applyParticles(particle: SKEmitterNode, object: SKNode) {
        particle.position = CGPoint(x: object.position.x, y: object.position.y)
        addChild(particle)
        
        particle.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    private func setupGame() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        backgroundManager = BackgroundManager(in: self)
        decorationSpawner = DecorationSpawner(in: self)
        camera = Camera.createCamera(for: self)
        player = Player(in: self)
        platforms = Platform.createInitialPlatforms(in: self)
        if let firstPlatform = platforms.first {
            EnvironmentFactory.addInitialEnvironment(
                below: firstPlatform,
                in: self
            )
        }
        SoundManager.playBackgroundMusic(fileName: "bgm.mp3")
        SoundManager.preloadEffect(fileName: "launch.mp3", volume: 0.8)
        SoundManager.preloadEffect(fileName: "land.mp3", volume: 0.3)
        restartButton = RestartButton.create(in: self)
        Wall.createWalls(in: self)
    }

    private func showStartOverlay() {
        startOverlay = SKNode()

        let background = SKSpriteNode(
            color: UIColor.black.withAlphaComponent(0.2),
            size: CGSize(width: size.width, height: size.height + 100)  // buffer at bottom
        )
        
        background.position = CGPoint(x: frame.midX, y: frame.midY - 50) // center shift
        background.zPosition = 100
        startOverlay?.addChild(background)

        let nameLabel = SKSpriteNode(imageNamed: "title_white")
        nameLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        nameLabel.size = CGSize(width: 300, height: 200)
        nameLabel.zPosition = 101
        startOverlay?.addChild(nameLabel)
        
        let scoreLabel = SKLabelNode(text: "000")
        scoreLabel.fontName = "Arial-BoldMT"
        scoreLabel.fontSize = 42
        scoreLabel.setScale(1.5)
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 25)
        scoreLabel.zPosition = 101
        startOverlay?.addChild(scoreLabel)
        
        let bestScoreLabel = SKLabelNode(text: "Best Score")
        bestScoreLabel.fontName = "Arial-BoldMT"
        bestScoreLabel.fontSize = 18
        bestScoreLabel.fontColor = .white
        bestScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        bestScoreLabel.zPosition = 101
        startOverlay?.addChild(bestScoreLabel)

        let gameButton = SKSpriteNode(
            color: UIColor.white.withAlphaComponent(0),
            size: self.size
        )
        gameButton.name = "playButton"
        gameButton.position = CGPoint(x: frame.midX, y: frame.midY)
        gameButton.zPosition = 102
        startOverlay?.addChild(gameButton)
        
        let instructionLabel = SKLabelNode(text: "Drag to Start")
        instructionLabel.fontName = "Arial-BoldMT"
        instructionLabel.fontSize = 18
        instructionLabel.fontColor = .white
        instructionLabel.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        instructionLabel.zPosition = 101
        startOverlay?.addChild(instructionLabel)
        
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        let blinkSequence = SKAction.sequence([fadeOut, fadeIn])
        let blinkForever = SKAction.repeatForever(blinkSequence)
        instructionLabel.run(blinkForever)

        addChild(startOverlay!)
    }

    private func hideStartOverlay() {
        guard let overlay = startOverlay else { return }

        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        overlay.run(SKAction.sequence([fadeOut, remove]))
        startOverlay = nil
    }
    
    private func showTutorial() {
        let swipeLabel = SKLabelNode(text: "← Swipe →")
        swipeLabel.fontName = "Arial-BoldMT"
        swipeLabel.fontSize = 18
        swipeLabel.fontColor = .white
        swipeLabel.position = CGPoint(x: frame.midX + 100, y: frame.maxY + 50)
        swipeLabel.zPosition = 101
        addChild(swipeLabel)
    }
}
