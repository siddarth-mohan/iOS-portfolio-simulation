//
//  PricesView.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/5/24.
//

import SwiftUI

struct PricesView: View {
    
    let c : String
    let d: String
    let dp: String
    var body: some View {
        HStack{
            let change = Double(d) ?? 0
            var color: Color = .gray
            var symbol = "minus"
            if change > 0 {
                color = .green
                symbol = "arrow.up.right"
            } else if change < 0 {
                color = .red
                symbol = "arrow.down.right"
            }
            return HStack{
                let cDouble = Double(c) ?? 0
                let dDouble = Double(d) ?? 0
                let dpDouble = Double(dp) ?? 0
                let formattedC = String(format: "%.2f", cDouble)
                let formattedD = String(format: "%.2f", dDouble)
                let formattedDP = String(format: "%.2f", dpDouble)
                Text("$\(formattedC)")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Image(systemName: symbol)
                    .foregroundColor(color)
                Text("$\(formattedD)")
                    .foregroundColor(color)
                    .font(.title)
                Text("(\(formattedDP)%)")
                    .foregroundColor(color)
                    .font(.title)
            }

        }
    }
}

#Preview {
    PricesView(c: "172.239", d: "1", dp: "2.3423")
}
