//
//  RidesController.swift
//  trackStar
//
//  Created by User on 4/21/19.
//  Copyright © 2019 Group 24. All rights reserved.
//

import UIKit
import CoreData

class RidesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var rides: [String] = []
    
    @IBOutlet weak var tableViewOutlet: UITableView! {
        didSet {
            tableViewOutlet.dataSource = self
            tableViewOutlet.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let query: NSFetchRequest<Ride> = Ride.fetchRequest()
        if let results = try? AppDelegate.viewContext.fetch(query) {
            rides = results.map { $0.name! }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        cell.textLabel?.text = rides[indexPath.row]
        return cell
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
