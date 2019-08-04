//
//  HistoryViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 20/03/2017.
//  Copyright © 2017 Hasadna. All rights reserved.
//

import Foundation
import RealmSwift

class HistoryViewController: UIViewController {
    static var storyboardId = "HistoryViewController"
    
    var data: Results<HistoryPosition>?
    var realm: Realm?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeBarButtonItem: UIBarButtonItem!
    
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { [weak self] in
            do {
                self?.realm = try Realm()
                self?.data = self?.realm?.objects(HistoryPosition.self)
                self?.tableView.reloadData()
            } catch {
                print(error)
            }
        }
        
    }
}

extension HistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DATA: \(String(describing: data?.count))")
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detail cell", for: indexPath)
        
        let history = data?[indexPath.row]
        
        let place = history?.locationPLacemark.flatMap(CLPlacemark.from)
        cell.textLabel?.text = String(placemark: place) ?? "Unknown Address"
        
        cell.detailTextLabel?.text = (history?.markers.count).flatMap{ "\($0) accidents" }
        
        return cell
    }
    
}

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        // get info
        guard
            let history = data?[indexPath.row],
            let loc = history.locationData.flatMap(CLLocation.from)
            else { return }
        print("showing: \(history)")
        
        // get map view
        guard
            let nav = navigationController,
            let splitVc = nav.presentingViewController as? UISplitViewController,
            let vc = splitVc.viewControllers.first as? ViewController,
            let mapView = vc.map
            else { return }
        
        
        nav.dismiss(animated: true) { [weak mapView] in
            mapView?.moveAndZoom(to: loc.coordinate)
        }
        
    }
    
}

extension String {
    init?(placemark: CLPlacemark?) {
        guard
            let myAddressDictionary = placemark?.addressDictionary,
            let myAddressLines = myAddressDictionary["FormattedAddressLines"] as? [String]
            else { return nil }
        
        self.init(myAddressLines.joined(separator: " "))
    }
}

