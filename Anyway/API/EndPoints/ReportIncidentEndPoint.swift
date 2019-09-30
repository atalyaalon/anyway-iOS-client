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
            return (.post, "/report-problem")
        }
    }
    
    
//    {
//    "email": "adva@gmail.com",
//    "first_name": "adva",
//    "last_name": "klinger",
//    "latitude": 23.5,
//    "longitude": 24.4,
//    "problem_description": "blablu",
//    "signs_on_the_road_not_clear": true,
//    "signs_problem": true,
//    "pothole": true,
//    "no_light": true,
//    "no_sign": true,
//    "crossing_missing": true,
//    "sidewalk_is_blocked": true,
//    "street_light_issue": true,
//    "road_hazard": true,
//    "phone_number": "1234",
//    "personal_id": "123",
//    "send_to_municipality": true,
//    "image_data": "blablabla"
//    }
}


