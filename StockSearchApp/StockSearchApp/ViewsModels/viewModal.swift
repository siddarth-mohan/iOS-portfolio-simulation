//
//  viewModal.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/3/24.
//

import Foundation
import Alamofire
import SwiftUI
import SwiftyJSON

class ContentViewModel: ObservableObject {
//    private let baseURL = "http://localhost:8080/"
    private let baseURL = "https://sid-assignment4-ios-backend.wl.r.appspot.com/"

    @Published var responseData: [String: Any]? = nil
    @Published var fundsAvailable: String = ""
    @Published var netWorth: String = ""
    @Published var detailedWLArray : [JSON] = []
    @Published var PortfolioListArray : [JSON] = []
    
    func fetchData() {
        AF.request("https://sid-assignment4-ios-backend.wl.r.appspot.com/search/companyProfile/aapl", method: HTTPMethod.get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    self.responseData = value as? [String: Any]
                    print("Response JSON: \(value)")
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
    }
    
    
    func getFundsAvailable() {
        let url = baseURL + "fundsAvailable"
        print("iiiiiiiiiiiiinside portfolio reorder: \(url)")
        AF.request(url)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let value):
                    self.fundsAvailable = value
                case .failure(let error):
                    print("API call failed: \(error)")
                }
        }
    }
    
    func getPortfolioValue() {
        BackendAPIservice.shared.getPortfolioValue{ stringResponse, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let stringResponse = stringResponse {
                print("bbbbbbbbbbbbqqqqqqqq: \(stringResponse)")
                let PortfolioValue = Double(stringResponse)
                let funds = Double(self.fundsAvailable)
                print("sdfghdfghdfghdfghdfgh: \(self.fundsAvailable)")
                let netW = (PortfolioValue ?? 0) + (funds ?? 0)
                self.netWorth = String(format: "%.2f", netW)
                print("aaaaaaaaaaaaaaqqqqqqqq: \(self.netWorth)")
            } else {
                print("Failed to fetch data: Unknown error")
            }
        }
    }
    
    
    func getWatchlistElements(){
        print("updated watchlisttttttttttttt")
        BackendAPIservice.shared.getDetailedWatchlist(){ jsonArray, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let jsonArray = jsonArray {
                self.detailedWLArray = jsonArray
            } else {
                print("Failed to fetch data: Unknown error")

            }
        }
    }
    
    func getPortfolioElements(){
        BackendAPIservice.shared.getAllPortfolioElements(){ jsonArray, error in
            if let error = error {
                print("Failed to fetch data: \(error)")
                return
            }
            
            if let jsonArray = jsonArray {
                self.PortfolioListArray = jsonArray
                print("Hellooooasdasdasd: \(self.PortfolioListArray)")
            } else {
                print("Failed to fetch data: Unknown error")

            }
        }
    }
    
}
