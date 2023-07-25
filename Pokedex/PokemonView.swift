import Alamofire
import PokemonAPI
import SwiftUI

struct PokemonView: View {
    
    //Parameters
    let pokemon: [Pokemon]
    @State var currentPokemonIndex: Int
        
    //State variables
    @State private var shuffleButtonPressed = false
    @State private var isLoading = true
    @State private var timerIndex = 0
    @State private var timer: Timer?
    
    //Carousel variables
    @State private var panelOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @GestureState private var translation = CGSize.zero
    @Environment(\.presentationMode) var presentationMode
    
    //PokeAPI variables
    @State private var pokemonSpecies: PokemonSpecies?
    @State private var pokemonName = ""
    @State private var pokemonGenus = ""
    @State private var pokemonFlavorText = ""
    @State private var pokemonTypes: [String]?
    
    var body: some View {
        let pokemonIndex = currentPokemonIndex
        let pkmnTypesColors = prepareBackgroundColors(types: pokemonTypes ?? [])
        let pkmnTypesGradient = Gradient(colors: pkmnTypesColors)
        let conicGradient = AngularGradient(gradient: pkmnTypesGradient, center: .center, startAngle: .degrees(120), endAngle: .degrees(420))

        let mask = LinearGradient(gradient: Gradient(colors: [.black, .white]), startPoint: .top, endPoint: .bottom)

        let viewBgColor = Color.clear
            .background(conicGradient)
            .mask(mask)
        
        VStack {
            VStack {
                HStack {
                    Text(pokemonName.capitalized.isEmpty ? "???" : pokemonName.capitalized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(alignment: .leading)

                    if let types = pokemonTypes {
                        ForEach(types, id: \.self) { type in
                            let color = PokemonTypeColorMap.colors[type] ?? .black
                            Text(type.capitalized.isEmpty ? "???" : type.capitalized)
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .foregroundColor(.white)
                                .background(color)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Text(pokemonGenus.capitalized.isEmpty ? "???" : pokemonGenus.capitalized)
                    .font(.body)
                    .italic()
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

            }
            .padding(.top, -15)
            
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonIndex+1).png")) { image in
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
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                        .frame(width: 400, height: 80) // Adjust the width and height as needed
                } else {
                    Text("Loading flavor text...")
                        .font(.body)
                        .lineLimit(4)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                        .frame(width: 400, height: 80) // Adjust the width and height as needed
                }
            }
            .padding(.top, -15)
        }
        .frame(maxHeight: .infinity)
        .background(viewBgColor)
        .onChange(of: pokemonIndex) { _ in
            startTimer()
            fetchPokemon()
            fetchPokemonSpecies()
            fetchPokemonTypes()
        }
        .onAppear {
            startTimer()
            fetchPokemon()
            fetchPokemonSpecies()
            fetchPokemonTypes()
        }
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: backButton,
            trailing: Button(action: {
                if !shuffleButtonPressed {
                    // Randomize the currentPokemonIndex
                    currentPokemonIndex = Int.random(in: 0..<pokemon.count)
                    print("Current Pokemon Index", currentPokemonIndex)
                    fetchPokemon()
                    shuffleButtonPressed = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        shuffleButtonPressed = false
                    }
                }
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
    }

    
    var backButton: some View {
        Button(action: {
            // Go back to PokedexView
            presentationMode.wrappedValue.dismiss()
        }) {
            ZStack {
                Circle()
                    .foregroundColor(Color.black.opacity(0.5))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.white)
                    .font(.system(size: 22, weight: .bold))
            }
        }
    }
    
    func startTimer() {
        let durationInSeconds: TimeInterval = 0.2
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
    
    func fetchPokemon() {
        let api = PokemonAPI()
        api.pokemonService.fetchPokemonSpecies(currentPokemonIndex + 1) { result in
            switch result {
            case .success(let poke):
                if let name = poke.name {
                    pokemonName = name
                }
                if let flavorText = poke.flavorTextEntries?.first(where: { $0.language?.name == "en" })?.flavorText {
                    pokemonFlavorText = flavorText
                }
                if let genus = poke.genera?.first(where: { $0.language?.name == "en" })?.genus {
                    pokemonGenus = genus
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchPokemonTypes() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(currentPokemonIndex+1)") else {
            print("Invalid URL")
            return
        }
        
        AF.request(url)
            .validate()
            .responseDecodable(of: PokemonDetail.self) { response in
                switch response.result {
                case .success(let pokemonDetail):
                    pokemonTypes = pokemonDetail.types.map { $0.type.name }
                case .failure(let error):
                    print("Error fetching Pokemon types:", error)
                }
            }
    }
    
    //TEMPORARY FIX FOR FLAVOR TEXT TO MAKE FORMAT UNIFORM
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
                    let englishSpecies = fetchFlavorTextVer (from: species)
                    pokemonSpecies = englishSpecies
                case .failure(let error):
                    print("Error fetching Pokemon species:", error)
                }
            }
    }
    
    func fetchFlavorTextVer (from species: PokemonSpecies) -> PokemonSpecies {
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
    
    func prepareBackgroundColors(types: [String]) -> [Color] {
        var colors: [Color] = []
        
        if types.count == 1 {
            let type = types[0]
            if let color = PokemonTypeColorMap.colors[type] {
                colors.append(.white)
                colors.append(color.opacity(0.7))
                colors.append(.white)
            } else {
                colors.append(.black)
            }
        } else if types.count == 2 {
            let type1 = types[0]
            let type2 = types[1]
            
            if let color1 = PokemonTypeColorMap.colors[type1], let color2 = PokemonTypeColorMap.colors[type2] {
                colors.append(.white)
                colors.append(color1.opacity(0.7))
                colors.append(color2.opacity(0.7))
                colors.append(.white)
            } else {
                colors.append(.black)
                colors.append(.black)
                colors.append(.black)
            }
        }
        
        return colors
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
