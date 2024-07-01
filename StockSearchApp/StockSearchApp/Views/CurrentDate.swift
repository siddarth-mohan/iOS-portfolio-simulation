//
//  CurrentDate.swift
//  assignment4
//
//  Created by Siddarth Mohan on 4/3/24.
//

import SwiftUI

struct CurrentDate: View {
    private var MMDDcomaYYYY: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
    }
    
    var body: some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
            
            Text("\(Date(), formatter: MMDDcomaYYYY)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(.systemGray))
                .multilineTextAlignment(.leading)
                .padding()
                        
        }
        .frame(width: 350, height: 70)
        .padding(.bottom, 30)
    }
}

#Preview {
    CurrentDate()
}
