import UIKit
import SDWebImage

class DetailsViewController: UIViewController, UICollectionViewDelegate {
    
    var lesson = LessonDetails.empty()

    var scrollView: UIScrollView!
    var collectionView: UICollectionView!
    var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Скролл для всего контента
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        // Коллекция изображений (горизонтальный слайдер)
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
        scrollView.addSubview(collectionView)
        
        // Текстовое описание
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .black
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = lesson.description
        descriptionLabel.frame = CGRect(x: 16, y: collectionView.frame.maxY + 16, width: view.frame.width - 32, height: 100)
        scrollView.addSubview(descriptionLabel)
        
        // Автоматическое подстраивание размера текста
        descriptionLabel.sizeToFit()

        // Обновляем contentSize для scrollView
        scrollView.contentSize = CGSize(width: view.frame.width, height: collectionView.frame.height + descriptionLabel.frame.height + 32)
    }
}

// MARK: - UICollectionViewDataSource
extension DetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lesson.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        // Удаляем старые subviews, чтобы избежать дублирования
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let urlString = lesson.images[indexPath.item]
        if let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
        
        cell.contentView.addSubview(imageView)
        return cell
    }
}
