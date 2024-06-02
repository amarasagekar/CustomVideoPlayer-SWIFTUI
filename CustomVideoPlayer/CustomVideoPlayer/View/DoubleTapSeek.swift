//
//  DoubleTapSeek.swift
//  CustomVideoPlayer
//
//  Created by AMAR on 01/06/24.
//

import SwiftUI

/// Seeking video forward/backward with double tap animation

struct DoubleTapSeek: View {
    var isForward: Bool = false
    var onTap: () -> ()
    
    ///Animation Properties
    @State private var isTapped: Bool = false
    ///Since we have three arrows
    @State private var showArrows: [Bool] = [false, false, false]
    var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .overlay{
                Circle()
                    .fill(.black.opacity(0.4))
                    .scaleEffect(2, anchor: isForward ? .leading : .trailing)
            }
            .opacity(isTapped ? 1 : 0)
        /// Arrows
            .overlay {
                VStack(spacing: 10){
                    HStack(spacing: 0){
                        ForEach(0...2, id:\.self){index in
                            Image(systemName: "arrowtriangle.backward.fill")
                                .opacity(showArrows[index] ? 1 : 0.2)
                        }
                    }
                    .font(.title)
                    .rotationEffect(.init(degrees: isForward ? 180 : 0))
                    
                    Text("15 Seconds")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                /// Showing only if tapped
                .opacity(isTapped ? 1 : 0)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation (.easeInOut(duration: 0.25)){
                    isTapped = true
                    showArrows[0] = true
                }
            }
    }
}

#Preview {
    ContentView()
}

