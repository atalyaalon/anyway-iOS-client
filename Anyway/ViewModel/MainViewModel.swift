//
//  HazardsViewModel.swift
//  Anyway
//
//  Created by Yigal Omer on 26/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import RSKImageCropper

class MainViewModel: NSObject, UINavigationControllerDelegate {
 

    let TIMEOUT_INTERVAL_FOR_REQUEST: Double = 15

    private var api: AnywayAPIImpl
    private let hud = JGProgressHUD(style: .light)
    weak var view: MainViewInput?
    private weak var cropDelegate: RSKImageCropViewControllerDelegate?
    private weak var imagePickerController: UIImagePickerController?
    private var filter = Filter()


    init(viewController: MainViewInput?) {
        self.view = viewController
        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TIMEOUT_INTERVAL_FOR_REQUEST
        self.api = AnywayAPIImpl(sessionConfiguration: sessionConfiguration)
        self.cropDelegate = viewController as? RSKImageCropViewControllerDelegate
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

    func showHUD() {
        DispatchQueue.main.async {
            if let view = self.view as? UIViewController {
                self.hud?.show(in: view.view, animated:true);
                //hud.mode = .indeterminate
                self.hud?.textLabel.text = "LOADING".localized
            }
        }
    }

    func hideHUD() {
        DispatchQueue.main.async {
            self.hud?.isHidden = true
        }
    }


    //let imageData = selectedImageView?.image?.jpegData(compressionQuality: 0.8)
    


}



// MARK: - FilterScreenDelegate
extension MainViewModel: MainViewOutput {

    func getAnnotations(_ edges: Edges, anotations: (( [NewMarker]?)->Void )? ){

        showHUD()

        self.api.getAnnotationsRequest(edges, filter: filter) { (markers: [NewMarker]?) in

            self.hideHUD()
            if markers == nil ||  markers?.count == 0  {
                print("finished parsing annotations. no markers received")
                self.view?.displayErrorAlert(error: nil)
                self.view?.restartMainViewState(0)
                return
            }
            print("finished parsing annotations. markers count : \(String(describing: markers?.count))")

            anotations?(markers)
        }
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

