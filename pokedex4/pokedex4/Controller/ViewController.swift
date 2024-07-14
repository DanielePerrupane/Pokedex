//
//  ViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit
import PokemonAPI

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView!
    private var dataArray: [(image: UIImage, text: String)] = []
    var pokemonDetails: [PokemonDetail] = []
    
    private var pendingRequests = 0
    
    //max 1302 fare test con 20 specie
    private var apiURL = "https://pokeapi.co/api/v2/pokemon?offset=0&limit=300"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Pokèmon"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        //Configurazione layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        //Configurazione UICollectionView
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //Registrazione della cella
        collectionView.register(CustomViewCell.self, forCellWithReuseIdentifier: "cell")
        
        view.addSubview(collectionView)
        
        //Effettua la chiamata API
        fetchUrlPokemon()
        
    }
    
    //MARK: - Pokemon Data Methods
    
    func fetchUrlPokemon() {
        
        guard let url = URL(string: apiURL) else {
            print("Errore: URL non valido")
            return
        }
        
        print("primo url: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            
            
            if let error = error {
                print("Errore nella richiesta: \(error)")
                return
            }
            
            guard let self = self, let data = data else {
                print("Errore: Nessun dato ricevuto")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(PokemonAPIResponse.self, from: data)
                let results = response.results
                
                DispatchQueue.main.async {
                    self.fetchPokemonDetails(results: results)
                }
                
            } catch {
                print("Errore durante il parsing dei dati: \(error)")
            }
        }.resume()
    }
    
    //PRE CAMBIAMENTI
    
    func fetchPokemonDetails(results: [PokemonAPIResult]) {
        let sortedResults = results.sorted { (result1, result2) -> Bool in
            guard let id1 = result1.idFromUrl, let id2 = result2.idFromUrl else {
                return false
            }
            return id1 < id2
        }
        
        for (_, result) in sortedResults.enumerated() {
            guard let url = URL(string: result.url) else {
                print("URL non valido per il Pokemon \(result.name)")
                continue
            }
            
            //id ordinati
            //print("url al dettaglio: \(url)")
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                print("url al dettaglio2: \(url)")
                
                if let error = error {
                    print("Errore durante il download dei dettagli del Pokemon \(result.name): \(error)")
                    return
                }
                
                guard let data = data else {
                    print("Errore: Nessun dato ricevuto per il Pokemon \(result.name)")
                    return
                }
                
                do {
                    let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
                    DispatchQueue.main.async {
                        // Verifica che il dettaglio scaricato corrisponda al Pokemon atteso
                        guard let currentResult = sortedResults.first(where: { $0.url == result.url }) else {
                            print("Pokemon non trovato tra i risultati ordinati per l'URL \(result.url)")
                            return
                        }
                        
                        if let currentIndex = sortedResults.firstIndex(where: { $0.url == currentResult.url }) {
                            self.pokemonDetails.append(pokemonDetail)
                            self.collectionView.reloadData()
                            print("Dettagli aggiornati per \(pokemonDetail.name)")
                        } else {
                            print("Pokemon non trovato tra i risultati ordinati per l'URL \(result.url)")
                        }
                    }
                    
                } catch {
                    print("Errore durante il parsing dei dettagli del Pokemon \(result.name): \(error)")
                }
            }.resume()
        }
    }
    
    func fetchPokemonSpeciesDetail(for speciesURL: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: speciesURL) else {
            print("Errore: URL non valido per i dettagli della specie")
            completion("N/A")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Errore nella richiesta: \(error)")
                completion("N/A")
                return
            }
            
            guard let data = data else {
                print("Errore: Nessun dato ricevuto")
                completion("N/A")
                return
            }
            do {
                let speciesDetail = try JSONDecoder().decode(PokemonSpeciesDetail.self, from: data)
                
                // Filtriamo il flavor text per lingua "en"
                if let flavorTextEntry = speciesDetail.flavorTextEntries.first(where: { $0.language.name == "en" }) {
                    completion(flavorTextEntry.flavorText)
                } else {
                    print("Flavor text in lingua 'en' non trovato")
                    completion("N/A")
                }
                
            } catch {
                print("Errore durante il parsing dei dettagli della specie: \(error)")
                completion("N/A")
            }
        }
        
        task.resume()
    }
    
    //MARK: - UICollectionView Data Source
    
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
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: width)
    }
    
    //MARK: - CollectionViewDelegate
    
    //Metodo che gestisce il tap sulla singola cella e che permette la navigazione nella DetailView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemonDetail = pokemonDetails[indexPath.item]
        let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonDetails[indexPath.item].id).png"
        
        let detailViewController = DetailViewController()
        detailViewController.configure(with: pokemonDetail)
        detailViewController.configureImage(with: imageUrl)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
}

extension PokemonAPIResult {
    var idFromUrl: Int? {
        // Esempio di estrazione dell'ID dall'URL
        guard let url = URL(string: self.url) else {
            return nil
        }
        
        // Dividi l'URL per '/' e prendi l'ultimo componente
        let components = url.pathComponents
        if let lastComponent = components.last, let id = Int(lastComponent) {
            return id
        }
        
        return nil
    }
}


