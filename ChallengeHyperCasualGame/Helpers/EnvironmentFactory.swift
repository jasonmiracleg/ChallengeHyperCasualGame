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
        
        let environment = SKSpriteNode(imageNamed: "bottom_environment_3")
        environment.setScale(0.37)
        environment.position = CGPoint(x: baseX, y: baseY + 280)
        environment.zPosition = 1
        scene.addChild(environment)
        
        let secondEnvironment = SKSpriteNode(imageNamed: "bottom_environment_2")
        secondEnvironment.setScale(0.125)
        secondEnvironment.position = CGPoint(x: baseX, y: baseY + 80)
        secondEnvironment.zPosition = 3
        scene.addChild(secondEnvironment)
    }
}
