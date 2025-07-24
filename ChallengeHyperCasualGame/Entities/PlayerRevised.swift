//
//  PlayerFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

class PlayerRevised: SKNode {
    
    let bottleBody: SKSpriteNode
    let bottleCap: SKSpriteNode
    let bottomSensor: SKNode
    
    init(in scene: SKScene) {
        // Dimensions
        let bodySize = CGSize(width: 20, height: 40)
        let capSize = CGSize(width: 10, height: 5)
        
        bottleBody = SKSpriteNode(imageNamed: "bottle_body")
        bottleCap = SKSpriteNode(imageNamed: "bottle_cap")
        
        bottomSensor = SKNode()
        
        super.init()
        
        self.position = CGPoint(x: scene.frame.midX, y: 100)
        
        setupBottle()
        setupPhysics(size: CGSize(width: 30, height: 45))
        setupSensors()
        
        self.addChild(bottleBody)
        self.addChild(bottleCap)
        self.addChild(bottomSensor)
        self.name = "PlayerRevised"
        
        scene.addChild(self)
    }
    
    private func setupBottle() {
        bottleBody.zPosition = 10
        bottleCap.zPosition = 11
        
        let scaleFactor: CGFloat = 0.15
        bottleBody.setScale(scaleFactor)
        bottleCap.setScale(scaleFactor)
        
        bottleCap.position = CGPoint(x: 0, y: bottleBody.size.height/2 + bottleCap.size.height/2)
    }
    
    
    private func setupPhysics(size: CGSize) {
        let capSize = CGSize(width: 10, height: 5)
        let capOffsetY: CGFloat = size.height / 2 + capSize.height / 2
        
        // Main bottle body
        let bottleBody = SKPhysicsBody(rectangleOf: size)
        bottleBody.usesPreciseCollisionDetection = true
        
        // Cap as separate body
        let capBody = SKPhysicsBody(rectangleOf: capSize, center: CGPoint(x: 0, y: capOffsetY))
        capBody.usesPreciseCollisionDetection = true
        
        // Combine the two bodies
        let compoundBody = SKPhysicsBody(bodies: [bottleBody, capBody])
        compoundBody.mass = 1.0
        compoundBody.friction = 1.0
        compoundBody.restitution = 0.3
        compoundBody.allowsRotation = true
        
        // Set category and masks
        compoundBody.categoryBitMask = PhysicsCategory.player.rawValue
        compoundBody.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        compoundBody.collisionBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        
        self.physicsBody = compoundBody
        
        // 🟠 Debug box for bottleBody
        let bodyDebug = debugBox(size: size, position: .zero, color: .orange, zPosition: 100)
        self.addChild(bodyDebug)
        
        // 🟡 Debug box for capBody
        let capDebug = debugBox(size: capSize, position: CGPoint(x: 0, y: capOffsetY), color: .yellow, zPosition: 100)
        self.addChild(capDebug)
    }
    
    
    
    
    private func setupSensors() {
        // --- Top Sensor ---
        let topSensor = SKNode()
        topSensor.name = "Bottle Cap"
        topSensor.position = bottleCap.position
        
        let topSensorSize = CGSize(width: bottleCap.size.width, height: 2)
        let topOffsetY = bottleCap.position.y + bottleCap.size.height / 2 + topSensorSize.height / 2
        topSensor.position = CGPoint(x: 0, y: topOffsetY)
        
        let topSensorBody = SKPhysicsBody(
            rectangleOf: topSensorSize
        )
        //        topSensorBody.isDynamic = false
        topSensorBody.categoryBitMask = PhysicsCategory.topSensor.rawValue
        topSensorBody.contactTestBitMask = PhysicsCategory.wall.rawValue | PhysicsCategory.platform.rawValue
        topSensorBody.collisionBitMask = 0
        
        topSensorBody.isDynamic = true
        topSensorBody.affectedByGravity = false
        topSensorBody.usesPreciseCollisionDetection = true
        
        topSensor.physicsBody = topSensorBody
        self.addChild(topSensor)
        
        // Add debug shape for top sensor
        let topDebug = debugBox(size: bottleCap.size, position: topSensor.position, color: .green)
        self.addChild(topDebug)
        
        // --- Bottom Sensor ---
        let sensorHeight: CGFloat = 2
        let bottomSensor = SKNode()
        bottomSensor.name = "Bottom Sensor"
        
        let bottomSensorSize = CGSize(width: bottleBody.size.width, height: sensorHeight)
        let bottomOffsetY = bottleBody.position.y - bottleBody.size.height / 2 - sensorHeight / 2
        bottomSensor.position = CGPoint(x: 0, y: bottomOffsetY)
        
        let bottomSensorBody = SKPhysicsBody(rectangleOf: bottomSensorSize)
        //        bottomSensorBody.isDynamic = false
        bottomSensorBody.categoryBitMask = PhysicsCategory.bottomSensor.rawValue
        bottomSensorBody.contactTestBitMask = PhysicsCategory.wall.rawValue | PhysicsCategory.platform.rawValue
        bottomSensorBody.collisionBitMask = 0
        
        bottomSensorBody.isDynamic = true
        bottomSensorBody.affectedByGravity = false
        bottomSensorBody.usesPreciseCollisionDetection = true
        
        bottomSensor.physicsBody = bottomSensorBody
        self.addChild(bottomSensor)
        
        // Add debug shape for bottom sensor
        let bottomDebug = debugBox(size: CGSize(width: bottleBody.size.width, height: sensorHeight), position: bottomSensor.position, color: .blue)
        self.addChild(bottomDebug)
    }
    
    func debugBox(size: CGSize, position: CGPoint, color: SKColor = .red, zPosition: CGFloat = 999) -> SKShapeNode {
        let shape = SKShapeNode(rectOf: size)
        shape.position = position
        shape.strokeColor = color
        shape.lineWidth = 1.5
        shape.zPosition = zPosition
        shape.fillColor = color.withAlphaComponent(0.2)
        shape.name = "debugSensorBox"
        return shape
    }
    
    
    
    func handleJump(from startPos: CGPoint, to endPos: CGPoint) {
        guard let body = self.physicsBody else { return }
        
        if isIdle() {
            let dx = endPos.x - startPos.x
            let dy = endPos.y - startPos.y
            
            let velocityX = -dx * 4
            let velocityY = min(-dy * 8, 1400)
            
            body.velocity = CGVector(dx: velocityX, dy: velocityY)
            
            let spin = dx * 0.15
            body.angularVelocity = spin
        }
    }
    
    func handleSpin(from startPos: CGPoint, to endPos: CGPoint) {
        guard let body = self.physicsBody else { return }
        
        let angularVelocity = body.angularVelocity
        
        if !isIdle() {
            var spinBoost: CGFloat = 0
            
            if endPos.x < startPos.x {
                spinBoost = angularVelocity + 5
            } else {
                spinBoost = angularVelocity - 5
            }
            
            body.angularVelocity = spinBoost
        }
    }
    
    func dampenLandingVelocity() {
        guard let body = self.physicsBody else { return }
        
        // Reduce vertical velocity to minimize bounce
        let reducedVelocity = CGVector(
            dx: body.velocity.dx * 0.1,  // Optional: Slightly reduce horizontal speed
            dy: body.velocity.dy * 0.1   // Reduce bounce by dampening Y velocity
        )
        
        body.velocity = reducedVelocity
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
    
    func flyBoost() {
        guard let body = self.physicsBody else { return }
        body.velocity = CGVector(dx: 0, dy: 1600)
        body.angularVelocity = CGFloat.random(in: -2.0...2.0)
    }
    
}

enum LandingType: String {
    case normal = "Normal"
    case bottomSensor = "Bottom"
    case bottleCap = "Top"
}
