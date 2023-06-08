//
//  SummaryView.swift
//  Traddy
//
//  Created by Stiven on 08/06/23.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        VStack(spacing: 20) {
            cardView(cardName: "peta")
            cardView(cardName: "barang")
            cardView(cardName: "tas")
        }
        .padding()
        .navigationBarTitle("Summary View") // Set the navigation bar title
    }
}

struct cardView: View {
    var cardName: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.blue)
            .frame(width: 350, height: 200)
            .overlay(
                Text(cardName)
                    .foregroundColor(.white)
                    .font(.title)
            )
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
