//
//  BackgroundManager.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 22/07/25.
//

import SpriteKit

class BackgroundManager {
    private var backgrounds: [SKSpriteNode] = []
    private weak var scene: SKScene?

    private var lastYPosition: CGFloat = 0
    private var nextBackgroundIndex = 1
    private let backgroundNames = ["background_1", "background_2"]

    init(in scene: SKScene) {
        self.scene = scene
        setupInitialBackgrounds()
    }

    private func setupInitialBackgrounds() {
        guard let scene = scene else { return }

        for i in 0..<2 {
            let name = backgroundNames[i % backgroundNames.count]
            let bg = createBackground(named: name, atYIndex: CGFloat(i))
            backgrounds.append(bg)
            scene.addChild(bg)
        }

        if let last = backgrounds.last {
            lastYPosition = last.position.y + last.size.height
        }
    }

    private func createBackground(named name: String, atYIndex index: CGFloat) -> SKSpriteNode {
        guard let scene = scene else { fatalError("Scene is nil") }

        let texture = SKTexture(imageNamed: name)
        let scale = scene.size.width / texture.size().width
        let height = texture.size().height * scale

        let bg = SKSpriteNode(texture: texture)
        bg.setScale(scale)
        bg.anchorPoint = .zero
        bg.position = CGPoint(x: 0, y: index * height)
        bg.zPosition = -100

        return bg
    }

    func update(playerY: CGFloat) {
        guard let scene = scene else { return }

        if let first = backgrounds.first,
           first.position.y + first.size.height < playerY - scene.size.height {
            first.removeFromParent()
            backgrounds.removeFirst()
        }

        if let last = backgrounds.last,
           last.position.y + last.size.height < playerY + scene.size.height * 2 {
            
            let name = backgroundNames[nextBackgroundIndex % backgroundNames.count]
            let newBG = createBackground(named: name, atYIndex: lastYPosition / last.size.height)
            
            scene.addChild(newBG)
            backgrounds.append(newBG)

            lastYPosition = newBG.position.y + newBG.size.height
            nextBackgroundIndex += 1
        }
    }
}
