//
//  GetAnnotationEndPoint.swift
//  Anyway
//
//  Created by Yigal Omer on 26/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation

public enum GetAnnotationEndPoint: APIEndPoint {

    case markers
    case marker_details

    public var info: APIEndPointInfo {
        switch self {
        case .markers:
            return (.get, "/markers")

        case .marker_details:
            return (.get, "/marker_details")

        }

    }
}


