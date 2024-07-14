//
//  ViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {

    private var collectionView: UICollectionView!
    private var dataArray: [(image: UIImage, text: String)] = []
    var pokemonDetails: [PokemonDetail] = []
    
    private var pendingRequests = 0
    
    private var offset = 0
    private let limit = 20
    private var isLoading = false
    
    private let maxPokemon = 300 // Limite massimo di Pokemon da caricare
    private var apiURL = "https://pokeapi.co/api/v2/pokemon"
    
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
        
        // Configurazione UICollectionView
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self  // Imposta la ViewController come delegate
        
        // Registrazione della cella
        collectionView.register(CustomViewCell.self, forCellWithReuseIdentifier: "cell")
        
        view.addSubview(collectionView)
        
        // Effettua la chiamata API per caricare i primi 20 Pokémon
        fetchUrlPokemon()
    }
    
    // MARK: - Pokemon Data Methods
    
    func fetchUrlPokemon() {
        guard !isLoading else { return } // Evita richieste multiple contemporaneamente
        guard offset < maxPokemon else { return } // Evita di superare il limite massimo
        isLoading = true
        
        let urlString = "\(apiURL)?offset=\(offset)&limit=\(limit)"
        
        guard let url = URL(string: urlString) else {
            print("Errore: URL non valido")
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Errore nella richiesta: \(error)")
                self.isLoading = false
                return
            }
            
            guard let data = data else {
                print("Errore: Nessun dato ricevuto")
                self.isLoading = false
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
                self.isLoading = false
            }
        }
        task.resume()
    }
    
    func fetchPokemonDetails(results: [PokemonAPIResult]) {
        let sortedResults = results.sorted { (result1, result2) -> Bool in
            guard let id1 = result1.idFromUrl, let id2 = result2.idFromUrl else {
                return false
            }
            return id1 < id2
        }
        
        for result in sortedResults {
            guard let url = URL(string: result.url) else {
                print("URL non valido per il Pokemon \(result.name)")
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
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
                    
                    // Aggiungi il dettaglio del Pokemon all'array
                    DispatchQueue.main.async {
                        self.pokemonDetails.append(pokemonDetail)
                        
                        // Ordina l'array pokemonDetails per ID
                        self.pokemonDetails.sort { $0.id < $1.id }
                        
                        // Stampa l'array pokemonDetails aggiornato dopo l'inserimento e l'ordinamento
                        print("PokemonDetails aggiornato: \(self.pokemonDetails.map { $0.id })")
                        
                        // Ricarica la collectionView
                        self.collectionView.reloadData()
                    }
                    
                } catch {
                    print("Errore durante il parsing dei dettagli del Pokemon \(result.name): \(error)")
                }
            }.resume()
        }
        
        // Incrementa l'offset e imposta isLoading su false
        self.offset += self.limit
        self.isLoading = false
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
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: width)
    }
    
    // MARK: - CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemonDetail = pokemonDetails[indexPath.item]
        let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonDetails[indexPath.item].id).png"
        
        let detailViewController = DetailViewController()
        detailViewController.configure(with: pokemonDetail)
        detailViewController.configureImage(with: imageUrl)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.height
        let scrollOffsetThreshold = contentHeight - scrollViewHeight
        
        if scrollView.contentOffset.y > scrollOffsetThreshold && scrollView.isDragging {
            fetchUrlPokemon()
        }
    }
}

extension PokemonAPIResult {
    var idFromUrl: Int? {
        guard let url = URL(string: self.url) else {
            return nil
        }
        
        let components = url.pathComponents
        if let lastComponent = components.last, let id = Int(lastComponent) {
            return id
        }
        
        return nil
    }
}


