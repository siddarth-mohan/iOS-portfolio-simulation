//
//  StockInfo.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/3/24.
//

import SwiftUI
import SwiftyJSON
import Kingfisher

struct StockData: Decodable {
    let ipo: String
    let currency: String
    let exchange: String
    let finnhubIndustry: String
    let phone: String
    let weburl: String
    let country: String
    let name: String
    let ticker: String
    let logo: String
}

struct StockInfo: View {
    let stockSymbol: String
    @State private var profileIsLoading = true
    @State private var quoteIsLoading = true
    @State private var peersIsLoading = true
    @State private var insiderSentiIsLoading = true
    @State private var isInPortfolioLoading = true
    @State private var isNewsLoading = true
    @State private var isHourlyLoading = true
    @State private var isHistoricalLoading = true

    @State private var isPortEmpty = true
    @State private var isWatchlisted = false
    @State private var companyProfile: StockData?
    @State private var peersArray = [""]
    @State private var quoteData: JSON?
    @State private var insiderSentiData: JSON?
    @State private var isInPortfolio: JSON?
    @State private var recommData: JSON?
    @State private var historicalData: JSON?
    @State private var hourlyData: JSON?
    @State private var earningsData: JSON?
    @State private var newsData: [JSON] = []
    @State private var firstNews: JSON?
    @State private var recomString : String = ""
    @State private var earningString : String = ""
    @State private var historicalString : String = ""
    @State private var hourlyString : String = ""
    
    @State private var isSheetPresented = false
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    @StateObject private var dataManager = DataManager()
    @EnvironmentObject var viewModel: ContentViewModel

    var body: some View {
        let companyName = companyProfile?.name ?? "Unknown Company"
        Group {
            if profileIsLoading || peersIsLoading || quoteIsLoading || insiderSentiIsLoading || isInPortfolioLoading || isNewsLoading || isHourlyLoading || isHistoricalLoading{
                ProgressView()
                Text("Fetching Data")
            } else {
                
                ScrollView(.vertical){
                    VStack(alignment: .leading){
                        HStack{
                            Text("\(companyProfile?.name ?? "Unknown Company")")
                                .font(.title2)
                                .foregroundColor(Color.gray)
                            Spacer()
                            KFImage(URL(string: companyProfile?.logo ?? "")!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Rectangle())
                                    .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                    .cornerRadius(15)
                                    .padding(.trailing,10)
                        }
                        
                        PricesView(c: dataManager.currentPrice, d: quoteData?["d"].stringValue ?? "", dp: quoteData?["dp"].stringValue ?? "")
                        
                        TabView{
                            WebView(data: hourlyString).tabItem { Label("Hourly", systemImage: "chart.xyaxis.line") }
                            WebView(data: historicalString).tabItem { Label("Historical", systemImage: "clock") }
                        }
                        .frame(height: 460)
                        
                        Text("Portfolio")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.top, 1)

                        if let _ = quoteData ,
                            let qty = isInPortfolio?["qty"].stringValue,
                            let avgCostString = isInPortfolio?["avgCost"].stringValue,
                            let avgCost = Double(avgCostString),
                            let doubleQty = Int(qty),
                            let currentCostString = quoteData?["c"].stringValue,
                            let doubleCurrentCost = Double(currentCostString) {
                            
                            let doubleTotalCost = Double(doubleQty) * avgCost
                            let totalCost = String(format: "%.2f", doubleTotalCost)
                            
                            let doubleChange = doubleCurrentCost - avgCost
                            let change = String(format: "%.2f", doubleChange)
                            
                            let doubleMarketValue = Double(doubleQty) * doubleCurrentCost
                            let marketValue = String(format: "%.2f", doubleMarketValue)
                            
                            PortfolioInfo(stockSymbol: stockSymbol , isInPortfolio: isPortEmpty, qty: qty, avgCost: avgCostString, totalCost: totalCost, change: change, marketValue: marketValue, tickerName : companyProfile?.name ?? "Unknown Company", currentprice: dataManager.currentPrice)
                            
                        } else{
                            PortfolioInfo(stockSymbol: stockSymbol, isInPortfolio : false, qty: "1", avgCost: "170.2", totalCost: "2000.122", change: "0.0", marketValue: "2342", tickerName : companyProfile?.name ?? "Unknown Company", currentprice: dataManager.currentPrice)
                            
                        }

                        
                        Text("Stats")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.top, 20)
                        StatsView(h: quoteData?["h"].stringValue ?? "", l: quoteData?["l"].stringValue ?? "", op: quoteData?["o"].stringValue ?? "", pc: quoteData?["pc"].stringValue ?? "")
                        
                        
                        Text("About")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.top, 20)
                        let ipo = companyProfile?.ipo ?? "Unknown Company"
                        let industry = companyProfile?.finnhubIndustry ?? "Unknown Company"
                        let weburl = companyProfile?.weburl ?? "Unknown Company"
                        AboutsView(ipo: ipo, weburl: weburl, industry: industry, peersArray: peersArray)


                        
                        
                        Text("Insights")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        InsightsView(
                            totalMSPR : insiderSentiData?["totalMSPR"].stringValue ?? "",
                            posMSPR : insiderSentiData?["posMSPR"].stringValue ?? "",
                            negMSPR : insiderSentiData?["negMSPR"].stringValue ?? "",
                            totalChng : insiderSentiData?["totalChng"].stringValue ?? "",
                            posChng : insiderSentiData?["posChng"].stringValue ?? "",
                            negChng : insiderSentiData?["negChng"].stringValue ?? "",
                            stockName : companyName)
                        WebView(data: recomString)
                            .frame(height: 400)
                            .padding(.top,30)
                        
                        WebView(data: earningString)
                            .frame(height: 390)
                        
                        Text("News")
                            .font(.title)
                            .fontWeight(.medium)
                            .padding(.top, 20)
                        VStack(alignment: .leading) {
                                KFImage(URL(string: firstNews?["image"].stringValue ?? "")!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 370, height: 220)
                                        .clipShape(Rectangle())
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                        .cornerRadius(15)
                                HStack{
                                    Text(firstNews?["source"].stringValue ?? "")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                    Text(firstNews?["dateString"].stringValue ?? "")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                }
                                Text(firstNews?["headline"].stringValue ?? "")
                                .fontWeight(.bold)
                                
                                Divider()
                        }
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
                                Text(firstNews?["source"].stringValue ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(firstNews?["dateString"].stringValue ?? "")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                Divider()
                                Text(firstNews?["headline"].stringValue ?? "")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                Text(firstNews?["summary"].stringValue ?? "")
                                    .font(.body)
                                HStack{
                                    Text("For more details click ")
                                        .font(.footnote)
                                    Text("here")
                                        .foregroundStyle(.blue)
                                        .onTapGesture {
                                            guard let url = URL(string: firstNews?["url"].stringValue ?? "") else { return }
                                            UIApplication.shared.open(url)
                                    }
                                }
                                HStack{
                                    Image("twitterLogo")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .onTapGesture {
                                            let tmp = "https://twitter.com/intent/tweet?text=\(firstNews?["headline"].stringValue ?? "") \(firstNews?["url"].stringValue ?? "")"
                                            guard let url = URL(string: tmp) else { return }
                                            UIApplication.shared.open(url)
                                        }
                                    Image("metaLogo")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .onTapGesture {
                                            let tmp = "https://www.facebook.com/sharer/sharer.php?u=\(firstNews?["url"].stringValue ?? "")&src=sdkpreparse"
                                            guard let url = URL(string: tmp) else { return }
                                            UIApplication.shared.open(url)
                                        }
                                }
                                Spacer()
                            }
                            .padding()
                        }

                        
                        NewsView(newsData : newsData)
                        
                        
                    }
                    .padding()
                    .padding(.top, 0)
                    .navigationTitle(stockSymbol.uppercased())
                    .toolbar(){
                        Button(action: {
                            if isWatchlisted{
                                showToast = true
                                toastMessage = "Removing \(stockSymbol) from Favorites"
                            }else{
                                showToast = true
                                toastMessage = "Adding \(stockSymbol) to Favorites"
                            }
                           addRemoveFromWatchlist(ticker: stockSymbol)
                            
                        }) {
                            if isWatchlisted{
                                Image(systemName: "plus.circle.fill")
                                
                            }
                            else{
                                Image(systemName: "plus.circle")

                            }
                        }
                    }
                }
                .toast(isPresented: $showToast) {
                    Text(toastMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(.gray)
                        .cornerRadius(10)
                        .opacity(75)
                    }

            }
        }
        .onAppear {
            dataManager.tickerSymbol = stockSymbol
            getIsStockInWatchlist(ticker: stockSymbol)
            getProfileData(ticker: stockSymbol)
            getPeersData(ticker: stockSymbol)
            getQuoteData(ticker: stockSymbol)
            getInsiderSentiData(ticker: stockSymbol)
            getHourlyChartData(ticker: stockSymbol)
            getHistoricalChartData(ticker: stockSymbol)
            getrecommData(ticker: stockSymbol)
            getEarningsData(ticker: stockSymbol)
            isStockInPortfolio(ticker: stockSymbol)
            getNewsData(ticker: stockSymbol)
            dataManager.startTimer()
        }
        .onDisappear{
            dataManager.stopTimer()
        }

        
    }
    
    
    func getProfileData(ticker: String) {
        BackendAPIservice.shared.getProfileData(tickerSearched: ticker) { result in
            switch result {
            case .success(let fetchedData):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: fetchedData, options: [])

                    let decoder = JSONDecoder()
                    companyProfile = try decoder.decode(StockData.self, from: jsonData)

                    profileIsLoading = false
                } catch {
                    print("Error decoding JSON: \(error)")
                    profileIsLoading = false

                }
            case .failure(let error):
                print("Failed to fetch data: \(error)")
            }
        }
    }
    
    
    func getPeersData(ticker: String){
        BackendAPIservice.shared.getPeersData(tickerSearched: ticker) { result in
            switch result {
            case .success(let fetchedData):
                peersArray = fetchedData
                peersIsLoading = false
            case .failure(let error):
                print("Failed to fetch data: \(error)")
                peersIsLoading = false
            }
        }
    }
    
    
    func getQuoteData(ticker: String) {
        BackendAPIservice.shared.getQuoteData(tickerSearched: ticker) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                quoteIsLoading = false
                return
            }
            
            if let json = json {
                quoteData = json
                dataManager.currentPrice = quoteData?["c"].stringValue ?? ""
                quoteIsLoading = false
            } else {
                print("Failed to fetch data: Unknown error")
                quoteIsLoading = false
            }
        }
    }
    
    
    func getInsiderSentiData(ticker: String) {
        BackendAPIservice.shared.getInsiderSentiData(tickerSearched: ticker) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                insiderSentiIsLoading = false
                return
            }
            
            if let json = json {
                insiderSentiData = json
                insiderSentiIsLoading = false
            } else {
                print("Failed to fetch data: Unknown error")
                insiderSentiIsLoading = false
            }
        }
    }
    
    func getrecommData(ticker: String) {
        BackendAPIservice.shared.getRecommData(tickerSearched: ticker) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let json = json {
                recommData = json
                let tempString = "recomChart(`" + (recommData?.rawString() ?? "") + "`)"
                recomString = tempString
            } else {
                print("Failed to fetch data: Unknown error")
            }
        }
    }
    
    func getEarningsData(ticker: String) {
        BackendAPIservice.shared.getEarningsData(tickerSearched: ticker) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let json = json {
                earningsData = json
                let tempString = "earningsChart(`" + (earningsData?.rawString() ?? "") + "`)"
                earningString = tempString
            } else {
                print("Failed to fetch data: Unknown error")
            }
        }
    }
    
    
    func isStockInPortfolio(ticker: String) {
        BackendAPIservice.shared.isStockInPortfolio(tickerSearched: ticker) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                isInPortfolioLoading = false
                return
            }
            
            if let json = json {
                isInPortfolio = json
                isPortEmpty = ((isInPortfolio?.description == "{}") != nil)
                isInPortfolioLoading = false
            } else {
                isInPortfolioLoading = false
                print("Failed to fetch data: Unknown error")
            }
        }
    }
    
    func getIsStockInWatchlist(ticker: String) {
        BackendAPIservice.shared.isStockInWatchlist(tickerSearched: ticker) { isInWatch, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            if isInWatch {
                isWatchlisted = true
            } else {
                isWatchlisted = false
            }
        }
    }
    
    func addRemoveFromWatchlist(ticker: String) {
        if !isWatchlisted{
            print("calling add to wl")
            BackendAPIservice.shared.addToWatchlist(tickerSearched: ticker)
        }
        else{
            print("calling remove to wl")
            BackendAPIservice.shared.removeFromWatchlist(tickerSearched: ticker)
        }
        isWatchlisted = !isWatchlisted
        viewModel.getWatchlistElements()
    }
    
    func getNewsData(ticker: String) {
        BackendAPIservice.shared.getNewsData(tickerSearched: ticker) { jsonArray, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                isNewsLoading = false
                return
            }
            
            if let jsonArray = jsonArray {
                let startIndex = 1
                let endIndex = jsonArray.count
                firstNews =  jsonArray.first!
                let slicedNewsData = Array(jsonArray[startIndex..<endIndex])
                newsData = slicedNewsData
                isNewsLoading = false
            } else {
                print("Failed to fetch data: Unknown error")
                isNewsLoading = false

            }
        }
    }
    
    
    func getHistoricalChartData(ticker: String) {
        BackendAPIservice.shared.getHistoricalChartData(tickerSearched: ticker) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let json = json {
                historicalData = json
                
                let temp2 = "`, '" + ticker + "')"
                let tempString = "historicalChart(`" + (historicalData?.rawString() ?? "") + temp2
                historicalString = tempString
                isHistoricalLoading = false
            } else {
                print("Failed to fetch data: Unknown error")
            }
        }
    }
    
    func getHourlyChartData(ticker: String) {
        BackendAPIservice.shared.getHourlyChartData(tickerSearched: ticker) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let json = json {
                hourlyData = json
                let temp3 = quoteData?["d"].stringValue ?? ""
                let temp4 = Double(temp3)!
                var color : String = "gray"
                if(temp4 > 0){
                    color = "green"
                }
                else{
                    color = "red"
                }
                let temp2 = "`, '" + ticker + "', '" + color + "')"
                let tempString = "hourlyChart(`" + (hourlyData?.rawString() ?? "") + temp2
                hourlyString = tempString
                isHourlyLoading = false
            } else {
                print("Failed to fetch data: Unknown error")
            }
        }
    }



    
}


class DataManager: ObservableObject {
    @Published var currentPrice: String = ""
    @Published var tickerSymbol: String = ""
    private var timer: Timer?
    
    func startTimer() {
        print("timer started")
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            self.updateData()
        }
    }
    
    func stopTimer() {
        print("timer stoped")

        timer?.invalidate()
        timer = nil
    }
    
    private func updateData() {
        print("refreshed")
        BackendAPIservice.shared.getQuoteData(tickerSearched: tickerSymbol) { json, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let json = json {
                let quoteData : JSON?
                quoteData = json

                self.currentPrice = quoteData?["c"].stringValue ?? ""
            } else {
                print("Failed to fetch data: Unknown error")
            }
        }
    }
}



#Preview {
    StockInfo(stockSymbol : "AAPL").environmentObject(ContentViewModel())
}

