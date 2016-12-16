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
import Charts
import RealmSwift

class TripTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tripTableView: UITableView!
    @IBOutlet weak var lineChartView: LineChartView!
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
        
        self.prepareChartData()
        self.updateChartWithData()
    }
    
    func prepareChartData() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        for _ in 1...10 {
            let chartData = ChartData()
            chartData.count = Int(arc4random_uniform(10) + 1)
            chartData.save()
        }
    }
    
    func getChartDataFromDatabase() -> Results<ChartData> {
        do {
            let realm = try Realm()
            return realm.objects(ChartData.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func updateChartWithData() {
        /***********************************
         * Create DataSet from Realm Store *
         ***********************************/
        var dataEntries: [ChartDataEntry] = []
        let chartData = getChartDataFromDatabase()
        for i in 0..<chartData.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(chartData[i].count))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Trip Scores")
        
        
        /*******************
         * Style the chart *
         *******************/
        let gradientColors = [Color.blue.base.cgColor, UIColor.clear.cgColor] // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations) // Gradient Object
        
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        chartDataSet.drawFilledEnabled = true
        chartDataSet.mode = .horizontalBezier
        chartDataSet.label = "Trip Scores"
        
        self.lineChartView.chartDescription?.text = "Recent Trip Scores"

        /*******************
         * Set chart Data  *
         *******************/
        let chartDataValues = LineChartData(dataSet: chartDataSet)
        self.lineChartView.data = chartDataValues
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
        cell.selectionStyle = .none

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
