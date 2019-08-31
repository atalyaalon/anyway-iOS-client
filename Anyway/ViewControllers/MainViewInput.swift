//
//  MainViewInput.swift
//  Anyway
//
//  Created by Yigal Omer on 28/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit

protocol MainViewInput: ViewInput {

    func displayErrorAlert(error: Error?)

    func showImagPickerScreen(_ pickerController: UIImagePickerController, animated: Bool)

    func showAlert(_ alert: UIAlertController, animated: Bool)

    func pushViewController(_ vc: UIViewController, animated: Bool)

    func popViewController( animated: Bool)

    //func restartMainViewState(_ after: Int)

    //func displaySendAnswersQuestionnaire()

    func addCoordinateListToHeatMap(coordinateList: [GMUWeightedLatLng])

    func removeHeatMapLayer()

    func addHeatMapLayer()

    func disableFilterAndHelpButtons()

    //func disableAllFloatingButtons()
    
    //func setMainViewState(state: MainVCState)

    func setCameraPosition(coordinate : CLLocationCoordinate2D)

    func setAddressLabel(address: String)

    func setActionForState(state: MainVCState)
    
    func setMarkerOnTheMap(coordinate: CLLocationCoordinate2D)

    
}
