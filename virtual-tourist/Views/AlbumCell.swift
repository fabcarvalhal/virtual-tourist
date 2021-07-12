//
//  AlbumCell.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 11/07/21.
//

import UIKit

final class AlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

extension AlbumCell {
    
    func setImage(_ imageData: Data) {
        OperationQueue.main.addOperation {
            if let image = UIImage(data: imageData) {
                self.imageView.image = image
                self.stopShimmering()
            }
        }
    }
}
