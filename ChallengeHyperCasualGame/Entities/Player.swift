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
        // Dimensions
        let bodySize = CGSize(width: 20, height: 40)
        let capSize = CGSize(width: 10, height: 5)
        
        
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
        setupBottleCap(offsetY: bodySize.height/2 + capSize.height/2, size: capSize)
        setupPhysics(size: bodySize)
        setupSensors(size: bodySize)
        
        self.addChild(bottleBody)
        self.addChild(bottleCap)
        self.addChild(bottomSensor)
        self.addChild(topSensor)
        
        scene.addChild(self)
    }
    
    private func setupBottleBody() {
        bottleBody.position = .zero
    }
    
    private func setupBottleCap(offsetY: CGFloat, size: CGSize) {
//            bottleCap.fillColor = .darkGray
//            bottleCap.strokeColor = .red // Use red outline for visibility
//            bottleCap.lineWidth = 1
//            bottleCap.zPosition = 1
            
            // Centered path so that the shape aligns correctly with the physics body
            let rect = CGRect(
                x: -size.width / 2,
                y: -size.height / 2,
                width: size.width,
                height: size.height
            )
//        bottleCap.path = CGPath(rect: rect, transform: nil)
            
        // Position cap visually at the same Y offset as its physics body center
        bottleCap.position = CGPoint(x: 0, y: offsetY)
    }

    
    private func setupPhysics(size: CGSize) {
        let capSize = CGSize(width: 10, height: 5)
        let capOffsetY: CGFloat = size.height / 2 + capSize.height / 2

        // Main bottle body
        let bottleBody = SKPhysicsBody(rectangleOf: size)

        // Cap body, positioned above the bottle
        let capBody = SKPhysicsBody(rectangleOf: capSize, center: CGPoint(x: 0, y: capOffsetY))

        // Combine into one physics body
        let combinedBody = SKPhysicsBody(bodies: [bottleBody, capBody])

        // Configure
        combinedBody.linearDamping = 1.0
        combinedBody.friction = 1.0
        combinedBody.restitution = 0.0
        combinedBody.allowsRotation = true

        combinedBody.categoryBitMask = PhysicsCategory.player.rawValue
        combinedBody.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        combinedBody.collisionBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue

        self.physicsBody = combinedBody
    }


    
    private func setupSensors(size: CGSize) {
        bottomSensor.position = CGPoint(x: 0, y: -size.height / 2)
        let bottomPhysics = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: 2))
        bottomPhysics.isDynamic = false
        bottomPhysics.affectedByGravity = false
        bottomPhysics.categoryBitMask = PhysicsCategory.bottomSensor.rawValue
        bottomPhysics.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        bottomPhysics.collisionBitMask = 0
        bottomPhysics.usesPreciseCollisionDetection = true
        bottomSensor.physicsBody = bottomPhysics
        
        topSensor.position = CGPoint(x: 0, y: size.height / 2)
        let topPhysics = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: 2))
        topPhysics.isDynamic = false
        topPhysics.affectedByGravity = false
        topPhysics.categoryBitMask = PhysicsCategory.topSensor.rawValue
        topPhysics.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
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
