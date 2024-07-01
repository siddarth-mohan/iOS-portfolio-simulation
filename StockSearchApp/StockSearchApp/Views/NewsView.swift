//
//  NewsView.swift
//  StockSearchApp
//
//  Created by Siddarth Mohan on 4/8/24.
//

import SwiftUI
import SwiftyJSON
import Kingfisher

struct NewsView: View {
    let newsData: [JSON]
    @State private var isSheetPresented = false

    var body: some View {
        
        
        ForEach(newsData.indices, id: \.self) { index in
                HStack{
                    VStack(alignment : .leading){
                        HStack{
                            Text(newsData[index]["source"].stringValue)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            Text(newsData[index]["dateString"].stringValue)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                        Text(newsData[index]["headline"].stringValue)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    KFImage(URL(string: newsData[index]["image"].stringValue)!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                .cornerRadius(10)
                            Divider()
                }
                .frame(height: 100)
                .onTapGesture {
                    isSheetPresented = true
                }
                .sheet(isPresented: $isSheetPresented) {
                    VStack(alignment : .leading) {
                        HStack{
                            Spacer()
                            Button(action: {
                               isSheetPresented = false
                            }) {
                                Image(systemName: "xmark")
                            }
                        }
                        Text(newsData[index]["source"].stringValue)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(newsData[index]["dateString"].stringValue)
                            .font(.footnote)
                            .foregroundStyle(.gray)
                        Divider()
                        Text(newsData[index]["headline"].stringValue)
                            .fontWeight(.bold)
                            .font(.title2)
                        Text(newsData[index]["summary"].stringValue)
                            .font(.body)
                        HStack{
                            Text("For more details click ")
                                .font(.footnote)
                            Text("here")
                                .foregroundStyle(.blue)
                                .onTapGesture {
                                    guard let url = URL(string: newsData[index]["url"].stringValue) else { return }
                                    UIApplication.shared.open(url)
                            }
                        }
                        HStack{
                            Image("twitterLogo")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    let tmp = "https://twitter.com/intent/tweet?text=\(newsData[index]["headline"].stringValue) \(newsData[index]["url"].stringValue)"
                                    guard let url = URL(string: tmp) else { return }
                                    UIApplication.shared.open(url)
                                }
                            Image("metaLogo")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    let tmp = "https://www.facebook.com/sharer/sharer.php?u=\(newsData[index]["url"].stringValue)&src=sdkpreparse"
                                    guard let url = URL(string: tmp) else { return }
                                    UIApplication.shared.open(url)
                                }
                        }
                        Spacer()
                    }
                    .padding()
                }

            }
    }
}

#Preview {
    NewsView(newsData: [])
}
