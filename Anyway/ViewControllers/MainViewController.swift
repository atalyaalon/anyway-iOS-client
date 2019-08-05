//
//  MainViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 15/05/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import GoogleMaps

class MainViewController: UIViewController {

    @IBOutlet weak var nextBarButton: UIBarButtonItem!
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
    private var keyboardObserver: KeyboardObserver = KeyboardObserver()
    private var textView = UITextView()
    private var snackbarView = SnackBarView()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMapView()
        self.initLocationManager()
        mapView.settings.compassButton = true
        self.nextBarButton.isEnabled = false
        setupHUD()
        mapView.animate(toZoom: ZOOM)
        addKeyboardObservers()
        addTapGesture()
        addHeatMapLayer()
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

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.displaySecondQuestionnaire()
        }
    }
    @objc func yesButtonClicked() {
        print("yes Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
             self.displayThirdQuestionnaire()
        }
    }
    @objc func noButtonClicked() {
        print("no Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.displayThirdQuestionnaire()
        }
    }
    @objc func yesButtonClickedLast() {
        print("yes Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.displayForthQuestionnaire()
        }
    }
    @objc func noButtonClickedLast() {
        print("no Button Clicked")
        snackbarView.hideSnackBar()
        snackbarView = SnackBarView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.displayForthQuestionnaire()
        }
    }
    @objc func cancelButtonClicked() {
        print("cancel Button Clicked")
        snackbarView.hideSnackBar()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.pickCount = 0
            self.mapView.clear()
            self.pickTitle.text = "בחר מקום על המפה שאתה חושד בו כמסוכן"
        }
    }
    @objc func sendButtonClicked() {
        print("send Button Clicked")
        snackbarView.hideSnackBar()
        self.pickTitle.text = "שולח תשובות..."
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.pickCount = 0
            self.mapView.clear()
            self.pickTitle.text = "בחר מקום על המפה שאתה חושד בו כמסוכן"
        }
    }

    private func displayFirstQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 170))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "?מדוע חשדת שמקום זה מסוכן")
        snackView.addSubview(label)
        self.textView = UITextView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width , height: 50))
        self.textView.textColor = UIColor.black
        self.textView.textAlignment = NSTextAlignment.center
        self.textView.font = UIFont.systemFont(ofSize: 14)
        self.textView.text = ""
        snackView.addSubview(self.textView)
        let continueButton = UIButton(frame: CGRect(x: 173, y: 120, width: 60, height: 35))
        continueButton.tintColor = UIColor.black
        continueButton.setTitle("המשך", for: UIControl.State.normal)
        continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        continueButton.backgroundColor = UIColor.lightGray
        continueButton.cornerRadius = 4
        continueButton.addTarget(self, action:#selector(self.continueButtonClicked), for: .touchUpInside)
        snackView.addSubview(continueButton)
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displaySecondQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "? האם הסימונים על הכביש ברורים")
        snackView.addSubview(label)
       self.addYesNoButtons(toView:snackView, yesAction:#selector(self.yesButtonClicked), noAction:#selector(self.noButtonClicked) )
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displayThirdQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "?האם קיימת בעיה בתמרור")
        snackView.addSubview(label)
        self.addYesNoButtons(toView:snackView, yesAction:#selector(self.yesButtonClickedLast), noAction:#selector(self.noButtonClickedLast) )
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func displayForthQuestionnaire() {
        let snackView = UIView( frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20.0, height: 130))
        let label = UILabel.questionnaireLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), text: "מעוניין לשלוח אלינו תשובות")
        snackView.addSubview(label)
        let yesButton = UIButton.questionnaireButton(frame: CGRect(x: 150, y: 80, width: BUTTON_WIDTH, height: BUTTON_HEIGHT), title: "שלח")
        yesButton.addTarget(self, action:#selector(self.sendButtonClicked), for: .touchUpInside)
        snackView.addSubview(yesButton)
        let noButton = UIButton.questionnaireButton(frame: CGRect(x: 210, y: 80, width: BUTTON_WIDTH, height: BUTTON_HEIGHT), title: "בטל")
        noButton.addTarget(self, action:#selector(self.cancelButtonClicked), for: .touchUpInside)
        snackView.addSubview(noButton)
        snackbarView.showSnackBar(superView: self.view, bgColor: SNACK_BAR_BG_COLOR, snackbarView: snackView)
    }

    private func addYesNoButtons(toView: UIView, yesAction: Selector, noAction: Selector) {

        let yesButton = UIButton.questionnaireButton(frame: CGRect(x: 150, y: 80, width: BUTTON_WIDTH, height: BUTTON_HEIGHT), title: "כן")
        yesButton.addTarget(self, action:yesAction, for: .touchUpInside)
        toView.addSubview(yesButton)

        let noButton = UIButton.questionnaireButton(frame: CGRect(x: 210, y: 80, width: BUTTON_WIDTH, height: BUTTON_HEIGHT), title: "לא")
        noButton.addTarget(self, action:noAction, for: .touchUpInside)
        toView.addSubview(noButton)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {

        DispatchQueue.main.async { [weak self]  in
             guard let self = self else { return }

            if self.pickCount == 1 {
                self.nextBarButton.isEnabled = false
                self.updateInfoIfPossible(filterChanged:false)
            } else if self.pickCount == 2 {
                self.nextBarButton.isEnabled = false
                self.pickTitle.text = "שאלון קצר"
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
        self.pickTitle.text = "טוען נתונים..."
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
                self?.pickTitle.text = "המקומות המסוכנים מוצגים בעזרת מפת חום. לחץ המשך"
            }
            self.nextBarButton.isEnabled = true
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
        self.pickTitle.text = "לחץ המשך"
        marker.snippet = ""
        marker.map = self.mapView
        if self.pickCount == 1 {
            marker.title = "המקום שנבחר כמסוכן"
            self.nextBarButton.isEnabled = true
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
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
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


