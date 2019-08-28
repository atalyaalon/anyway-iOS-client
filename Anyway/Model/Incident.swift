//
//  NewMarker.swift
//  Anyway
//
//  Created by Yigal Omer on 25/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation
import UIKit


struct Incident{

    var longitude: Double
    var latitude: Double
    var signs_on_the_road_not_clear: Bool
    var signs_problem: Bool
    var pothole: Bool
    var no_light: Bool
    var no_sign: Bool
    var crossing_missing: Bool
    var sidewalk_is_blocked: Bool
    var street_light_issue: Bool
    var road_hazard: Bool
    var fist_name: String
    var last_name: String
    var phone_number: String
    var email: String
    var id: String
    var send_to_monicipality: Bool
    var problem_descripion: Bool
    var imageData: Data



    enum CodingKeys: String, CodingKey {
        case markers = "markers"
    }
}

