struct PokemonResponse: Codable {
    let results: [PokemonResult]
}

struct PokemonResult: Codable {
    let name: String
    let url: String
    var id: Int? {
        guard let index = url.split(separator: "/").last else { return nil }
        return Int(index)
    }
}

struct Pokemon: Decodable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
}

struct PokemonSpecies: Codable {
    let name: String
    let flavorTextEntries: [FlavorTextEntry]
    let genera: [Genus]

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case flavorTextEntries = "flavor_text_entries"
        case genera = "genera"
    }
}


struct Genus: Codable {
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
    let minimumVersionId: Int?

    // Other properties...

    private enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language, version, minimumVersionId = "version_id"
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
