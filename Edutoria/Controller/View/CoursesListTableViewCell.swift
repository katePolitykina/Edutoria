//
//  CoursesListTableViewCell.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 28.03.25.
//

import UIKit
import SDWebImage
class CoursesListTableViewCell: UITableViewCell {
    @IBOutlet var courseImageView: UIImageView!
    @IBOutlet var courseNameLabel: UILabel!
    @IBOutlet var favouriteButton: UIButton!
    
    var onFavouriteTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupFavouriteButton()
    }
    private func setupFavouriteButton() {
        favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func configure(with course: Course, isFavourite: Bool) {
        courseNameLabel.text = course.name
        courseImageView.sd_setImage(with: URL(string: course.imageURL), placeholderImage: UIImage(named: "placeholder"))
        favouriteButton.isSelected = isFavourite
    }

    static func nib() -> UINib {
        return UINib(nibName: "CoursesListTableViewCell", bundle: nil)
    }

    static func identifier() -> String {
        return "CoursesListTableViewCell"
    }
    @IBAction func favouriteBtnClicked(_ sender: UIButton) {
        sender.isSelected.toggle()
        onFavouriteTapped?()
    }
}

