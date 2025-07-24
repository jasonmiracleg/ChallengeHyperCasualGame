//
//  PhysicsBitMask.swift
//  ChallengeHyperCasualGame
//
//  Created by Gerald Gavin Lienardi on 23/07/25.
//
struct PhysicsCategory: OptionSet {
    let rawValue: UInt32

    static let player       = PhysicsCategory(rawValue: 1 << 0)
    static let platform     = PhysicsCategory(rawValue: 1 << 1)
    static let bottomSensor = PhysicsCategory(rawValue: 1 << 2)
    static let topSensor    = PhysicsCategory(rawValue: 1 << 3)
    static let wall         = PhysicsCategory(rawValue: 1 << 4)
}
