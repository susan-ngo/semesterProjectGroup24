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
        let sorter = NSSortDescriptor(key: "name", ascending: true)
        query.sortDescriptors = [ sorter ]
        let res = try? AppDelegate.viewContext.fetch(query)
        
        let datePrint = DateFormatter()
        datePrint.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        if let results = res {
            for ride in results {
                if let name = ride.name {
                    rides.append(name)
                }
            }
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
    
    // Delete rows
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [UIContextualAction(
            style: .destructive,
            title: "Delete",
            handler: { (action, view, completionHandler) in
                let row = indexPath.row
                self.rides.remove(at: row)
                completionHandler(true)
                tableView.reloadData()
            })
        ])
        return config
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EntireRide" {
            if let rideC = segue.destination as? DetailController, let cell = sender as? UITableViewCell {
                rideC.rideName = (cell.textLabel?.text)!
            }
        }
    }

}
