// DecorationSpawner.swift
// ChallengeHyperCasualGame
//
// Created by Akmal Ariq on 22/07/25.

import SpriteKit

class DecorationSpawner {
    weak var scene: SKScene?
    var lastDecorationY: CGFloat = 0
    let decorationGap: CGFloat = 300
    let decorationNames = ["fish", "jellyfish", "trash"]
    
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
        
        let assetName = decorationNames.randomElement() ?? "fish"
        let decoration = SKSpriteNode(imageNamed: assetName)
        
        if assetName == "fish" {
            decoration
                .setScale(
                    CGFloat.random(in: 0.3...0.5)
                )
        } else {
            decoration
                .setScale(
                    CGFloat.random(in: 0.1...0.25)
                )
        }
        
        let randomX = CGFloat.random(in: 50...(scene.size.width - 50))
        decoration.position = CGPoint(
            x: randomX,
            y: y + CGFloat.random(in: -50...50)
        )
        
        decoration.zPosition = 1.5
        scene.addChild(decoration)
        
        if assetName == "fish" {
            moveFish(decoration)
        } else if assetName == "jellyfish" {
            moveJellyfish(decoration)
        }
    }
    
    private func moveFish(_ fish: SKSpriteNode) {
        guard let scene = scene else { return }
        
        let scaledWidth = fish.size.width * fish.xScale
        let moveDistance = scene.size.width - scaledWidth - fish.position.x
        
        let duration = TimeInterval(moveDistance / 100)
        let moveAction = SKAction.moveBy(x: moveDistance, y: 0, duration: duration)
        
        let resetPositionAction = SKAction.run {
            if fish.position.x >= scene.size.width + scaledWidth {
                fish.position = CGPoint(x: -scaledWidth, y: fish.position.y)
            }
        }
        
        let sequence = SKAction.sequence([moveAction, resetPositionAction])
        let loopAction = SKAction.repeatForever(sequence)
        
        fish.run(loopAction)
    }
    
    private func moveJellyfish(_ jellyfish: SKSpriteNode) {
        guard scene != nil else { return }
        
        let moveDistance: CGFloat = 2000
        
        let duration = TimeInterval(moveDistance / 80)
        let moveAction = SKAction.moveBy(x: 0, y: moveDistance, duration: duration)
        
        let removeAction = SKAction.run {
            jellyfish.removeFromParent()
        }
        
        let sequence = SKAction.sequence([moveAction, removeAction])
        jellyfish.run(sequence)
    }
}
