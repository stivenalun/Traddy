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
                        .fontWeight(.bold)
                        .padding(.trailing, 190)
                        .padding(.vertical, 50)
                        .foregroundColor(Color(red: 0, green: 0.4, blue: 0.7))
                    
                    if cards.isEmpty {
                        VStack(spacing: 15) {
                            Text("Welcome to Traddy!")
                                .foregroundColor(Color(red: 0, green: 0.4, blue: 0.7))
                                .fontWeight(.semibold)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 35)
                            Image("home")
                            Spacer()
                                .frame(height: 120)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        PagerView(pageCount: cards.count, currentIndex: $currentPage) {
                            ForEach(cards) { card in
                                CardView(card: card, cards: $cards)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                
                VStack {
                    Spacer()
                        .frame(height: 630)
                    
                    Button(action: { isCreatingCard = true }) {
                                            if cards.isEmpty {
                                                Text("Create a trip")
                                                    .font(.system(.title2).weight(.semibold))
                                                    .frame(width: 180, height: 40)
                                                    .foregroundColor(.white)
                                                
                                            } else {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                                    .frame(width: 30, height: 35)
                                                    .background(Color(red: 0, green: 0.6, blue: 0.9))
                                                    .cornerRadius(30)
                                            }
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(Color(red: 0, green: 0.6, blue: 0.9))
                                        .buttonBorderShape(.roundedRectangle(radius: 18))
                                        
                                    }
                                }
            .sheet(isPresented: $isCreatingCard) {
                CreateCardView(isCreatingCard: $isCreatingCard, cards: $cards)
            }
        }
    }
}


struct CardView: View {
    let card: Card
    @State private var isLinkActive = false
    @State private var isShowingActionSheet = false
    @State private var editedText = ""
    @Binding var cards: [Card] // Add binding for cards array
    @State private var isTracking = false
    
    var body: some View {
        VStack {
            if let imageName = card.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(32)
                    .padding(.horizontal, 35)
                    .onTapGesture {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isLinkActive = true
                        }
                    }
                    .overlay(alignment: .bottom){
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 32)
                                                    .frame(width: 247, height: 169)
                                                    .foregroundColor(Color.white.opacity(0.8))
                                                    .padding(.bottom, 20)
                                                VStack{
                                                    Text("\(card.text)")
                                                        .font(.title)
                                                    
                                                    Button(action: {
                                                        isTracking.toggle() // Toggle the tracking state
                                                    }, label: {
                                                        ZStack{
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .frame(width: 156, height: 40)
                                                                .foregroundColor(isTracking ? Color.red : Color(red: 0, green: 0.6, blue: 0.9)) // Change button color based on tracking state
                                                            Text(isTracking ? "Stop Tracking" : "Start Tracking") // Change button text based on tracking state
                                                                .foregroundColor(Color.white)
                                                        }
                                                    })
                                                }
                                            }
                                        }
                    .background(
                        NavigationLink(destination: SummaryView(), isActive: $isLinkActive) {
                            EmptyView()
                        }
                            .frame(width: 0, height: 0)
                            .opacity(0)
                            .buttonStyle(PlainButtonStyle())
                    )
                    .onLongPressGesture {
                        isShowingActionSheet = true
                    }
                    .actionSheet(isPresented: $isShowingActionSheet) {
                        ActionSheet(
                            title: Text("Delete Card"),
                            message: Text("Are you sure you want to delete this card?"),
                            buttons: [
                                .destructive(Text("Delete"), action: {
                                    deleteCard()
                                }),
                                .cancel()
                            ]
                        )
                    }
            }
        }
    }
    
    private func deleteCard() {
        // Find the index of the card in the cards array
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            // Remove the card from the cards array
            cards.remove(at: index)
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
                .padding(.trailing, 20)
                .padding(.top, 10)
            }
            Text("Create a New Trip")
                .font(.title)
                .padding(.trailing, 100)
                .padding(.bottom, 40)
                .padding(.top, 20)
                .foregroundColor(Color(red: 0, green: 0.4, blue: 0.7))
                .fontWeight(.semibold)
            
            Text("Your Trip's Name")
                .frame(maxWidth: .infinity, alignment: .leading)
                .textFieldStyle(.roundedBorder)
                .padding(.leading, 35)
                .foregroundColor(Color(red: 0, green: 0.4, blue: 0.7))
                .fontWeight(.medium)
            
            TextField("Ex: Trip Malang", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 320)
                .padding(.bottom, 20)
            
            Text("Your Start Location")
                .frame(maxWidth: .infinity, alignment: .leading)
                .textFieldStyle(.roundedBorder)
                .padding(.leading, 35)
                .foregroundColor(Color(red: 0, green: 0.4, blue: 0.7))
                .fontWeight(.medium)
            
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
                    .background(Color(red: 0, green: 0.6, blue: 0.9))
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
            let newCard = Card(text: text, location: selectedLocation, imageName: getImageName()) // Pass the image name to the card
            cards.append(newCard)
            isCreatingCard = false
        }
    
    private func getImageName() -> String? {
            // Return a different image name for each card based on some logic or data source
            // Example: Assigning image names based on the index of the card
            let imageNames = ["pic1", "pic3", "pic4"] // Add your image names here
            
            let index = cards.count % imageNames.count
            return imageNames[index]
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
