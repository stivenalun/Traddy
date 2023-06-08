//
//  CardDetailScreen.swift
//  Traddy
//
//  Created by Stiven on 07/06/23.
//

import SwiftUI
import MapKit

struct CardDetailScreen: View {
    let card: Card
    
    var body: some View {
        VStack {
            Text(card.text)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            
            if let location = card.location {
       //         MapView(coordinate: location)
//                    .frame(height: 200)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 35)
            }
        }
    }
}
