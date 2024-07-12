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
    private var data: [(image: UIImage, text: String)] = []
    private var tempData: [(image: UIImage?, text: String)] = []
    private var imageCache: [String: UIImage] = [:]
    
    private var pendingRequests = 0
    
    
    //max 1302 fare test con 20 specie
    private var apiURL = "https://pokeapi.co/api/v2/pokemon?offset=0&limit=200"
    
    //var pokemons: [Pokemon] = []
    
    private var currentPage = 0
    private var isLoading = false
    private var itemsPerPage = 20
    
    // Dati di esempio
    private let allData: [(image: UIImage, text: String)] = [
        
        (image: UIImage(named: "charizard")!, text: "Charizard"),
        (image: UIImage(named: "charizard")!, text: "Item 2"),
        (image: UIImage(named: "charizard")!, text: "Item 3")
        
    ]
    
    
    
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
        
        
        //loadMoreData()
        //Effettua la chiamata API
        fetchData()
        
    }
    
    //MARK: - Pokemon Data Methods
    
    private func fetchData() {
        guard let url = URL(string: apiURL) else {
            print("Errore: URL non valido")
            return
        }
        
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
                // Debug: visualizza i dati ricevuti
                print("Dati ricevuti: \(String(data: data, encoding: .utf8) ?? "Nessun dato")")
                
                let response = try JSONDecoder().decode(PokemonAPIResponse.self, from: data)
                let results = response.results
                
                self.pendingRequests = results.count
                self.tempData = results.map {(image: nil, text: $0.name)}
                
                for (index, pokemon) in results.enumerated() {
                    self.fetchPokemonDetails(for: pokemon, at: index)
                }
                
            } catch {
                print("Errore durante il parsing dei dati: \(error)")
            }
        }
        
        task.resume()
    }
    
    private func fetchPokemonDetails(for pokemon: PokemonAPIResult,at index: Int) {
//    https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(idString).png
//    https://img.pokemondb.net/artwork/\(pokemon.name).jpg
        
        //Estrai id pokemon dall'url
        guard let id = pokemon.id else {
            print("Errore: ID non valido per il pokemon \(pokemon.name)")
            return
        }
        
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        print("URL immagine per \(pokemon.name): \(imageUrlString)")
        
        if let cachedImage = imageCache[imageUrlString] {
            
            DispatchQueue.main.async {
                self.tempData[index].image = cachedImage
                self.pendingRequests -= 1
                if self.pendingRequests == 0 {
                    self.data = self.tempData.compactMap { item in
                        guard let image = item.image else { return nil }
                        return (image, item.text)
                    }
                    self.collectionView.reloadData()
                }
            }
            return
        }
        
        guard let imageUrl = URL(string: imageUrlString) else {
            print("Errore URL immagine non valido per il pokemon \(pokemon.name)")
            return
        }
        
        let imageDataTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] imageData, _ , imageError in
            if let imageError = imageError {
                
                print("Errore durante il download dell'immagine: \(imageError)")
                return
                
            }
            guard let self = self, let imageData = imageData, let image = UIImage(data: imageData) else {
                
                print("Errore: Immagine non valida per il pokemon \(pokemon.name)")
                
                return
                
            }
            
            DispatchQueue.main.async {
                self.imageCache[imageUrlString] = image //Aggiungi l'immagine alla cache
                self.tempData[index].image = image
                self.pendingRequests -= 1
                if self.pendingRequests == 0 {
                    self.data = self.tempData.compactMap { item in
                        guard let image = item.image else { return nil }
                        return (image, item.text)
                    }
                    self.collectionView.reloadData()
                }
            }
        }
        imageDataTask.resume()
    }
    
    
    
    
    
    //MARK: - Data Loading
    /*
     Il metodo loadMoreData() è progettato per caricare ulteriori dati quando l’utente scorre verso il basso nella UICollectionView. Questo metodo implementa una forma di paginazione che carica un set di elementi alla volta
     */
    
    private func loadMoreData() {
        /*
         Questo controllo garantisce che il metodo non venga eseguito se un caricamento è già in corso. Se isLoading è true, il metodo restituisce immediatamente e non fa nulla.
         */
        guard !isLoading else { return }
        
        //Imposta isLoading su true per indicare che un’operazione di caricamento è in corso.
        isLoading = true
        
        //Utilizza una coda globale per eseguire un blocco di codice dopo un ritardo di 1 secondo
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in //evita perdite di memoria
            guard let self = self else { return }
            //Calcola l’indice iniziale dei dati da caricare per la pagina corrente.
            let startIndex = self.currentPage * self.itemsPerPage
            
            //Calcola l’indice finale dei dati da caricare, assicurandosi che non superi il numero totale di elementi disponibili in allData.
            let endIndex = min(startIndex + self.itemsPerPage, self.allData.count)
            
            //Controlla se ci sono nuovi dati
            if startIndex < endIndex {
                let newData = Array(self.allData[startIndex..<endIndex])
                self.data.append(contentsOf: newData)
                //Incrementa il numero della pagina corrente, preparandosi per il successivo caricamento.
                self.currentPage += 1
            }
            
            //Aggiornamento della collectionView
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    //MARK: - UICollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Verifica che il numero di elementi nel dataset sia corretto
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomViewCell
        
        let item = data[indexPath.item]
        cell.configure(with: item.image, text: item.text)
        
        
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
        let selectedItem = data[indexPath.item]
        
        print("Hai selezionato: \(selectedItem.text)")
        let detailViewController = DetailViewController()
        //passiamo l'elemento selezionato alla prossima view
        detailViewController.item = selectedItem
        navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    
    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            //loadMoreData()
            fetchData()
        }
    }
    
}


