//
//  Footer.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/3/24.
//

import SwiftUI

struct Footer: View {
    var body: some View {
        HStack{
            Spacer()
            Text("Powered by Finnhub.io")
                .multilineTextAlignment(.center)
                .onTapGesture {
                    guard let url = URL(string: "https://finnhub.io") else { return }
                    UIApplication.shared.open(url)
                }
                .foregroundColor(.gray)
            Spacer()
        }
        
    }
}

#Preview {
    Footer()
}
