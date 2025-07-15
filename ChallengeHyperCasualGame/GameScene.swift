//
//  GameScene.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 15/07/25.
//

import SpriteKit
import GameplayKit

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

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        backgroundColor = .cyan

        camera = CameraFactory.createCamera(for: self)
        player = PlayerFactory.createPlayer(in: self)
        platforms = PlatformFactory.createInitialPlatforms(in: self)
        restartButton = RestartButtonFactory.create(in: self)
        (leftWall, rightWall) = WallManager.createWalls(in: self)
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

        PlayerFactory.handleJumpOrSpin(player: player, startPos: start, endPos: location, lastTapTime: &lastTapTime)
        TrajectoryHelper.clear(in: self)
        jumpDirection = 0
        startPos = nil
    }

    override func update(_ currentTime: TimeInterval) {
        CameraFactory.follow(player: player, camera: camera, scene: self)
        WallManager.updateWalls(in: self)
        platforms = PlatformFactory.cleanupAndGenerate(platforms: platforms, in: self, lastPlatformX: &lastPlatformX)
        PlayerFactory.wrapAroundEdges(player: player, in: self)
    }
}
