//
//  ViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {

    private var collectionView: UICollectionView!
    var pokemonDetails: [PokemonDetail] = []
    private var offset = 0
    private let limit = 20
    private var isLoading = false
    // Limite massimo di Pokemon da caricare
    private let maxPokemon = 300
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
            // Evita richieste multiple contemporaneamente
            guard !isLoading else { return }
            // Evita di superare il limite massimo
            guard offset < maxPokemon else { return }
            // Imposta isLoading a true per indicare che una richiesta è in corso
            isLoading = true
            
            // Costruisce l'URL con offset e limit
            let urlString = "\(apiURL)?offset=\(offset)&limit=\(limit)"
            
            // Verifica che l'URL sia valido
            guard let url = URL(string: urlString) else {
                print("Errore: URL non valido")
                // Ripristina isLoading in caso di errore
                isLoading = false
                return
            }
            
            // Crea una task per recuperare i dati dall'API
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                // Verifica che self esista ancora
                guard let self = self else { return }
                
                // Gestisce gli errori della richiesta
                if let error = error {
                    print("Errore nella richiesta: \(error)")
                    // Ripristina isLoading in caso di errore
                    self.isLoading = false
                    return
                }
                
                // Verifica che i dati siano stati ricevuti
                guard let data = data else {
                    print("Errore: Nessun dato ricevuto")
                    // Ripristina isLoading in caso di errore
                    self.isLoading = false
                    return
                }
                
                do {
                    // Decodifica la risposta JSON nei risultati dell'API
                    let response = try JSONDecoder().decode(PokemonAPIResponse.self, from: data)
                    let results = response.results
                    
                    // Aggiorna l'interfaccia utente sulla main thread
                    DispatchQueue.main.async {
                        self.fetchPokemonDetails(results: results)
                    }
                } catch {
                    // Gestisce gli errori di decodifica
                    print("Errore durante il parsing dei dati: \(error)")
                    // Ripristina isLoading in caso di errore
                    self.isLoading = false
                }
            }
            // Avvia la task
            task.resume()
        }
    
    func fetchPokemonDetails(results: [PokemonAPIResult]) {
            // Ordina i risultati per ID estratti dall'URL
            let sortedResults = results.sorted { (result1, result2) -> Bool in
                guard let id1 = result1.idFromUrl, let id2 = result2.idFromUrl else {
                    return false
                }
                return id1 < id2
            }
            
            // Itera attraverso ogni risultato ordinato
            for result in sortedResults {
                // Verifica che l'URL del dettaglio sia valido
                guard let url = URL(string: result.url) else {
                    print("URL non valido per il Pokemon \(result.name)")
                    continue
                }
                
                // Crea una task per recuperare i dettagli del Pokemon
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    // Verifica che self esista ancora
                    guard let self = self else { return }
                    
                    // Gestisce gli errori di download
                    if let error = error {
                        print("Errore durante il download dei dettagli del Pokemon \(result.name): \(error)")
                        return
                    }
                    
                    // Verifica che i dati siano stati ricevuti
                    guard let data = data else {
                        print("Errore: Nessun dato ricevuto per il Pokemon \(result.name)")
                        return
                    }
                    
                    do {
                        // Decodifica i dati JSON nei dettagli del Pokemon
                        let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
                        
                        // Aggiungi il dettaglio del Pokemon all'array e ordina l'array pokemonDetails per ID
                        DispatchQueue.main.async {
                            self.pokemonDetails.append(pokemonDetail)
                            
                            // Ordina l'array pokemonDetails per ID
                            self.pokemonDetails.sort { $0.id < $1.id }
                            
                            // Stampa l'array pokemonDetails aggiornato dopo l'inserimento e l'ordinamento
                            print("PokemonDetails aggiornato: \(self.pokemonDetails.map { $0.id })")
                            
                            // Ricarica la collectionView per aggiornare la UI
                            self.collectionView.reloadData()
                        }
                        
                    } catch {
                        // Gestisce gli errori di parsing
                        print("Errore durante il parsing dei dettagli del Pokemon \(result.name): \(error)")
                    }
                }.resume() // Avvia la task
            }
            
            // Incrementa l'offset e imposta isLoading su false dopo aver processato tutti i risultati
            self.offset += self.limit
            self.isLoading = false
        }
    
    // MARK: - UICollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            // Recupera una cella riutilizzabile dalla collectionView usando l'identificatore "cell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomViewCell
            
            // Ottieni il dettaglio del Pokémon corrispondente all'indice corrente
            let pokemonDetail = pokemonDetails[indexPath.item]
            
            // Ottieni l'URL dell'immagine ufficiale del Pokémon
            let imageUrlString = pokemonDetail.sprites.other.officialArtwork.frontDefault
            
            // Capitalizza il nome del Pokémon per una migliore visualizzazione
            let name = pokemonDetail.name.capitalized
            
            // Configura la cella con l'URL dell'immagine e il nome del Pokémon
            cell.configure(with: imageUrlString, name: name)
            
            // Restituisci la cella configurata
            return cell
        }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: width)
    }
    
    // MARK: - CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ottieni il dettaglio del Pokémon corrispondente all'indice selezionato
        let pokemonDetail = pokemonDetails[indexPath.item]
        
        // Costruisci l'URL dell'immagine del Pokémon
        let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonDetails[indexPath.item].id).png"
        // Crea un'istanza del DetailViewController
        let detailViewController = DetailViewController()
        
        // Configura il DetailViewController con i dettagli del Pokémon
        detailViewController.configure(with: pokemonDetail)
        
        // Configura il DetailViewController con l'URL dell'immagine del Pokémon
        detailViewController.configureImage(with: imageUrl)
        
        // Effettua una push del DetailViewController nel navigation stack per visualizzarlo
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Altezza totale del contenuto della scrollView
            let contentHeight = scrollView.contentSize.height
            
            // Altezza visibile della scrollView
            let scrollViewHeight = scrollView.bounds.height
            
            // Soglia di offset per il caricamento dei nuovi dati
            let scrollOffsetThreshold = contentHeight - scrollViewHeight
            
            // Verifica se l'utente ha scrollato oltre la soglia e sta ancora trascinando
            if scrollView.contentOffset.y > scrollOffsetThreshold && scrollView.isDragging {
                // Richiama il metodo per caricare altri Pokémon
                fetchUrlPokemon()
            }
        }
}

extension PokemonAPIResult {
    // Calcola l'ID del Pokémon dall'URL
    var idFromUrl: Int? {
        // Crea un oggetto URL dalla stringa dell'URL del Pokémon
        guard let url = URL(string: self.url) else {
            // Restituisce nil se l'URL non è valido
            return nil
        }
        
        // Ottiene i componenti del percorso dell'URL
        let components = url.pathComponents
        
        // Verifica se l'ultimo componente del percorso può essere convertito in un intero (ID)
        if let lastComponent = components.last, let id = Int(lastComponent) {
            // Restituisce l'ID se la conversione ha successo
            return id
        }
        
        // Restituisce nil se l'ultimo componente non può essere convertito in un intero
        return nil
    }
}


