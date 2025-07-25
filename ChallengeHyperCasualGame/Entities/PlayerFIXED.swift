//
//  PlayerFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 15/07/25.
//

import SpriteKit

class PlayerFIXED: SKNode {
    
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
        self.name = "PlayerRevised"
        
        let scaleFactor: CGFloat = 0.15
        bottleBody.setScale(scaleFactor)
        bottleCap.setScale(scaleFactor)
        
        setupBottleBody(size: bodySize)
        setupBottleCap(size: capSize)
        setupBottomSensor(bottleBody)
        
        viewPhysicsHitbox()
        
        scene.addChild(self)
        
        // === CREATE JOINTS ===
        let bodyToCap = SKPhysicsJointFixed.joint(
            withBodyA: bottleBody.physicsBody!,
            bodyB: bottleCap.physicsBody!,
            anchor: convert(bottleCap.position, to: scene)
        )

        let bodyToBottom = SKPhysicsJointFixed.joint(
            withBodyA: bottleBody.physicsBody!,
            bodyB: bottomSensor.physicsBody!,
            anchor: convert(bottomSensor.position, to: scene)
        )

        scene.physicsWorld.add(bodyToCap)
        scene.physicsWorld.add(bodyToBottom)
    }
    
    private func setupBottleBody(size: CGSize) {
        let bottlePhysicsBody = SKPhysicsBody(
            rectangleOf: size
        )
        bottleBody.name = "Bottle Body"
        
        bottlePhysicsBody.categoryBitMask = PhysicsCategory.player.rawValue
        bottlePhysicsBody.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        bottlePhysicsBody.collisionBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        
        bottleBody.physicsBody = bottlePhysicsBody
        
        self.addChild(bottleBody)
    }
    
    private func setupBottleCap(size: CGSize) {
        let capOffsetY: CGFloat = bottleBody.size.height / 2 + bottleCap.size.height / 2
        
        let capPhysicsBody = SKPhysicsBody(
            rectangleOf: size,
            center: CGPoint(x: bottleBody.size.width / 2, y: capOffsetY)
        )
        bottleCap.name = "Bottle Cap"
        
        capPhysicsBody.categoryBitMask = PhysicsCategory.topSensor.rawValue
        capPhysicsBody.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        capPhysicsBody.collisionBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        
        bottleCap.physicsBody = capPhysicsBody
        
        self.addChild(bottleCap)
    }
    
    private func setupBottomSensor(_ bottle: SKSpriteNode) {
        let bottomSensorSize = CGSize(width: bottle.size.width * 0.9, height: 2)
        
        let bottomPhysicsBody = SKPhysicsBody(
            rectangleOf: bottomSensorSize,
            center: CGPoint(x: bottleBody.size.width / 2, y: bottleBody.size.height * -0.01)
            )
        bottomSensor.name = "Bottom Sensor"
        
        bottomPhysicsBody.categoryBitMask = PhysicsCategory.bottomSensor.rawValue
        bottomPhysicsBody.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        bottomPhysicsBody.collisionBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        
        bottomSensor.physicsBody = bottomPhysicsBody
        
        self.addChild(bottomSensor)
    }
    
    private func viewPhysicsHitbox(){
        // Add debug shape for top sensor
        let topDebug = debugBox(size: bottleCap.size, position: bottleCap.position, color: .green)
        self.addChild(topDebug)
        
        // Add debug shape for bottom sensor
        let bottomDebug = debugBox(size: CGSize(width: bottleBody.size.width * 0.9, height: 2), position: bottomSensor.position, color: .blue)
        self.addChild(bottomDebug)
        
        // 🟠 Debug box for bottleBody
        let bodyDebug = debugBox(size: bottleBody.size, position: bottleBody.position, color: .orange, zPosition: 100)
        self.addChild(bodyDebug)
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
        guard let body = bottleBody.physicsBody else { return }
        
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
        guard let body = bottleBody.physicsBody else { return }
        
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
        guard let body = bottleBody.physicsBody else { return }
        
        // Reduce vertical velocity to minimize bounce
        let reducedVelocity = CGVector(
            dx: body.velocity.dx * 0.1,  // Optional: Slightly reduce horizontal speed
            dy: body.velocity.dy * 0.1   // Reduce bounce by dampening Y velocity
        )
        
        body.velocity = reducedVelocity
    }
    
    func isIdle() -> Bool {
        guard let body = bottleBody.physicsBody else { return false}
        
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
        guard let body = bottleBody.physicsBody else { return }
        body.velocity = CGVector(dx: 0, dy: 1600)
        body.angularVelocity = CGFloat.random(in: -2.0...2.0)
    }
    
}
