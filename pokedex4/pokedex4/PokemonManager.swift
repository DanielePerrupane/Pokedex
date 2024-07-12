//
//  Pokemon.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 12/07/24.
//

import Foundation

struct PokemonManager: Decodable, Identifiable {
    let id: Int
    let name: String
    let imageUrl: String
    let description: String
    let type: String
}

// Struttura per la risposta API
struct PokemonAPIResponse: Codable {
    let results: [PokemonAPIResult]
}

struct PokemonAPIResult: Codable {
    let name: String
    let url: String
    
    var id: String? {
        return url.split(separator: "/").last.map(String.init)
    }
}

struct PokemonDetails: Codable {
    let id: Int
    let name: String
}
