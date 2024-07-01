//
//  PortfolioBalance.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/3/24.
//

import SwiftUI

struct PortfolioBalance: View {
    let portfolioValue : String
    let funds :  String
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text("Net Worth")
                    .font(.title3)
                Text("$\(portfolioValue)")
                    .fontWeight(.bold)
                
            }
            .padding(.leading, 10)
            Spacer()
            VStack{
                Text("Cash Balance")
                    .font(.title3)
                Text("$\(funds)")
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
        }
    }
}

#Preview {
    PortfolioBalance(portfolioValue : "1234.1234", funds: "12122.00")
}
