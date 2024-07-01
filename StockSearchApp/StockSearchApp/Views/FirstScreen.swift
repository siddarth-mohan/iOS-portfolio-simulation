//
//  ContentView.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/2/24.
//

import SwiftUI
import Alamofire
struct FirstScreen: View {
    @StateObject var viewModel = ContentViewModel()
        
        var body: some View {
            VStack() {
                Text("Response JSON: \(viewModel.fundsAvailable)")
                    .padding()
                
                Button("Fetch Data") {
                    viewModel.getFundsAvailable()
                }
            }
        }
}

#Preview {
    FirstScreen()
}

