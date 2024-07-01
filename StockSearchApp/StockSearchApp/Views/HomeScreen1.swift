//
//  HomeScreen1.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/4/24.
//

import SwiftUI
import Alamofire
import Combine
import SwiftyJSON

struct HomeScreen1: View {
    @State private var searchText = ""
    @State private var PortfolioValue = ""
    @State private var isSearching = false
    @State private var isPortfolioLoading = true
    @State private var isWatchlistLoading = true
    @State private var isPortfolioValueLoading = true
    @State private var flag : Bool = false
    @State private var suggestions: [(ticker: String, name: String)] = []
    @State private var portfolioArray : [JSON] = []
    
    @StateObject var viewModel = ContentViewModel()
    @State private var reloadFlag = false

    
    var body: some View {
        Group{
            if isPortfolioLoading || isWatchlistLoading || isPortfolioValueLoading{
                ProgressView()
                Text("Fetching Data")
            }
            else{
                NavigationStack{
                    List{
                        if (flag){
                            ForEach(suggestions, id: \.ticker) { suggestion in
                                NavigationLink(destination: StockInfo(stockSymbol: suggestion.ticker).environmentObject(viewModel)){
                                    VStack(alignment: .leading) {
                                        Text(suggestion.ticker)
                                            .font(.headline)
                                            .foregroundStyle(Color.black)
                                        Text(suggestion.name)
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                        }
                        else{
                            Text("\(Date(), formatter: MMDDcomaYYYY)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                            
                            Section("Portfolio"){
                                PortfolioBalance(portfolioValue : viewModel.netWorth , funds: viewModel.fundsAvailable)
                                PortfolioList()
                            }
                            
                            Section("Favorites"){
                                FavoritesList()
                            }

                            Footer()

                        }
                    }
                    .environmentObject(viewModel)
                    .searchable(text: $searchText, isPresented: $flag)
                    .onAppear(perform: {
                        print("helloooooooooooooooo")
                        viewModel.getFundsAvailable()
                        viewModel.getPortfolioValue()
                        viewModel.getWatchlistElements()
                        viewModel.getPortfolioElements()
                    })

                    .navigationTitle("Stocks")
                    .toolbar {
                        EditButton()
                    }
                    .onChange(of: searchText) { newValue in
                        fetchSuggestions(for: newValue)
                    }
                }
               
            }
        }
        .onAppear{
            BackendAPIservice.shared.fundsAvailable(ticker: "")
            viewModel.getFundsAvailable()
            getPortfolioElements()
            getWatchlistElements()
            viewModel.getPortfolioValue()
            viewModel.getPortfolioElements()
            isPortfolioValueLoading = false
        }

        

    }
    
        


    
    private var MMDDcomaYYYY: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
    }
    
    private func fetchSuggestions(for query: String) {
//        guard let url = URL(string: "http://localhost:8080/autocomplete/\(query)") else { return }
        guard let url = URL(string: "https://sid-assignment4-ios-backend.wl.r.appspot.com/autocomplete/\(query)") else { return }
    
        AF.request(url)
            .validate()
            .responseDecodable(of: [[String]].self) { response in
                guard let data = response.value else { return }
                let suggestions = data.compactMap { innerArray -> (ticker: String, name: String)? in
                    guard innerArray.count == 2 else { return nil }
                    return (ticker: innerArray[0], name: innerArray[1])
                }
                DispatchQueue.main.async {
                    self.suggestions = suggestions
                }
            }
    }
    
    func getPortfolioElements(){
        BackendAPIservice.shared.getAllPortfolioElements(){ jsonArray, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                isPortfolioLoading = false
                return
            }
            
            if let jsonArray = jsonArray {
                viewModel.PortfolioListArray = jsonArray
                isPortfolioLoading = false
            } else {
                print("Failed to fetch data: Unknown error")
                isPortfolioLoading = false

            }
        }
    }
    
    func getWatchlistElements(){
        print("insideeeeeeeeeeeeeeeeeeeeeee")
        BackendAPIservice.shared.getDetailedWatchlist(){ jsonArray, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                isWatchlistLoading = false
                return
            }
            
            if let jsonArray = jsonArray {
                viewModel.detailedWLArray = jsonArray
                
                
                isWatchlistLoading = false
            } else {
                print("Failed to fetch data: Unknown error")
                isWatchlistLoading = false

            }
        }
    }
}

#Preview {
    HomeScreen1()
}
