//
//  AlbumViewController.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import UIKit
import CoreLocation

final class AlbumViewController: UIViewController {
    
    var mapImage: UIImage?
    var selectedPlace: Place?
    
    @IBOutlet private weak var locationImageView: UIImageView!
    @IBOutlet private weak var albumCollectionView: UICollectionView! {
        didSet {
            albumCollectionView.backgroundView = noImagesFoundLabel
        }
    }
    
    @IBOutlet private weak var  noImagesFoundLabel: UILabel!
    
    private let apiClient: FlickerAPIInterface = FlickerAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationImage()
        loadAlbum()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setLocationImage() {
        locationImageView.image = mapImage
    }
    
    func loadAlbum() {
        guard let location = selectedPlace else { return }
        var randomNumberGenerator = SystemRandomNumberGenerator()
        toggleEmptyState(isEmpty: false)
        let randomPage = String(randomNumberGenerator.next(upperBound: UInt(30)))
        
        let request = SearchPhotosRequest(lat: String(location.latitude),
                                          lon: String(location.longitude),
                                          page: randomPage)
        apiClient.searchPhotos(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let failure):
                print(failure)
            case .success(let data):
                guard data.response.photoList.count > 0 else {
                    return self.toggleEmptyState(isEmpty: true)
                }
            }
        }
    }
    
    private func toggleEmptyState(isEmpty: Bool) {
        DispatchQueue.main.async {
            self.noImagesFoundLabel.isHidden = !isEmpty
            self.albumCollectionView.isHidden = isEmpty
        }
    }
    
    func save() {

    }
}
