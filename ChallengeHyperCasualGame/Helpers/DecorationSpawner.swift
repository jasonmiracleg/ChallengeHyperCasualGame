//
//  DecorationSpawner.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 22/07/25.
//

import SpriteKit

class DecorationSpawner {
    weak var scene: SKScene?
    var lastDecorationY: CGFloat = 0
    let decorationGap: CGFloat = 300
    let decorationNames = ["fish", "jellyfish", "trash", "fishnet"]

    init(in scene: SKScene) {
        self.scene = scene
        self.lastDecorationY = scene.camera?.position.y ?? 0
    }

    func update(playerY: CGFloat) {
        guard let scene = scene else { return }

        while playerY + scene.frame.height > lastDecorationY + decorationGap {
            spawnDecoration(atY: lastDecorationY + decorationGap)
            lastDecorationY += decorationGap
        }
    }

    private func spawnDecoration(atY y: CGFloat) {
        guard let scene = scene else { return }

        let assetName = decorationNames.randomElement() ?? "fish_1"
        let decoration = SKSpriteNode(imageNamed: assetName)
        decoration.setScale(CGFloat.random(in: 0.1...0.25))

        let randomX = CGFloat.random(in: 50...(scene.size.width - 50))
        decoration.position = CGPoint(x: randomX, y: y + CGFloat.random(in: -50...50))
        decoration.zPosition = -51

        scene.addChild(decoration)
    }
}
