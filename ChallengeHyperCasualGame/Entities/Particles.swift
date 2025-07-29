//
//  Particles.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 23/07/25.
//

import SpriteKit

struct Particles {
    static func createDustEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "star")
        emitter.particleBirthRate = 1 // Number of particles created per second
        emitter.numParticlesToEmit = 1 // The total number of particles to create before stopping.
        emitter.particleLifetime = 5 // How long each particle stays alive (in seconds).
        emitter.particleLifetimeRange = 0.2 // Adds a random variation to lifetime.
        emitter.particleSpeed = 50 // The initial speed at which particles move.
        emitter.particleSpeedRange = 30 // Adds randomness to speed.
        emitter.particleAlpha = 0.8 // The starting transparency of the particle. (1.0 = visible)
        emitter.particleAlphaRange = 0.2 // Random variation for alpha.
        emitter.particleAlphaSpeed = -1.0 // How fast alpha changes over time.
        emitter.particleScale = 0.1 // Initial size scale of the particle relative to its texture.
        emitter.particleScaleRange = 0.05 // Random variation for size.
        emitter.particleScaleSpeed = -0.3 // How much the particle shrinks or grows per second.
        emitter.particlePositionRange = CGVector(dx: 20, dy: 10) // Defines a random spawn area around the emitter.
        emitter.particleRotationRange = .pi * 2 // The initial random rotation angle for each particle.
        emitter.particleBlendMode = .alpha // Defines how particles blend with the background.
        emitter.zPosition = 1000
        return emitter
    }
}
