/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreLocation

let storedItemsKey = "storedItems"

class ItemsViewController: UIViewController {
    
    var firebase: FirebaseManager = FirebaseManager()
    @IBOutlet weak var tableView: UITableView!
    
    var items:[Item] = [
        Beacons.lightBlue.item,
        Beacons.green.item,
        Beacons.purple.item
    ]
    
    let locationManager = CLLocationManager()
    
    var distances: [Item: CLLocationAccuracy] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        setupView()
        loadItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let _ = UserDefaults.standard.value(forKey: "com.bt.name") else {
            // show name modal
            if let vc = storyboard?.instantiateViewController(withIdentifier: "NewUserVC") {
                present(vc, animated: true, completion: nil)
            }
            return
        }
    }
    
    func loadItems() {
        
        for item in items {
            startMonitoringItem(item)
        }
    }
    
    func setupView() {
        let rightBtn = UIBarButtonItem.init(title: "User List", style: .plain, target: self, action: #selector(loadUsersList(_:)))
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    func startMonitoringItem(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringItem(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func loadUsersList(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "UserListVC") as? UserListViewController {
            vc.firebase = firebase
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: UITableViewDataSource
extension ItemsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
        cell.item = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            stopMonitoringItem(items[indexPath.row])
            
            tableView.beginUpdates()
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

// MARK: UITableViewDelegate
extension ItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        let detailMessage = "UUID: \(item.uuid.uuidString)\nMajor: \(item.majorValue)\nMinor: \(item.minorValue)"
        let detailAlert = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .alert)
        detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(detailAlert, animated: true, completion: nil)
    }
}

// MARK: CLLocationManagerDelegate
extension ItemsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // Find the same beacons in the table.
        var indexPaths = [IndexPath]()
        for beacon in beacons {
            for row in 0..<items.count {
                let item = items[row]
                
                if item == beacon {
                    item.beacon = beacon
                    
                    distances[item] = beacon.accuracy
                    
                    indexPaths += [IndexPath(row: row, section: 0)]
                }
            }
        }
        
        if distances.count == 3 {
            let phoneCoord = trilaterateWithCenterOfGravity(beaconA: items[0].coordinates, beaconB: items[1].coordinates, beaconC: items[2].coordinates, distanceA: distances[items[0]]!, distanceB: distances[items[1]]!, distanceC: distances[items[2]]!)
            print("\(phoneCoord)")
        }
        
        // Update beacon locations of visible rows.
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let rowsToUpdate = visibleRows.filter { indexPaths.contains($0) }
            for row in rowsToUpdate {
                let cell = tableView.cellForRow(at: row) as! ItemCell
                cell.refreshLocation()
            }
        }
    }
    
    func trilaterateWithCenterOfGravity(beaconA: CGPoint, beaconB: CGPoint, beaconC: CGPoint, distanceA: Double, distanceB: Double, distanceC: Double) -> CGPoint {
        let METERS_IN_COORDINATE_UNITS_RATIO = 2.0
        
        let cogX = (beaconA.x + beaconB.x + beaconC.x) / 3
        let cogY = (beaconA.y + beaconB.y + beaconC.y) / 3
        let cog = CGPoint(x: cogX, y: cogY)
        
        var nearestBeaconPoint: CGPoint
        var shortestDistanceInMeters: Double
        
        if distanceA < distanceB && distanceA < distanceC {
            nearestBeaconPoint = beaconA
            shortestDistanceInMeters = distanceA;
        } else if distanceB < distanceC {
            nearestBeaconPoint = beaconB
            shortestDistanceInMeters = distanceB
        } else {
            nearestBeaconPoint = beaconC
            shortestDistanceInMeters = distanceC
        }
        
        //Distance between nearest beacon and COG
        let distanceSqToCog = pow(cog.x - nearestBeaconPoint.x, 2) + pow(cog.y - nearestBeaconPoint.y, 2)
        let distanceToCog = pow(distanceSqToCog, 0.5)
        
        //Convert shortest distance in meters into coordinates units.
        let shortestDistInCoordUnits = shortestDistanceInMeters * METERS_IN_COORDINATE_UNITS_RATIO
        
        // On the line between Nearest Beacon and COG find shortestDistance point apart from Nearest Beacon
        let t = shortestDistInCoordUnits/Double(distanceToCog)
        let pointsDifference = CGPoint(x: cog.x - nearestBeaconPoint.x, y: cog.y - nearestBeaconPoint.y)
        let tTimesDifference = CGPoint(x: Double(pointsDifference.x) * t, y: Double(pointsDifference.y) * t)
        
        let userLocation = CGPoint(x: nearestBeaconPoint.x + tTimesDifference.x, y: nearestBeaconPoint.y + tTimesDifference.y)
        
        return userLocation
    }
}

