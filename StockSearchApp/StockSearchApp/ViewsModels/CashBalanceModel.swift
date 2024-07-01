//
//  PortfolioBalanceModel.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/3/24.
//

import Foundation
import Alamofire
import SwiftUI

class CashBalanceModel : ObservableObject {
    @Published var cashBalance: String? = "25000.00"
        
        func fetchData() {
            let urlString = "https://sid-assignment4-ios-backend.wl.r.appspot.com/fundsAvailable"
            
            AF.request(urlString, method: .get)
                .validate(statusCode: 200..<300)
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        self.cashBalance = value
                        print("Response String: \(value)")
                        // Handle successful response
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        // Handle failure
                    }
                }
            
        }
}


