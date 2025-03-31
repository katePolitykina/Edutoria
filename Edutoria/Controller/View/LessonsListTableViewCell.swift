//
//  LessonsListTableViewCell.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 30.03.25.
//

import UIKit

class LessonsListTableViewCell: UITableViewCell {
    @IBOutlet weak var lessonIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with lesson :Lesson) {
        titleLabel.text = lesson.name
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.text = lesson.topics.joined(separator: "\n")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    static func nib() -> UINib {
        return UINib(nibName: "LessonsListTableViewCell", bundle: nil)
    }

    static func identifier() -> String {
        return "LessonsListTableViewCell"
    }
    
}
