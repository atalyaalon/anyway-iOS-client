//
//  GetAnnotationEndPoint.swift
//  Anyway
//
//  Created by Yigal Omer on 26/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation

public enum ReportIncidentEndPoint: APIEndPoint {

    case report_incident

    public var info: APIEndPointInfo {
        switch self {
        case .report_incident:
            return (.get, "/report_incident")
        }
    }
}


