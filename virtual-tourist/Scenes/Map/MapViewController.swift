//
//  ViewController.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 04/07/21.
//

import UIKit
import MapKit
import CoreData


// This is a flickr photo url structure
// https://live.staticflickr.com/{server}/{photo_id}_{secret}_c.jpg
class MapViewController: UIViewController {
    
    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    private let dataManager = CoreDataManager.shared
    
    private lazy var fetchResultsManager: FetchResultsManager<Place> = {
        let manager = FetchResultsManager<Place>()
        manager.configure(with: self.dataManager.viewContext,
                          delegate: self,
                          request: placesRequest)
        return manager
    }()
    
    private let placesRequest: NSFetchRequest<Place> = {
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLongpressGesture()
        loadPins()
    }
    
    private func loadPins() {
        guard let dataSource = fetchResultsManager.dataSource else { return }
        fetchResultsManager.performFetch()
        dataSource.fetchedObjects?.forEach { place in
            mapView.addAnnotation(makeAnnotation(from: place))
        }
    }
    
    private func makeAnnotation(from place: Place) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        let coordinates = CLLocationCoordinate2D(latitude: place.latitude,
                                                 longitude: place.longitude)
        annotation.coordinate = coordinates
        annotation.title = place.name
        return annotation
    }
    
    @objc
    private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        savePlace(for: coordinates)
    }
    
    private func configureLongpressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(handleLongPressGesture(_:)))
        gesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(gesture)
    }
    
    private func savePlace(for coordinates: CLLocationCoordinate2D) {
        getPlaceName(from: coordinates) { [weak self] placeName, error in
            guard let context = self?.dataManager.viewContext else  { return }
            guard error == nil else { return }
            let place = Place(context: context)
            place.latitude = coordinates.latitude
            place.longitude = coordinates.longitude
            place.name = placeName
            try? self?.dataManager.viewContext.save()
        }
    }
    
    private func getPlaceName(from coordinates: CLLocationCoordinate2D,
                              completion: @escaping (String?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude,
                                  longitude: coordinates.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placeMark, error in
            let address = self?.formatAddress(from: placeMark?.first)
            completion(address, error)
        }
    }
    
    private func formatAddress(from placeMark: CLPlacemark?) -> String? {
        
        var address : String = ""
        if let subLocality = placeMark?.subLocality {
            address = address.appending(subLocality).appending(", ")
        }
        if let throughfare = placeMark?.thoroughfare {
            address = address.appending(throughfare).appending(", ")
        }
        if let locality = placeMark?.locality {
            address = address.appending(locality).appending(", ")
        }
        if let country = placeMark?.country {
            address = address.appending(country).appending(", ")
        }
        if let postalCode = placeMark?.postalCode {
            address = address.appending(postalCode)
        }
        return address
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // TODO: Take the user to the album
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newPlace = anObject as? Place else { return }
            mapView.addAnnotation(makeAnnotation(from: newPlace))
        default:
            break
        }
    }
}
