//
//  ObjectDetailViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 31.03.25.
//


import UIKit

class DetailsViewController: UIViewController {
    
    var object: Object?

    // Создаем UICollectionView для слайдера изображений
    var collectionView: UICollectionView!
    
    // Создаем UILabel для отображения текста
    var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем фон экрана
        view.backgroundColor = .white
        
        // Настроим UICollectionView для слайдера изображений
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height / 2)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 2), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        // Настроим UILabel для текста
        descriptionLabel = UILabel()
        descriptionLabel.frame = CGRect(x: 16, y: collectionView.frame.maxY + 16, width: view.frame.width - 32, height: 100)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .black
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = object?.description
        view.addSubview(descriptionLabel)
        
        // Добавим отступы, если описание длинное
        descriptionLabel.sizeToFit()
    }
}

// MARK: - UICollectionViewDataSource
extension DetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return object?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        // Создаем UIImageView для отображения изображения
        let imageView = UIImageView(image: object?.images[indexPath.item])
        imageView.frame = cell.contentView.bounds
        imageView.contentMode = .scaleAspectFill
        cell.contentView.addSubview(imageView)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DetailsViewController: UICollectionViewDelegate {
    // Здесь можно добавить обработку выбора изображения, если нужно
}
