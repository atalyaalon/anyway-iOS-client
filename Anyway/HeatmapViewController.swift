
//
//  HeatmapViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 20/05/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit


//import Google_Maps_iOS_Utils

class HeatmapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    private var heatmapLayer: GMUHeatmapTileLayer!

    private let ZOOM: Float = 10
    
    
    /// Handling the network calls
    let network = Network()
    
    /// Progress hud
    var hud :JGProgressHUD?
    
    var filter = Filter()

    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as? [NSNumber]


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMapView()
        self.initLocationManager()
        mapView.settings.compassButton = true
        //self.hud = newHud()
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints!,
                                            colorMapSize: 256)

        mapView.animate(toZoom: ZOOM)

        //mapView.setMinZoom(20, maxZoom: mapView.maxZoom)
        //let camera = GMSCameraPosition.camera(withLatitude: 32.06728, longitude: 32.06728, zoom: 15)

        //mapview.camera = GMSCameraPosition(latitude: 32.06728, longitude: 32.06728, zoom: 13)
        //locationManager.stopUpdatingLocation()

        //updateInfoIfPossible(filterChanged:true)


        // Set the heatmap to the mapview.
        heatmapLayer.map = mapView
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
    }

    
    private func newHud() -> JGProgressHUD {
        let hud = JGProgressHUD(style: .light)
        hud?.animation = JGProgressHUDFadeZoomAnimation() as JGProgressHUDFadeZoomAnimation
        hud?.interactionType = JGProgressHUDInteractionType.blockNoTouches
        return hud!
    }
    
   
    
    func updateInfoIfPossible( filterChanged: Bool) {
        
        print("Getting some...")
          let projection = mapView.projection.visibleRegion()

        //let topLeftCorner: CLLocationCoordinate2D = projection.farLeft
        let topRightCorner: CLLocationCoordinate2D = projection.farRight
        let bottomLeftCorner: CLLocationCoordinate2D = projection.nearLeft
        //let bottomRightCorner: CLLocationCoordinate2D = projection.nearRight
        let edges:Edges = (ne: topRightCorner, sw: bottomLeftCorner)
        
        //typealias Edges = (ne: Coordinate, sw: Coordinate)
        
        network.getAnnotations(edges, filter: filter) { [weak self] marks, count in
            print("finished parsing. markers count : \(marks.count)")
            guard let self = self else {return}

            self.addHeatmap(markers: marks)

            self.heatmapLayer.map = self.mapView
            
        }
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension HeatmapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //reverseGeocodeCoordinate(position.target)
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
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
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}


// MARK: - CLLocationManagerDelegate
extension HeatmapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: ZOOM, bearing: 0, viewingAngle: 0)
        //locationManager.stopUpdatingLocation()

         updateInfoIfPossible(filterChanged:true)

             heatmapLayer.map = mapView
        //fetchNearbyPlaces(coordinate: location.coordinate)
    }
}
