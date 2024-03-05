 //
//  DogImageCell.swift
//  Concurrent Dogs
//
//  Created by Fernando Goulart on 3/4/24.
//

import Foundation
import UIKit

final class DogImageCell: UICollectionViewCell {

    lazy var dogImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(dogImageView)
        NSLayoutConstraint(
            item: dogImageView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        ).isActive = true

        NSLayoutConstraint(
            item: dogImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        ).isActive = true

        NSLayoutConstraint(
            item: dogImageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .width,
            multiplier: 1,
            constant: 0
        ).isActive = true

        NSLayoutConstraint(
            item: dogImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .height,
            multiplier: 1,
            constant: 0
        ).isActive = true

        guard let image: UIImage = dogImageView.image else { return }

        NSLayoutConstraint(
            item: image,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        ).isActive = true

        NSLayoutConstraint(
            item: image,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        ).isActive = true

        NSLayoutConstraint(
            item: image,
            attribute: .width,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .width,
            multiplier: 1,
            constant: 0
        ).isActive = true

        NSLayoutConstraint(
            item: image,
            attribute: .height,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .height,
            multiplier: 1,
            constant: 0
        ).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage) {
        dogImageView.contentMode = .scaleAspectFit
        dogImageView.image = image
    }
}
