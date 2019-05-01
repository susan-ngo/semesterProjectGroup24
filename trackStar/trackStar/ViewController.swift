//
//  ViewController.swift
//  trackStar
//
//  Created by User on 4/16/19.
//  Copyright © 2019 Group 24. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let place = CLLocationCoordinate2D(latitude: 38.9779, longitude: -77.0075)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MapSegue" {
            guard let mapController = segue.destination as? MapController else {return}
            mapController.place = place
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

