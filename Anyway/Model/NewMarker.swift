//
//  NewMarker.swift
//  Anyway
//
//  Created by Yigal Omer on 25/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import Foundation
import UIKit


struct NewMarkers: Codable {
    var markers: [NewMarker]?

    enum CodingKeys: String, CodingKey {
        case markers = "markers"
    }
}


struct NewMarker: Codable {

//[{"accident_severity":3,"created":"2019-06-26T11:00:00","id":"2019034183","latitude":32.0693479016437,"location_accuracy":1,"longitude":34.7877873216838,"provider_code":3}

    //"accident_severity":3,"created":"2019-06-26T11:00:00","id":"2019034183","latitude":32.0693479016437,"location_accuracy":1,"longitude":34.7877873216838,"provider_code":3}
    var accident_severity: Int
    var created: String
    var id: String
    var latitude: Double
    var location_accuracy: Int
    var longitude: Double
    var provider_code: Int

//    var content: String?
//    var title: String?
//    var accuracy: Int?
//    var severity: Int?
//    var subtype: Int?
//    var type: Int?
//    var roadShape: Int?
//    var cross_mode: Int?
//    var secondaryStreet: String?
//    var cross_location: Int?
//    var one_lane: Int?
//    var speed_limit: Int?
//    var weather: Int?
//    var road_object: Int?
//    var didnt_cross: Int?
//    var object_distance: Int?
//    var road_sign: Int?
//    var intactness: Int?
//    var junction: Int?
//    var road_control: Int?
//    var road_light: Int?
//    var multi_lane: Int?
//    var dayType: Int?
//    var unit: Int?
//    var road_width: Int?
//    var cross_direction: Int?
//    var roadType: Int?
//    var road_surface: Int?
//    var mainStreet: String?


//    let lat = marker["latitude"].number!.doubleValue
//    let lng = marker["longitude"].number!.doubleValue
//    let coord = CLLocationCoordinate2DMake(lat, lng)
//
//    let address = marker["address"].string ?? ""
//    let content = marker["description"].string ?? ""
//    let title = marker["title"].string ?? ""
//


//    let created: Date
//    if let createdRaw = marker["created"].string {
//        let form = DateFormatter()
//        form.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        created = form.date(from: createdRaw) ?? Date(timeIntervalSince1970: 0)
//    } else {
//    created = Date(timeIntervalSince1970: 0)
//    }
//
//    let id = Int(marker["id"].string ?? "") ?? 0
//    let accuracy = marker["locationAccuracy"].number ?? 0
//    let severity = marker["severity"].number ?? 0
//    let subtype = marker["subtype"].number ?? 0
//    let type = marker["type"].number ?? 0
//
//    let mView = Marker(coord: coord, address: address, content: content, title: title, created: created, id: id, accuracy: accuracy.intValue, severity: severity.intValue, subtype: subtype.intValue, type: type.intValue)
//
//    mView.roadShape = marker["roadShape"].intValue
//    mView.cross_mode = marker["cross_mode"].intValue
//    mView.secondaryStreet = marker["secondaryStreet"].stringValue
//    mView.cross_location = marker["cross_location"].intValue
//    mView.one_lane = marker["one_lane"].intValue
//    mView.speed_limit = marker["speed_limit"].intValue
//    mView.weather = marker["weather"].intValue
//    mView.provider_code = marker["provider_code"].intValue
//    mView.road_object = marker["road_object"].intValue
//    mView.didnt_cross = marker["didnt_cross"].intValue
//    mView.object_distance = marker["object_distance"].intValue
//    mView.road_sign = marker["road_sign"].intValue
//    mView.intactness = marker["intactness"].intValue
//    mView.junction = marker["secondaryStreet"].stringValue
//    mView.road_control = marker["road_control"].intValue
//    mView.road_light = marker["road_light"].intValue
//    mView.multi_lane = marker["multi_lane"].intValue
//    mView.dayType = marker["dayType"].intValue
//    mView.unit = marker["unit"].intValue
//    mView.road_width = marker["road_width"].intValue
//    mView.cross_direction = marker["cross_direction"].intValue
//    mView.roadType = marker["roadType"].intValue
//    mView.road_surface = marker["road_surface"].intValue
//    mView.mainStreet = marker["secondaryStreet"].stringValue

//    dynamic var address: String = ""
//    dynamic var descriptionContent: String = ""
//    dynamic var titleAccident: String = ""
//    dynamic var created: Date = Date(timeIntervalSince1970: 0)
//    var followers: [AnyObject] = []
//    dynamic var following: Bool = false
//    dynamic var id: Int = 0
//    dynamic var locationAccuracy: Int = 0
//    dynamic var severity: Int = 0
//    dynamic var subtype: Int = 0
//    dynamic var type: Int = 0
//    dynamic var user: String = ""
//
//    dynamic var roadShape: Int = -1
//    dynamic var cross_mode: Int = -1
//    dynamic var secondaryStreet: String = ""
//    dynamic var cross_location: Int = -1
//    dynamic var one_lane: Int = -1
//    dynamic var speed_limit: Int = -1
//    dynamic var weather: Int = -1
//    dynamic var provider_code: Int = -1
//    dynamic var road_object: Int = -1
//    dynamic var didnt_cross: Int = -1
//    dynamic var object_distance: Int = -1
//    dynamic var road_sign: Int = -1
//    dynamic var intactness: Int = -1
//    dynamic var junction: String = ""
//    dynamic var road_control: Int = -1
//    dynamic var road_light: Int = -1
//    dynamic var multi_lane: Int = -1
//    dynamic var dayType: Int = -1
//    dynamic var unit: Int = -1
//    dynamic var road_width: Int = -1
//    dynamic var cross_direction: Int = -1
//    dynamic var roadType: Int = -1
//    dynamic var road_surface: Int = -1
//    dynamic var mainStreet: String = ""



    enum CodingKeys: String, CodingKey {
        
        case accident_severity = "accident_severity"
        case created = "created"
        case id = "id"
        case latitude = "latitude"
        case location_accuracy = "location_accuracy"
        case longitude = "longitude"
        case provider_code = "provider_code"

//        case severity = "severity"
//        case subtype = "subtype"
//        case type = "type"
//        case roadShape = "roadShape"
//        case cross_mode = "cross_mode"
//        case secondaryStreet = "secondaryStreet"
//        case cross_location = "cross_location"
//        case one_lane = "one_lane"
//        case speed_limit = "speed_limit"
//        case weather = "weather"
//        case provider_code = "provider_code"
//        case road_object = "road_object"
//        case didnt_cross = "didnt_cross"
//        case object_distance = "object_distance"
//        case road_sign = "road_sign"
//        case intactness = "intactness"
//        case junction = "junction"
//        case road_control = "road_control"
//        case road_light = "road_light"
//        case multi_lane = "multi_lane"
//        case dayType = "dayType"
//        case unit = "unit"
//        case road_width = "road_width"
//        case cross_direction = "cross_direction"
//        case roadType = "roadType"
//        case road_surface = "road_surface"
//        case mainStreet = "mainStreet"

    }
}
