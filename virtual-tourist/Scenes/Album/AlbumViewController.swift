//
//  AlbumViewController.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import UIKit

final class AlbumViewController: UIViewController {
    
    var mapImage: UIImage?
    
    @IBOutlet private weak var locationImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setLocationImage() {
        locationImageView.image = mapImage
    }
}
