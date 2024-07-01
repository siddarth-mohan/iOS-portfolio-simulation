//
//  ContentView.swift
//  StockSearchApp
//
//  Created by Siddarth Mohan on 4/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showHomeScreen = false
    
    var body: some View {
            if showHomeScreen {
                HomeScreen1()
            } else {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showHomeScreen = true

                        }
                    }
            }
    }
}
