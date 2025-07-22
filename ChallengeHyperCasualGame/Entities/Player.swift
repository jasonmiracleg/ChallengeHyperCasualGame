//
//  PlayerFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

class Player: SKNode {
    
    let bottleBody: SKSpriteNode
    let bottleCap: SKSpriteNode
    let topSensor: SKNode
    let bottomSensor: SKNode
    
    init(in scene: SKScene) {
        bottleBody = SKSpriteNode(imageNamed: "bottle_body")
        bottleCap = SKSpriteNode(imageNamed: "bottle_cap")
        
        bottomSensor = SKNode()
        topSensor = SKNode()
        
        super.init()
        
        self.position = CGPoint(x: scene.frame.midX, y: 100)
        bottleBody.zPosition = 10
        bottleCap.zPosition = 11
        
        let scaleFactor: CGFloat = 0.15
        bottleBody.setScale(scaleFactor)
        bottleCap.setScale(scaleFactor)
        
        setupBottleBody()
        setupBottleCap()
        setupPhysics(size: bottleBody.size)
        setupSensors(size: bottleBody.size)
        
        self.addChild(bottleBody)
        self.addChild(bottleCap)
        self.addChild(bottomSensor)
        self.addChild(topSensor)
        
        scene.addChild(self)
    }
    
    private func setupBottleBody() {
        bottleBody.position = .zero
    }
    
    private func setupBottleCap() {
        let offsetY = bottleBody.size.height / 2 + bottleCap.size.height / 2
        bottleCap.position = CGPoint(x: 0, y: offsetY)
    }
    
    private func setupPhysics(size: CGSize) {
        let physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody.linearDamping = 1.0
        physicsBody.friction = 1.0
        physicsBody.restitution = 0.0
        physicsBody.allowsRotation = true
        physicsBody.categoryBitMask = 0x1 << 0
        physicsBody.contactTestBitMask = 0x1 << 1
        physicsBody.collisionBitMask = 0x1 << 1
        
        self.physicsBody = physicsBody
    }
    
    private func setupSensors(size: CGSize) {
        bottomSensor.position = CGPoint(x: 0, y: -size.height / 2)
        let bottomPhysics = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: 2))
        bottomPhysics.isDynamic = false
        bottomPhysics.affectedByGravity = false
        bottomPhysics.categoryBitMask = 0x1 << 2
        bottomPhysics.contactTestBitMask = 0x1 << 1
        bottomPhysics.collisionBitMask = 0
        bottomPhysics.usesPreciseCollisionDetection = true
        bottomSensor.physicsBody = bottomPhysics
        
        topSensor.position = CGPoint(x: 0, y: size.height / 2)
        let topPhysics = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: 2))
        topPhysics.isDynamic = false
        topPhysics.affectedByGravity = false
        topPhysics.categoryBitMask = 0x1 << 3
        topPhysics.contactTestBitMask = 0x1 << 1
        topPhysics.collisionBitMask = 0
        topPhysics.usesPreciseCollisionDetection = true
        topSensor.physicsBody = topPhysics
    }
    
    func handleJump(from startPos: CGPoint, to endPos: CGPoint) {
        guard let body = self.physicsBody else { return }
        
        let velocity = body.velocity
        let speedThreshold: CGFloat = 1
        let isIdle = abs(velocity.dy) < speedThreshold
        
        if isIdle {
            let dx = endPos.x - startPos.x
            let dy = endPos.y - startPos.y
            
            let velocityX = -dx * 4
            let velocityY = min(-dy * 7, 1300)
            
            body.velocity = CGVector(dx: velocityX, dy: velocityY)
            
            let spin = dx * 0.1
            body.angularVelocity = spin
        }
    }
    
    func handleSpin(from startPos: CGPoint, to endPos: CGPoint) {
        guard let body = self.physicsBody else { return }
        
        let velocity = body.velocity
        let speedThreshold: CGFloat = 1
        let isIdle = abs(velocity.dy) < speedThreshold
        
        if isIdle {
            let dx = startPos.x - endPos.x
            let dy = startPos.y - endPos.y
            
            let velocityX = dx * 4
            let velocityY = min(dy * 7, 1300)
            
            body.velocity = CGVector(dx: velocityX, dy: velocityY)
            
            let spin = dx * 0.1
            body.angularVelocity = spin
        }
    }
    
    func wrapAroundEdges(in scene: SKScene) {
        if position.x < -50 {
            position.x = scene.frame.width + 50
        } else if position.x > scene.frame.width + 50 {
            position.x = -50
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flyBoost() {
        guard let body = self.physicsBody else { return }
        body.velocity = CGVector(dx: 0, dy: 1600)
        body.angularVelocity = CGFloat.random(in: -2.0...2.0)
    }

}
