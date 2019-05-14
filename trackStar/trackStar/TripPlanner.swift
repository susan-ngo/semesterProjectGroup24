//
//  TripPlanner.swift
//  trackStar
//
//  Created by Chase Lampert on 5/6/19.
//  Copyright © 2019 Group 24. All rights reserved.
//
import UIKit
import CoreLocation

class TripPlannerController: UIViewController {
    
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
}
// MARK: - CLLocationManagerDelegate
//1
extension TripPlannerController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        // 4
        locationManager.startUpdatingLocation()
        
        //5
        loadView().isMyLocationEnabled = true
        loadView().settings.myLocationButton = true
    }
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        // 7
        loadView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        // 8
        //locationManager.stopUpdatingLocation()
    }
}
