import SwiftUI
import Foundation

struct PokemonPage: Codable {
    let count: Int
    let next: String
    let results: [Pokemon]
}

//from local JSON file "pokemon.json"
struct Pokemon: Codable, Identifiable, Equatable {
    let id = UUID()
    let name: String
    let url: String
    var index: Int
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        // Set a default index value here or decode it from the data, depending on your needs
        index = 0 // Use a default value, replace it as necessary
    }
}

//from URL: https://pokeapi.co/api/v2/pokemon/(id)
struct PokemonDetail: Codable {
    let id: Int
    let height: Int
    let weight: Int
    
    let stats: [Stats]
    let types: [Types]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case height
        case weight
        case stats = "stats"
        case types = "types"
    }
}

struct Stats: Codable {
    let base_stat: Int
    let stat: Stat

    private enum CodingKeys: String, CodingKey {
        case base_stat = "base_stat"
        case stat = "stat"
    }
}

struct Stat: Codable {
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}

struct Types: Codable {
    let slot: Int
    let type: Typing
    
    private enum CodingKeys: String, CodingKey {
        case slot = "slot"
        case type = "type"
    }
}

struct Typing: Codable {
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}

struct PokemonTypeColorMap {
    static let colors: [String: Color] = [
        "normal": Color(red: 168/255, green: 168/255, blue: 120/255),
        "fire": Color(red: 240/255, green: 128/255, blue: 48/255),
        "water": Color(red: 104/255, green: 144/255, blue: 240/255),
        "electric": Color(red: 248/255, green: 208/255, blue: 48/255),
        "grass": Color(red: 120/255, green: 200/255, blue: 80/255),
        "ice": Color(red: 152/255, green: 216/255, blue: 216/255),
        "fighting": Color(red: 192/255, green: 48/255, blue: 40/255),
        "poison": Color(red: 160/255, green: 64/255, blue: 160/255),
        "ground": Color(red: 224/255, green: 192/255, blue: 104/255),
        "flying": Color(red: 168/255, green: 144/255, blue: 240/255),
        "psychic": Color(red: 248/255, green: 88/255, blue: 136/255),
        "bug": Color(red: 168/255, green: 184/255, blue: 32/255),
        "rock": Color(red: 184/255, green: 160/255, blue: 56/255),
        "ghost": Color(red: 112/255, green: 88/255, blue: 152/255),
        "dragon": Color(red: 112/255, green: 56/255, blue: 248/255),
        "dark": Color(red: 112/255, green: 88/255, blue: 72/255),
        "steel": Color(red: 184/255, green: 184/255, blue: 208/255),
        "fairy": Color(red: 238/255, green: 153/255, blue: 172/255)
    ]
}


//from URL: https://pokeapi.co/api/v2/pokemon-species/(id)
struct PokemonSpecies: Codable {
    let name: String
    let flavorTextEntries: [FlavorTextEntry]
    let genera: [Genera]

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case flavorTextEntries = "flavor_text_entries"
        case genera = "genera"
    }
}


struct Genera: Codable {
    let genus: String
    let language: Language

    private enum CodingKeys: String, CodingKey {
        case genus = "genus"
        case language
    }
}

struct FlavorTextEntry: Codable {
    let flavorText: String
    let language: Language
    let version: Version
    
    private enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
        case version
    }
}   

struct Language: Codable {
    let name: String
    let url: String
}

struct Version: Codable {
    let name: String
    let url: String
}
