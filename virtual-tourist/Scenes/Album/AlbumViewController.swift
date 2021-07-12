//
//  AlbumViewController.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import UIKit
import CoreLocation
import CoreData

final class AlbumViewController: UIViewController {
    
    var mapImage: UIImage?
    var selectedPlace: Place?
    @IBOutlet private weak var newAlbumButton: UIButton!
    @IBOutlet private weak var locationImageView: UIImageView!
    @IBOutlet private weak var albumCollectionView: UICollectionView! {
        didSet {
            albumCollectionView.delegate = self
            albumCollectionView.dataSource = self
        }
    }
    
    @IBOutlet private weak var  noImagesFoundLabel: UILabel!
    
    private let apiClient: FlickerAPIInterface = FlickerAPIClient()
    
    private let dataManager = CoreDataManager.shared
    private lazy var fetchResultsManager: FetchResultsManager<Photo> = {
        let manager = FetchResultsManager<Photo>()
        manager.configure(with: dataManager.viewContext,
                          delegate: self,
                          request: photosRequest)
        return manager
    }()
    
    private lazy var photosRequest: NSFetchRequest<Photo> = {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = []
        if let selectedPlace = self.selectedPlace {
            request.predicate = NSPredicate(format: "place = %@", selectedPlace)
        }
        return request
    }()
    private let maxPageNumber = 30
    private let interItemSpacing: CGFloat = 2
    private let lineSpacing: CGFloat = 4
    private let itemsPerLine: CGFloat = 3
    
    private lazy var itemSize: CGSize = {
        let itemWidth = albumCollectionView.bounds.width / itemsPerLine - interItemSpacing
        let itemHeight = itemWidth - lineSpacing
        return CGSize(width: itemWidth,
                      height: itemHeight)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationImage()
        loadAlbum()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        try? dataManager.viewContext.save()
    }
    
    private func setLocationImage() {
        locationImageView.image = mapImage
    }
    
    private func loadAlbum() {
        fetchResultsManager.performFetch()
        guard fetchResultsManager.dataSource?.fetchedObjects?.count == .zero else {
            albumCollectionView.reloadData()
            return
        }
        guard let place = selectedPlace else { return }
        getAlbumFromFlickr(location: place)
    }
    
    private func toggleEmptyState(isEmpty: Bool) {
        DispatchQueue.main.async {
            self.noImagesFoundLabel.isHidden = !isEmpty
            self.albumCollectionView.isHidden = isEmpty
        }
    }
    
    private func save(_ loadedPhotos: [SearchPhotosResponseItem],
                      context: NSManagedObjectContext) {
        loadedPhotos.map { item -> Photo in
            let photo = Photo(context: context)
            photo.id = item.id
            photo.place = selectedPlace
            photo.secret = item.secret
            photo.server = item.server
            return photo
        }.forEach {
            dataManager.viewContext.insert($0)
            downloadPhoto(for: $0)
        }
        try? context.save()
    }
    
    private func save(downloadedImageData: Data,
                      forObjectWith id: NSManagedObjectID,
                      context: NSManagedObjectContext) {
        context.perform {
            guard let photo = context.object(with: id) as? Photo else { return }
            photo.imageData = downloadedImageData
        }
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        if let selectedPlace = selectedPlace,
           let item = fetchResultsManager.dataSource?.object(at: indexPath) {
            selectedPlace.removeFromAlbum(item)
            try? dataManager.viewContext.save()
        }
    }
    
    private func getAlbumFromFlickr(location: Place) {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        toggleEmptyState(isEmpty: false)
        let randomPage = String(randomNumberGenerator.next(upperBound: UInt(maxPageNumber)))
        
        let request = SearchPhotosRequest(lat: String(location.latitude),
                                          lon: String(location.longitude),
                                          page: randomPage)
        apiClient.searchPhotos(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.newAlbumButton.isEnabled = true
                switch result {
                case .failure(let failure):
                    self.showErrorAlert(message: failure.localizedDescription, title: "Error")
                case .success(let data):
                    guard data.response.photoList.count > 0 else {
                        return self.toggleEmptyState(isEmpty: true)
                    }
                    self.save(data.response.photoList, context: self.dataManager.viewContext)
                }
            }
        }
    }
    
    private func downloadPhoto(for item: Photo) {
        apiClient.downloadPhoto(url: FlickrPhotoUrlBuilder.buildUrl(of: item)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageData):
                let context = self.dataManager.viewContext
                self.save(downloadedImageData: imageData,
                          forObjectWith: item.objectID,
                          context: context)
            default:
                break
            }
        }
    }
    
    @IBAction private func newAlbumAction() {
        guard let place = selectedPlace else { return }
        newAlbumButton.isEnabled = false
        deleteAllItems()
        getAlbumFromFlickr(location: place)
    }
    
    private func deleteAllItems() {
        if let selectedPlace = selectedPlace {
            fetchResultsManager.dataSource?.fetchedObjects?.forEach { item in
                selectedPlace.removeFromAlbum(item)
                dataManager.viewContext.processPendingChanges()
            }
            try? dataManager.viewContext.save()
        }
    }
}

extension AlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath)
        guard let albumCell = cell as? AlbumCell,
              let item = fetchResultsManager.dataSource?.object(at: indexPath)
        else { return .init() }
        if let imageData = item.imageData {
            albumCell.setImage(imageData)
        } else {
            cell.startShimmering()
        }
        return albumCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fetchResultsManager.dataSource?.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResultsManager.dataSource?.fetchedObjects?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deleteItem(at: indexPath)
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        interItemSpacing
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension AlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            albumCollectionView.reloadData()
        case .update:
            guard let indexPath = indexPath else { return }
            albumCollectionView.reloadItems(at: [indexPath])
        case .delete:
            guard let indexPath = indexPath else { return }
            albumCollectionView.deleteItems(at: [indexPath])
        default:
            break
        }
    }
}
