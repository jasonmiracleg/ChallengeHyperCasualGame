//
//  SceneRestarter.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

enum SceneRestarter {
    static func restart(scene: SKScene) {
        if let view = scene.view {
            let newScene = GameScene(size: scene.size)
            newScene.scaleMode = scene.scaleMode
            view.presentScene(newScene, transition: .fade(withDuration: 0.5))
        }
    }
}
