//
//  SplashScreenView.swift
//  StockSearchApp
//
//  Created by Siddarth Mohan on 4/18/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack{
            Color(red: 0.95, green: 0.95, blue: 0.95)
            Image("splashscreen")
                .resizable()
                .frame(width: 390, height: 390)
        }
        
    }
}

#Preview {
    SplashScreenView()
}
