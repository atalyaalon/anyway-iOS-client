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

enum MainVCState: Int {
    case start = 0
    case placePicked = 1
    case continueTappedAfterPlacePicked = 2
    case loadingMarkers = 3
    case MarkersReceived = 4
}

class MainViewController: UIViewController {

    private static let ZOOM: Float = 16
    private static let YES_NO_BUTTON_WIDTH = 50
    private static let YES_NO_BUTTON_HEIGHT = 40
    private static let SNACK_BAR_BG_COLOR = UIColor.purple

    @IBOutlet weak var nextButton2: MDCFloatingButton!
    @IBOutlet weak var nextButton: MDCFloatingButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var pickTitle: UITextView!
    private let network = Network()
    private let hud = JGProgressHUD(style: .light)
    private var filter = Filter()
    private var locationManager = CLLocationManager()
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.02, 0.09] as [NSNumber]
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var textView = UITextView()
    private var snackbarView = SnackBarView()
    private var helpButton: MDCFloatingButton!
    private var filterButton: MDCFloatingButton!
    private var currentState:MainVCState = .start
    private var pickTitleFrameWithContinue = CGRect(x: 0, y: 0, width: 0, height:0)
    private var pickTitleFrameWithoutContinue = CGRect(x: 0, y: 0, width: 0, height:0)


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.setupMapView()
        self.initLocationManager()
        setupTitle()
        setupHUD()
        mapView.animate(toZoom: MainViewController.ZOOM)
        addKeyboardObservers()
        addTapGesture()
        addHeatMapLayer()
        restartMainViewState()
    }

    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    private func setupTitle() {
        nextButton.setTitle("CONTINUE".localized, for: UIControl.State.normal)
        nextButton.backgroundColor = UIColor.lightGray
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        nextButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)

        nextButton2.setTitle("CONTINUE".localized, for: UIControl.State.normal)
        nextButton2.backgroundColor = UIColor.lightGray
        nextButton2.setTitleColor(UIColor.white, for: .normal)
        nextButton2.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        nextButton2.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)

        pickTitleFrameWithoutContinue = pickTitle.frame
        pickTitleFrameWithContinue = CGRect(x: 0, y: 0, width: pickTitle.frame.width, height: pickTitle.frame.height * 2 + 10)
        //nextButton.applyOutlinedTheme(withScheme: containerScheme)
        setTitleWithoutContinue()
    }
    private func setTitleWithContinue() {
        self.nextButton.isHidden = false
        self.nextButton2.isHidden = false
        self.pickTitle.frame = pickTitleFrameWithContinue
        super.updateViewConstraints()
        view.setNeedsUpdateConstraints()
    }
    private func setTitleWithoutContinue() {
        self.nextButton.isHidden = true
        self.nextButton2.isHidden = true
        self.pickTitle.frame = pickTitleFrameWithoutContinue
        super.updateViewConstraints()
        view.setNeedsUpdateConstraints()
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
    }

    fileprivate func restartMainViewState(_ after: Int = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(after)) {
            self.enableFilterAndHelpButtons()
            self.currentState = .start
            self.mapView.clear()
            self.pickTitle.text = "CHOOSE_A_PLACE".localized
        }
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        if self.currentState == .placePicked {
            self.disableFilterAndHelpButtons()
            self.setTitleWithoutContinue()
            self.updateInfoIfPossible(filterChanged:false)
        }
    }

    @IBAction func nextButon2Tapped(_ sender: Any) {
        self.setTitleWithoutContinue()
        self.pickTitle.text = "SHORT_QUESTIONNAIRE".localized
        self.snackbarView = SnackBarView()
        self.displayFirstQuestionnaire()
    }
    fileprivate func setupHelpButton() {
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

    @objc func handleHelpTap(_ sender: UIButton) {
        print("Help button tapped")
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoViewController") as UIViewController
        self.present(viewController, animated: false, completion: nil)
    }

    fileprivate func setupFilterButton() {
        filterButton = MDCFloatingButton(frame: CGRect(x: 30, y: 125, width: 23, height: 23))
        //let filterButton = UIButton(frame: CGRect(x: 30, y: 150, width: 26, height: 26))
        filterButton.setImage(#imageLiteral(resourceName: "filter_add"), for: .normal)
        filterButton.backgroundColor = UIColor.white
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .normal)
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        filterButton.addTarget(self, action: #selector(handleFilterTap), for: .touchUpInside)
        self.view.addSubview(filterButton)
    }

    @objc func handleFilterTap(_ sender: UIButton) {
        print("Filter button tapped")
        let filterViewController:FilterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterViewController") as UIViewController as! FilterViewController
        filterViewController.filter = filter
        filterViewController.delegate = self as FilterScreenDelegate

        self.navigationController!.pushViewController(filterViewController, animated: true)
        //self.present(viewController, animated: false, completion: nil)
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupHUD() {
        hud?.animation = JGProgressHUDFadeZoomAnimation() as JGProgressHUDFadeZoomAnimation
        hud?.interactionType = JGProgressHUDInteractionType.blockNoTouches
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
        self.textView.endEditing(true)
    }

    fileprivate func addHeatMapLayer() {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.9
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints,
                                            colorMapSize: 256)
    }

    fileprivate func displayMunicipalityForm() {
        let alertStyle: UIAlertController.Style = .actionSheet
        //let alert = UIAlertController(style: alertStyle, title: "טופס רשויות", message: "שליחת תשובות לרשויות")
        let alert = UIAlertController(style: alertStyle)

        let textFieldOne: TextField.Config = configAlertTextField(placeHoler: "FIRST_NAME".localized, keyboardType: .default )

        let textFieldTwo: TextField.Config = configAlertTextField(placeHoler: "LAST_NAME".localized, keyboardType: .default )

        let textFieldThree: TextField.Config = configAlertTextField(placeHoler: "ID_NUMBER".localized, keyboardType: .phonePad )

        let textFieldFour: TextField.Config = configAlertTextField(placeHoler: "EMAIL".localized, keyboardType: .emailAddress )

        let textFieldFive: TextField.Config = configAlertTextField(placeHoler: "PHONE_NUMBER".localized, keyboardType: .phonePad )

        alert.addFiveTextFields(
            height: alertStyle == .alert ? 50 : 65,
            hInset: alertStyle == .alert ? 12 : 0,
            vInset: alertStyle == .alert ? 12 : 0,
            textFieldOne: textFieldOne,
            textFieldTwo: textFieldTwo,
            textFieldThree: textFieldThree,
            textFieldFour: textFieldFour,
            textFieldFive: textFieldFive)

        alert.addAction(title: "SEND_TO_AUTH".localized, style: .cancel) { [weak self] action in
            self?.pickTitle.text = "SENDING_ANSWERS".localized
            self?.restartMainViewState(1000)
        }
        alert.show()
    }

    private func configAlertTextField(placeHoler: String, keyboardType: UIKeyboardType ) -> TextField.Config {

        let textFieldResult: TextField.Config = { textField in
            //textField.left(image: #imageLiteral(resourceName: "user"), color: UIColor(hex: 0x007AFF))
            textField.leftViewPadding = 16
            textField.leftTextPadding = 12
            textField.borderWidth = 1
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.textColor = .black
            textField.placeholder = placeHoler
            textField.clearsOnBeginEditing = true
            textField.autocapitalizationType = .none
            textField.keyboardAppearance = .default
            textField.keyboardType = keyboardType
            //textField.isSecureTextEntry = true
            textField.returnKeyType = .done
            textField.action { textField in
                print("textField = \(String(describing: textField.text))")
            }
        }
        return textFieldResult
    }

    private func disableFilterAndHelpButtons(){
        filterButton.isEnabled = false;
        helpButton.isEnabled = false;
    }
    private func enableFilterAndHelpButtons(){
        filterButton.isEnabled = true;
        helpButton.isEnabled = true;
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
        // Add the latlng list to the heatmap layer.
        heatmapLayer.weightedData = list
        self.heatmapLayer.map = self.mapView
    }

    fileprivate func addMarkers(markers: [MarkerAnnotation]) {

        for marker in markers {
            let googleMarker: GMSMarker = GMSMarker() // Allocating Marker
            googleMarker.title =  marker.title ?? ""
            googleMarker.snippet = marker.subtitle ?? ""
            //googleMarker.icon = marker.
            googleMarker.appearAnimation = .pop // Appearing animation
            googleMarker.position = marker.coordinate
            DispatchQueue.main.async {
                googleMarker.map = self.mapView
            }
        }
    }

    func updateInfoIfPossible( filterChanged: Bool) {

        print("Getting Annotations...")
        self.pickTitle.text = "LOADING".localized
        let projection = mapView.projection.visibleRegion()
        //let topLeftCorner: CLLocationCoordinate2D = projection.farLeft
        let topRightCorner: CLLocationCoordinate2D = projection.farRight
        let bottomLeftCorner: CLLocationCoordinate2D = projection.nearLeft
        //let bottomRightCorner: CLLocationCoordinate2D = projection.nearRight
        let edges:Edges = (ne: topRightCorner, sw: bottomLeftCorner)

        hud?.show(in: view)

        network.getAnnotations(edges, filter: filter) { [weak self] (markers: [MarkerAnnotation], count: Int) in
            print("finished parsing annotations. markers count : \(markers.count)")
            guard let self = self else {return}
            self.removeHeatMapLayer()
            self.addHeatMapLayer()

            self.addHeatmap(markers: markers)
            //self.addMarkers(markers: markers)

            self.hud?.dismiss()
            self.currentState = .MarkersReceived
            DispatchQueue.main.async { [weak self]  in
                self?.pickTitle.text = "PLACES_MAKRKED_WITH_HEATMAP".localized
                //self?.setTitleWithContinue()
                self?.nextButton.isHidden = true
                self?.nextButton2.isHidden = false
            }
        }
    }

    private func removeHeatMapLayer() {
        heatmapLayer.map = nil
        heatmapLayer = nil
    }

}



// MARK: - GMSMapViewDelegate
extension MainViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if self.currentState == .start {
            reverseGeocodeCoordinate(position.target)
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
            self.mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: MainViewController.ZOOM)
        }
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {

        if self.currentState != .start  {
            mapView.resignFirstResponder()
            return
        }
        reverseGeocodeCoordinate(coordinate)
        addMarkerOnTheMap(coordinate)
        mapView.resignFirstResponder()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
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

    fileprivate func addMarkerOnTheMap(_ coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)

        self.currentState = .placePicked
        self.pickTitle.text = "TAP_CONTINUE_TO_GET_DANGEROUS_PLACES".localized
        marker.snippet = ""
        /// Add the marker on the map
        marker.map = self.mapView

        //marker.title = "המקום שנבחר כמסוכן"
        //self.setTitleWithContinue()
        self.nextButton.isHidden = false
        self.nextButton2.isHidden = true
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return }
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: MainViewController.ZOOM, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
        //fetchNearbyPlaces(coordinate: location.coordinate)
    }
}

// MARK: - FilterScreenDelegate
extension MainViewController: FilterScreenDelegate {

    func didCancel(_ vc: FilterViewController, filter: Filter) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }

    func didSave(_ vc: FilterViewController, filter: Filter) {
        self.navigationController?.isNavigationBarHidden = true
        self.filter = filter
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Questionnaires
extension MainViewController {

    private func displayFirstQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 170))

        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "WHY_DID_YOU_SUSPECT_THIS_PLACE".localized)
        snackView.addSubview(label)
        self.textView = UITextView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width , height: 50))
        self.textView.textColor = UIColor.black
        self.textView.textAlignment = NSTextAlignment.center
        self.textView.font = UIFont.systemFont(ofSize: 14)
        self.textView.text = ""
        snackView.addSubview(self.textView)
        let continueButton = UIButton(frame: CGRect(x: 173, y: 120, width: 60, height: 35))
        continueButton.tintColor = UIColor.black
        continueButton.setTitle("CONT".localized, for: UIControl.State.normal)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.backgroundColor = UIColor.lightGray
        continueButton.cornerRadius = 4
        continueButton.addTarget(self, action:#selector(self.continueButtonClicked), for: .touchUpInside)
        snackView.addSubview(continueButton)
        snackbarView.showSnackBar(superView: self.view, bgColor: MainViewController.SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displaySecondQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "SIGNS_ARE_CLEAR".localized)
        snackView.addSubview(label)
        self.addYesNoButtons(toView:snackView, yesAction:#selector(self.yesButtonClicked), noAction:#selector(self.noButtonClicked) )
        snackbarView.showSnackBar(superView: self.view, bgColor: MainViewController.SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displayThirdQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "PROBLEM_WITH_SIGN".localized)
        snackView.addSubview(label)
        self.addYesNoButtons(toView:snackView, yesAction:#selector(self.yesButtonClickedLast), noAction:#selector(self.noButtonClickedLast) )
        snackbarView.showSnackBar(superView: self.view, bgColor: MainViewController.SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displayForthQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "WISH_TO_SEND_ANSWERS".localized)
        snackView.addSubview(label)

        self.addYesNoButtons(toView:snackView, yesAction:#selector(self.sendButtonClicked), noAction:#selector(self.cancelButtonClicked) )
        snackbarView.showSnackBar(superView: self.view, bgColor: MainViewController.SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func addYesNoButtons(toView: UIView, yesAction: Selector, noAction: Selector) {

        let yesButton = UIButton.questionnaireButton(frame: CGRect(x: 150, y: 80, width: MainViewController.YES_NO_BUTTON_WIDTH, height: MainViewController.YES_NO_BUTTON_HEIGHT), title: "YES".localized)
        yesButton.addTarget(self, action:yesAction, for: .touchUpInside)
        toView.addSubview(yesButton)

        let noButton = UIButton.questionnaireButton(frame: CGRect(x: 210, y: 80, width: MainViewController.YES_NO_BUTTON_WIDTH, height: MainViewController.YES_NO_BUTTON_HEIGHT), title: "NO".localized)
        noButton.addTarget(self, action:noAction, for: .touchUpInside)
        toView.addSubview(noButton)
    }
    @objc func continueButtonClicked() {
        print("Fist Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.displaySecondQuestionnaire()
        }
    }
    @objc func yesButtonClicked() {
        print("yes Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.displayThirdQuestionnaire()
        }
    }
    @objc func noButtonClicked() {
        print("no Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.displayThirdQuestionnaire()
        }
    }
    @objc func yesButtonClickedLast() {
        print("yes Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.displayForthQuestionnaire()
        }
    }
    @objc func noButtonClickedLast() {
        print("no Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.displayForthQuestionnaire()
        }
    }
    @objc func cancelButtonClicked() {
        print("cancel Button Clicked")
        snackbarView.hideSnackBar()
        restartMainViewState(200)
    }
    @objc func sendButtonClicked() {
        print("send Button Clicked")
        snackbarView.hideSnackBar()
        displayMunicipalityForm()
    }
}
