//
//  ViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 2/16/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

private func newHud() -> JGProgressHUD {
    let hud = JGProgressHUD(style: .light)
    hud?.animation = JGProgressHUDFadeZoomAnimation() as JGProgressHUDFadeZoomAnimation
    hud?.interactionType = JGProgressHUDInteractionType.blockNoTouches
    return hud!
}

/**
 Main app screen
  Main view is the map, on the botton a bar with
  "accidents list" button and "filter" button.
*/
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    enum DateSelectionType { case none, start, end }

    @IBOutlet weak var btnFilter: UIBarButtonItem!
    @IBOutlet weak var btnAccidents: UIBarButtonItem!
    @IBOutlet weak var btnInfo: UIButton!
    
    
    @IBOutlet weak var detailLabel: UILabel! {
        didSet{
            detailLabel?.backgroundColor = UIColor.white
            detailLabel?.layer.borderColor = UIColor.gray.cgColor
            detailLabel?.layer.borderWidth = 0.5
            detailLabel?.layer.cornerRadius = 4
            detailLabel?.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var map: OCMapView!
    
    
    /// Holds the filter params for the current results
    var filter = Filter()
    
    /// Last area shown on the map
    var lastRegion = MKCoordinateRegion(MKMapRect.null)
    
    /// Location Services
    let locationManager = CLLocationManager()
    
    /// Handling the network calls
    let network = Network()
    
    /// Progress hud
    let hud = newHud()
    
    /// Wether we currently get info from server
    var gettingInfo = false
    
    /// flag for determine the first time the view layed out
    var initialLayout = true
    
    /// flag for handling auto-moving the map when app launches
    var shouldJumpToStartLocation = true
    
    var isTrackingHistory: Bool {
        get{ return UserDefaults.standard.bool(forKey: "isTrackingHistory") }
        set{ UserDefaults.standard.set(newValue, forKey: "isTrackingHistory") }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        map.clusterSize = 0.1
        map.minimumAnnotationCountPerCluster = 4
        
        // Always present master and detail side-by-side
        splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
        
        // Set the master (map) relative side
        splitViewController?.minimumPrimaryColumnWidth = view.frame.width * 0.6
        splitViewController?.maximumPrimaryColumnWidth = view.frame.width * 0.6
        
        if isTrackingHistory {
            Location.shared.beginTrackingLocation(requestAuthorizationIfNeeded: false)
        }
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        annotation.title = "iOSDevCenter-Kirit Modi"
//        annotation.subtitle = "Ahmedabad"
//        map.addAnnotation(annotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLocationMonitoringAuthorized() {
            sync{ self.beginTrackingLocation() }
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destinationController(FilterViewController.self) {
            dest.filter = filter
            dest.delegate = self
        }
    }
    
    
    //MARK: - Logic
    
    var isMapCloseEnoughToFetchData: Bool {
        return btnFilter.isEnabled
    }
    
    func setAreaCanFetchDataUI(_ canFetch: Bool) {
        if !canFetch {
            self.detailLabel.text = "איזור גדול מדי, נסה להתקרב"
            self.detailLabel.isHidden = false
            self.btnAccidents.title = "תאונות"
        }
        btnFilter.isEnabled = canFetch
        btnAccidents.isEnabled = canFetch
    }
    
    func updateInfoIfPossible(_ map: MKMapView, filterChanged: Bool) {
        
        // Too far >> don't get anything
        if Int(map.edgesDistance()) > MAX_DIST_OF_MAP_EDGES {
            self.setAreaCanFetchDataUI(false)
            return
        }
        self.setAreaCanFetchDataUI(true)
        
        // Only Zoomed in >> don't update
        if !filterChanged && MKCoordinateRegionContainsRegion(lastRegion, map.region) && map.visibleAnnotations().count > 0 {
            return
        }
        
        // In the middle >> don't update
        if gettingInfo { return }
        
        
        gettingInfo = true
        hud.show(in: view)
        print("Getting some...")
        
        
        network.getAnnotations(map.edgePoints(), filter: filter) { [weak self] marks, count in
            print("finished parsing")
            guard let s = self else {return}
            
            s.map.annotationsToIgnore = nil
            s.map.removeAnnotations(s.map.annotations) // remove old
            s.map.addAnnotations(marks) // add new
            s.detailLabel.isHidden = true
            s.btnAccidents.title = String.localizedStringWithFormat(local("main_presenting_count_label"), count)
            
            s.gettingInfo = false
            
            // iPad/big iPhone >> update accidents list in split view
            if let
                nav = s.splitViewController?.viewControllers.safeRetrieveElement(1) as? UINavigationController,
                let detail = nav.viewControllers.first as? AccidentsViewController
            {
                s.populate(accidentsViewController: detail)
                detail.refreshUI()
            }
            
            s.hud.dismiss() // hide progress hud
        }

    }
    
    
    
    //MARK: - Actions
    
    @IBAction func actionAccidents(_ sender: UIBarButtonItem) {
        
        // Create the accidents VC from the current storyboard
        let destNav = storyboard?.instantiateViewController(withIdentifier: AccidentsViewController.storyboardId) as! UINavigationController
        
        guard let dest = destNav.topViewController as? AccidentsViewController
            else {return}
        
        
        //Populate the accidents VC with data
        populate(accidentsViewController: dest)
        
        // Show it
        showDetailViewController(destNav, sender: self)
        
    }
    
    @IBAction func actionLocationHistory(_ sender: UIButton) {
        
        if isTrackingHistory {
            //open location history
            let storyboardId = HistoryViewController.storyboardId
            let vc = storyboard!.instantiateViewController(withIdentifier: storyboardId)
            present(vc, animated: true, completion: nil)
            
        } else {
            
            let title = NSLocalizedString("main_history_prompt_alert_title", comment: "")
            let msg = NSLocalizedString("main_history_prompt_alert_message", comment: "")
            let prompt = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            
            
            let cancelText = NSLocalizedString("main_history_prompt_alert_cancel", comment: "")
            let cancel = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
            
            
            let locationAllowed = Location.shared.isLocationMonitoringAuthorized
            let confirmLocationText = NSLocalizedString("main_history_prompt_alert_confirm_request_location", comment: "")
            let confirmText = NSLocalizedString("main_history_prompt_alert_confirm", comment: "")
            let confirmTitle = locationAllowed ? confirmText : confirmLocationText
            
            let confirm = UIAlertAction(title: confirmTitle, style: .default) { [weak self] _ in
                if Location.shared.didAskAuthorization == false || locationAllowed {
                    // begin tracking
                    Location.shared.beginTrackingLocation(requestAuthorizationIfNeeded: true)
                    self?.isTrackingHistory = true
                } else {
                    // open app settings to change authorization
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
            
            prompt.addAction(confirm)
            prompt.addAction(cancel)
            
            prompt.popoverPresentationController?.sourceView = sender
            prompt.popoverPresentationController?.sourceRect = sender.bounds
            prompt.popoverPresentationController?.permittedArrowDirections = .any

            present(prompt, animated: true, completion: nil)
        }
        
        
    }
    
    
    //MARK: - UI Logic
    
    func populate(accidentsViewController dest: AccidentsViewController) {
        // get map annotations as MarkerAnnotation
        let annots = map.annotations.compactMap{ ($0 as? MarkerAnnotation) ?? nil }
        
        // break any MarkerGroup and create Marker array
        var markers = [Marker]()
        for annot in annots {
            if let group = annot as? MarkerGroup {
                markers += group.markers
            }
            if let marker = annot as? Marker {
                markers.append(marker)
            }
        }
        
        
        dest.dataSource = markers.sorted{$0.created.compare($1.created as Date) == .orderedDescending}
    }
    
    
}

