//
//  UserPickViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 15/05/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import GoogleMaps

class UserPickViewController: UIViewController {

    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var pickTitle: UITextView!
    var locationManager = CLLocationManager()
    var pickCount:Int = 0
    private let ZOOM: Float = 16

    /// Handling the network calls
    let network = Network()

    var hud = JGProgressHUD(style: .light)

    var filter = Filter()

//    private var gradientColors = [UIColor.green, UIColor.orange, UIColor.yellow, UIColor.red]
//    private var gradientStartPoints = [0.02,0.02,0.02, 0.02] as [NSNumber]

    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.02, 0.09] as [NSNumber]


    private var heatmapLayer: GMUHeatmapTileLayer!

    
    fileprivate func addHeatMapLayer() {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.9
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints,
                                            colorMapSize: 256)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMapView()
        self.initLocationManager()
        mapView.settings.compassButton = true
        self.nextBarButton.isEnabled = false


        hud?.animation = JGProgressHUDFadeZoomAnimation() as JGProgressHUDFadeZoomAnimation
        hud?.interactionType = JGProgressHUDInteractionType.blockNoTouches

        mapView.animate(toZoom: ZOOM)

        addHeatMapLayer()
    }


    @IBAction func nextButtonPressed(_ sender: Any) {

        DispatchQueue.main.async { [weak self]  in
            self?.updateInfoIfPossible(filterChanged:false)
            //self?.pickTitle.text = "Here are the dangerouse places"
        }
    }
    func addHeatmap(markers: [MarkerAnnotation])  {
        var list = [GMUWeightedLatLng]()

        print ("addHeatmap. markers count \(markers.count)")
        for marker in markers {
            let lat = marker.coordinate.latitude
            let lng = marker.coordinate.longitude


            let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat, lng ), intensity: 1.0)
            list.append(coords)
        }
        // Add the latlngs to the heatmap layer.
        heatmapLayer.weightedData = list

        self.heatmapLayer.map = self.mapView
    }


    fileprivate func addMarkers(markers: [MarkerAnnotation]) {

        for marker in markers {

            let googleMarker: GMSMarker = GMSMarker() // Allocating Marker

            googleMarker.title =  marker.title ?? ""
            googleMarker.snippet = marker.subtitle ?? ""
            //googleMarker.icon = marker.
            googleMarker.appearAnimation = .pop // Appearing animation. default
            googleMarker.position = marker.coordinate//   location.coordinate // CLLocationCoordinate2D

            DispatchQueue.main.async {
                googleMarker.map = self.mapView
            }

        }
    }

    func updateInfoIfPossible( filterChanged: Bool) {

        print("Getting Annotations...")

        self.pickTitle.text = "Calculating..."
        let projection = mapView.projection.visibleRegion()

        //let topLeftCorner: CLLocationCoordinate2D = projection.farLeft
        let topRightCorner: CLLocationCoordinate2D = projection.farRight
        let bottomLeftCorner: CLLocationCoordinate2D = projection.nearLeft
        //let bottomRightCorner: CLLocationCoordinate2D = projection.nearRight
        let edges:Edges = (ne: topRightCorner, sw: bottomLeftCorner)

        hud?.show(in: view)


        network.getAnnotations(edges, filter: filter) { [weak self] (markers: [MarkerAnnotation], count: Int) in
            print("finished parsing. markers count : \(markers.count)")
            guard let self = self else {return}

            self.removeHeatMapLayer()
            self.addHeatMapLayer()

            self.addHeatmap(markers: markers)

            //self.addMarkers(markers: markers)

            self.hud?.dismiss()

            DispatchQueue.main.async { [weak self]  in
                self?.pickTitle.text = "Here are the dangerous places displayed as a heat map"
            }
            self.nextBarButton.isEnabled = false
        }

    }

    private func removeHeatMapLayer() {
        heatmapLayer.map = nil
        heatmapLayer = nil
    }


    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupMapView() {
        mapView.isTrafficEnabled   = false
        mapView.isHidden           = false
        mapView.delegate           = self
    }

    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            print ("address  = \(address)")
            self.addressLabel.text = lines.joined(separator: "\n")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showHeatMap") {
           // let heatmapViewController = segue.destination as? HeatmapViewController
        }
    }
}


// MARK: - GMSMapViewDelegate
extension UserPickViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {

        if self.pickCount < 2 {
            reverseGeocodeCoordinate(position.target)
        } else {
            self.updateInfoIfPossible(filterChanged:false)
        }


    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            self.mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: ZOOM)
        }
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if self.pickCount >= 2 {
            return
        }
        reverseGeocodeCoordinate(coordinate)
        // Creates a marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
  
        self.pickCount += 1
        self.pickTitle.text = "Cool! now pick another one"
        marker.snippet = ""
        marker.map = self.mapView
        if self.pickCount == 1 {
            marker.title = "You picked this one first"
        }
        else{
            self.nextBarButton.isEnabled = true
            marker.title = "That's the second place you picked"
            self.pickTitle.text = "You've picked two places, tap next to continue"
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}

// MARK: - CLLocationManagerDelegate
extension UserPickViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
 
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: ZOOM, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()

        //updateInfoIfPossible(filterChanged:true)
        //locationManager.stopUpdatingLocation()
        //fetchNearbyPlaces(coordinate: location.coordinate)
    }

    private func newHud() -> JGProgressHUD {
        let hud = JGProgressHUD(style: .light)
        hud?.animation = JGProgressHUDFadeZoomAnimation() as JGProgressHUDFadeZoomAnimation
        hud?.interactionType = JGProgressHUDInteractionType.blockNoTouches
        return hud!
    }
}


