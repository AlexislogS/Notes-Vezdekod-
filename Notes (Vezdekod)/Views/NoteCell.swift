//
//  NoteCell.swift
//  Notes (Vezdekod)
//
//  Created by Alex Yatsenko on 24.04.2021.
//

import UIKit

final class NoteCell: UITableViewCell {
  
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  
  func updateUI(with note: Note) {
    titleLabel.text = note.title
    if let imageData = note.image, let image = UIImage(data: imageData) {
      iconImageView.image = image
    } else {
      iconImageView.image = #imageLiteral(resourceName: "placeholder")
    }
  }
}
