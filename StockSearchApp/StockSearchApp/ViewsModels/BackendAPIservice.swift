//
//  BackendAPIservice.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/5/24.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftUI

class BackendAPIservice: ObservableObject {
    static let shared = BackendAPIservice()
    private let baseURL = "https://sid-assignment4-ios-backend.wl.r.appspot.com/"
//    private let baseURL = "http://localhost:8080/"
    @State var fundsAvailable : String = ""
    private init() {}
    

    
    func getProfileData(tickerSearched : String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = baseURL + "search/companyProfile/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let data = value as? [String: Any] {
                        completion(.success(data))
                    } else {
                        let error = NSError(domain: "ParsingError", code: 0, userInfo: nil)
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    
    func getPeersData(tickerSearched : String, completion: @escaping (Result<[String], Error>) -> Void) {
        let url = baseURL + "search/peers/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let stringArray = value as? [String] {
                        completion(.success(stringArray))
                    } else {
                        completion(.failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    
    func getQuoteData(tickerSearched: String, completion: @escaping (JSON?, Error?) -> Void) {
        let url = baseURL + "search/companyQuote/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    
    func getInsiderSentiData(tickerSearched: String, completion: @escaping (JSON?, Error?) -> Void) {
        let url = baseURL + "insights/insiderSenti/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func getRecommData(tickerSearched: String, completion: @escaping (JSON?, Error?) -> Void) {
        let url = baseURL + "insights/recomm/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func getEarningsData(tickerSearched: String, completion: @escaping (JSON?, Error?) -> Void) {
        let url = baseURL + "insights/earnings/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    
    func isStockInPortfolio(tickerSearched: String, completion: @escaping (JSON?, Error?) -> Void) {
        let url = baseURL + "isStockInPortfolio/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    
    func isStockInWatchlist(tickerSearched: String, completion: @escaping (Bool, Error?) -> Void) {
        let url = baseURL + "isStockInWatchlist/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                                if let isInWatchlist = value as? Bool {
                                    completion(isInWatchlist, nil)
                                } else {
                                    let error = NSError(domain: "ParsingError", code: 0, userInfo: nil)
                                    completion(false, error)
                                }
                case .failure(let error):
                    completion(false, error)
                }
            }
    }
    
    func getPortfolioValue(completion: @escaping (String?, Error?) -> Void) {
        let url = baseURL + "getPortfolioValue"
        
        AF.request(url)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let value):
                    completion(value, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func addToWatchlist(tickerSearched: String){
        let url = baseURL + "watchlist/add/\(tickerSearched)"
        AF.request(url)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    print("API call successful")
                    // Process data if needed
                case .failure(let error):
                    print("API call failed: \(error)")
            }
        }
    }
    
    func removeFromWatchlist(tickerSearched: String){
        let url = baseURL + "watchlist/remove/\(tickerSearched)"

        AF.request(url)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    print("API call successful")
                    // Process data if needed
                case .failure(let error):
                    print("API call failed: \(error)")
                }
            }
    }
    
    func getNewsData(tickerSearched: String, completion: @escaping ([JSON]?, Error?) -> Void) {
        let url = baseURL + "news/\(tickerSearched)"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let jsonArray = json.arrayValue
                    completion(jsonArray, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func getHistoricalChartData(tickerSearched: String, completion: @escaping (JSON?, Error?) -> Void){
        let url = baseURL + "search/charts/daily/\(tickerSearched)/2022-04-26/2024-04-26"
        print(url)
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func getHourlyChartData(tickerSearched: String, completion: @escaping (JSON?, Error?) -> Void){
        let url = baseURL + "search/charts/hourly/\(tickerSearched)/2024-04-25/2024-04-26"
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func updateTransactionInPortfolio(ticker: String, updatedQty: String, newAvgCost: String, tickername: String){
        let url = baseURL + "portfolio/update/\(ticker)/\(updatedQty)/\(newAvgCost)/\(tickername)"
        AF.request(url)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    print("API call successful")
                    // Process data if needed
                case .failure(let error):
                    print("API call failed: \(error)")
            }
        }
    }
    
    func removePortfolioElement(ticker: String){
        let url = baseURL + "removePortfolioElement/\(ticker)"
        AF.request(url)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    print("API call successful")
                    // Process data if needed
                case .failure(let error):
                    print("API call failed: \(error)")
            }
        }
    }
    
    func getAllPortfolioElements(completion: @escaping ([JSON]?, Error?) -> Void) {
        let url = baseURL + "getPortfolio"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let jsonArray = json.arrayValue
                    completion(jsonArray, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func getDetailedWatchlist(completion: @escaping ([JSON]?, Error?) -> Void) {
        let url = baseURL + "watchlist"
        
        AF.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let jsonArray = json.arrayValue
                    completion(jsonArray, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func removeWatchlistElement(ticker: String){
        let url = baseURL + "watchlist/remove/\(ticker)"
        AF.request(url)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    print("API call successful")
                    // Process data if needed
                case .failure(let error):
                    print("API call failed: \(error)")
            }
        }
    }
    
    func reorderWatchlist(reorderedJSon: String){
        let url = baseURL + "reorderWatchlist/\(reorderedJSon)"
        AF.request(url)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    print("API call successful")
                    // Process data if needed
                case .failure(let error):
                    print("API call failed: \(error)")
            }
        }
    }
    
    func reorderPortfolio(reorderedJSon: String){
        let url = baseURL + "reorderPortfolio/\(reorderedJSon)"
        AF.request(url)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    print("API call successful")
                    // Process data if needed
                case .failure(let error):
                    print("API call failed: \(error)")
            }
        }
    }
    
    func fundsAvailable(ticker : String){
        let url = baseURL + "fundsAvailable"
        AF.request(url)
            .validate()
            .response { [self] response in
                switch response.result {
                case .success(let data):
                    if let data = data, let fundsString = String(data: data, encoding: .utf8) {
                        print("api resp: \(fundsString)")
                        fundsAvailable = fundsString
                        print("Available funds:", fundsAvailable)
                    } else {
                        print("Failed to convert data to string")
                    }
                case .failure(let error):
                    print("API call failed: \(error)")
                }
        }
    }


}
