//
//  AboutsView.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/5/24.
//

import SwiftUI

struct AboutsView: View {
    //var ur = "https://www.apple.com"
    let ipo : String
    let weburl : String
    let industry : String
    var peersArray = ["aapl", "dell", "aapl", "dell", "aapl", "dell", "aapl", "dell"]
    @EnvironmentObject var vm : ContentViewModel
    var body: some View {
        
        HStack(alignment: .top){
                VStack(alignment: .leading){
                    Text("IPO Start Date: ")
                        .font(.callout)
                        .fontWeight(.bold)
                    Text("Industry: ")
                        .font(.callout)
                        .fontWeight(.bold)

                    Text("Webpage: ")
                        .font(.callout)
                        .fontWeight(.bold)

                    Text("Company Peers: ")
                        .fontWeight(.bold)
                        .font(.callout)
                        .padding(.top,1)
                }
                VStack(alignment: .leading){
                    Text(ipo.prefix(10))
                        .font(.callout)
                    Text(industry)
                        .font(.callout)
                    Text(weburl)
                        .font(.callout)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            guard let url = URL(string: weburl) else { return }
                            UIApplication.shared.open(url)
                        }
                        .padding(.all, 0)
                    ScrollView(.horizontal){
                        HStack {
                            ForEach(peersArray, id: \.self) { string in
                                NavigationLink(destination: StockInfo(stockSymbol: string).environmentObject(vm)){
                                    Text("\(string),")
                                        .padding(.leading, 0)
                                        .font(.callout)
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                    .padding(.top, 0)
                    
                }
                
            }
        }
}

#Preview {
    AboutsView(ipo: "123", weburl: "sfasfafaf.com", industry: "sbdaisub").environmentObject(ContentViewModel())
}
