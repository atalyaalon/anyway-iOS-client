//
//  Constants.swift
//  Anyway
//
//  Created by Aviel Gross on 8/10/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation

/// When launching and the user location is unknown - show this fallback coordinate
let fallbackStartLocationCoordinate = CLLocationCoordinate2D(latitude: 32.158091269627874, longitude: 34.88087036877948)

/// When launching and zooming to inital location - show this radius
let appLaunchZoomRadius = 0.005


struct AnywayColor {
    static var red = UIColor(red:0.856, green:0.123, blue:0.168, alpha:1)
    static var orange = UIColor(red:1, green:0.626, blue:0, alpha:1)
    static var yellow = UIColor(red:1, green:0.853, blue:0, alpha:1)
    static var blue = UIColor(red:0, green:0.526, blue:0.808, alpha:1)
}

enum Severity: Int {
    case fatal = 1, severe, light, various
}

enum AccidentType: Int {
    case carToCar = -1
    case carToObject = -2
    case carToPedestrian = 1
}

enum AccidentMinorType: Int {
    case car_TO_CAR = -1 // Synthetic type
    case car_TO_OBJECT = -2 // Synthetic type
    case car_TO_PEDESTRIAN = 1
    case front_TO_SIDE = 2
    case front_TO_REAR = 3
    case side_TO_SIDE = 4
    case front_TO_FRONT = 5
    case with_STOPPED_CAR_NO_PARKING = 6
    case with_STOPPED_CAR_PARKING = 7
    case with_STILL_OBJECT = 8
    case off_ROAD_OR_SIDEWALK = 9
    case rollover = 10
    case skid = 11
    case hit_PASSSENGER_IN_CAR = 12
    case falling_OFF_MOVING_VEHICLE = 13
    case fire = 14
    case other = 15
    case back_TO_FRONT = 17
    case back_TO_SIDE = 18
    case with_ANIMAL = 19
    case with_VEHICLE_LOAD = 20
}


func accidentMinorTypeToType(_ type: AccidentMinorType) -> AccidentType? {
    switch type {
        case .car_TO_PEDESTRIAN: return .carToPedestrian
        case .front_TO_SIDE: return .carToCar
        case .front_TO_REAR: return .carToCar
        case .side_TO_SIDE: return .carToCar
        case .front_TO_FRONT: return .carToCar
        case .with_STOPPED_CAR_NO_PARKING: return .carToCar
        case .with_STOPPED_CAR_PARKING: return .carToCar
        case .with_STILL_OBJECT: return .carToObject
        case .off_ROAD_OR_SIDEWALK: return .carToObject
        case .rollover: return .carToObject
        case .skid: return .carToObject
        case .hit_PASSSENGER_IN_CAR: return .carToCar
        case .falling_OFF_MOVING_VEHICLE: return .carToObject
        case .fire: return .carToObject
        case .other: return .carToObject
        case .back_TO_FRONT: return .carToCar
        case .back_TO_SIDE: return .carToCar
        case .with_ANIMAL: return .carToPedestrian
        case .with_VEHICLE_LOAD: return .carToCar
    default: return nil
    }
}

/**
 Accident Providing Organization
 
 - CBS:    הלמ״ס
            raw can be 1 or 3
 - Ihud:   איחוד והצלה
             raw can be 2
 
 */
enum Provider {
    case cbs
    case ihud
    
    init?(_ raw: Int) {
        switch raw {
        case 1,3: self = .cbs
        case 2: self = .ihud
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case .cbs: return local("PROVIDER_cbs")
        case .ihud: return local("PROVIDER_ihud")
        }
    }
    
    var logo: String {
        switch self {
        case .cbs: return "cbs"
        case .ihud: return "ihud"
        }
    }
    
    var url: String {
        switch self {
        case .cbs: return "http://www.cbs.gov.il"
        case .ihud: return "http://www.1221.org.il"
        }
    }

    
    
}

