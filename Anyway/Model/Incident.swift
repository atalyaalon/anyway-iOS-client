//
//  Incident.swift
//  Anyway
//
//  Created by Yigal Omer on 25/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation
import UIKit


struct Incident{


    var signs_on_the_road_not_clear: Bool // 0
    var sidewalk_is_blocked: Bool //1
    var pothole: Bool //2
    var no_sign: Bool //3
    var road_hazard: Bool//4
    var no_light: Bool//5
    var crossing_missing: Bool//6
    var signs_problem: Bool//7
    var street_light_issue: Bool//8

    var longitude: Double
    var latitude: Double
    
    var fist_name: String?
    var last_name: String?
    var id: String?
    var email: String?
    var phone_number: String?

    var send_to_monicipality: Bool
    var problem_descripion: String?
    var imageData: Data?
    
    init() {
        self.signs_on_the_road_not_clear = false
        self.sidewalk_is_blocked = false
        self.pothole = false
        self.no_sign = false
        self.road_hazard = false
        self.no_light = false
        self.crossing_missing = false
        self.signs_problem = false
        self.street_light_issue = false
        
        self.longitude = 0.0
        self.latitude = 0.0
        self.send_to_monicipality = false
    }

}

