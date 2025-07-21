//
//  GameScene.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 15/07/25.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKShapeNode!
    var platforms: [SKSpriteNode] = []
    var jumpDirection: CGFloat = 0
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

    var startJumpPosition: CGPoint?
    var score: UInt32 = 0
    var scoreLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        backgroundColor = .cyan

        camera = Camera.createCamera(for: self)
        player = Player.createPlayer(in: self)
        platforms = Platform.createInitialPlatforms(in: self)
        restartButton = RestartButton.create(in: self)
        (leftWall, rightWall) = Wall.createWalls(in: self)
        createScoreLabel()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        jumpDirection = location.x < frame.midX ? -1 : 1
        startPos = location
        TrajectoryHelper.show(from: startPos!, to: location, in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        currentPos = touch.location(in: self)
        TrajectoryHelper.show(from: startPos!, to: currentPos!, in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = startPos else { return }
        let location = touch.location(in: self)

        if nodes(at: location).contains(where: { $0.name == "restartButton" }) {
            SceneRestarter.restart(scene: self)
            return
        }

        Player.handleJumpOrSpin(
            player: player,
            startPos: start,
            endPos: location
        )
        TrajectoryHelper.clear(in: self)
        jumpDirection = 0
        startPos = nil
    }

    override func update(_ currentTime: TimeInterval) {
        Camera.follow(player: player, camera: camera, scene: self)
        Wall.updateWalls(in: self)
        platforms = Platform.cleanupAndGenerate(
            platforms: platforms,
            in: self,
            lastPlatformX: &lastPlatformX
        )
        Player.wrapAroundEdges(player: player, in: self)

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
        // Batas toleransi untuk perbedaan posisi (karena fisika tidak selalu presisi)
        let verticalTolerance: CGFloat = 2.0

        for platform in platforms {
            let playerBottomY = player.frame.minY
            let platformTopY = platform.frame.maxY

            // Cek apakah posisi horizontal player ada di atas platform
            let isHorizontallyAligned =
                player.frame.maxX > platform.frame.minX
                && player.frame.minX < platform.frame.maxX

            // Cek apakah posisi vertikal player berada di atas platform dengan toleransi
            let isVerticallyOnTop =
                abs(playerBottomY - platformTopY) <= verticalTolerance

            if isHorizontallyAligned && isVerticallyOnTop {
                return true
            }
        }
        return false
    }
}
