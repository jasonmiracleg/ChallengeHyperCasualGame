//
//  PlatformDecorationFactory.swift
//  ChallengeHyperCasualGame
//
//  Created by Akmal Ariq on 22/07/25.
//

import SpriteKit

struct EnvironmentFactory {
    static func addInitialEnvironment(below platform: SKSpriteNode, in scene: SKScene) {
        let baseY = platform.position.y
        let baseX = platform.position.x
        
        let environment = SKSpriteNode(imageNamed: "bottom_environment")
        environment.setScale(0.4)
        environment.position = CGPoint(x: baseX, y: baseY + 165)
        environment.zPosition = -50
        scene.addChild(environment)
        
        
        let secondEnvironment = SKSpriteNode(imageNamed: "bottom_environment_2")
        secondEnvironment.setScale(0.123)
        secondEnvironment.position = CGPoint(x: baseX, y: baseY - 120)
        secondEnvironment.zPosition = -40
        scene.addChild(secondEnvironment)
    }
}
