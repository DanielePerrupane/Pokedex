//
//  DetailViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class DetailViewController: UIViewController {
    
    //Contenitore per i dati dell'elemento da visualizzare
    var item: (image: UIImage, nameLabel: String, typeLabel1: String, typeLabel2: String, flavorTextLabel: String)?
    
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
        
        private var typeLabel1: UILabel = {
            let typeLabel1 = UILabel()
            typeLabel1.translatesAutoresizingMaskIntoConstraints = false
            typeLabel1.textAlignment = .center
            typeLabel1.layer.borderColor = UIColor.white.cgColor
            typeLabel1.layer.borderWidth = 1.0
            typeLabel1.layer.cornerRadius = 8
            return typeLabel1
        }()
    
        private var typeLabel2: UILabel = {
            let typeLabel2 = UILabel()
            typeLabel2.translatesAutoresizingMaskIntoConstraints = false
            typeLabel2.textAlignment = .center
            typeLabel2.layer.borderColor = UIColor.white.cgColor
            typeLabel2.layer.borderWidth = 1.0
            typeLabel2.layer.cornerRadius = 8
            return typeLabel2
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
        view.addSubview(typeLabel1)
        view.addSubview(typeLabel2)
        view.addSubview(flavorTextLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            typeLabel1.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            typeLabel1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 145),
            typeLabel1.trailingAnchor.constraint(equalTo: typeLabel2.leadingAnchor, constant: -10),
            
            typeLabel2.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            typeLabel2.leadingAnchor.constraint(equalTo: typeLabel1.trailingAnchor, constant: 10),
            typeLabel2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -145),
            
            flavorTextLabel.topAnchor.constraint(equalTo: typeLabel1.bottomAnchor, constant: 20),
            flavorTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            flavorTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // Imposta i dati dell'elemento
        if let item = item {
            imageView.image = item.image
            nameLabel.text = item.nameLabel
            typeLabel1.text = item.typeLabel1
            typeLabel2.text = item.typeLabel2
            flavorTextLabel.text = item.flavorTextLabel
            
        }
    }
    
    
    //Metodo per configurare la cella con i dettagli
    func configure(with pokemonDetail: Pokemon) {
        nameLabel.text = pokemonDetail.name.capitalized
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        if (pokemonDetail.types.count == 2) {
            typeLabel1.text = pokemonDetail.types[0].type?.name
            typeLabel2.text = pokemonDetail.types[1].type?.name
        } else {
            typeLabel1.text = pokemonDetail.types[0].type?.name
        }
        
        flavorTextLabel.text = pokemonDetail.flavorText
        
        
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
    
    
    
    
}
