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
    case hazardSelected = 4
}


class MainViewModel: NSObject, UINavigationControllerDelegate {
 

    let TIMEOUT_INTERVAL_FOR_REQUEST: Double = 15

    private var api: AnywayAPIImpl
    private let hud = JGProgressHUD(style: .light)
    weak var view: MainViewInput?
    private weak var cropDelegate: RSKImageCropViewControllerDelegate?
    private weak var imagePickerController: UIImagePickerController?
    private var filter = Filter()
    private var locationManager = CLLocationManager()
    private var currentState:MainVCState = .start


    init(viewController: MainViewInput?) {
        self.view = viewController
        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TIMEOUT_INTERVAL_FOR_REQUEST
        self.api = AnywayAPIImpl(sessionConfiguration: sessionConfiguration)
        self.cropDelegate = viewController as? RSKImageCropViewControllerDelegate
    }

    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func openImagePickerScreen(delegate: RSKImageCropViewControllerDelegate) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false
        pickerController.delegate = self
        self.imagePickerController = pickerController
        self.view?.showImagPickerScreen(pickerController, animated: true)
    }

    func openCameraScreen(delegate: RSKImageCropViewControllerDelegate) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.allowsEditing = false
        pickerController.cameraCaptureMode = .photo
        pickerController.delegate = self
        self.imagePickerController = pickerController
        self.view?.showImagPickerScreen(pickerController, animated: true)
    }

    // MARK: - Select image alert
    func showSelectImageAlert() {
        let selecetImageAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        selecetImageAlert.addAction(UIAlertAction(title: "select_image_alert_action_take_photo".localized, style: .default) { [unowned self] _ in
            self.openCameraScreen(delegate: self.cropDelegate!)
        })
        selecetImageAlert.addAction(UIAlertAction(title: "select_image_alert_action_select_from_album".localized, style: .default) { [unowned self] _ in
            self.openImagePickerScreen(delegate: self.cropDelegate!)
        })

        selecetImageAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.view?.showAlert(selecetImageAlert, animated: true)
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
        let selectHazardViewController:SelectHazardViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "SelectHazardViewController") as UIViewController as! SelectHazardViewController

        selectHazardViewController.delegate = self as SelectHazardViewControllerDelegate
        self.view?.pushViewController(selectHazardViewController, animated: true)
    }

    private func configAlertTextField(placeHoler: String, keyboardType: UIKeyboardType ) -> TextField.Config {

        let textFieldConfig: TextField.Config = { (textField:TextField) in
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
        return textFieldConfig
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

        self.api.getAnnotationsRequest(edges, filter: filter) { (markers: [NewMarker]?) in

            self.hideHUD()
            guard let markers = markers else {
                print("finished parsing annotations. ERROR markers ar nil")
                self.view?.displayErrorAlert(error: nil)
                self.setMainViewState(state: .start)
                return
            }
            if  markers.count == 0  {
                print("finished parsing annotations. no markers received")
                self.view?.displayErrorAlert(error: nil)
                self.setMainViewState(state: .start)
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

    func closeImagePicker() {
        self.imagePickerController?.dismiss(animated: true)
        self.imagePickerController = nil

    }

    func handleReportButtonTap() {
        startSelectHazardView()
    }


    func handleSendToMunicipalityTap() {
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
            //self?.pickTitle.text = "SENDING_ANSWERS".localized
            self?.setMainViewState(state: .start)
        }

        self.view?.showAlert(alert, animated: true)
    }
    func handleNextButtonTap(_ mapRectangle: GMSVisibleRegion) {

        let topRightCorner: CLLocationCoordinate2D = mapRectangle.farRight
        let bottomLeftCorner: CLLocationCoordinate2D = mapRectangle.nearLeft
        let edges:Edges = (ne: topRightCorner, sw: bottomLeftCorner)

        self.setMainViewState(state: .continueTappedAfterPlacePicked)

        self.getAnnotations(edges)
    }
    func handleCancelButtonTap() {
        self.setMainViewState(state: .start)
    }

    func handleCancelSendButtonTap() {
        self.setMainViewState(state: .start)
    }

    func handleTapOnTheMap(coordinate: CLLocationCoordinate2D){
        if self.currentState != .start  {
            //mapView.resignFirstResponder()
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

// MARK: - SelectHazardViewControllerDelegate
extension MainViewModel: SelectHazardViewControllerDelegate {
    func didSelectHazard(selectedItems: Array<Any>?, hazardDescription: String?) {
        let hazards:Array<HazardData>? = selectedItems as? Array<HazardData>

        print("didSelectHazard Hazard = \(hazards ?? [])  hazardDescription =\(hazardDescription ?? "")")
        view?.popViewController(animated: true)

        self.setMainViewState(state: .hazardSelected)
        //view?.displaySendAnswersQuestionnaire()
    }

    func didCancelHazard() {
        view?.popViewController(animated: true)
    }
}


// MARK: - UIImagePickerControllerDelegate
extension MainViewModel: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController = nil
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let viewController = RSKImageCropViewController(image: image, cropMode: .square)
            viewController.delegate = self.cropDelegate
            picker.pushViewController(viewController, animated: true)
        } else {
            self.imagePickerController = nil
        }
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


