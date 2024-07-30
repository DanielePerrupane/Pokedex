//
//  PokemonManager.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

struct PokemonResponse: Codable {
    let sprites: Sprites
    let types: [TypeSlot]
}

struct PokemonSpeciesResponse: Codable {
    let name: String
    let flavor_text_entries: [FlavorTextEntry]
}

struct TypeSlot: Codable {
    let slot: Int
    let type: Types?
}

struct Types: Codable {
    let name: String
    let url: String
}

struct FlavorTextEntry: Codable {
    let flavor_text: String
    let language: Language
}

struct Language: Codable {
    let name: String
}

struct Sprites: Codable {
    let other: Other
    
    struct Other: Codable {
        let officialArtwork: OfficialArtwork
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
        
        struct OfficialArtwork: Codable {
            let frontDefault: String
            
            enum CodingKeys: String, CodingKey {
                case frontDefault = "front_default"
            }
        }
    }
}

struct Pokemon {
    var id: Int
    var name: String
    var sprites: Sprites
    var types: [TypeSlot]
    var flavorText: String
}
