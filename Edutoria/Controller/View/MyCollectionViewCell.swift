import UIKit
import SDWebImage

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with category: (name: String, imageUrl: String)) {
        nameLabel.text = category.name

        // Проверяем корректность URL
        guard let url = URL(string: category.imageUrl) else {
            print("Некорректный URL: \(category.imageUrl)")
            return
        }

        // Загружаем изображение
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")) { image, error, _, _ in
            if let error = error {
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
            } else {
                print("Успешно загружено изображение для \(category.name)")
            }
        }
    }

    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }

    static func identifier() -> String {
        return "MyCollectionViewCell"
    }
}
