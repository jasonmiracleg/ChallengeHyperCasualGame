//
//  SoundManager.swift
//  ChallengeHyperCasualGame
//
//  Created by Jason Miracle Gunawan on 24/07/25.
//

import AVFoundation

import AVFoundation

struct SoundManager {
    private static var backgroundMusicPlayer: AVAudioPlayer?
    private static var soundEffects: [String: AVAudioPlayer] = [:]
    
    // MARK: - Background Music
    static func playBackgroundMusic(fileName: String, volume: Float = 0.5) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Background music file not found: \(fileName)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Infinite loop
            backgroundMusicPlayer?.volume = volume
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("Could not load or play music file: \(fileName), error: \(error)")
        }
    }
    
    // MARK: - Sound Effects
    static func preloadEffect(fileName: String, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Sound effect file not found: \(fileName)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            soundEffects[fileName] = player
        } catch {
            print("Could not preload sound effect: \(fileName), error: \(error)")
        }
    }
    
    static func playEffect(fileName: String) {
        guard let player = soundEffects[fileName] else {
            print("Sound effect not preloaded: \(fileName)")
            return
        }
        player.currentTime = 0 // Reset to start
        player.play()
    }
}

