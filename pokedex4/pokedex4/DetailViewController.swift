//
//  DetailViewController.swift
//  pokedex4
//
//  Created by Daniele Perrupane on 10/07/24.
//

import UIKit

class DetailViewController: UIViewController {

    //Contenitore per i dati dell'elemento da visualizzare
    var item: (image: UIImage, text: String)?
    
    //Elementi UI 
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    private let label: UILabel = {
       
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
        
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        //Aggiungiamo gli elementi alla UI
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                    
                    label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
                ])
        
        // Imposta i dati dell'elemento
        if let item = item {
            imageView.image = item.image
            label.text = item.text
        }
    }
    
}
