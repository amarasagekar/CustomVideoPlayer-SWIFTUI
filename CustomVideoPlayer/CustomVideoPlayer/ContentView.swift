//
//  ContentView.swift
//  CustomVideoPlayer
//
//  Created by AMAR on 21/05/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader{
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            Home(size: size, safeArea: safeArea)
                .ignoresSafeArea()
        }
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
