//
//  DetailViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class DetailViewController: UIViewController {
    
    //Contenitore per i dati dell'elemento da visualizzare
    var item: (image: UIImage, nameLabel: String, typeLabel: String, flavorTextLabel: String)?
    
    //Elementi UI
    private var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private var nameLabel: UILabel = {
            let nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.textAlignment = .center
            nameLabel.numberOfLines = 0
            return nameLabel
        }()
        
        private var typeLabel: UILabel = {
            let typeLabel = UILabel()
            typeLabel.translatesAutoresizingMaskIntoConstraints = false
            typeLabel.textAlignment = .center
            return typeLabel
        }()
        
        private var flavorTextLabel: UILabel = {
            let flavorTextLabel = UILabel()
            flavorTextLabel.translatesAutoresizingMaskIntoConstraints = false
            flavorTextLabel.textAlignment = .center
            flavorTextLabel.numberOfLines = 0
            return flavorTextLabel
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        //Aggiungiamo gli elementi alla UI
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(typeLabel)
        view.addSubview(flavorTextLabel)
        
        NSLayoutConstraint.activate([
                 imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                 imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 imageView.widthAnchor.constraint(equalToConstant: 200),
                 imageView.heightAnchor.constraint(equalToConstant: 200),
                 
                 nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                 nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                 nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                 
                 typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
                 typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                 typeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                 
                 flavorTextLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 20),
                 flavorTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                 flavorTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             ])
        
        // Imposta i dati dell'elemento
        if let item = item {
            imageView.image = item.image
            nameLabel.text = item.nameLabel
            typeLabel.text = item.typeLabel
            flavorTextLabel.text = item.flavorTextLabel
            
        }
    }
    
    
    //Metodo per configurare la cella con i dettagli
    func configure(with pokemonDetail: PokemonDetail) {
        nameLabel.text = pokemonDetail.name.capitalized
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        typeLabel.text = pokemonDetail.types.map { $0.type.name }.joined(separator: ", ").capitalized
        fetchFlavorText(for: pokemonDetail.species.url)
          
        }
    
    //Metodo per configurare l'immagine della cella di dettaglio
    func configureImage(with imageUrlString: String) {
        guard let imageUrl = URL(string: imageUrlString) else {
            print("URL dell'immagine non valido: \(imageUrlString)")
            return
        }
        
        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Errore durante il download dell'immagine: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Impossibile convertire i dati in immagine")
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }
    
    //Metodo per fetchare il flavorText e selezionare il corrispondente al campo language = "en"
    func fetchFlavorText(for speciesUrl: String) {
            guard let url = URL(string: speciesUrl) else { return }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self, let data = data else { return }
                
                if let error = error {
                    print("Error fetching flavor text: \(error)")
                    return
                }
                
                do {
                    let speciesDetail = try JSONDecoder().decode(PokemonSpeciesDetail.self, from: data)
                    
                    if let flavorTextEntry = speciesDetail.flavorTextEntries.first(where: { $0.language.name == "en" }) {
                        DispatchQueue.main.async {
                            self.flavorTextLabel.text = flavorTextEntry.flavorText
                        }
                    }
                } catch {
                    print("Error decoding species detail: \(error)")
                }
            }.resume()
        }
    
}
