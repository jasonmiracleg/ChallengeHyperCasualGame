//
//  RestartButtonFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum RestartButtonFactory {
    static func create(in scene: SKScene) -> SKLabelNode {
        let button = SKLabelNode(text: "Restart")
        button.fontName = "AvenirNext-Bold"
        button.fontSize = 32
        button.fontColor = .white
        button.position = CGPoint(x: scene.frame.midX, y: (scene.camera?.position.y ?? 0) - 200)
        button.zPosition = 1000
        button.name = "restartButton"
        scene.camera?.addChild(button)
        return button
    }
}
