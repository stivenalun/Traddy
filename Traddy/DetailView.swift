//
//  TripList.swift
//  Traddy
//
//  Created by Stiven on 07/06/23.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        VStack {
            Text("Trip List")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.vertical, 30)
                .foregroundColor(.blue)
            
            Text("Here is a list of your trips.")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
