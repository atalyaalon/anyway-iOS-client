//
//  MainViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 15/05/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
import MaterialComponents.MaterialButtons
//import MaterialComponents.MaterialButtons_Theming

class MainViewController: BaseViewController {

    private static let ZOOM: Float = 16
    private let BIG_DRAWER_HEIGHT:CGFloat = 150.0
    private let SMALL_DRAWER_HEIGHT:CGFloat = 120.0
    private let BIG_DRAWER_BUTTON_HEIGHT_OFFSET:CGFloat = 30.0
    
    private let BUTTON_Y:CGFloat = 95.0
    private let BUTTON_HEIGHT:CGFloat = 30.0
    private let BUTTON_WIDTH:CGFloat = 100.0

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!

    private var mainViewModel: MainViewOutput! //MainViewModel
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.02, 0.09] as [NSNumber]
    private var heatmapLayer: GMUHeatmapTileLayer!
    //private var snackbarView = SnackBarView()
    private var helpButton: MDCFloatingButton!
    private var filterButton: MDCFloatingButton!
    private var topDrawer: TopDrawer?
    private var addImageModel: AddImageOutput! //AddImageViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewModel = MainViewModel(viewController: self)
        addImageModel = AddImageViewModel(viewController: self)
        mainViewModel.viewDidLoad()
    }

    override func setupView() {
        self.navigationController?.isNavigationBarHidden = true
        self.setupMapView()
        self.topDrawer = TopDrawer()
        self.view.addSubview(topDrawer!)
    }

    private func setupMapView() {
        mapView.isTrafficEnabled   = false
        mapView.isHidden           = false
        mapView.delegate           = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        setupHelpButton()
        setupFilterButton()
        mapView.animate(toZoom: MainViewController.ZOOM)
    }

    private func setupHelpButton() {
        helpButton = MDCFloatingButton(frame: CGRect(x: UIScreen.main.bounds.width - 50, y: 130, width: 26, height: 26))
        helpButton.setImage(#imageLiteral(resourceName: "information"), for: .normal)
        helpButton.backgroundColor = UIColor.white
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .normal)
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
                //helpButton.layer.borderWidth  = 6 // not working TODO ?
               //helpButton.layer.borderColor = UIColor.black.cgColor
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        self.view.addSubview(helpButton)
    }

    private func setupFilterButton() {
        filterButton = MDCFloatingButton(frame: CGRect(x: UIScreen.main.bounds.minX + 30 , y: 130, width: 23, height: 23))
        filterButton.setImage(#imageLiteral(resourceName: "filter_add"), for: .normal)
        filterButton.backgroundColor = UIColor.white
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .normal)
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        filterButton.addTarget(self, action: #selector(filterButtonTap), for: .touchUpInside)
        self.view.addSubview(filterButton)
    }

    private func enableFilterAndHelpButtons(){
        filterButton.isEnabled = true;
        helpButton.isEnabled = true;
    }

    private func addMarkers(markers: [MarkerAnnotation]) {
        for marker in markers {
            let googleMarker: GMSMarker = GMSMarker() // Allocating Marker
            googleMarker.title =  marker.title ?? ""
            googleMarker.snippet = marker.subtitle ?? ""
            googleMarker.appearAnimation = .pop // Appearing animation
            googleMarker.position = marker.coordinate
            DispatchQueue.main.async {
                googleMarker.map = self.mapView
            }
        }
    }

    @objc private func helpButtonTapped(_ sender: UIButton) {
        mainViewModel?.handleHelpTap()
    }
    @objc private func filterButtonTap(_ sender: UIButton) {
        mainViewModel?.handleFilterTap()
    }
    @objc private func nextButtonTapped(_ sender: Any) {
        let mapRectangle: GMSVisibleRegion = mapView.projection.visibleRegion()
        mainViewModel.handleNextButtonTap(mapRectangle) //Loading annotations
    }
    @objc private func cancelButtonTapped(_ sender: Any) {
        mainViewModel.handleCancelButtonTap()
    }
    @objc private func reportButtonTapped(_ sender: Any) {
        //addImageModel.showSelectImageAlert(true)
        mainViewModel.handleReportButtonTap()
    }

    private func addTwoButtons(toView: UIView?,
                               firstButtonText: String,
                               secondButtonText: String,
                               firstButtonAction: Selector,
                               secondButtonAction: Selector) {

        toView?.subviews.forEach({ $0.removeFromSuperview() })

        //let buttonY = UIScreen.main.bounds.size.height - self.BIG_DRAWER_HEIGHT  - self.BIG_DRAWER_BUTTON_HEIGHT_OFFSET
        let buttonY =  BUTTON_Y //self.BIG_DRAWER_HEIGHT  - self.BIG_DRAWER_BUTTON_HEIGHT_OFFSET
        //let firstButtonX = UIScreen.main.bounds.size.width/2 + 10
        
        let firstButtonX = UIScreen.main.bounds.size.width/2  - 10 - BUTTON_WIDTH
        let firstButton = MDCFloatingButton(frame: CGRect(x: firstButtonX, y: buttonY, width: BUTTON_WIDTH, height: BUTTON_HEIGHT))
        firstButton.setTitle(firstButtonText, for: UIControl.State.normal)
        firstButton.backgroundColor = UIColor.lightGray
        firstButton.setTitleColor(UIColor.white, for: .normal)
        firstButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        firstButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        firstButton.addTarget(self, action: firstButtonAction, for: .touchUpInside)

        //let secondButtonX = UIScreen.main.bounds.size.width/2 - 110
        let secondButtonX = UIScreen.main.bounds.size.width/2 + 10
        let secondButton = MDCFloatingButton(frame: CGRect(x: secondButtonX, y: buttonY, width: BUTTON_WIDTH, height: BUTTON_HEIGHT))
        secondButton.setTitle(secondButtonText, for: UIControl.State.normal)
        secondButton.backgroundColor = UIColor.lightGray
        secondButton.setTitleColor(UIColor.white, for: .normal)
        secondButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        secondButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        secondButton.addTarget(self, action: secondButtonAction, for: .touchUpInside)

        toView?.addSubview(firstButton)
        toView?.addSubview(secondButton)
    }
}

// MARK: - GMSMapViewDelegate
extension MainViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mainViewModel?.handleCameraMovedToPosition(coordinate: position.target)
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
            self.mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: MainViewController.ZOOM)
        }
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mainViewModel?.handleTapOnTheMap(coordinate: coordinate)
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}

// MARK: - MainViewInput
extension MainViewController : MainViewInput {

    func showImagPickerScreen(_ pickerController: UIImagePickerController, animated: Bool) {
        self.present(pickerController, animated: animated)
    }


    
    func pushViewController(_ vc: UIViewController, animated: Bool) {
        self.navigationController!.pushViewController(vc, animated: animated)
    }
    
    func popViewController( animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    func addCoordinateListToHeatMap(coordinateList: [GMUWeightedLatLng]) {
        // Add the latlng list to the heatmap layer.
        heatmapLayer.weightedData = coordinateList
        self.heatmapLayer.map = self.mapView
    }

    func removeHeatMapLayer() {
        heatmapLayer.map = nil
        heatmapLayer = nil
    }

    func addHeatMapLayer() {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.9
        heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints,colorMapSize: 256)
    }

    func disableFilterAndHelpButtons(){
        filterButton.isEnabled = false;
        helpButton.isEnabled = false;
    }

    func setActionForState(state: MainVCState) {

        switch state {
        case .start:
            DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return }
                self.enableFilterAndHelpButtons()
                self.mapView.clear()
                self.topDrawer?.subviews.forEach({ $0.removeFromSuperview() })
                self.topDrawer?.setText(text: "CHOOSE_A_PLACE".localized, drawerHeight: self.SMALL_DRAWER_HEIGHT)
                self.topDrawer?.setVisibility(visible: true)
            }
        case .placePicked:
            DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return }
                self.disableFilterAndHelpButtons()
                self.addTwoButtons(toView: self.topDrawer,
                              firstButtonText: "CANCEL".localized,
                              secondButtonText:  "CONTINUE".localized,
                              firstButtonAction: #selector(self.cancelButtonTapped ),
                              secondButtonAction: #selector(self.nextButtonTapped))

                self.topDrawer?.setText(text: "TAP_CONTINUE_TO_GET_DANGEROUS_PLACES".localized, drawerHeight: self.BIG_DRAWER_HEIGHT)
                self.topDrawer?.setVisibility(visible: true)
            }
        case .continueTappedAfterPlacePicked:
            DispatchQueue.main.async { [weak self]  in
                self?.topDrawer?.setVisibility(visible: false)

            }
        case .markersReceived:
            DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return  }
                self.addTwoButtons(toView: self.topDrawer,
                                   firstButtonText:  "CANCEL".localized,
                                   secondButtonText: "CONTINUE_TO_INFORM".localized,
                                   firstButtonAction: #selector(self.cancelButtonTapped),
                                   secondButtonAction: #selector(self.reportButtonTapped ))

                self.topDrawer?.setText(text:"PLACES_MAKRKED_WITH_HEATMAP".localized, drawerHeight: self.BIG_DRAWER_HEIGHT)
                //self.topDrawer?.setVisibility(visible: true)
                // DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(14)) {
                // self?.topDrawer?.setVisibility(visible: true)
                // }
            }
        case .reportTapped:
            DispatchQueue.main.async { [weak self]  in
                //self?.topDrawer?.setVisibility(visible: false)
                self?.addImageModel.showSelectImageAlert(true)
            }
        }
    }

    func setCameraPosition(coordinate : CLLocationCoordinate2D) {
        mapView.camera = GMSCameraPosition(target: coordinate, zoom: MainViewController.ZOOM, bearing: 0, viewingAngle: 0)
    }

    func setAddressLabel(address: String) {
        self.addressLabel.text = address
    }

    func setMarkerOnTheMap(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // marker.snippet = ""
        marker.map = self.mapView
    }
}

// MARK: - AddImageInput
extension MainViewController: AddImageInput {

    func setSelectedImage(image: UIImage) {
        mainViewModel.handleSelectedImage(image: image)
    }
    func skipSelectedWhenAddingImage() {
        mainViewModel.handleSkipSelectedWhenAddingImage()
    }
}
