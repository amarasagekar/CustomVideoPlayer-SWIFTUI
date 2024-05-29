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
    @State private var isPlaying: Bool = false
    @State private var timeoutTask: DispatchWorkItem?
    
    ///Video seeker properties
    @GestureState private var isDragging: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastDraggedProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0){
            let videoPlayerSize: CGSize = .init(width: size.width, height: size.height / 3.5)
            //custom video player
            ZStack {
                if let player {
                    CustomVideoPlayer(player: player)
                        .overlay{
                            Rectangle()
                                .fill(.black.opacity(0.4))
                                .opacity(showPlayerControls ? 1 : 0)
                                .overlay{PlaybackControls()
                                }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                showPlayerControls.toggle()
                            }
                            
                            ///Timing out controls, only if the video is Playing
                            if isPlaying {
                                timeoutControls()
                            }
                        }
                        .overlay(alignment: .bottom){
                            VideoSeekerview()
                        }
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
    /// Video seekar view
    @ViewBuilder
    func VideoSeekerview()-> some View{
        ZStack{
            9:57
        }
    }
    ///playback control view
    @ViewBuilder
    func PlaybackControls() -> some View {
        HStack(spacing:25){
            Button{
                
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background{
                        Circle()
                            .fill(.black.opacity(0.35))
                    }
            }
            ///Disabling button
            .disabled(true)
            .opacity(0.6)
            
            Button{
                /// Changing the video status to Play/Pause based on user input
                if isPlaying{
                    player?.pause()
                    /// cancling timeout task when the video is paused
                    if let timeoutTask {
                        timeoutTask.cancel()
                    }
                }else{
                    player?.play()
                    timeoutControls()
                }
                
                withAnimation(.easeInOut(duration: 0.2)){
                    isPlaying.toggle()
                }
            } label: {
                //changing icon based on video status
                Image(systemName: isPlaying ? "pause:fill" : "play.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background{
                        Circle()
                            .fill(.black.opacity(0.35))
                    }
            }
            .scaleEffect(1.1)
            
            
            Button{
                
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background{
                        Circle()
                            .fill(.black.opacity(0.35))
                    }
            }
            ///Disabling button
            .disabled(true)
            .opacity(0.6)
        }
        .opacity(showPlayerControls ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: showPlayerControls)
    }
    
    ///Timing out play back controls
    /// After some 2-5 seconds
    func timeoutControls(){
        ///cancling already pending timeout task
        if let timeoutTask{
            timeoutTask.cancel()
        }
        
        timeoutTask = .init(block: {
            withAnimation (.easeInOut(duration: 0.35)) {
                showPlayerControls = false
            }
        })
        
        ///scheduling task
        if let timeoutTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: timeoutTask)
        }
    }
}

#Preview {
    ContentView()
}
