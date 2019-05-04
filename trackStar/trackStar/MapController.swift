//
//  MapController.swift
//  trackStar
//
//  Created by User on 4/17/19.
//  Copyright © 2019 Group 24. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var id = Int64(1)
    var place: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var previousLocation: CLLocation?
    
    // MARK: OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var onOffOutlet: UISwitch!
    
    // MARK: ACTIONS
    @IBAction func onOffSwitch(_ sender: UISwitch) {
        if onOffOutlet.isOn {
            startTracking()
        } else {
            locationManager.stopUpdatingLocation()
            endRide()
        }
    }
    
    @IBAction func mapTypeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .satellite
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 10)
        
        // Annotation
        if let loc = place {
            let circle = MKCircle(center: loc, radius: 10)
            mapView.add(circle)
            centerMap(loc: loc)
            
            let ann = MKPointAnnotation()
            ann.title = "Takoma Junction"
            ann.coordinate = loc
            mapView.addAnnotation(ann)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func centerMap(loc: CLLocationCoordinate2D) {
        let radius: CLLocationDistance = 300
        let region = MKCoordinateRegionMakeWithDistance(loc, radius, radius)
        mapView.setRegion(region, animated: true)
    }
    
    func startTracking() {
        let status = CLLocationManager.authorizationStatus()
        if (status == .authorizedWhenInUse || status == .authorizedAlways) && onOffOutlet.isOn {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Needed for deferred
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("Finished deferred: \(error!)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
        }
    }
    
    var distance = 0.0
    var allPoints: [CLLocation] = []
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latest = locations.last!
        if previousLocation != nil {
            let distanceInMeters = previousLocation?.distance(from: latest) ?? 0
            let distanceInMiles = distanceInMeters * 3.28 / 5280
            let duration = latest.timestamp.timeIntervalSince(previousLocation!.timestamp)
            let speed = distanceInMiles * (3600.0 / duration)
            
            distance += distanceInMiles
            distanceLabel.text = String(format: "%.2f miles", distance)
            
            speedLabel.text = String(format: "%.1f mph", speed)
            
            var coords = [previousLocation!.coordinate]
            coords += locations.map { $0.coordinate }
            mapView.add(MKPolyline(coordinates: coords, count: coords.count))
            //mapView.add(MKPolyline(coordinates: coords, count: coords.count), level: .aboveLabels)
        }
        allPoints += locations
        
        previousLocation = latest
        centerMap(loc: latest.coordinate)
    }
    
    func endRide() {
        let alert = UIAlertController(
            title: "Save Ride?",
            message: "Enter a name for your new ride.",
            preferredStyle: .alert)
        alert.addTextField(configurationHandler: {tf in tf.text = "New Ride"})
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { (action: UIAlertAction!) in
                //DispatchQueue.main.async {
                    if let name = alert.textFields?[0].text {
                        self.saveRide(name: name)
                        // Added
                        self.allPoints = []
                        self.distance = 0.0
                    }
                //}
        }))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { (action: UIAlertAction!) in
                //DispatchQueue.main.async {
                    self.allPoints = []
                //}
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // Core data
    func nextID() -> Int64 {
        let query: NSFetchRequest<Location> = Location.fetchRequest()
        let predicate = NSPredicate(format: "id = max(id)")
        query.predicate = predicate
        
        let results = try? AppDelegate.viewContext.fetch(query)
        if let locs = results, locs.count > 0 {
            let id = locs[0].id
            return id + 1
        } else {
            return 1
        }
    }
    
    func saveRide(name: String) {
        id = nextID()
        
        let ride = Ride(context: AppDelegate.viewContext)
        ride.name = name
        ride.when = Date()
        ride.distance = distance
        
        for loc in allPoints {
            let obj = Location(context: AppDelegate.viewContext)
            obj.latitude = loc.coordinate.latitude
            obj.longitude = loc.coordinate.longitude
            obj.when = loc.timestamp
            obj.ridename = name
            obj.id = id
            id += 1
            obj.ride = ride
        }
        
        do {
            try AppDelegate.viewContext.save()
        } catch {
            print("loc save odd")
        }
        
        let fetchRides: NSFetchRequest<Ride> = Ride.fetchRequest()
        let resR = try? AppDelegate.viewContext.fetch(fetchRides)
        if let rides = resR {
            print(rides)
        }
        
        let fetchLocations: NSFetchRequest<Location> = Location.fetchRequest()
        let resL = try? AppDelegate.viewContext.fetch(fetchLocations)
        if let locations = resL {
            print(locations)
        }
        
        do {
            try AppDelegate.viewContext.save()
        } catch {
            print("Error saving ride \(name)")
        }
        //allPoints = []
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil}
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let poly = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: poly)
            renderer.lineWidth = 3
            renderer.strokeColor = .red
            return renderer
        } else if let circle = overlay as? MKCircle {
            let renderer =  MKCircleRenderer(circle: circle)
            renderer.lineWidth = 3
            renderer.strokeColor = .blue
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
