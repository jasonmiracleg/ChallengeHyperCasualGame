//
//  PlayerFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

class Player : SKNode {
    
    let bottleBody: SKShapeNode
    let bottleCap: SKShapeNode
    let topSensor: SKNode
    let bottomSensor: SKNode
    
    init(in scene: SKScene) {
        // Dimensions
        let bodySize = CGSize(width: 20, height: 40)
        let capSize = CGSize(width: 10, height: 5)
        
        // Make Shapes
        bottleBody = SKShapeNode(rectOf: bodySize, cornerRadius: 6)
        bottleCap = SKShapeNode(rectOf: capSize)
        
        bottomSensor = SKNode()
        topSensor = SKNode()

        super.init()
        
        self.position = CGPoint(x: scene.frame.midX, y: 100)
        
        setupBottleBody()
        setupBottleCap(offsetY: bodySize.height/2 + capSize.height/2)
        setupPhysics(size: bodySize)
        setupPhysics(size: bodySize)
        
        self.addChild(bottleBody)
        self.addChild(bottleCap)
        self.addChild(bottomSensor)
        self.addChild(topSensor)

        scene.addChild(self)
    }
    
    private func setupBottleBody() {
        bottleBody.fillColor = .gray
        bottleBody.strokeColor = .clear
        bottleBody.position = .zero
    }
    
    private func setupBottleCap(offsetY: CGFloat) {
        bottleCap.fillColor = .darkGray
        bottleCap.strokeColor = .clear
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
        // Bottom sensor
        bottomSensor.position = CGPoint(x: 0, y: -size.height / 2)
        let bottomPhysics = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: 2))
        bottomPhysics.isDynamic = false
        bottomPhysics.affectedByGravity = false
        bottomPhysics.categoryBitMask = 0x1 << 2
        bottomPhysics.contactTestBitMask = 0x1 << 1
        bottomPhysics.collisionBitMask = 0
        bottomPhysics.usesPreciseCollisionDetection = true
        bottomSensor.physicsBody = bottomPhysics

        // Top sensor
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
        
        if isIdle() {
            let dx = endPos.x - startPos.x
            let dy = endPos.y - startPos.y
            
            let velocityX = -dx * 4
            let velocityY = min(-dy * 8, 1400)

            body.velocity = CGVector(dx: velocityX, dy: velocityY)
            
            let spin = dx * 0.1
            body.angularVelocity = spin
        }
    }
    
    func handleSpin(from startPos: CGPoint, to endPos: CGPoint) {
        guard let body = self.physicsBody else { return }
        
        let angularVelocity = body.angularVelocity
        
        if !isIdle() {
            var spinBoost: CGFloat = 0
            
            if endPos.x > startPos.x {
                spinBoost = angularVelocity + 5
            } else {
                spinBoost = angularVelocity - 5
            }
            
            body.angularVelocity = spinBoost
        }
    }
    
    func wrapAroundEdges(in scene: SKScene) {
        if position.x < -50 {
            position.x = scene.frame.width + 50
        } else if position.x > scene.frame.width + 50 {
            position.x = -50
        }
    }
    
    func isIdle() -> Bool {
        guard let body = self.physicsBody else { return false}

        let velocity = body.velocity
        let speedThreshold: CGFloat = 1
        if abs(velocity.dy) < speedThreshold {
            return true
        } else {
            return false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
