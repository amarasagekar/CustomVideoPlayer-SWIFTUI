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
    @State private var isFinishedPlaying: Bool = false
    ///Video seeker properties
    @GestureState private var isDragging: Bool = false
    @State private var isSeeking: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastDraggedProgress: CGFloat = 0
    @State private var isObserverAdded:Bool = false
    
    /// Video Seeker Thumbnails
    @State private var thubnailFrame: [UIImage] = []
    @State private var draggingImage: UIImage?
    @State private var playerStatusobserver: NSKeyValueObservation?
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
                                .opacity(showPlayerControls || isDragging ? 1 : 0)
                            /// Animating dragging state
                                .animation(.easeInOut(duration: 0.35), value: isDragging)
                                .overlay{PlaybackControls()
                                }
                        }
                        .overlay(content: {
                            HStack(spacing: 60){
                                DoubleTapSeek{
                                    /// Seeking 15 sec backward
                                    let seconds = player.currentTime().seconds - 15
                                    player.seek(to: .init(seconds:seconds, preferredTimescale: 1))
                        
                                }
                                DoubleTapSeek(isForward: true){
                                    /// Seeking 15 sec Forward
                                    let seconds = player.currentTime().seconds + 15
                                    player.seek(to: .init(seconds:seconds, preferredTimescale: 1))
                                }
                            }
                        })
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                showPlayerControls.toggle()
                            }
                            
                            ///Timing out controls, only if the video is Playing
                            if isPlaying {
                                timeoutControls()
                            }
                        }
                        .overlay(alignment: .leading, content: {
                            SeekerThumbnailView(videoPlayerSize)
                        })
                        .overlay(alignment: .bottom){
                            VideoSeekerview(videoPlayerSize)
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
        .onAppear{
            guard !isObserverAdded else {return}
            /// Adding observer to update seeker when the video is playing
            player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 1), queue: .main, using: {time in
                /// Calculating video progress
                if let currentPlayerTime = player?.currentItem{
                    let totalDuration = currentPlayerTime.duration.seconds
                    guard let currentDuration = player?.currentTime().seconds else { return}
                    
                    let calculatedProgress = currentDuration / totalDuration
                    if !isSeeking{
                        progress = calculatedProgress
                        lastDraggedProgress = progress
                    }
                    
                    
                    if calculatedProgress == 1 {
                        /// Video finished playing
                        isFinishedPlaying = true
                        isPlaying = false
                    }
                }
            })
            isObserverAdded = true
            
            /// Before generating thumnails, Check is the video is loaded
            playerStatusobserver = player?.observe(\.status, options: .new, changeHandler: { player, _ in
                if player.status == .readyToPlay{
                    generatethumbnailframe()
                }
            })
        }
        .onDisappear{
            /// Clearing Observers
            playerStatusobserver?.invalidate()
        }
    }
    
    /// Dragging Thumbnail View
    @ViewBuilder
    func SeekerThumbnailView(_ videoSize: CGSize) -> some View{
        let thumbSize : CGSize = .init(width: 175, height: 100)
        ZStack{
            
            if let draggingImage {
                Image(uiImage: draggingImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(alignment: .bottom, content: {
                        
                    })
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    }
            }else{
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    }
            }
        }
        .frame(width: thumbSize.width, height: thumbSize.height)
        .opacity(isDragging ? 1: 0)
        /// Moving Along side
        .offset(x: progress * (videoSize.width - thumbSize.width - 20))
        .offset(x: 10)
    }
    /// Video seekar view
    @ViewBuilder
    func VideoSeekerview(_ videoSize: CGSize)-> some View{
        ZStack(alignment:.leading){
            Rectangle()
                .fill(.gray)
            
            Rectangle()
                .fill(.red)
                .frame(width: max(size.width * progress, 0))
        }
        .frame(height: 3)
        .overlay(alignment: .leading) {
            Circle()
                .fill(.red)
                .frame(width: 15, height: 15)
            ///Showing dragg knob only when dragging
                .scaleEffect(showPlayerControls || isDragging ? 1 : 0.001, anchor: progress * size.width > 15 ? .trailing : .leading)
                ///For more dragging space
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                ///Moving along side with gesture progress
                .offset(x: size.width * progress)
                .gesture(
                    DragGesture()
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged({ value in
                            /// Cancling existing Timeout task
                            if let timeoutTask {
                                timeoutTask.cancel()
                            }
                            ///Calculating progress
                            let translationX: CGFloat = value.translation.width
                            let calculatedProgress = (translationX / videoSize.width) + lastDraggedProgress
                            
                            progress = max(min(calculatedProgress, 1), 0)
                            isSeeking = true
                            
                            let dragIndex = Int(progress / 0.01)
                            // Checking if FrameThumbnails Contains the frame
                            if thubnailFrame.indices.contains(dragIndex){
                                draggingImage = thubnailFrame[dragIndex]
                            }
                        })
                        .onEnded({ value in
                            ///Storing last known progress
                            lastDraggedProgress = progress
                            ///Seeking video to drgged time
                            if let currentPlayerItem = player?.currentItem {
                                let totalDurartion = currentPlayerItem.duration.seconds
                                
                                player?.seek(to: .init(seconds: totalDurartion * progress, preferredTimescale: 1))
                                
                                ///Re-scheduling Timeout task
                                if isPlaying {
                                    timeoutControls()
                                }
                                
                                /// Releasing with slight delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    isSeeking = false
                                }
                            }
                        })
                )
                .offset(x: progress * videoSize.width > 15 ? -15 : 0)
                .frame(width: 15, height: 15)
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
                
                if isFinishedPlaying {
                    ///Setting video to start and playing Again
                    isFinishedPlaying = false
                    player?.seek(to: .zero)
                    progress = .zero
                    lastDraggedProgress = .zero
                }
                
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
                ///changing icon based on video status
                /// Changing Icon when Video was finishhed  Playing
                Image(systemName: isFinishedPlaying ? "arrow.clockwise" : (isPlaying ? "pause:fill" : "play.fill"))
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
        ///Hiding controls while dragging
        .opacity(showPlayerControls && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: showPlayerControls && !isDragging)
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
    
    /// Genrating Thumbnail frames
    func generatethumbnailframe(){
        Task.detached {
            guard let asset = player?.currentItem?.asset else { return }
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            ///Min Size
            generator.maximumSize = .init(width: 250, height: 250)
            
            do{
                let totalDuration = try await asset.load(.duration).seconds
                var frameTimes: [CMTime] = []
                /// Frame Timings
                /// 1/0.1 = 100 (frames)
                for progress in stride(from: 0, to: 1, by: 0.01){
                    let time = CMTime(seconds: progress * totalDuration, preferredTimescale: 1)
                }
                
                ///Generating Frame Images
                for await result in generator.images(for: frameTimes) {
                    let cgImage = try result.image
                    // Adding frame Image
                    await MainActor.run {
                        thubnailFrame.append(UIImage(cgImage: cgImage))
                    }
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}


