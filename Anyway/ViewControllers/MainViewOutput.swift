//
//  MainViewOutput.swift
//  Anyway
//
//  Created by Yigal Omer on 28/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit


protocol MainViewOutput : ViewOutput {


    func handleFilterTap()

    func handleHelpTap()

    //func getAnnotations(_ edges: Edges, response: ()->Void  )

    //func closeImagePicker()

    func handleReportButtonTap()

    func handleSendToMunicipalityTap()

    func handleNextButtonTap(_ mapRectangle: GMSVisibleRegion)

    func handleCancelButtonTap()

    func handleCancelSendButtonTap()

    func handleTapOnTheMap(coordinate: CLLocationCoordinate2D)

    func handleCameraMovedToPosition(coordinate: CLLocationCoordinate2D)

    func setSelectedImage(image: UIImage)

}

