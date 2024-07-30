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
        
        private var typeLabel1: PaddingLabel = {
            let typeLabel1 = PaddingLabel()
            typeLabel1.translatesAutoresizingMaskIntoConstraints = false
            typeLabel1.textAlignment = .center
            typeLabel1.layer.borderColor = UIColor.white.cgColor
            typeLabel1.layer.borderWidth = 1.0
            typeLabel1.layer.cornerRadius = 15
            
            return typeLabel1
        }()
    
        private var typeLabel2: PaddingLabel = {
            let typeLabel2 = PaddingLabel()
            typeLabel2.translatesAutoresizingMaskIntoConstraints = false
            typeLabel2.textAlignment = .center
            
            typeLabel2.layer.borderColor = UIColor.white.cgColor
            typeLabel2.layer.borderWidth = 1.0
            typeLabel2.layer.cornerRadius = 15
            return typeLabel2
        }()
        
        private var flavorTextLabel: UILabel = {
            let flavorTextLabel = UILabel()
            flavorTextLabel.translatesAutoresizingMaskIntoConstraints = false
            flavorTextLabel.textAlignment = .center
            flavorTextLabel.numberOfLines = 0
            flavorTextLabel.font = .systemFont(ofSize: 15)
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
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
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
            typeLabel1.text = pokemonDetail.types[0].type?.name.capitalized
            typeLabel2.text = pokemonDetail.types[1].type?.name.capitalized
            
            NSLayoutConstraint.activate([
            
                
                typeLabel1.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
                typeLabel1.trailingAnchor.constraint(equalTo: view.centerXAnchor,constant: -5),
                
                
                typeLabel2.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
                typeLabel2.leadingAnchor.constraint(equalTo: view.centerXAnchor,constant: 5),
            
            ])
            
        } else {
            
            typeLabel1.text = pokemonDetail.types[0].type?.name.capitalized
            
            NSLayoutConstraint.activate([
            
                typeLabel1.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
                typeLabel1.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                
            ])
            
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

    @IBDesignable class PaddingLabel: UILabel {
        
        @IBInspectable var topInset: CGFloat = 5.0
        @IBInspectable var bottomInset: CGFloat = 5.0
        @IBInspectable var leftInset: CGFloat = 9.0
        @IBInspectable var rightInset: CGFloat = 9.0
        
        override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
            super.drawText(in: rect.inset(by: insets))
        }
        
        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + leftInset + rightInset,
                          height: size.height + topInset + bottomInset)
        }
    }

}
