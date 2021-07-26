//
//  PhotoCell.swift
//  VirtualTourism
//
//  Created by Luthfi Abdurrahim on 26/07/21.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.contentMode = .scaleAspectFit
        imageView.image = nil
        imageView.kf.indicatorType = .activity
    }
}
