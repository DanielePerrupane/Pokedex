//
//  ViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class PokemonViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var pokemonDetails: [Pokemon] = []
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pokèmon"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        // Configura la UICollectionView
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CustomViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(collectionView)
        
        // Fetch dei dati dei Pokémon
        fetchAndPopulatePokemonData(ids: Array(1...151)) { [weak self] result in
            switch result {
            case .success(let pokemons):
                self?.pokemonDetails = pokemons
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("Errore: \(error)")
            }
        }
    }
    
    // MARK: - UICollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomViewCell
        
        let pokemonDetail = pokemonDetails[indexPath.item]
        let imageUrlString = pokemonDetail.sprites.other.officialArtwork.frontDefault
        let name = pokemonDetail.name.capitalized
        
        cell.configure(with: imageUrlString, name: name)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsPerRow: CGFloat = 2
        let padding: CGFloat = 10
        let collectionViewWidth = collectionView.frame.width
        let totalPadding = (numberOfCellsPerRow + 1) * padding
        let cellWidth = (collectionViewWidth - totalPadding) / numberOfCellsPerRow
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // MARK: - CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemonDetail = pokemonDetails[indexPath.item]
        let detailViewController = DetailViewController()
        
        detailViewController.configure(with: pokemonDetail)
        detailViewController.configureImage(with: pokemonDetail.sprites.other.officialArtwork.frontDefault)
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // MARK: - Fetching Data
    
    func fetchAndPopulatePokemonData(ids: [Int], completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var pokemonResults: [Int: Pokemon] = [:]
        var fetchError: Error?
        
        for id in ids {
            dispatchGroup.enter()
            fetchCompletePokemonData(id: id) { result in
                switch result {
                case .success(let pokemon):
                    pokemonResults[id] = pokemon
                case .failure(let error):
                    fetchError = error
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                let sortedPokemons = ids.compactMap { pokemonResults[$0] }
                completion(.success(sortedPokemons))
            }
        }
    }
    
    func fetchCompletePokemonData(id: Int, completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var fetchedName: String?
        var fetchedSprites: Sprites?
        var fetchedTypes: [TypeSlot] = []
        var fetchedFlavorText: String?
        var fetchError: Error?
        
        dispatchGroup.enter()
        fetchPokemonImagesAndTypes(id: id) { result in
            switch result {
            case .success(let pokemonResponse):
                fetchedSprites = pokemonResponse.sprites
                fetchedTypes = pokemonResponse.types
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchPokemonNameAndFlavorText(id: id) { result in
            switch result {
            case .success(let pokemonSpeciesResponse):
                fetchedName = pokemonSpeciesResponse.name
                if let flavorTextEntry = pokemonSpeciesResponse.flavor_text_entries.first(where: { $0.language.name == "en" }) {
                    fetchedFlavorText = flavorTextEntry.flavor_text.replacingOccurrences(of: "\n", with: " ")
                }
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else if let name = fetchedName, let sprites = fetchedSprites, let flavorText = fetchedFlavorText {
                let pokemon = Pokemon(id: id, name: name, sprites: sprites, types: fetchedTypes, flavorText: flavorText)
                completion(.success(pokemon))
            } else {
                completion(.failure(NSError(domain: "Incomplete data", code: 3, userInfo: nil)))
            }
        }
    }
    
    func fetchPokemonImagesAndTypes(id: Int, completion: @escaping (Result<PokemonResponse, Error>) -> Void) {
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(id)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 2, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let pokemonResponse = try decoder.decode(PokemonResponse.self, from: data)
                completion(.success(pokemonResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchPokemonNameAndFlavorText(id: Int, completion: @escaping (Result<PokemonSpeciesResponse, Error>) -> Void) {
        let urlString = "https://pokeapi.co/api/v2/pokemon-species/\(id)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 2, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let pokemonSpeciesResponse = try decoder.decode(PokemonSpeciesResponse.self, from: data)
                completion(.success(pokemonSpeciesResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}




