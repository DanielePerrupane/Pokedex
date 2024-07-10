//
//  ViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView!
    
    // Dati di esempio
        private let data: [(image: UIImage, text: String)] = [
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
    
}
