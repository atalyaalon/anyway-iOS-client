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

class MainViewController: UIViewController {

    @IBOutlet weak var nextButton: MDCFloatingButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var pickTitle: UITextView!
    var locationManager = CLLocationManager()
    var pickCount:Int = 0
    private let ZOOM: Float = 16
    private let BUTTON_WIDTH = 50
    private let BUTTON_HEIGHT = 40
    private let SNACK_BAR_BG_COLOR = UIColor.purple
    let network = Network()
    var hud = JGProgressHUD(style: .light)
    var filter = Filter()
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.02, 0.09] as [NSNumber]
    private var heatmapLayer: GMUHeatmapTileLayer!
    //private var keyboardObserver: KeyboardObserver = KeyboardObserver()
    private var textView = UITextView()
    private var snackbarView = SnackBarView()
    var pickTitleFrameWithContinue = CGRect(x: 0, y: 0, width: 0, height:0)
    var pickTitleFrameWithoutContinue = CGRect(x: 0, y: 0, width: 0, height:0)


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.setupMapView()
        self.initLocationManager()
        setupTitle()
        setupHUD()
        mapView.animate(toZoom: ZOOM)
        addKeyboardObservers()
        addTapGesture()
        addHeatMapLayer()
        restartMainViewState()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = true
//    }

    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    private func setupTitle() {
        nextButton.setTitle("CONTINUE".localized, for: UIControl.State.normal)
        nextButton.backgroundColor = UIColor.lightGray
        nextButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        nextButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)

        // keep reference to  frames
        pickTitleFrameWithoutContinue = pickTitle.frame
        pickTitleFrameWithContinue = CGRect(x: 0, y: 0, width: pickTitle.frame.width, height: pickTitle.frame.height * 2 + 10)
        //nextButton.applyOutlinedTheme(withScheme: containerScheme)

        setTitleWithoutContinue()
    }
    private func setTitleWithContinue() {
        self.nextButton.isHidden = false
        self.pickTitle.frame = pickTitleFrameWithContinue

        super.updateViewConstraints()
        view.setNeedsUpdateConstraints()
    }
    private func setTitleWithoutContinue() {
        self.nextButton.isHidden = true
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

    fileprivate func setupHelpButton() {
        let helpButton = MDCFloatingButton(frame: CGRect(x: 330, y: 125, width: 26, height: 26))
        helpButton.setImage(#imageLiteral(resourceName: "information"), for: .normal)
        helpButton.backgroundColor = UIColor.clear
        helpButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        helpButton.addTarget(self, action: #selector(handleHelpTap), for: .touchUpInside)
        self.view.addSubview(helpButton)
    }

    @objc func handleHelpTap(_ sender: UIButton) {
        print("Help button tapped")
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoViewController") as UIViewController
        self.present(viewController, animated: false, completion: nil)
    }

    fileprivate func setupFilterButton() {
        let helpButton = MDCFloatingButton(frame: CGRect(x: 30, y: 125, width: 21, height: 21))
        //let helpButton = UIButton(frame: CGRect(x: 30, y: 150, width: 26, height: 26))
        helpButton.setImage(#imageLiteral(resourceName: "filter_add"), for: .normal)
        helpButton.backgroundColor = UIColor.clear
        helpButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        helpButton.addTarget(self, action: #selector(handleFilterTap), for: .touchUpInside)
        self.view.addSubview(helpButton)
    }

    @objc func handleFilterTap(_ sender: UIButton) {
        print("Help button tapped")
        let viewController:FilterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterViewController") as UIViewController as! FilterViewController
        viewController.filter = filter
        viewController.delegate = self as FilterScreenDelegate

        self.navigationController!.pushViewController(viewController, animated: true)
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

    @objc func continueButtonClicked() {
        print("Fist Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.displaySecondQuestionnaire()
        }
    }
    @objc func yesButtonClicked() {
        print("yes Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
             self.displayThirdQuestionnaire()
        }
    }
    @objc func noButtonClicked() {
        print("no Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.displayThirdQuestionnaire()
        }
    }
    @objc func yesButtonClickedLast() {
        print("yes Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.displayForthQuestionnaire()
        }
    }
    @objc func noButtonClickedLast() {
        print("no Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.displayForthQuestionnaire()
        }
    }

    fileprivate func restartMainViewState(_ after: Int = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(after)) {
            self.pickCount = 0
            self.mapView.clear()
            self.pickTitle.text = "CHOOSE_A_PLACE".localized
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
        self.pickTitle.text = "SENDING_ANSWERS".localized

        displayMunicipalityForm()
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
            self?.restartMainViewState(1000)
        }
        alert.show()
    }

    private func configAlertTextField(placeHoler: String, keyboardType: UIKeyboardType ) -> TextField.Config {

        let textFieldResult: TextField.Config = { textField in
            textField.left(image: #imageLiteral(resourceName: "user"), color: UIColor(hex: 0x007AFF))
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
        continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        continueButton.backgroundColor = UIColor.lightGray
        continueButton.cornerRadius = 4
        continueButton.addTarget(self, action:#selector(self.continueButtonClicked), for: .touchUpInside)
        snackView.addSubview(continueButton)
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displaySecondQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "SIGNS_ARE_CLEAR".localized)
        snackView.addSubview(label)
       self.addYesNoButtons(toView:snackView, yesAction:#selector(self.yesButtonClicked), noAction:#selector(self.noButtonClicked) )
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displayThirdQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "PROBLEM_WITH_SIGN".localized)
        snackView.addSubview(label)
        self.addYesNoButtons(toView:snackView, yesAction:#selector(self.yesButtonClickedLast), noAction:#selector(self.noButtonClickedLast) )
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displayForthQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "WISH_TO_SEND_ANSWERS".localized)
        snackView.addSubview(label)

        self.addYesNoButtons(toView:snackView, yesAction:#selector(self.sendButtonClicked), noAction:#selector(self.cancelButtonClicked) )
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func addYesNoButtons(toView: UIView, yesAction: Selector, noAction: Selector) {

        let yesButton = UIButton.questionnaireButton(frame: CGRect(x: 150, y: 80, width: BUTTON_WIDTH, height: BUTTON_HEIGHT), title: "YES".localized)
        yesButton.addTarget(self, action:yesAction, for: .touchUpInside)
        toView.addSubview(yesButton)

        let noButton = UIButton.questionnaireButton(frame: CGRect(x: 210, y: 80, width: BUTTON_WIDTH, height: BUTTON_HEIGHT), title: "NO".localized)
        noButton.addTarget(self, action:noAction, for: .touchUpInside)
        toView.addSubview(noButton)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {

        DispatchQueue.main.async { [weak self]  in
             guard let self = self else { return }

            if self.pickCount == 1 {
                //self.nextButton.isEnabled = false
                self.setTitleWithoutContinue()
                self.updateInfoIfPossible(filterChanged:false)
            } else if self.pickCount == 2 {
                //self.nextButton.isEnabled = false
                self.setTitleWithoutContinue()
                self.pickTitle.text = "SHORT_QUESTIONNAIRE".localized
                self.snackbarView = SnackBarView()
                self.displayFirstQuestionnaire()
            }
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
            print("finished parsing. markers count : \(markers.count)")
            guard let self = self else {return}
            self.removeHeatMapLayer()
            self.addHeatMapLayer()

            self.addHeatmap(markers: markers)
            //self.addMarkers(markers: markers)

            self.hud?.dismiss()
            self.pickCount = 2
            DispatchQueue.main.async { [weak self]  in
                self?.pickTitle.text = "PLACES_MAKRKED_WITH_HEATMAP".localized
                self?.setTitleWithContinue()
            }


        }
    }

    private func removeHeatMapLayer() {
        heatmapLayer.map = nil
        heatmapLayer = nil
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
}

// MARK: - GMSMapViewDelegate
extension MainViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if self.pickCount < 1 {
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
        
        if self.pickCount >= 1 {
            mapView.resignFirstResponder()
            return
        }
        reverseGeocodeCoordinate(coordinate)
        // Creates a marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
  
        self.pickCount += 1
        self.pickTitle.text = "TAP_CONTINUE_TO_GET_DANGEROUS_PLACES".localized
        marker.snippet = ""
        marker.map = self.mapView
        if self.pickCount == 1 {
            //marker.title = "המקום שנבחר כמסוכן"
            //self.nextButton.isHidden = true
             self.setTitleWithContinue()

            //self.nextBarButton.isEnabled = true
        }
        mapView.resignFirstResponder()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return }
        locationManager.startUpdatingLocation()
//        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: ZOOM, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
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


extension MainViewController: FilterScreenDelegate {

    func didCancel(_ vc: FilterViewController, filter: Filter) {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)

    }

    func didSave(_ vc: FilterViewController, filter: Filter) {
//        dismiss(animated: true) {
//            self.filter = filter
//            //self.updateInfoIfPossible( filterChanged: true)
//        }
        self.navigationController?.isNavigationBarHidden = true
        self.filter = filter
        self.navigationController?.popViewController(animated: true)
    }

}


