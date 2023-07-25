import Foundation

struct PokemonManager {
    func getPokemon() -> [Pokemon] {
        let data: PokemonPage = Bundle.main.decode(file: "pokemon.json")
        let pokemon: [Pokemon] = data.results
        
        return pokemon
    }
    
    func getPokemonDetail(id: Int, completion: @escaping (Result<PokemonDetail, Error>) -> Void) {
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(id)/"
        
        Bundle.main.fetchData(url: urlString, model: PokemonDetail.self) { data in
            completion(.success(data))
        } failure: { error in
            completion(.failure(error))
        }
    }
    
    func getPokemonSpecies(id: Int, completion: @escaping (Result<PokemonSpecies, Error>) -> Void) {
        let url = "https://pokeapi.co/api/v2/pokemon-species/\(id)/"
        
        Bundle.main.fetchData(url: url, model: PokemonSpecies.self) { data in
            completion(.success(data))
        } failure: { error in
            completion(.failure(error))
        }
    }
}
