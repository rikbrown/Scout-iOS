//
//  ScoutAudioHelper.swift
//  Scout
//
//  Created by Brown, Rik on 2017-02-19.
//  Copyright © 2017 Scout. All rights reserved.
//

import Foundation
import AVFoundation

class ScoutAudioHelper {
    var player: AVAudioPlayer?
    
    public func playSiren() {
        playSound(name: "siren")
    }
    
    public func playBeyonce() {
        playSound(name: "formation")
    }
    
    func playSound(name: String) {
        print("playing " + name)
        
        if let path = Bundle.main.path(forResource: name, ofType: "mp3", inDirectory: "Scout-UI") {
            let url = URL(fileURLWithPath: path)
            print("at url: " + url.absoluteString)
            
            stopPlaying()
            
            do {
                /// this codes for making this app ready to takeover the device audio
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                /// change fileTypeHint according to the type of your audio file (you can omit this)
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
                
                player!.play()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    public func stopPlaying() {
        if let player = player {
            player.stop()
        }
    }
    
}
