import Alamofire
import SwiftUI

struct PokedexView: View {
    @State private var searchInput = ""
    @State private var filteredPokemon = [Pokemon]()
    @State private var pokemon = [Pokemon]()
    @State private var selectedPokemon: Pokemon? = nil
    @State private var isGridMode = false
    
    let pokemonManager = PokemonManager()

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HeaderView()
                    SearchBarView(searchInput: $searchInput, onEditingChanged: { isEditing in
                        if !isEditing {
                            filterPokemon()
                        }
                    }, onInputChange: { inputValue in
                        filterPokemon()
                    })
                    .disableAutocorrection(true)
                    HStack {
                        Spacer()
                        Button(action: {
                            isGridMode.toggle()
                        }) {
                            Image(systemName: isGridMode ? "list.bullet" : "square.grid.2x2.fill")
                                .foregroundColor(.white)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .edgesIgnoringSafeArea(.bottom)
                .background(Color.red)
                //Spacer()
                if isGridMode {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(filteredPokemon) { poke in
                                NavigationLink(destination: PokemonView(pokemon: pokemon, currentPokemonIndex: poke.index)) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.clear)
                                            .background(.thinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                        
                                        VStack(alignment: .leading) {
                                            Spacer()
                                            Text(poke.name.capitalized)
                                                .foregroundColor(.black)
                                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                                .padding(.bottom, 1)
                                            
                                            Text("#\(poke.index + 1)")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                                .padding(.horizontal, 5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.black.opacity(0.8))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(poke.index+1).png")) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 150, height: 150)
                                                    .offset(x: 35, y: 5)
                                            } placeholder: {
                                                Image("Pokeball")
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .scaleEffect(0.3)
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 150, height: 150)
                                                    .offset(x: 35, y: 5)
                                                    .foregroundColor(.gray)
                                                    .saturation(0)
                                            }
                                            Spacer()
                                        }
                                        .padding(.leading, 10)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                    }
                                }
                            }
                        }
                        .padding(10)
                    }
                } else {
                    List(filteredPokemon) { poke in
                        NavigationLink(destination: PokemonView(pokemon: pokemon, currentPokemonIndex: poke.index)) {
                            HStack {
                                Text("#\(poke.index+1)")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                                Text(poke.name.capitalized)
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                                Spacer()
                                AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(poke.index+1).png")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                } placeholder: {
                                    Image("Pokeball")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(0.3)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onAppear {
                        fetchPokemonList()
                    }
                }
            }
            .background(Color.clear)
        }
    }

    func fetchPokemonList() {
        pokemon = pokemonManager.getPokemon().enumerated().map { index, pokemon in
            var modifiedPokemon = pokemon
            modifiedPokemon.index = index
            return modifiedPokemon
        }
        filteredPokemon = pokemon
    }

    func filterPokemon() {
        if searchInput.isEmpty {
            filteredPokemon = pokemon
        } else {
            filteredPokemon = pokemon.filter { $0.name.contains(searchInput.lowercased()) }
        }
    }
}


struct PokedexView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
