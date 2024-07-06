//
//  CMTime+Extensions.swift
//  CustomVideoPlayer
//
//  Created by AMAR on 06/07/24.
//

import SwiftUI
import AVKit

extension CMTime{
    func toTimeString() -> String{
        let roundedSeconds = seconds.rounded()
        let hours: Int = Int(roundedSeconds / 3600)
        let min: Int = int(roundedSeconds.truncatingRemainder(dividingBy: 3600) /60)
        let sec: int = Int(roundedSeconds / 60)
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, moin, sec)
        }
        
        return String(format: "%02d:%02d", min, sec)
    }
}