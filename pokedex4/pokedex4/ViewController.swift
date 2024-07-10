//
//  ViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView!
    private var data: [(image: UIImage, text: String)] = []
    private var currentPage = 0
    private var isLoading = false
    private var itemsPerPage = 20
    
    // Dati di esempio
        private let allData: [(image: UIImage, text: String)] = [
            (image: UIImage(named: "charizard")!, text: "Charizard"),
            (image: UIImage(named: "charizard")!, text: "Item 2"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 5"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4"),
            (image: UIImage(named: "charizard")!, text: "Item 3"),
            (image: UIImage(named: "charizard")!, text: "Item 4")
            // Aggiungi più elementi qui
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
        
        //
        loadMoreData()
        
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
    
    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            loadMoreData()
        }
    }
    
}
