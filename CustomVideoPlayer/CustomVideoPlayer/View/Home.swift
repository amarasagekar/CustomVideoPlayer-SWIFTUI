//
//  Home.swift
//  CustomVideoPlayer
//
//  Created by AMAR on 21/05/24.
//

import SwiftUI

struct Home: View {
    var size: CGSize
    var safeArea: EdgeInsets
    
    //view properties
    @State private var player: AVPlayer? = {
       
        return nil
    }()
    var body: some View {
        VStack{
            let videoPlayerSize: CGSize = .init(width: size.width, height: size.height / 3.5)
            //custom video player
        }
    }
}

#Preview {
    ContentView()
}
