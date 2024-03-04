//
//  DogImageCell.swift
//  Concurrent Dogs
//
//  Created by Fernando Goulart on 3/4/24.
//

import Foundation
import UIKit

final class DogImageCell: UICollectionViewCell {
    @IBOutlet weak var dogImageView: UIImageView!
    
    func setImage(_ image: UIImage) {
        dogImageView.image = image
    }
}
