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
    let wallCategory: UInt32 = 0x1 << 2
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
    var score: UInt32 = 0
    var scoreLabel: SKLabelNode!

    //background and asset
    var backgroundManager: BackgroundManager!
    var decorationSpawner: DecorationSpawner!
    
    private var lastPrintTime: TimeInterval = 0  // Tambahkan ini di kelas GameScene

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
        player = Player(in: self)
        platforms = Platform.createInitialPlatforms(in: self)
        if let firstPlatform = platforms.first {
            EnvironmentFactory.addInitialEnvironment(
                below: firstPlatform,
                in: self
            )
        }

        restartButton = RestartButton.create(in: self)
        Wall.createWalls(in: self)
        createScoreLabel()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node

        // Ensure one is the player and the other is a platform
        if let playerNode = bodyA as? Player,
            let platform = bodyB as? SKSpriteNode
        {
            handlePlatformContact(platform)
        } else if let playerNode = bodyB as? Player,
            let platform = bodyA as? SKSpriteNode
        {
            handlePlatformContact(platform)
        }
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

    private func handlePlatformContact(_ platform: SKSpriteNode) {
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
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        jumpDirection = location.x < frame.midX ? -1 : 1
        dragStartPos = location

        if player.isIdle(), let start = dragStartPos,
            let current = dragCurrentPos
        {
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = dragStartPos else {
            return
        }
        let location = touch.location(in: self)

        // Restart button check
        if nodes(at: location).contains(where: { $0.name == "restartButton" }) {
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
