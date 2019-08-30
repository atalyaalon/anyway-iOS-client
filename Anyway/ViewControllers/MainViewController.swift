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
import RSKImageCropper
//import MaterialComponents.MaterialButtons_Theming

class MainViewController: UIViewController {

    private static let ZOOM: Float = 16
    private static let YES_NO_BUTTON_WIDTH = 50
    private static let YES_NO_BUTTON_HEIGHT = 40
    private static let SNACK_BAR_BG_COLOR = UIColor.purple

    @IBOutlet weak var reportButton: MDCFloatingButton!
    @IBOutlet weak var nextButton: MDCFloatingButton!
    @IBOutlet weak var cancelButton: MDCFloatingButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var pickTitle: UITextView!

    private var mainViewModel: MainViewOutput! //MainViewModel
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.02, 0.09] as [NSNumber]
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var snackbarView = SnackBarView()
    private var helpButton: MDCFloatingButton!
    private var filterButton: MDCFloatingButton!
    //private var currentState:MainVCState = .start
    private var selectedImageView: UIImageView!
    private var topDrawer: TopDrawer?


    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewModel = MainViewModel(viewController: self)
        mainViewModel.viewDidLoad()
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

    private func setupTitle() {
        nextButton.setTitle("CONTINUE".localized, for: UIControl.State.normal)
        nextButton.backgroundColor = UIColor.lightGray
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        nextButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)

        reportButton.setTitle("CONTINUE_TO_INFORM".localized, for: UIControl.State.normal)
        reportButton.backgroundColor = UIColor.lightGray
        reportButton.setTitleColor(UIColor.white, for: .normal)
        reportButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        reportButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)

        cancelButton.setTitle("CANCEL".localized, for: UIControl.State.normal)
        cancelButton.backgroundColor = UIColor.lightGray
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        cancelButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
    }

    private func setupHelpButton() {
        helpButton = MDCFloatingButton(frame: CGRect(x: 370, y: 125, width: 26, height: 26))
        helpButton.setImage(#imageLiteral(resourceName: "information"), for: .normal)
        helpButton.backgroundColor = UIColor.white
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .normal)
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        //        helpButton.borderWidth = 4  not working TODO ?
        //        helpButton.borderColor = UIColor.black
        helpButton.addTarget(self, action: #selector(handleHelpTap), for: .touchUpInside)
        self.view.addSubview(helpButton)
    }

    private func setupFilterButton() {
        filterButton = MDCFloatingButton(frame: CGRect(x: 30, y: 125, width: 23, height: 23))
        filterButton.setImage(#imageLiteral(resourceName: "filter_add"), for: .normal)
        filterButton.backgroundColor = UIColor.white
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .normal)
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        filterButton.addTarget(self, action: #selector(handleFilterTap), for: .touchUpInside)
        self.view.addSubview(filterButton)
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        let mapRectangle: GMSVisibleRegion = mapView.projection.visibleRegion()
//        self.pickTitle.text = "LOADING".localized
        mainViewModel.handleNextButtonTap(mapRectangle)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        mainViewModel.handleCancelButtonTapped()
    }

    @IBAction func reportButtonTapped(_ sender: Any) {
        mainViewModel.handleReportButtonTapped()
    }
    @objc private func handleHelpTap(_ sender: UIButton) {
        mainViewModel?.handleHelpTap()
    }

    @objc private func handleFilterTap(_ sender: UIButton) {
        mainViewModel?.handleFilterTap()
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

// MARK: - Questionnaires
extension MainViewController {

    private func addYesNoButtons(toView: UIView, yesAction: Selector, noAction: Selector) {

        let yesButton = UIButton.questionnaireButton(frame: CGRect(x: 150, y: 80, width: MainViewController.YES_NO_BUTTON_WIDTH, height: MainViewController.YES_NO_BUTTON_HEIGHT), title: "YES".localized)
        yesButton.addTarget(self, action:yesAction, for: .touchUpInside)
        toView.addSubview(yesButton)

        let noButton = UIButton.questionnaireButton(frame: CGRect(x: 210, y: 80, width: MainViewController.YES_NO_BUTTON_WIDTH, height: MainViewController.YES_NO_BUTTON_HEIGHT), title: "NO".localized)
        noButton.addTarget(self, action:noAction, for: .touchUpInside)
        toView.addSubview(noButton)
    }

    @objc private func cancelSendButtonClicked() {
        print("cancel send Button Clicked")
        snackbarView.hideSnackBar()
        mainViewModel?.handleCancelSendButtonTap()

    }
    @objc private func sendButtonClicked() {
        print("send Button Clicked")
        snackbarView.hideSnackBar()
        mainViewModel?.handleSendToMunicipalityTap()
    }
}


// MARK: - RSKImageCropViewControllerDelegate
extension MainViewController : RSKImageCropViewControllerDelegate {

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.mainViewModel?.closeImagePicker()
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        DispatchQueue.main.async {
            self.selectedImageView.image = croppedImage
            self.mainViewModel?.closeImagePicker()
        }
    }
}

// MARK: - MainViewInput
extension MainViewController : MainViewInput {
   
    func setupView() {
        self.navigationController?.isNavigationBarHidden = true
        self.setupMapView()
        setupTitle()
        //self.view.addSubview(topDrawer)
    }

    func showImagPickerScreen(_ pickerController: UIImagePickerController, animated: Bool) {
        self.present(pickerController, animated: animated)
    }

    func showAlert(_ alert: UIAlertController, animated: Bool) {
        self.present(alert, animated: animated)
    }

    public func displayErrorAlert(error: Error? = nil) {
        let title = "Network Error"
        var erroDesc = ""
        if let err = error {
            erroDesc = err.localizedDescription
        }
        //let erroDesc = (error == nil) ? "" : error.debugDescription
        let msg = "Something went wrong \(erroDesc)"
        let prompt = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let cancelText = "OK".localized
        let cancel = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
        prompt.addAction(cancel)
        //        prompt.popoverPresentationController?.sourceView = nextButton
        //        prompt.popoverPresentationController?.sourceRect = nextButton.bounds
        //        prompt.popoverPresentationController?.permittedArrowDirections = .any
        present(prompt, animated: true, completion: nil)
    }
    
    func pushViewController(_ vc: UIViewController, animated: Bool) {
        self.navigationController!.pushViewController(vc, animated: animated)
    }
    
    func popViewController( animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    func displaySendAnswersQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "WISH_TO_SEND_ANSWERS".localized)
        snackView.addSubview(label)

        self.addYesNoButtons(toView:snackView, yesAction:#selector(self.sendButtonClicked), noAction:#selector(self.cancelSendButtonClicked) )
        snackbarView.showSnackBar(superView: self.view, bgColor: MainViewController.SNACK_BAR_BG_COLOR, snackbarView: snackView)
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

    func disableAllFloatingButtons() {
        self.nextButton.isHidden = true
        self.reportButton.isHidden = true
        self.cancelButton.isHidden = true
    }

    func disableFilterAndHelpButtons(){
        filterButton.isEnabled = false;
        helpButton.isEnabled = false;
    }

    func setActionForState(state: MainVCState) {

        switch state {
        case .start:
            //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            DispatchQueue.main.async {
                self.enableFilterAndHelpButtons()
                self.mapView.clear()
                //self.pickTitle.text = "CHOOSE_A_PLACE".localized
                self.disableAllFloatingButtons()
                self.pickTitle.isHidden = true

                self.topDrawer = TopDrawer(text: "CHOOSE_A_PLACE".localized)
                self.view.addSubview(self.topDrawer!)

//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//                    self.topDrawer?.toggleVisibility()
//                }
            }
        case .placePicked:
            DispatchQueue.main.async {
                //self.pickTitle.text = "TAP_CONTINUE_TO_GET_DANGEROUS_PLACES".localized
                self.topDrawer?.setText(text: "TAP_CONTINUE_TO_GET_DANGEROUS_PLACES".localized)
                self.nextButton.isHidden = false
                self.reportButton.isHidden = true
                self.cancelButton.isHidden = true
            }
        case .continueTappedAfterPlacePicked:
            DispatchQueue.main.async { [weak self]  in
                //self?.pickTitle.text = "LOADING".localized
                self?.topDrawer?.toggleVisibility()
                self?.disableFilterAndHelpButtons()
                self?.disableAllFloatingButtons()
            }
        case .markersReceived:
            DispatchQueue.main.async { [weak self]  in
                self?.topDrawer?.toggleVisibility()
                self?.topDrawer?.setText(text:"PLACES_MAKRKED_WITH_HEATMAP".localized)
                //self?.pickTitle.text = "PLACES_MAKRKED_WITH_HEATMAP".localized
                self?.nextButton.isHidden = true
                self?.reportButton.isHidden = false
                self?.cancelButton.isHidden = false
            }
        case .hazardSelected:
            DispatchQueue.main.async { [weak self]  in
                self?.disableAllFloatingButtons()
                self?.topDrawer?.toggleVisibility()
                //self?.pickTitle.isHidden = true
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


