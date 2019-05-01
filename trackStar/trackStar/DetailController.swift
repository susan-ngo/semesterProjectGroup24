//
//  DetailController.swift
//  trackStar
//
//  Created by User on 4/21/19.
//  Copyright © 2019 Group 24. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var rideName = ""
    
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        if let outlet = labelOutlet {
            outlet.text = rideName
        }
        
        let query: NSFetchRequest<Location> = Location.fetchRequest()
        let predicate = NSPredicate(format: "ride.name = %@", rideName)
        let sorter = NSSortDescriptor(key: "id", ascending: true)
        query.predicate = predicate
        query.sortDescriptors = [ sorter ]
        let results = try? AppDelegate.viewContext.fetch(query)
        
        if let locs = results {
            let coords = locs.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
            
            let minLat = coords.map { $0.latitude }.min()!
            let maxLat = coords.map { $0.latitude }.max()!
            let minLong = coords.map { $0.longitude }.min()!
            let maxLong = coords.map { $0.longitude }.max()!
            
            let midLat = (minLat + maxLat) / 2
            let midLong = (minLong + maxLong) / 2
            
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: midLat, longitude: midLong), 500, 500)
            mapView.setRegion(region, animated: true)
            
            let poly = MKPolyline(coordinates: coords, count: coords.count)
            mapView.add(poly, level: .aboveLabels)
            //mapView.add(poly)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let poly = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: poly)
            renderer.lineWidth = 3
            renderer.strokeColor = .green
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
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

}
