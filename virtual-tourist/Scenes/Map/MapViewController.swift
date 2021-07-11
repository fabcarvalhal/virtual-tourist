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
    
    private let locationDetailSegueIdentifier = "showPlaceDetails"
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
        request.sortDescriptors = []
        return request
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLongpressGesture()
        loadPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func loadPins() {
        guard let dataSource = fetchResultsManager.dataSource else { return }
        fetchResultsManager.performFetch()
        let annotations = dataSource.fetchedObjects?.map { place in
            makeAnnotation(from: place)
        }
        guard let unwrappedAnnotations = annotations else { return }
        mapView.showAnnotations(unwrappedAnnotations, animated: true)
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
    
    private func snapshotMap(coordinate: CLLocationCoordinate2D,
                             completion: @escaping (UIImage?) -> Void) {
        let options = MKMapSnapshotter.Options()
        let camera = MKMapCamera()
        camera.centerCoordinateDistance = 1000000
        camera.centerCoordinate = coordinate
        options.camera = camera
        
        let width = Double(UIScreen.main.bounds.width)
        let height = width * 0.30
        options.size = CGSize(width: width, height: height)
        
        let snapshot = MKMapSnapshotter(options: options)
        snapshot.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                return
            }

            let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                snapshot.image.draw(at: .zero)
                let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                let pinImage = pinView.image
                let point = snapshot.point(for: coordinate)
                pinImage?.draw(at: point)
            }
            completion(image)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumViewController {
            destination.mapImage = sender as? UIImage
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let currentAnnotation = view.annotation else { return }
        snapshotMap(coordinate: currentAnnotation.coordinate) { [weak self] image in
            guard let self = self, let image = image else { return }
            self.performSegue(withIdentifier: self.locationDetailSegueIdentifier, sender: image)
        }
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
