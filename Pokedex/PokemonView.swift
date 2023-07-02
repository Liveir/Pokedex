import Alamofire
import PokemonAPI
import SwiftUI

struct PokemonView: View {
    
    //Parameters
    let pokemon: [Pokemon]
    @State var currentPokemonIndex: Int
        
    //Timer variables
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
    @State private var pokemonGenus = "T"
    @State private var pokemonFlavorText = ""

    
    var body: some View {
        let pokemonIndex = currentPokemonIndex
        
        VStack {
            VStack {
                Text(pokemonName.capitalized.isEmpty ? "???" : pokemonName.capitalized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
                Text(pokemonFlavorText.capitalized.isEmpty ? "???" : pokemonFlavorText.capitalized)                        .font(.title)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 24)
                    .frame(width: 420, height: 80)
            }
            .padding(.top, -15)
        }
        .onChange(of: pokemonIndex) { _ in
            startTimer()
            fetchPokemon()

            //fetchPokemonSpecies()
        }
        .onAppear {
            startTimer()
            fetchPokemon()
            //fetchPokemonSpecies()
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
                fetchPokemon()
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
    
    func fetchPokemon() {
        let api = PokemonAPI()
        api.pokemonService.fetchPokemonSpecies(currentPokemonIndex + 1) { result in
            switch result {
            case .success(let poke):
                if let name = poke.name {
                    pokemonName = name
                }
                if let genus = poke.flavorTextEntries?.first(where: { $0.language?.name == "en" })?.flavorText {
                    pokemonGenus = genus
                }
                if let flavorText = poke.genera?.first(where: { $0.language?.name == "en" })?.genus {
                    pokemonGenus = flavorText
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
