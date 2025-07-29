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
    
    let bodySize: CGSize = CGSize(width: 20, height: 40)
    let capSize: CGSize = CGSize(width: 10, height: 5)
    private var capOffsetY: CGFloat {
        return bodySize.height/2 + capSize.height/2 + 7
    }
    
    init(in scene: SKScene) {
        // applying asset texture
        bottleBody = SKSpriteNode(imageNamed: "bottle_body")
        bottleCap = SKSpriteNode(imageNamed: "bottle_cap")
        
        super.init()
        self.position = CGPoint(x: scene.frame.midX, y: 100)
        
        setupBottle()
        
        // adding into scene
        scene.addChild(self)
    }
    
    private func setupBottle(){
        // z position
        bottleBody.zPosition = 10
        bottleCap.zPosition = 11
        
        // position
        bottleBody.position = .zero
        bottleCap.position = CGPoint(x: 0, y: capOffsetY)
        
        //scale them to size
        let scaleFactor: CGFloat = 0.15
        bottleBody.setScale(scaleFactor)
        bottleCap.setScale(scaleFactor)
        
        // setting up physics
        setupPhysics()

        //adding into the Player SKNode Container
        self.addChild(bottleBody)
        self.addChild(bottleCap)
        
    }
    
    private func setupPhysics() {
        // creating physics bodies
        let bottleBody = SKPhysicsBody(rectangleOf: bodySize)
        let capBody = SKPhysicsBody(rectangleOf: capSize, center: CGPoint(x: 0, y: capOffsetY))
        
        let combinedBody = SKPhysicsBody(bodies: [bottleBody, capBody])
        
        // physics configuration here
        combinedBody.linearDamping = 1.0
        combinedBody.friction = 1.0
        combinedBody.restitution = 0.3
        combinedBody.allowsRotation = true
        
        // physics bit mask configuration
        combinedBody.categoryBitMask = PhysicsCategory.player.rawValue
        combinedBody.contactTestBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        combinedBody.collisionBitMask = PhysicsCategory.platform.rawValue | PhysicsCategory.wall.rawValue
        
        self.physicsBody = combinedBody
    }
    
    func handleJump(from startPos: CGPoint, to endPos: CGPoint) {
        guard let body = self.physicsBody else { return }
        
        if isIdle() {
            let dx = endPos.x - startPos.x
            let dy = endPos.y - startPos.y
            
            let velocityX = -dx * 4.5
            let velocityY = min(-dy * 8, 1400)
            
            body.velocity = CGVector(dx: velocityX, dy: velocityY)
            
            var spin = 0.0
            if dx > 0{
                spin = 3.0
            } else {
                spin = -3.0
            }
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

        // Reduce vertical and horizontal velocity to minimize bounce
        // V keep manipulating these for the platform's "stickiness"
        let reducedVelocity = CGVector(
            dx: body.velocity.dx * 0.1,  // Optional: Slightly reduce horizontal speed
            dy: body.velocity.dy * 0.1   // Reduce bounce by dampening Y velocity
        )

        body.velocity = reducedVelocity
    }
    
//    whats this function for
    func isIdle() -> Bool {
        guard let body = self.physicsBody else { return false }

        let velocity = body.velocity
        let speedThreshold: CGFloat = 1
        if abs(velocity.dy) < speedThreshold {
            return true
        } else {
            return false
        }
    }
    
//    checks what rotation it is for scoring purposes
    func checkRotation() -> LandingType {
        // Convert radians to degrees
        let degrees = abs(zRotation * 180 / .pi).truncatingRemainder(dividingBy: 360)
        let tolerance: CGFloat = 10

        if abs(degrees - 0) <= tolerance || abs(degrees - 360) <= tolerance {
            return .standing
        } else if abs(degrees - 180) <= tolerance {
            return .bottleCap
        } else {
            return .normal
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

// again for scoring purposes
enum LandingType: String {
    case normal = "Normal"
    case standing = "Standing"
    case bottleCap = "Bottle Cap"
}
