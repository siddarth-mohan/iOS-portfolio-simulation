//
//  PortfolioList.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/4/24.
//

import SwiftUI
import SwiftyJSON

struct PortfolioList: View {
    @State private var items = [["AAPL", "3", "512.98", "30", "2.01"], ["DELL","4", "513", "-30", "2.01"], ["NVDA", "2", "543.21", "0", "2.01"]]
    @EnvironmentObject var vm : ContentViewModel
    var body: some View {

        ForEach(vm.PortfolioListArray.indices, id: \.self) { index in
            NavigationLink(destination: StockInfo(stockSymbol: vm.PortfolioListArray[index]["ticker"].stringValue).environmentObject(vm)){
                VStack{
                    HStack{
                        Text(vm.PortfolioListArray[index]["ticker"].stringValue)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        let totalVal = Double(vm.PortfolioListArray[index]["total"].stringValue) ?? 0.0
                        let totalStrFormatted = String(format: "%.2f", totalVal)
                        Text("$\(totalStrFormatted)")
                            .fontWeight(.bold)
                            .padding(.trailing)
                    }
                    HStack{
                        Text("\(vm.PortfolioListArray[index]["qty"]) shares")
                            .foregroundStyle(.gray)
                        Spacer()
                        if let change = Double(vm.PortfolioListArray[index]["change"].stringValue){
                            if change > 0 {
                                Image(systemName: "arrow.up.right")
                                    .foregroundStyle(.green)
                            } else if change < 0 {
                                Image(systemName: "arrow.down.right")
                                    .foregroundStyle(.red)
                            }
                            else{
                                Image(systemName: "minus")
                                    .foregroundStyle(.gray)
                            }
                            
                            let temp = String(format: "%.2f", vm.PortfolioListArray[index]["changePer"].doubleValue)
                            let temop1 = String(format: "%.2f", vm.PortfolioListArray[index]["change"].doubleValue)
                            Text("$\(temop1) (\(temp)%)")
                                .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .gray))
                        }
                    }
                }
            }
        }
        .onMove{sourceOffsets, destinationOffset in
            vm.PortfolioListArray.move(fromOffsets: sourceOffsets, toOffset: destinationOffset)
            print(vm.PortfolioListArray)

            var jsonArray = JSON(vm.PortfolioListArray)
            var rawJSONString = jsonArray.rawString()
            
            BackendAPIservice.shared.reorderPortfolio(reorderedJSon: rawJSONString ?? "{}")
        }
    }
    
    

}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let json = """
        [
          {
            "ticker": "DELL",
            "name": "Dell Technologies Inc",
            "qty": "2",
            "avgCost": "1061.93",
            "currentPrice": 123.37,
            "total": 246.74,
            "change": -1877.12,
            "changePer": -88.3824734210353
          },
          {
            "ticker": "AAPL",
            "name": "Apple Inc",
            "qty": "1",
            "avgCost": "167.78",
            "currentPrice": 167.78,
            "total": 167.78,
            "change": 0,
            "changePer": 0
          }
        ]
        """

        let jsonData = JSON(parseJSON: json).arrayValue

        return PortfolioList()
    }
}
