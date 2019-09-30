//
//  HazardsViewModel.swift
//  Anyway
//
//  Created by Yigal Omer on 26/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import RSKImageCropper
import GoogleMaps

enum MainVCState: Int {
    case start = 0
    case placePicked = 1
    case continueTappedAfterPlacePicked = 2
    case markersReceived = 3
    case reportTapped = 4
    //case hazardSelected = 5
}

class MainViewModel: NSObject, UINavigationControllerDelegate {

    private var api: AnywayAPIImpl
    private let hud = JGProgressHUD(style: .light)
    weak var view: MainViewInput?
    private var filter = Filter()
    private var locationManager = CLLocationManager()
    private var currentState:MainVCState = .start
    private var selectedImageView: UIImageView?

    init(viewController: MainViewInput?) {
        self.view = viewController
        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = Config.TIMEOUT_INTERVAL_FOR_REQUEST
        self.api = AnywayAPIImpl(sessionConfiguration: sessionConfiguration)
        super.init()
     }

    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func showHUD() {
        DispatchQueue.main.async {
            if let view = self.view as? UIViewController {
                self.hud?.isHidden = false
                self.hud?.show(in: view.view, animated:true);
                //hud.mode = .indeterminate
                self.hud?.textLabel.text = "LOADING".localized
            }
        }
    }

    private func hideHUD() {
        DispatchQueue.main.async {
            self.hud?.isHidden = true
        }
    }
    //let imageData = selectedImageView?.image?.jpegData(compressionQuality: 0.8)
    
    private func startSelectHazardView() {
        let ReportIncidentViewController:ReportIncidentViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "ReportIncidentViewController") as UIViewController as! ReportIncidentViewController

        ReportIncidentViewController.delegate = self as ReportIncidentViewControllerDelegate
        ReportIncidentViewController.incidentImageView = self.selectedImageView

        self.view?.pushViewController(ReportIncidentViewController, animated: true)
    }

    private func addHeatmap(markers: [NewMarker])  {
        var list = [GMUWeightedLatLng]()
        print ("addHeatmap. markers count \(markers.count)")
        for marker in markers {
            let lat = marker.latitude
            let lng = marker.longitude

            let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat, lng ), intensity: 1.0)
            list.append(coords)
        }
        view?.addCoordinateListToHeatMap(coordinateList: list)
     }


    func getAnnotations(_ edges: Edges) {

        showHUD()
        //view?.showLoadingIndicator()

        self.api.getAnnotationsRequest(edges, filter: filter) { (markers: [NewMarker]?) in

            self.hideHUD()
            //self.view?.hideLoadingIndicator()
            guard let markers = markers else {
                print("finished parsing annotations. ERROR markers ar nil")

                //YIGAL TODO UNCOMMENT - JUST FOR TETSING
                //self.view?.displayErrorAlert(error: nil)
                //self.setMainViewState(state: .start)
                self.setMainViewState(state: .markersReceived)
                return
            }
            if  markers.count == 0  {
                print("finished parsing annotations. no markers received")

                //YIGAL TODO UNCOMMENT - JUST FOR TETSING
                //self.view?.displayErrorAlert(error: nil)
                //self.setMainViewState(state: .start)
                self.setMainViewState(state: .markersReceived)
                return
            }
            print("finished parsing annotations. markers count : \(String(describing: markers.count))")
            self.view?.removeHeatMapLayer()
            self.view?.addHeatMapLayer()
            self.addHeatmap(markers: markers)
            self.setMainViewState(state: .markersReceived)
            //anotations?(markers)
        }
    }

    func setMainViewState(state:MainVCState) {
        self.currentState = state
        view?.setActionForState(state: self.currentState)
    }
}

// MARK: - MainViewOutput
extension MainViewModel: MainViewOutput {

    func viewDidLoad() {
        self.view?.setupView()
        self.initLocationManager()
        self.view?.addHeatMapLayer()
        self.setMainViewState(state: .start)
    }

    func handleFilterTap() {

        print("Filter button tapped")
        let filterViewController:FilterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterViewController")  as! FilterViewController
        filterViewController.filter = self.filter
        filterViewController.delegate = self

        view?.pushViewController(filterViewController, animated: true)
    }

    func handleHelpTap() {
        print("Help button tapped")
        let helpViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoViewController") as UIViewController
        self.view?.pushViewController(helpViewController, animated: true)
    }

    func handleNextButtonTap(_ mapRectangle: GMSVisibleRegion) {

        let topRightCorner: CLLocationCoordinate2D = mapRectangle.farRight
        let bottomLeftCorner: CLLocationCoordinate2D = mapRectangle.nearLeft
        let edges:Edges = (ne: topRightCorner, sw: bottomLeftCorner)
        self.setMainViewState(state: .continueTappedAfterPlacePicked)
        self.getAnnotations(edges)
    }

    func handleReportButtonTap() {
        self.setMainViewState(state: .reportTapped)
        //showSelectImageAlert()
    }
    func handleCancelButtonTap() {
        self.setMainViewState(state: .start)
    }

    func handleCancelSendButtonTap() {
        self.setMainViewState(state: .start)
    }

    func handleTapOnTheMap(coordinate: CLLocationCoordinate2D){
        if self.currentState != .start  {
            return
        }
        reverseGeocodeCoordinate(coordinate)
        addMarkerOnTheMap(coordinate)
    }

    func handleCameraMovedToPosition(coordinate: CLLocationCoordinate2D) {
        if self.currentState == .start {
            reverseGeocodeCoordinate(coordinate)
        }
    }

    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            print ("address  = \(address)")
            self.view?.setAddressLabel(address: lines.joined(separator: "\n"))
            //self.addressLabel.text = lines.joined(separator: "\n")
        }
    }

    private func addMarkerOnTheMap(_ coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)

        self.setMainViewState(state: .placePicked)
        view?.setMarkerOnTheMap(coordinate: coordinate)
    }

    func handleSelectedImage(image: UIImage) {

        self.selectedImageView = UIImageView()
        self.selectedImageView?.image = image
        self.startSelectHazardView()
    }

    func handleSkipSelectedWhenAddingImage(){
        self.startSelectHazardView()
    }
}

// MARK: - FilterScreenDelegate
extension MainViewModel: FilterScreenDelegate {

    func didCancel() {
        view?.popViewController(animated: true)
    }

    func didSave(filter: Filter) {
        self.filter = filter
        view?.popViewController(animated: true)
    }
}

// MARK: - ReportIncidentViewControllerDelegate
extension MainViewModel: ReportIncidentViewControllerDelegate {

    func didSelectHazard(incidentData: Incident?) {
        

        self.api.reportIncident2(incidentData!) { (result: Bool) in
           
            self.hideHUD()
            print("finished reportIncident. result = \(result)")
        }
        
   
        view?.popViewController(animated: true)
        self.setMainViewState(state: .start)
    }

    func didCancelHazard() {
        view?.popViewController(animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return }
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        view?.setCameraPosition(coordinate: location.coordinate)
        locationManager.stopUpdatingLocation()
        //fetchNearbyPlaces(coordinate: location.coordinate)
    }
}


