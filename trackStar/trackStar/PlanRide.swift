/*
 *
 */

import UIKit
//import GooglePlacePicker
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import MediaPlayer
import AVFoundation
import AVKit

/// A view controller which displays a UI for opening the Place Picker. Once a place is selected
/// it navigates to the place details screen for the selected location.
class PickAPlaceViewController: UIViewController , GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var destLocation = UITextField()
    var mapView:GMSMapView?
    var zoomSize = 15.0
    var zoomOut = UIButton()
    var zoomIn = UIButton()
    var chooseDestination = UIButton()
    
    var startMusic = UIButton()
    var musicOne = UIButton()
    var musicTwo = UIButton()
    var musicThree = UIButton()
    var player = AVAudioPlayer()
//    var zoom = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        chooseDestination = UIButton(frame: CGRect(x: screenWidth * 0.25, y: screenHeight * 0.6, width: screenWidth * 0.5, height: screenHeight * 0.05))
        chooseDestination.setTitleColor(.black, for: .normal)
        chooseDestination.setTitle("Choose Destination", for: .normal)
        chooseDestination.addTarget(self, action: #selector(setDestination(_:)), for: .touchUpInside)
        chooseDestination.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        
        zoomOut = UIButton(frame: CGRect(x: screenWidth * 0.25, y: screenHeight * 0.7, width: screenWidth * 0.5, height: screenHeight * 0.05))
        zoomOut.setTitle("Zoom Out", for: .normal)
        zoomOut.addTarget(self, action: #selector(btnZoomOut(_:)), for: .touchUpInside)
        zoomOut.setTitleColor(.black, for: .normal)
        zoomOut.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        
        zoomIn = UIButton(frame: CGRect(x: screenWidth * 0.25, y: screenHeight * 0.65, width: screenWidth * 0.5, height: screenHeight * 0.05))
        zoomIn.setTitle("Zoom In", for: .normal)
        zoomIn.addTarget(self, action: #selector(btnZoomIn(_:)), for: .touchUpInside)
        zoomIn.setTitleColor(.black, for: .normal)
        zoomIn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        
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
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else{
            locationManager.requestWhenInUseAuthorization()
        }
        let currLocation = locationManager.location?.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: currLocation!.latitude, longitude: currLocation!.longitude, zoom: Float(zoomSize))
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.6), camera: camera)
        mapView!.isMyLocationEnabled = true
        mapView!.settings.compassButton = true
        mapView!.settings.myLocationButton = true
        self.view.addSubview(mapView!)
        self.view.addSubview(destLocation)
        self.view.addSubview(zoomIn)
        self.view.addSubview(zoomOut)
        self.view.addSubview(chooseDestination)
        self.view.addSubview(musicOne)
        self.view.addSubview(musicTwo)
        self.view.addSubview(musicThree)
        self.view.addSubview(startMusic)
        createMarker(titleMarker:"Current Location",latitude: currLocation!.latitude, longitude: currLocation!.longitude)
    }
    
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
    
    @objc func btnZoomIn(_ button: UIButton) {
        zoomSize = zoomSize + 1
        mapView!.animate(toZoom: Float(zoomSize))
    }
    
    @objc func  btnZoomOut(_ button: UIButton) {
        zoomSize = zoomSize - 1
        mapView!.animate(toZoom: Float(zoomSize))
        
    }
    
    // location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    
    func createMarker(titleMarker: String,latitude: CLLocationDegrees,longitude:CLLocationDegrees ){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.map = mapView!
    }
    
    @objc func setDestination(_ button: UIButton) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    func drawPath(startLocation: CLLocation, endLocation: GMSPlace){
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=bicycling&key=AIzaSyAfOpgD1d6CTMZedq8mY9bQUQYznI9yVDs"
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)
            print(response.response as Any)
            print(response.data as Any)
            print(response.result as Any)
            
            let json = try? JSON( data: response.data!)
            let routes = json?["routes"].arrayValue
            
            for route in routes! {
                let routeOverViewPolyline = route["overview_polyline"].dictionary
                let points = routeOverViewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor =  .blue
                polyline.strokeWidth = 4
                polyline.map = self.mapView!
            }

        }
    }
}

extension PickAPlaceViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        //textField.text = place.name
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
        createMarker(titleMarker: "destination", latitude: place.coordinate.latitude, longitude: place.coordinate.latitude)
        drawPath(startLocation: locationManager.location!, endLocation: place)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
}
