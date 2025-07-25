//
//  GameOverUI.swift
//  ChallengeHyperCasualGame
//
//  Created by Wardatul Amalia Safitri on 25/07/25.
//


import SpriteKit

class GameOverUI: SKNode {
    
    var restartButton: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    override init() {
        super.init()
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        // Create the background overlay
        let background = SKSpriteNode(color: .black, size: CGSize(width: 400, height: 300))
        background.position = CGPoint(x: 0, y: 0)
        background.alpha = 0.7
        addChild(background)

        // Create the score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: 50)
        addChild(scoreLabel)
        
        // Create the restart button
        restartButton = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 60))
        restartButton.position = CGPoint(x: 0, y: -50)
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        // Add a label to the restart button
        let restartLabel = SKLabelNode(text: "Restart")
        restartLabel.fontName = "AvenirNext-Bold"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: 0)
        restartButton.addChild(restartLabel)
    }

    func showGameOver(score: Int) {
        // Show the game over UI
        scoreLabel.text = "Score: \(score)"
        self.isHidden = false
    }

    func hideGameOver() {
        self.isHidden = true
    }
}
