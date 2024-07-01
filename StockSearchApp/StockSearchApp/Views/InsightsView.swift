//
//  InsightsView.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/5/24.
//

import SwiftUI

struct InsightsView: View {
    let totalMSPR : String
    let posMSPR : String
    let negMSPR : String
    let totalChng : String
    let posChng : String
    let negChng : String
    let stockName : String
    var body: some View {
        let totalMSPRDouble = Double(totalMSPR) ?? 0
        let posMSPRDouble = Double(posMSPR) ?? 0
        let negMSPRDouble = Double(negMSPR) ?? 0
        let totalChngDouble = Double(totalChng) ?? 0
        let posChngDouble = Double(posChng) ?? 0
        let negChngDouble = Double(negChng) ?? 0

        let formattedTotMSPR = String(format: "%.2f", totalMSPRDouble)
        let formattedPosMSPR = String(format: "%.2f", posMSPRDouble)
        let formattedNegMSPR = String(format: "%.2f", negMSPRDouble)
        let formattedTotChng = String(format: "%.2f", totalChngDouble)
        let formattedPosChng = String(format: "%.2f", posChngDouble)
        let formattedNegChng = String(format: "%.2f", negChngDouble)
        
        HStack{
            Spacer()
            Text("Insider Sentiments")
                .font(.title)
                .fontWeight(.medium)
                .padding(.bottom, 10)
            Spacer()
        }

        HStack{
            VStack(alignment: .leading){
                Text(stockName)
                    .fontWeight(.bold)
                Divider()
                Text("Total")
                    .fontWeight(.bold)
                Divider()
                Text("Positive")
                    .fontWeight(.bold)
                Divider()
                Text("Negative")
                    .fontWeight(.bold)
            }
            
            VStack(){
                Text("MSPR")
                    .fontWeight(.bold)
                Divider()
                Text(formattedTotMSPR)
                Divider()
                Text(formattedPosMSPR)
                Divider()
                Text(formattedNegMSPR)
            }
            
            VStack(){
                Text("Change")
                    .fontWeight(.bold)
                Divider()
                Text(formattedTotChng)
                Divider()
                Text(formattedPosChng)
                Divider()
                Text(formattedNegChng)
            }
            
            
        }
    }
}

#Preview {
    InsightsView(totalMSPR: "222.2222", posMSPR: "111111.1111", negMSPR: "-1212.1212", totalChng: "1", posChng: "123241", negChng: "-123456.123456", stockName: "Apple Inc")
}
