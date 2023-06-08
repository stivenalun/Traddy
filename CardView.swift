//
//  CardView.swift
//  Traddy
//
//  Created by Stiven on 07/06/23.
//

import SwiftUI
import MapKit

struct CardView: View {
    let card: Card
    
    var body: some View {
        VStack {
            Text(card.text)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            
            if let location = card.location {
                MapView(coordinate: location)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.horizontal, 35)
            }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let card = Card(text: "Sample Trip", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        return CardView(card: card)
    }
}

