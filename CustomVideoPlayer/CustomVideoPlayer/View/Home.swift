//
//  Home.swift
//  CustomVideoPlayer
//
//  Created by AMAR on 21/05/24.
//

import SwiftUI
import AVKit

struct Home: View {
    var size: CGSize
    var safeArea: EdgeInsets
    
    //view properties
    @State private var player: AVPlayer? = {
        if let  bundle = Bundle.main.path(forResource: "Sample Video", ofType: "mp4"){
            return .init(url: URL(filePath: bundle))
        }
        return nil
    }()
    @State private var showPlayerControls: Bool = false
    var body: some View {
        VStack(spacing: 0){
            let videoPlayerSize: CGSize = .init(width: size.width, height: size.height / 3.5)
            //custom video player
            ZStack {
                if let player {
                    CustomVideoPlayer(player: player)
                }
            }
            .frame(width: videoPlayerSize.width, height: videoPlayerSize.height)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10){
                    ForEach(1...5, id:\.self){index in
                        GeometryReader{
                            let size = $0.size
                            
                            Image("Thumb \(index)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        .frame(height: 220)
                    }
                    
                }
                .padding(.horizontal, 15)
                .padding(.top, 30)
                .padding(.bottom, 15 + safeArea.bottom)
            }
        }
        .padding(.top, safeArea.top)
    }
}

#Preview {
    ContentView()
}
