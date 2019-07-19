//
//  AccidentsViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 7/6/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

/**
 A screen for a list of accidents
 
 Visible:
    a. when tapping the button at the
       bottom bar in the main screen.
    b. on an iPad, in a split-screen enviroment.
 
*/
class AccidentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static let storyboardId = "all acidents storyboard id"

    var dataSource = [Marker]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "logo_rectangle")!
        navigationItem.titleView = UIImageView(image: img)
        
        if splitViewController?.isCollapsed ?? true {
            // show the close button
            closeBarButton.isEnabled = true
            closeBarButton.tintColor = nil
        } else {
            // hide
            closeBarButton.isEnabled = false
            closeBarButton.tintColor = UIColor.clear
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.deselectRowIfNeeded()
    }
    
    func refreshUI() {
        tableView.reloadData()
    }
    
    /**
     Prepare for presenting another screen
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let
            dest = segue.destination as? DetailViewController,
            let cell = sender as? UITableViewCell,
            let path = tableView.indexPath(for: cell),
            let marker = dataSource.safeRetrieveElement(path.row)
        else {return}
        
        dest.detailData = marker
    }
    
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detail cell", for: indexPath) 
        
        let data = dataSource[indexPath.row]
        
        if let name = data.iconName {
            cell.imageView?.image = UIImage(named: name)
        }
        
        cell.textLabel?.text = data.title ?? ""
        cell.detailTextLabel?.text = "\(data.subtitle ?? "") \(data.created.shortDate)"
        
        
        return cell
    }
    
    
    //MARK: Actions
    
    @IBAction func ActionClose(_ sender: UIBarButtonItem) {
        let controller = self.presentingViewController ?? self.navigationController?.presentingViewController
        controller?.dismiss(animated: true) { }
    }
}
