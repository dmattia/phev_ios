//
//  TripTableViewController.swift
//  
//
//  Created by David Mattia on 9/23/16.
//
//

import UIKit
import Firebase
import Material

class TripTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tripTableView: UITableView!
    var user_ref: FIRDatabaseReference!
    var trip_ref: FIRDatabaseReference!
    
    var trip_snapshots = [FIRDataSnapshot]()
    var indexPathClicked: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Color.blue.base
        self.tripTableView.backgroundColor = Color.blue.lighten1
        
        user_ref = FIRDatabase.database().reference().child("users")
        trip_ref = FIRDatabase.database().reference().child("trips")
        
        self.tripTableView.delegate = self
        self.tripTableView.dataSource = self
        
        trip_ref.observe(FIRDataEventType.value, with: { (snapshot) in
            self.trip_snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
            self.tripTableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trip_snapshots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "tripCell")
        print(self.trip_snapshots[indexPath.row].key)
        cell.textLabel?.text = self.trip_snapshots[indexPath.row].key
        cell.textLabel?.font = RobotoFont.regular(with: 24)
        cell.textLabel?.textColor = Color.white

        cell.backgroundColor = Color.blue.lighten2
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination_vc = segue.destination as! TripDetailViewController
        destination_vc.trip_snapshot = self.trip_snapshots[self.indexPathClicked.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPathClicked = indexPath
        performSegue(withIdentifier: "TripDetailSegue", sender: self)
    }
}
