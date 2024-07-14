//
//  CustomViewCell.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class CustomViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        
        nameLabel = UILabel()
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        contentView.addSubview(nameLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
            
        ])
    }
    
    func configure(with imageUrlString: String, name: String) {
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
                self.nameLabel.text = name
            }
        }.resume()
    }
}
