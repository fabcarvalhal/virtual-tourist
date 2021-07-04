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
    
    @IBOutlet private weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLongpressGesture()
    }
    
    @objc
    private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
    private func configureLongpressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(handleLongPressGesture(_:)))
        gesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(gesture)
    }
}

