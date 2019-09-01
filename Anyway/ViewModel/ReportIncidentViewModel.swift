//
//  ReportIncidentViewModel.swift
//  Anyway
//
//  Created by Yigal Omer on 01/09/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import RSKImageCropper

enum ReportIncidentVCState: Int {
    case start = 0
}

class ReportIncidentViewModel: NSObject {

    weak var view: ReportIncidentInput?
    private var api: AnywayAPIImpl

    init(viewController: ReportIncidentInput?) {
        self.view = viewController
        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = Config.TIMEOUT_INTERVAL_FOR_REQUEST
        self.api = AnywayAPIImpl(sessionConfiguration: sessionConfiguration)
        super.init()

    }



}



// MARK: - MainViewOutput
extension ReportIncidentViewModel: ReportIncidentOutput {


    func viewDidLoad() {

        self.view?.setupView()
        //self.setMainViewState(state: .start)
    }
}



