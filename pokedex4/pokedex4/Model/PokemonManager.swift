//
//  Pokemon.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 12/07/24.
//

struct PokemonAPIResponse: Codable {
    let results: [PokemonAPIResult]
}

struct PokemonAPIResult: Codable {
    var name: String
    var url: String
    
}

struct PokemonDetail: Codable {
    var id: Int
    var name: String
    var sprites: Sprites
    var types: [TypeEntry]
    var species: Species
    
    struct Sprites: Codable {
        var other: Other
        
        struct Other: Codable {
            var officialArtwork: OfficialArtwork
            
            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }
            
            struct OfficialArtwork: Codable {
                var frontDefault: String
                
                enum CodingKeys: String, CodingKey {
                    case frontDefault = "front_default"
                }
            }
        }
    }
    
    struct TypeEntry: Codable {
        var type: PokemonType
    }
    
    struct PokemonType: Codable {
        var name: String
    }
    
    struct Species: Codable {
        var url: String
    }
}

struct PokemonSpeciesDetail: Codable {
    var flavorTextEntries: [FlavorTextEntry]
    
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
    }
    
    struct FlavorTextEntry: Codable {
        var flavorText: String
        var language: Language
        
        enum CodingKeys: String, CodingKey {
            case flavorText = "flavor_text"
            case language
        }
        
        struct Language: Codable {
            var name: String
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            flavorText = try container.decode(String.self, forKey: .flavorText)
            language = try container.decodeIfPresent(Language.self, forKey: .language) ?? Language(name: "en")
        }
    }
}

