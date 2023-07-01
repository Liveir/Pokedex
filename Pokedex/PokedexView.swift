import Alamofire
import SwiftUI

struct PokedexView: View {
    @State private var searchInput = ""
    @State private var filteredPokemon = [Pokemon]()
    @State private var pokemon = [Pokemon]()
    @State private var selectedPokemon: Pokemon? = nil

    var body: some View {
        NavigationView {
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
                Spacer()
                List(filteredPokemon) { poke in
                    NavigationLink(destination: PokemonView(pokemon: pokemon,
                                                             currentPokemonIndex: poke.id-1)) {
                        HStack {
                            Text("#\(poke.id)")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            Text(poke.name.capitalized)
                                .foregroundColor(.black)
                                .font(.body)
                            Spacer()
                            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(poke.id).png")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            } placeholder: {
                                Image("Pokeball")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.5)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onAppear {
                    fetchPokemonList()
                }
            }
            .background(Color.red)
        }
    }

    func fetchPokemonList() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1010") else {
            return
        }
        AF.request(url)
            .validate()
            .responseDecodable(of: PokemonResponse.self) { response in
                switch response.result {
                case .success(let pokemonResponse):
                    self.pokemon = pokemonResponse.results.enumerated().map { (index, result) in
                        // Extract the id from the API URL
                        let id = Int(result.url.split(separator: "/").last ?? "") ?? 0
                        return Pokemon(id: id, name: result.name)
                    }
                    self.filteredPokemon = self.pokemon
                case .failure(let error):
                    print("API request failed with error: \(error.localizedDescription)")
                }

                if let statusCode = response.response?.statusCode {
                    print("Status code: \(statusCode)")
                }
            }
    }

    func filterPokemon() {
        if searchInput.isEmpty {
            filteredPokemon = pokemon
        } else {
            filteredPokemon = pokemon.filter { $0.name.contains(searchInput.lowercased()) }
        }
    }
}
