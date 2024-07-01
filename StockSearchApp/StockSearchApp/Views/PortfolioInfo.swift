//
//  PortfolioInfo.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/5/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire

struct PortfolioInfo: View {
    let stockSymbol: String
    let isInPortfolio: Bool
    let qty : String
    let avgCost : String
    let totalCost : String
    let change : String
    let marketValue : String
    let tickerName: String
    let currentprice : String
    @State private var transactionShares = ""
    @State private var cashBalance = ""
    @State private var isSheetPresented = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showGreenScreen = false
    @State private var qtyTran : String = ""
    @State private var buyOrSell : String = ""
    @State private var colorOfText : Color
    
    @State private var tickSymbol: String = ""
    @State private var isItInPortfolio: Bool = false
    @State private var qtyOwned : String = ""
    @State private var avgCostOfShare : String = ""
    @State private var totalCostOfShares : String = ""
    @State private var changeInPrice : String = ""
    @State private var marketValueOfShares : String = ""
    @State private var stockTickerName: String = ""
    @State private var currentpriceOfShare : String = ""
    
    @EnvironmentObject var viewModel: ContentViewModel
    
    init(stockSymbol: String, isInPortfolio: Bool, qty : String, avgCost : String, totalCost : String, change : String, marketValue : String ,tickerName: String, currentprice : String){
        self.stockSymbol = stockSymbol
                self.isInPortfolio = isInPortfolio
                self.qty = qty
                self.avgCost = avgCost
                self.totalCost = totalCost
                self.change = change
                self.marketValue = marketValue
                self.tickerName = tickerName
                self.currentprice = currentprice
        if (Double(change) ?? 0 > 0){
                colorOfText = .green
            }
        else if(Double(change) ?? 0 < 0){
                colorOfText = .red
            }
        else{
            colorOfText = .black
        }
    }
    var body: some View {
        HStack{
            if !isItInPortfolio{
                VStack(alignment: .leading){
                    Text("You have 0 shares of \(tickSymbol)")
                        .font(.callout)
                    Text("Start trading!")
                        .font(.callout)
                }
            }else{
                VStack(alignment: .leading){
                    HStack {
                        Text("Shares Owned: ")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text(qtyOwned)
                            .font(.callout)
                    }.padding(.top, 10)
                    HStack {
                        Text("Avg. Cost / Share: ")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text(avgCostOfShare)
                            .font(.callout)
                    }.padding(.top, 10)
                    HStack {
                        Text("Total Cost: ")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text(totalCostOfShares)
                            .font(.callout)
                    }.padding(.top, 10)

                    
                    HStack {
                        Text("Change: ")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text("$\(changeInPrice)")
                            .font(.callout)
                            .foregroundStyle(colorOfText)
                    }.padding(.top, 10)
                    HStack {
                        Text("Market Value: ")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text("$\(marketValueOfShares)")
                            .font(.callout)
                            .foregroundStyle(colorOfText)
                    }.padding(.top, 10)

                    
                }
            }
            
            Spacer()
            Text("Trade")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: 135)
                .background(Color.green)
                .cornerRadius(40)
                .onTapGesture {
                    getFundsAvailable()
                    isSheetPresented = true
                }
                .sheet(isPresented: $isSheetPresented) {
                    if showGreenScreen{
                        ZStack{
                            Color(.green)
                                .ignoresSafeArea()
                            VStack{
                                Spacer()
                                Text("Congratulations!")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                let te = Double(qtyTran) ?? 0
                                let share = te > 1 ? "shares" : "share"
                                let buySell = buyOrSell=="buy" ? "bought" : "sold"
                                Text("You have successfully \(buySell) \(qtyTran) \(share) of \(tickSymbol)")
                                    .foregroundStyle(.white)
                                    .padding(.top)
                                Spacer()
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding()
                                    .frame(maxWidth: 350)
                                    .background(.white)
                                    .cornerRadius(40)
                                    .padding(.bottom)
                                    .onTapGesture {
                                        showGreenScreen = false
                                        isSheetPresented = false
                                    }
                            }
                        }
                    }
                    else{
                    VStack{
                        HStack{
                            Spacer()
                            Button(action: {
                                isSheetPresented = false
                            }) {
                                Image(systemName: "xmark")
                            }
                        }
                        Text("Trade \(stockTickerName) shares")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top)
                        Spacer()
                        HStack{
                            TextField("0", text: $transactionShares)
                                .font(.system(size: 100))
                                .keyboardType(.numberPad)
                                .padding(.bottom, 0)
                                .padding(.leading)
                            Spacer()
                            Text("Shares")
                                .font(.largeTitle)
                        }
                        HStack{
                            Spacer()
                            let cp = Double(currentpriceOfShare)
                            let tranQty = Double(transactionShares)
                            let tranCost = (cp ?? 0.0) * (tranQty ?? 0.0)
                            let showTotal = String(format: "%.2f", tranCost)
                            let cpStr = String(format: "%.2f", cp ?? 0.0)
                            if(tranQty ?? 0>1){
                                Text("x $\(cpStr)/shares = $\(showTotal)")
                            }
                            else{
                                Text("x $\(currentpriceOfShare)/share = $\(showTotal)")
                            }
                        }
                        Spacer()
                        Text("$\(cashBalance) available to buy \(stockSymbol)")
                            .foregroundStyle(.gray)
                        HStack{
                                Text("Buy")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: 170)
                                    .background(Color.green)
                                    .cornerRadius(40)
                                    .onTapGesture {
                                        if let transactionQty = Double(transactionShares) {
                                            let cp = Double(currentpriceOfShare) ?? 0.0
                                            let tranQty = transactionQty
                                            let tranCost = cp * tranQty
                                            let cash = Double(cashBalance) ?? 0.0
                                            
                                            if tranQty < 1 {
                                                showToast = true
                                                toastMessage = "Cannot buy non-positive shares"
                                            } else if tranCost > cash {
                                                showToast = true
                                                toastMessage = "Not enough money to buy"
                                            } else {
                                                if !isItInPortfolio{
                                                    qtyOwned = "0"
                                                    avgCostOfShare = "0"
                                                    totalCostOfShares = "0"
                                                    changeInPrice = "0"
                                                    marketValueOfShares = "0"

                                                }
                                                qtyTran = transactionShares
                                                buyOrSell = "buy"
                                                showGreenScreen = true
                                                buyShare(ticker: stockSymbol, qtyPurchased: transactionShares, transactionPrice: currentpriceOfShare)
                                                isItInPortfolio = true
                                                transactionShares = "0"
                                            }
                                        } else {
                                            showToast = true
                                            toastMessage = "Please enter a valid amount"
                                        }
                                    }
                                Spacer()
                                Text("Sell")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: 170)
                                    .background(Color.green)
                                    .cornerRadius(40)
                                    .onTapGesture {
                                        
                                        if let transactionQty = Double(transactionShares) {
                                            let cp = Double(currentpriceOfShare) ?? 0.0
                                            let tranQty = transactionQty
                                            let tranCost = cp * tranQty
                                            let cash = Double(cashBalance) ?? 0.0
                                            let qtyOwned = Double(qtyOwned) ?? 0.0
                                            
                                            if tranQty < 1 {
                                                showToast = true
                                                toastMessage = "Cannot sell non-positive shares"
                                            } else if tranQty > qtyOwned {
                                                showToast = true
                                                toastMessage = "Not enough shares to sell"
                                            } else {
                                                qtyTran = transactionShares
                                                showGreenScreen = true
                                                buyOrSell = "sell"
                                                sellShare(ticker: stockSymbol, qtyPurchased: transactionShares, transactionPrice: currentpriceOfShare)
                                                transactionShares = "0"
                                            }
                                        } else {
                                            showToast = true
                                            toastMessage = "Please enter a valid amount"
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
                    .padding()
                    }
                    
                }
                
        }
        .onAppear {
                tickSymbol = stockSymbol
                isItInPortfolio = isInPortfolio
                qtyOwned = qty
                avgCostOfShare = avgCost
                totalCostOfShares = totalCost
                changeInPrice = change
                marketValueOfShares = marketValue
                stockTickerName = tickerName
                currentpriceOfShare = currentprice
                print("\(colorOfText)")
            }

    }
    
    func getFundsAvailable() {
        let urlString = "https://sid-assignment4-ios-backend.wl.r.appspot.com/fundsAvailable"
        
        AF.request(urlString, method: .get)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    cashBalance = value
                    let temp = Double(cashBalance)
                    cashBalance = String(format: "%.2f", temp ?? "")
                    print("Response String: \(value)")
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
    }
    
    func buyShare(ticker : String, qtyPurchased: String, transactionPrice: String){
        print(ticker)
        print("qty owned\(qtyOwned), qty purchased\(qtyPurchased)")
        print(transactionPrice)
        var temp = Double(qtyPurchased) ?? 0
        var temp1 = Double(qtyOwned) ?? 0
        var temp3 = temp + temp1
        var temp4 = String(format: "%.0f", temp3)
        var temp5 = Double(totalCostOfShares) ?? 0
        var temp6 = Double(transactionPrice) ?? 0
        var temp7 = temp * temp6
        var temp8 = temp5 + temp7
        var temp9 = temp8/temp3
        var temp10 = String(format: "%.2f", temp9)
        var temp11 = temp3 * temp9
        var temp12 = String(format: "%.2f", temp11)
        var temp13 = temp6 - temp9
        var temp14 = String(format: "%.2f", temp13)
        var temp15 = temp3 * temp6
        var temp16 = String(format: "%.2f", temp15)
        var temp17 = Double(cashBalance) ?? 0
        var temp18 = temp17 - temp7
        var temp19 = String(format: "%.2f", temp18)
        qtyOwned = temp4
        avgCostOfShare = temp10
        totalCostOfShares = temp12
        changeInPrice = temp14
        marketValueOfShares = temp16
        cashBalance = temp19
        

        BackendAPIservice.shared.updateTransactionInPortfolio(ticker: ticker, updatedQty: qtyOwned, newAvgCost: avgCostOfShare , tickername: tickerName)
        updateFunds(newsFunds: cashBalance)
        viewModel.getPortfolioElements()
    }
    
    func sellShare(ticker : String, qtyPurchased: String, transactionPrice: String){
        print(ticker)
        print(qtyPurchased)
        print(transactionPrice)
        var temp = Double(qtyPurchased) ?? 0
        var temp1 = Double(qtyOwned) ?? 0
        var temp3 = temp1 - temp
        var temp4 = String(format: "%.0f", temp3)
        if(temp4 == "0"){
            isItInPortfolio = false
            BackendAPIservice.shared.removePortfolioElement(ticker: ticker)
        }
        var temp5 = Double(avgCostOfShare) ?? 0
        var temp6 = temp3 * temp5
        var temp7 = String(format: "%.2f", temp6)
        var temp8 = Double(transactionPrice) ?? 0
        var temp10 = temp8 - temp5
        var temp11 = String(format: "%.2f", temp10)
        var temp12 = temp3 * temp8
        var temp13 = String(format: "%.2f", temp12)
        var temp14 = temp * temp8
        var temp15 = Double(cashBalance) ?? 0
        var temp16 = temp15 + temp14
        var temp17 = String(format: "%.2f", temp16)
        qtyOwned = temp4
        totalCostOfShares = temp7
        changeInPrice = temp11
        marketValueOfShares = temp13
        cashBalance = temp17
        BackendAPIservice.shared.updateTransactionInPortfolio(ticker: ticker, updatedQty: qtyOwned, newAvgCost: avgCostOfShare, tickername: tickerName)
        updateFunds(newsFunds: cashBalance)
        viewModel.getPortfolioElements()
    }
    
    func updateFunds(newsFunds: String){
        let urlString = "https://sid-assignment4-ios-backend.wl.r.appspot.com/fundsAvailable/edit/\(newsFunds)"
        
        AF.request(urlString, method: .get)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    print("Response String: \(value)")
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
    }
        
}

#Preview {
    PortfolioInfo(stockSymbol: "AAPL", isInPortfolio : true, qty: "5", avgCost: "200", totalCost: "848.15", change: "-0.1", marketValue: "848.35", tickerName : "Apple Inc", currentprice: "169.67")
}



