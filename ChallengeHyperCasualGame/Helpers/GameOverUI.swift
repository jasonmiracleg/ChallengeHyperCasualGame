//
//  GameOverUI.swift
//  ChallengeHyperCasualGame
//
//  Created by Wardatul Amalia Safitri on 25/07/25.
//

import SpriteKit

class GameOverUI: SKNode {
    
    var restartButton: SKSpriteNode!
    var dividerRectangle: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var scoreTextLabel: SKLabelNode!
    var bestScoreTextLabel: SKLabelNode!
    var bottle_overlay: SKSpriteNode!
    var bestScoreNumberTextLabel: SKLabelNode!
    var bottle_image: SKSpriteNode!
    var highScore: Int = 0
    
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        let background = SKSpriteNode(imageNamed: "gameover_background_overlay")
        background.setScale(0.35)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 15
        background.alpha = 1
        addChild(background)
        
        bottle_image = SKSpriteNode(imageNamed: "gameover_bottle_image")
        bottle_image.setScale(0.15)
        bottle_image.position = CGPoint(x: 0, y: 120)
        bottle_image.zPosition = 16
        bottle_image.alpha = 1
        bottle_image.zRotation = -(CGFloat.pi / 4)
        addChild(bottle_image)
        
        let bottle_overlay = SKSpriteNode(imageNamed: "gameover_bottle_overlay")
        bottle_overlay.setScale(0.25)
        bottle_overlay.position = CGPoint(x: 0, y: 100)
        bottle_overlay.zPosition = 14
        bottle_overlay.alpha = 1
        bottle_overlay.zRotation = -(CGFloat.pi / 4)
        addChild(bottle_overlay)
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = "ArialRoundedMTBold"
        scoreLabel.fontSize = 64
        scoreLabel.zPosition = 16
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: -64)
        addChild(scoreLabel)
        
        bestScoreNumberTextLabel = SKLabelNode(text: "\(highScore)")
        bestScoreNumberTextLabel.fontName = "ArialRoundedMTBold"
        bestScoreNumberTextLabel.fontSize = 40
        bestScoreNumberTextLabel.zPosition = 16
        bestScoreNumberTextLabel.fontColor = .white
        bestScoreNumberTextLabel.position = CGPoint(x: 0, y: -175)
        addChild(bestScoreNumberTextLabel)
        
        restartButton = SKSpriteNode(imageNamed: "gameover_restart_button")
        restartButton.setScale(0.3)
        restartButton.position = CGPoint(x: 0, y: -240)
        restartButton.name = "restartButton"
        restartButton.zPosition = 16
        addChild(restartButton)
    }
    
    func showGameOver(score: Int) {
        scoreLabel.text = "\(score)"
        self.isHidden = false
        
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8.0)
        let infiniteRotation = SKAction.repeatForever(rotateAction)
        bottle_image.run(infiniteRotation, withKey: "rotateForever")
    }
    
    func setHighScore(highScore: Int) {
        self.highScore = highScore
        bestScoreNumberTextLabel.text = "\(highScore)"
    }
    
    func hideGameOver() {
        self.isHidden = true
    }
}
