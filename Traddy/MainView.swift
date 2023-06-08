//
//  MainView.swift
//  Traddy
//
//  Created by Stiven on 02/06/23.
//

import SwiftUI
import MapKit

struct MainView: View {
    @State private var isCreatingCard = false
    @State private var cards: [Card] = []
    @State private var currentPage = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.white).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("My Trips")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.trailing, 190)
                        .padding(.vertical, 30)
                        .foregroundColor(.blue)
                    
                    if cards.isEmpty {
                        VStack(spacing: 15) {
                            Text("Welcome to Traddy!")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 35)
                            Image("pic1")
                            Spacer()
                                .frame(height: 120)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        PagerView(pageCount: cards.count, currentIndex: $currentPage) {
                            ForEach(cards) { card in
                                CardView(card: card)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                
                VStack {
                    Spacer()
                        .frame(height: 620)
                    
                    Button(action: { isCreatingCard = true }) {
                        Text("Create a trip")
                            .font(.system(.title2).weight(.semibold))
                            .frame(width: 180, height: 40)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .buttonBorderShape(.roundedRectangle(radius: 18))
                    
                }
            }
            .sheet(isPresented: $isCreatingCard) {
                CreateCardView(isCreatingCard: $isCreatingCard, cards: $cards)
            }
        }
    }
}


//struct CardView: View {
//    let card: Card
//
//    var body: some View {
//        VStack {
//            Text(card.text)
//                .font(.title)
//                .fontWeight(.semibold)
//                .padding(.bottom, 10)
//
//            if let imageName = card.imageName {
//                Image(imageName)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 35)
//            }
//        }
//    }
//}

struct CardView: View {
    let card: Card
    
    var body: some View {
        VStack {
                Text(card.text)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                
            NavigationLink(destination: SummaryView()) {
                if let imageName = card.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .padding(.horizontal, 35)
                }
            }
        }
    }
}


struct PagerView<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    content
                        .frame(width: geometry.size.width, height: nil)
                }
            }
            .content.offset(x: CGFloat(currentIndex) * -geometry.size.width)
            .frame(width: geometry.size.width, alignment: .leading)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            currentIndex = min(currentIndex + 1, pageCount - 1)
                        } else if value.translation.width > 0 {
                            currentIndex = max(currentIndex - 1, 0)
                        }
                    }
            )
        }
    }
}

struct CreateCardView: View {
    @Binding var isCreatingCard: Bool
    @Binding var cards: [Card]
    @State private var text: String = ""
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: CLLocationCoordinate2D?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isCreatingCard = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 10)
                .padding(.top, 10)
            }
            Text("Create a New Trip")
                .font(.title)
                .padding(.trailing, 110)
                .padding(.bottom, 30)
                .padding(.top, 20)
            
            Text("Your Trip's Name")
                .frame(maxWidth: .infinity, alignment: .leading)
                .textFieldStyle(.roundedBorder)
                .padding(.leading, 35)
            
            TextField("Ex: Trip Malang", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 320)
            
            Text("Your Start Location")
                .frame(maxWidth: .infinity, alignment: .leading)
                .textFieldStyle(.roundedBorder)
                .padding(.leading, 35)
            
            TextField("Location", text: $searchQuery) { isEditing in
                if isEditing {
                    searchResults = []
                }
            } onCommit: {
                searchLocations()
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 320)
            
            List(searchResults, id: \.self) { item in
                Button(action: {
                    selectLocation(item.placemark)
                }) {
                    VStack(alignment: .leading) {
                        Text(item.name ?? "")
                            .font(.headline)
                        Text(formatAddress(item.placemark))
                            .font(.subheadline)
                    }
                }
            }
            .frame(height: 150)
            .cornerRadius(10)
            .padding(.horizontal, 35)
            .opacity(searchResults.isEmpty ? 0 : 1)
            
            if let selectedLocation = selectedLocation {
                MapView(coordinate: selectedLocation)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.horizontal, 35)
            }
            
            Button(action: {
                createCard()
            }) {
                Text("Add a trip")
                    .font(.system(.title2).weight(.semibold))
                    .frame(width: 150, height: 20)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(20)
            }
            .padding()
        }
        Spacer()
    }
    
    func searchLocations() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                searchResults = response.mapItems
            }
        }
    }
    
    func selectLocation(_ placemark: MKPlacemark) {
        selectedLocation = placemark.coordinate
        searchQuery = formatAddress(placemark) // Set the formatted address as the searchQuery
    }
    
    private func formatAddress(_ placemark: MKPlacemark) -> String {
        let addressComponents = [placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode, placemark.country]
            .compactMap { $0 }
        return addressComponents.joined(separator: ", ")
    }
    
    func createCard() {
        let newCard = Card(text: text, location: selectedLocation, imageName: "pic2")
        cards.append(newCard)
        isCreatingCard = false
    }
}

struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        uiView.setRegion(region, animated: true)
    }
}

struct Card: Identifiable {
    let id = UUID()
    var text: String
    var location: CLLocationCoordinate2D?
    var imageName: String?
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
