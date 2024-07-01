//
//  FavoritesList.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/5/24.
//

import SwiftUI
import SwiftyJSON

struct FavoritesList: View {
    @State private var items = [["AAPL", "Apple Inc", "172.98", "30", "2.01"], ["DELL","Dell Tech", "120", "-30", "2.01"], ["NVDA", "Nvidia", "915.21", "0.00", "2.01"]]
    @EnvironmentObject var vm: ContentViewModel
    var body: some View {

        ForEach(vm.detailedWLArray.indices, id: \.self) { index in
            NavigationLink(destination: StockInfo(stockSymbol: vm.detailedWLArray[index]["ticker"].stringValue).environmentObject(vm)){
                let change = vm.detailedWLArray[index]["d"].doubleValue //Double(vm.detailedWLArray[index]["d"])
                var color: Color = .gray
                var symbol = "minus"
                if change > 0 {
                    color = .green
                    symbol = "arrow.up.right"
                } else if change < 0 {
                    color = .red
                    symbol = "arrow.down.right"
                }

                return HStack {
                    VStack(alignment: .leading) {
                        Text("\(vm.detailedWLArray[index]["ticker"].stringValue)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("\(vm.detailedWLArray[index]["name"].stringValue)")
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    HStack(alignment : .top){
                        Image(systemName: symbol)
                            .foregroundColor(color)
                    }
                    VStack {
                        let currentPrice = Double(vm.detailedWLArray[index]["c"].stringValue) ?? 0.0
                        let currentPriceStrFormatted = String(format: "%.2f", currentPrice)
                        let chgStrFormatted = String(format: "%.2f", change)
                        let chgper = Double(vm.detailedWLArray[index]["dp"].stringValue) ?? 0.0
                        let chgPerStrFormated = String(format: "%.2f", chgper)
                        Text("$\(currentPriceStrFormatted)")
                            .fontWeight(.bold)
                        Text("$\(chgStrFormatted) (\(chgPerStrFormated)%)")
                            .foregroundColor(color)
//                        Text("(\(chgPerStrFormated)%)")
//                            .foregroundColor(color)
                    }
                }
            }
        }
        .onMove{sourceOffsets, destinationOffset in
            vm.detailedWLArray.move(fromOffsets: sourceOffsets, toOffset: destinationOffset)
            print(vm.detailedWLArray)
            var jsonArray = JSON(vm.detailedWLArray)
            var rawJSONString = jsonArray.rawString()
            BackendAPIservice.shared.reorderWatchlist(reorderedJSon: rawJSONString ?? "{}")
        }
        .onDelete(perform: delete)
    }
    
    private func delete(at offsets: IndexSet) {
        let index = offsets.first ?? 1
        let tick = vm.detailedWLArray[index]["ticker"].stringValue
            vm.detailedWLArray.remove(atOffsets: offsets)
        BackendAPIservice.shared.removeWatchlistElement(ticker: tick)
            print(vm.detailedWLArray)

    }
    
    
    private func move(from source: IndexSet, to destination: Int) {
            print("hello")
            vm.detailedWLArray.move(fromOffsets: source, toOffset: destination)
            print(vm.detailedWLArray)
            let jsonData = try! JSONSerialization.data(withJSONObject: vm.detailedWLArray, options: [])

            let temp1 = try! JSON(data: jsonData)
            let rawJSONString = temp1.rawString()
            BackendAPIservice.shared.reorderWatchlist(reorderedJSon: rawJSONString ?? "")
    }
}





struct ContenView_Previews: PreviewProvider {
    static var previews: some View {
        let json = """
        [{
          "t" : 1712952001,
          "d" : 1.51,
          "h" : 178.36000000000001,
          "l" : 174.21000000000001,
          "o" : 174.285,
          "dp" : 0.86270000000000002,
          "c" : 176.55000000000001,
          "ticker" : "AAPL",
          "pc" : 175.03999999999999,
          "name" : "Apple Inc"
        }, {
          "t" : 1712952031,
          "d" : -6.2800000000000002,
          "h" : 122.345,
          "l" : 117.63,
          "o" : 121.48999999999999,
          "dp" : -5.0629,
          "c" : 117.76000000000001,
          "ticker" : "DELL",
          "pc" : 124.04000000000001,
          "name" : "Dell Technologies Inc"
        }, {
          "t" : 1712952002,
          "d" : -0.69999999999999996,
          "h" : 29.18,
          "l" : 28.359999999999999,
          "o" : 28.989999999999998,
          "dp" : -2.3948,
          "c" : 28.530000000000001,
          "ticker" : "HPQ",
          "pc" : 29.23,
          "name" : "HP Inc"
        }, {
          "t" : 1712952000,
          "d" : -1.845,
          "l" : 71.730000000000004,
          "o" : 73.25,
          "dp" : -2.4965999999999999,
          "c" : 72.055000000000007,
          "ticker" : "WDC",
          "pc" : 73.900000000000006,
          "h" : 73.319999999999993
        }]
        """

        let jsonData = JSON(parseJSON: json).arrayValue

        return FavoritesList()
            .environmentObject(ContentViewModel())
    }
}
