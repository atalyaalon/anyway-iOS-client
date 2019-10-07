//
//  AddImageViewModel.swift
//  Anyway
//
//  Created by Yigal Omer on 01/09/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import RSKImageCropper

class AddImageViewModel: NSObject, UINavigationControllerDelegate {

    weak var view: AddImageInput?

    private weak var cropDelegate: RSKImageCropViewControllerDelegate?
    private weak var imagePickerController: UIImagePickerController?
    private var selectedImageView: UIImageView?


    init(viewController: AddImageInput?) {
        self.view = viewController
        super.init()
        self.cropDelegate = self
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

}



// MARK: - UIImagePickerControllerDelegate
extension AddImageViewModel: UIImagePickerControllerDelegate {

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

// MARK: - RSKImageCropViewControllerDelegate
extension AddImageViewModel : RSKImageCropViewControllerDelegate {

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.closeImagePicker()
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        DispatchQueue.main.async {
            self.selectedImageView?.image = croppedImage
            self.closeImagePicker()

            self.view?.setSelectedImage(image: croppedImage)
        }
    }
}

// MARK: - AddImageViewOutput
extension AddImageViewModel: AddImageOutput {

    func viewDidLoad() {
    }

    func showSelectImageAlert(_ withSkip: Bool) {
        let selecetImageAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        selecetImageAlert.addAction(UIAlertAction(title: "SELECT_IMAGE_ALERT_ACTION_TAKE_PHOTO".localized, style: .default) { [unowned self] _ in
            self.openCameraScreen(delegate: self.cropDelegate!)
        })
        selecetImageAlert.addAction(UIAlertAction(title: "SELECT_IMAGE_ALERT_ACTION_SELECT_FROM_ALBUM".localized, style: .default) { [unowned self] _ in
            self.openImagePickerScreen(delegate: self.cropDelegate!)
        })

        if withSkip {
            selecetImageAlert.addAction(UIAlertAction(title: "SKIP".localized, style: .default) { (action: UIAlertAction) in

                self.view?.skipSelectedWhenAddingImage()
                //self.startSelectHazardView()
            })
        }

        selecetImageAlert.addAction(UIAlertAction(title: "CANCEL".localized, style: .cancel))
        self.view?.showAlert(selecetImageAlert, animated: true)
    }

    func closeImagePicker() {
        self.imagePickerController?.dismiss(animated: true)
        self.imagePickerController = nil

    }


}
