import Alamofire
import SwiftUI

struct PokemonView: View {
    
    let pokemon: [Pokemon]
    @State var currentPokemonIndex: Int
    
    @State private var randomizedIndex = 0
    
    @State private var isLoading = true
    @State private var timerIndex = 0
    @State private var timer: Timer?
    
    @State private var pokemonSpecies: PokemonSpecies?
    
    @State private var panelOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @GestureState private var translation = CGSize.zero
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let pokemonIndex = currentPokemonIndex
        
        VStack {
            VStack {
                if let species = pokemonSpecies {
                    Text(species.name.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                } else {
                    Text("Loading name...")
                        .font(.body)
                        .italic()
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                }
                
                if let species = pokemonSpecies {
                    Text(species.genera.first?.genus ?? "???")
                        .font(.body)
                        .italic()
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                } else {
                    Text("Loading species...")
                        .font(.body)
                        .italic()
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                }
            }
            .padding(.top, -15)
            
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon[currentPokemonIndex].id).png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350, height: 350)
            } placeholder: {
                Image("Pokeball")
                    .renderingMode(.original)
                    .resizable()
                    .scaleEffect(0.5)
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20)
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        if value.translation.width > 50 {
                            // Swiped right
                            currentPokemonIndex -= 1
                            print("Previous Pokemon Index", currentPokemonIndex)
                            if currentPokemonIndex < 0 {
                                currentPokemonIndex = pokemon.count - 1
                            }
                        } else if value.translation.width < -50 {
                            // Swiped left
                            currentPokemonIndex += 1
                            print("Next Pokemon Index", currentPokemonIndex)
                            if currentPokemonIndex >= pokemon.count {
                                currentPokemonIndex = 0
                            }
                        }
                    }
            )
            .overlay(
                HStack {
                    Image(systemName: "chevron.left")
                        .opacity(0.2)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.2)
                }
            )
            
            VStack {
                HStack {
                    Text("#\(timerIndex + 1)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding(.bottom, 10)
                
                if let species = pokemonSpecies {
                    Text(species.flavorTextEntries.first?.flavorText ?? "???")
                        .font(.title)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                        .frame(width: 420, height: 80) // Adjust the width and height as needed
                } else {
                    Text("Loading flavor text...")
                        .font(.body)
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                        .frame(width: 400, height: 80) // Adjust the width and height as needed
                }
            }
            .padding(.top, -15)
        }
        .onChange(of: pokemonIndex) { _ in
            startTimer()
            fetchPokemonSpecies()
        }
        .onAppear {
            startTimer()
            fetchPokemonSpecies()
        }
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: backButton,
            trailing: Button(action: {
                // Randomize the currentPokemonIndex
                currentPokemonIndex = Int.random(in: 0..<pokemon.count)
                print("Current Pokemon Index", currentPokemonIndex)
            }) {
                Image(systemName: "shuffle")
            }
        )
        .overlay(
            VStack {
                Spacer()
                    .frame(height: 20)
            }
            .offset(y: panelOffset)
            .gesture(
                DragGesture()
                    .updating(GestureState(initialValue: panelOffset)) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            panelOffset = 300 // Adjust the height to hide the panel completely
                        } else {
                            panelOffset = 0
                        }
                    }
            )

        )
        VStack {
            // Additional info content here
        }
        .offset(y: panelOffset)        
    }
    
    var backButton: some View {
        Button(action: {
            // Go back to PokedexView
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
        }
    }
    
    func startTimer() {
        let durationInSeconds: TimeInterval = 1
        let targetValue: Int = currentPokemonIndex
        let desiredTimeInterval: TimeInterval = durationInSeconds / TimeInterval(abs(targetValue - timerIndex))
        //let iterations = Int(ceil(durationInSeconds / desiredTimeInterval))
        //let changePerIteration = Double(targetValue - timerIndex) / Double(iterations)
        
        timer = Timer.scheduledTimer(withTimeInterval: desiredTimeInterval, repeats: true) { _ in
            if timerIndex < currentPokemonIndex {
                timerIndex += 1
            } else if timerIndex > currentPokemonIndex {
                timerIndex -= 1
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    func fetchPokemonSpecies() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(currentPokemonIndex+1)") else {
            print("Invalid URL")
            return
        }
        
        AF.request(url)
            .validate()
            .responseDecodable(of: PokemonSpecies.self) { response in
                switch response.result {
                case .success(let species):
                    let englishSpecies = getEnglishLanguageSpecies(from: species)
                    pokemonSpecies = englishSpecies
                case .failure(let error):
                    print("Error fetching Pokemon species:", error)
                }
            }
    }

    func getEnglishLanguageSpecies(from species: PokemonSpecies) -> PokemonSpecies {
        var versionId = 15
        var flavorTextEntries: [FlavorTextEntry]
        
        // Loop through the version IDs starting from 40
        repeat {
            let versionUrl = "https://pokeapi.co/api/v2/version/\(versionId)/"
            flavorTextEntries = species.flavorTextEntries.filter { $0.language.name == "en" && $0.version.url == versionUrl }
            
            // Break the loop if non-empty flavor text entries found
            if !flavorTextEntries.isEmpty {
                break
            }
            
            versionId += 2 // Increase the version ID by 5 for the next iteration
        } while versionId <= 42 // Continue until version ID is not more than 40
        
        let genera = species.genera.filter { $0.language.name == "en" }
        return PokemonSpecies(name: species.name, flavorTextEntries: flavorTextEntries, genera: genera)
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
