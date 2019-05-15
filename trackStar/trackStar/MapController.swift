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
import MediaPlayer
import AVFoundation
import AVKit

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var id = Int64(1)
    var place: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var previousLocation: CLLocation?
    
    var startMusic = UIButton()
    var musicOne = UIButton()
    var musicTwo = UIButton()
    var musicThree = UIButton()
    var player = AVAudioPlayer()
    
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
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        startMusic = UIButton(frame: CGRect(x: screenWidth * 0.25, y: screenHeight * 0.75, width: screenWidth * 0.5, height: screenHeight * 0.05))
        startMusic.setTitle("Sample Music: ", for: .normal)
        startMusic.setTitleColor(.blue, for: .normal)
        startMusic.titleLabel?.font = UIFont(name: "Comic Sans MS", size: 16)
        
        musicOne = UIButton(frame: CGRect(x: screenWidth * 0.25, y: screenHeight * 0.8, width: screenWidth * 0.5, height: screenHeight * 0.04))
        musicOne.setTitle("\"Loud Pipes\" x Ratatat", for: .normal)
        musicOne.addTarget(self, action: #selector(playMusicOne(_:)), for: .touchUpInside)
        musicOne.setTitleColor(.black, for: .normal)
        musicOne.titleLabel?.font = UIFont(name: "Comic Sans MS", size: 12)
        musicOne.layer.cornerRadius = 5
        musicOne.layer.borderWidth = 1
        
        musicTwo = UIButton(frame: CGRect(x: screenWidth * 0.25, y: screenHeight * 0.85, width: screenWidth * 0.5, height: screenHeight * 0.04))
        musicTwo.setTitle("\"Gettysburg\" x Ratatat", for: .normal)
        musicTwo.addTarget(self, action: #selector(playMusicTwo(_:)), for: .touchUpInside)
        musicTwo.setTitleColor(.black, for: .normal)
        musicTwo.titleLabel?.font = UIFont(name: "Comic Sans MS", size: 12)
        musicTwo.layer.cornerRadius = 5
        musicTwo.layer.borderWidth = 1
        
        musicThree = UIButton(frame: CGRect(x: screenWidth * 0.25, y: screenHeight * 0.9, width: screenWidth * 0.5, height: screenHeight * 0.04))
        musicThree.setTitle("\"Montanita\" x Ratatat", for: .normal)
        musicThree.addTarget(self, action: #selector(playMusicThree(_:)), for: .touchUpInside)
        musicThree.setTitleColor(.black, for: .normal)
        musicThree.titleLabel?.font = UIFont(name: "Comic Sans MS", size: 12)
        musicThree.layer.cornerRadius = 5
        musicThree.layer.borderWidth = 1
        
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
        self.view.addSubview(musicOne)
        self.view.addSubview(musicTwo)
        self.view.addSubview(musicThree)
        self.view.addSubview(startMusic)
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
    @objc func playMusicOne(_ button: UIButton) {
        guard let path = Bundle.main.path(forResource: "Loud Pipes", ofType: "mp3") else {return}
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    @objc func playMusicTwo(_ button: UIButton) {
        guard let path = Bundle.main.path(forResource: "Ratatat - Gettysburg", ofType: "mp3") else {return}
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    @objc func playMusicThree(_ button: UIButton) {
        guard let path = Bundle.main.path(forResource: "Ratatat - Montanita", ofType: "mp3") else {return}
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
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
            
            speedLabel.text = String(format: "%.1f mph", speed)
            
            distance += distanceInMiles
            distanceLabel.text = String(format: "%.2f miles", distance)
            
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
    
    var index = 0
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
        
        // Save as .gpx file
        index = index + 1
        let name = "Ride\(index)"
        let fileName = "\(ride.name ?? name).gpx"
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! String
        let writePath = NSURL(fileURLWithPath: documents).appendingPathComponent(fileName)
        var gpxText : String = String("<?xml version=\"1.0\" encoding=\"UTF-8\"?><gpx version=\"1.1\" creator=\"trackStar\" xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:gte=\"http://www.gpstrackeditor.com/xmlschemas/General/1\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">")
        gpxText.append("<trk><trkseg><name>\(String(describing: ride.name))</name>")
        for locations in self.allPoints {
            let newLine : String = String("<trkpt lat=\"\(String(format:"%.6f", locations.coordinate.latitude))\" lon=\"\(String(format:"%.6f", locations.coordinate.longitude))\"><ele>\(locations.altitude)</ele><time>\(String(describing: locations.timestamp))</time></trkpt>")
            gpxText.append(contentsOf: newLine)
        }
        gpxText.append("</trkseg></trk></gpx>")
        do {
            try gpxText.write(to: writePath!, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [writePath!], applicationActivities: [])
            self.present(vc, animated: true, completion: nil)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        do {
            try AppDelegate.viewContext.save()
        } catch {
            print("loc save odd")
        }
        
        // Debugging
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
