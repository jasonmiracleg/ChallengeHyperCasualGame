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
        bottleBody.fillColor = .gray
        bottleBody.strokeColor = .clear
        bottleBody.position = .zero
    }
    
    private func setupBottleCap(offsetY: CGFloat, size: CGSize) {
            bottleCap.fillColor = .darkGray
            bottleCap.strokeColor = .red // Use red outline for visibility
            bottleCap.lineWidth = 1
            bottleCap.zPosition = 1
            
            // Centered path so that the shape aligns correctly with the physics body
            let rect = CGRect(
                x: -size.width / 2,
                y: -size.height / 2,
                width: size.width,
                height: size.height
            )
        bottleCap.path = CGPath(rect: rect, transform: nil)
            
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

        combinedBody.categoryBitMask = PhysicsBitMasks.player
        combinedBody.contactTestBitMask = PhysicsBitMasks.platform | PhysicsBitMasks.wall
        combinedBody.collisionBitMask = PhysicsBitMasks.platform | PhysicsBitMasks.wall

        self.physicsBody = combinedBody
    }


    
    private func setupSensors(size: CGSize) {
        // Bottom sensor
        bottomSensor.position = CGPoint(x: 0, y: -size.height / 2)
        let bottomPhysics = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: 2))
        bottomPhysics.isDynamic = false
        bottomPhysics.affectedByGravity = false
        bottomPhysics.categoryBitMask = PhysicsBitMasks.bottomSensor
        bottomPhysics.contactTestBitMask = PhysicsBitMasks.platform | PhysicsBitMasks.wall
        bottomPhysics.collisionBitMask = 0
        bottomPhysics.usesPreciseCollisionDetection = true
        bottomSensor.physicsBody = bottomPhysics

        // Top sensor
        topSensor.position = CGPoint(x: 0, y: size.height / 2)
        let topPhysics = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: 2))
        topPhysics.isDynamic = false
        topPhysics.affectedByGravity = false
        topPhysics.categoryBitMask = PhysicsBitMasks.topSensor
        topPhysics.contactTestBitMask = PhysicsBitMasks.platform | PhysicsBitMasks.wall
        topPhysics.collisionBitMask = 0
        topPhysics.usesPreciseCollisionDetection = true
        topSensor.physicsBody = topPhysics
    }

    func handleJumpOrSpin(from startPos: CGPoint, to endPos: CGPoint) {
        guard let body = self.physicsBody else { return }

        let velocity = body.velocity
        let speedThreshold: CGFloat = 1
        let isIdle = abs(velocity.dy) < speedThreshold

        if isIdle {
            let dx = endPos.x - startPos.x
            let dy = endPos.y - startPos.y
            let length = sqrt(dx * dx + dy * dy)
            let jumpStrengthX = dx * 20
            let jumpStrengthY = dy * 45

            body.velocity = CGVector(dx: -jumpStrengthX, dy: jumpStrengthY)
            body.angularVelocity = dx > 0 ? -length * 0.5 : length * 0.5
        }
    }
    
//    func wrapAroundEdges(in scene: SKScene) {
//        if position.x < -50 {
//            position.x = scene.frame.width + 50
//        } else if position.x > scene.frame.width + 50 {
//            position.x = -50
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
