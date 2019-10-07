//
//  BaseViewConroller.swift
//  Anyway
//
//  Created by Yigal Omer on 02/09/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, ViewInput {

    private var loadingIndicator: UIActivityIndicatorView!
    //
    // MARK: Lifecycle
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingIndicator()
    }

    @objc func setupView() {
    }

    func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }

    func showAlert(_ alert: UIAlertController, animated: Bool) {
        print("Trying to show alert of base VC. Am I on main thread? \(Thread.isMainThread)")
        if Thread.callStackSymbols.count > 2 {
            print("Who called me: \(Thread.callStackSymbols[2])")
        }
        self.present(alert, animated: animated, completion: nil)
    }

    func show(error: String) {
        print("Trying to show error of base VC. Am I on main thread? \(Thread.isMainThread)")
        if Thread.callStackSymbols.count > 2 {
            print("Who called me: \(Thread.callStackSymbols[2])")
        }
        let alertController: UIAlertController = UIAlertController(title: error, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .cancel))

        present(alertController, animated: true, completion: nil)
    }

    public func displayErrorAlert(error: Error? = nil) {
        let title = "Error"
        var erroDesc = ""
        if let err = error {
            erroDesc = err.localizedDescription
        }
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

    var isApplicationActive: Bool {
        return UIApplication.shared.applicationState == UIApplication.State.active 
    }

    //
    // MARK: Layout
    //
    override func updateViewConstraints() {

        loadingIndicator.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
        }
        super.updateViewConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.view.bringSubviewToFront(self.loadingIndicator)
    }

    //
    // MARK: Private
    //
    private func setupLoadingIndicator() {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true

        self.view.addSubview(view)
        self.loadingIndicator = view
    }

    func addCustomBackButton() {
        let backButton: UIButton = UIButton(type: .custom)
        backButton.setTitle("BACK".localized, for: .normal)
        backButton.setTitleColor(UIColor.f8Blue, for: .normal)
        backButton.setImage(#imageLiteral(resourceName: "BackIcon"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(onBackButtonClick), for: .touchUpInside)

        let backBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }

    @objc func onBackButtonClick() {
        print("On back button click called. Am I on main thread? \(Thread.isMainThread)")
        if Thread.callStackSymbols.count > 2 {
            print("Who called me: \(Thread.callStackSymbols[2])")
        }
        self.navigationController?.popViewController(animated: true)
    }

//    func onHandleError(_ error: Error, figure8ErrorHandler: Figure8ErrorHandler) -> Bool {
//        return false
//    }
}

