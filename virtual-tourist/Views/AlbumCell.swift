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

extension UIView {
    
    var gradientColorOne: CGColor { UIColor(white: 0.85, alpha: 1.0).cgColor }
    var gradientColorTwo: CGColor { UIColor(white: 0.95, alpha: 1.0).cgColor }
    
    func createGradientLayer() -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        return gradientLayer
    }
    
    func createAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }
    
    func startShimmering() {
        
        let gradientLayer = createGradientLayer()
        let animation = createAnimation()
    
        gradientLayer.add(animation, forKey: animation.keyPath)
        layer.addSublayer(gradientLayer)
        
    }
    
    func stopShimmering() {
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }
    
}

