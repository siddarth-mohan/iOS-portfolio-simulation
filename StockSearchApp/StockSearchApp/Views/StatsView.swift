//
//  StatsView.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/5/24.
//

import SwiftUI

struct StatsView: View {
    let h : String
    let l: String
    let op: String
    let pc: String
    var body: some View {
        let hDouble = Double(h) ?? 0
        let lDouble = Double(l) ?? 0
        let opDouble = Double(op) ?? 0
        let pcDouble = Double(pc) ?? 0
        let formattedH = String(format: "%.2f", hDouble)
        let formattedL = String(format: "%.2f", lDouble)
        let formattedOP = String(format: "%.2f", opDouble)
        let formattedPC = String(format: "%.2f", pcDouble)
        HStack{
            Text("High Price: ")
                .font(.callout)
                .fontWeight(.bold)
            Text("$\(formattedH)")
                .font(.callout)
            Spacer()
            Text("Open Price")
                .font(.callout)
                .fontWeight(.bold)
            Text("$\(formattedOP)")
                .font(.callout)
        }
        .padding(.top, 3)
        .padding(.trailing, 20)
        HStack{
            Text("Low Price: ")
                .font(.callout)
                .fontWeight(.bold)
            Text("$\(formattedL)")
                .font(.callout)
            Spacer()

            Text("Prev. Close")
                .font(.callout)
                .fontWeight(.bold)
            Text("$\(formattedPC)")
                .font(.callout)
        }
        .padding(.trailing, 20)
    }
}

#Preview {
    StatsView(h: "", l: "", op: "", pc: "")
}
