//
//  MapProvider.swift
//  Anyway
//
//  Created by Aviel Gross on 2/16/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import SwiftyJSON

let MAX_DIST_OF_MAP_EDGES = 10000
let MIN_DIST_CLUSTER_DISABLE = 1000

typealias Edges = (ne: Coordinate, sw: Coordinate)

extension MKMapView {
    func edgePoints() -> Edges {
        let nePoint = CGPoint(x: self.bounds.maxX, y: self.bounds.origin.y)
        let swPoint = CGPoint(x: self.bounds.minX, y: self.bounds.maxY)
        let neCoord = self.convert(nePoint, toCoordinateFrom: self)
        let swCoord = self.convert(swPoint, toCoordinateFrom: self)
        return (ne: neCoord, sw: swCoord)
    }
    
    func edgesDistance() -> CLLocationDistance {
        let edges = self.edgePoints()
        return CLLocation.distance(from: edges.sw, to: edges.ne)
    }
}

extension CLLocation {
    // In meteres
    class func distance(from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}

class Network {
    
    var currentRequest: Request? = nil
    
    func cancelRequestIfNeeded() {
        if let current = currentRequest { current.cancel() }
    }
    
    func getMarkerDetails(markerId id: Int, result:@escaping ([Person], [Vehicle])->Void) {
        
        let domain = "http://www.anyway.co.il/markers/"
        let url = "\(domain)\(id)"
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // handle response
        let response = { (json: JSON) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("getMarkerDetails response from server ended")
            
            guard json != JSON.null else {
                result([], [])
                return
            }
            
            var persons = [Person]()
            var vehicles = [Vehicle]()
            
            for obj in json.array ?? [] {
                if obj["sex"].number != nil {
                    persons.append(Person(json: obj, index: persons.count + 1))
                } else {
                    vehicles.append(Vehicle(json: obj, index: vehicles.count + 1))
                }
            }
            
            result(persons, vehicles)
        }

        // build request
        let request = Alamofire.request(
            url,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.`default`,
            headers: nil
        )
        
        // get value from response
        request.responseJSON { responseValue in
            
            let json: JSON
            
            switch responseValue.result {
            case .success:
                if let value = responseValue.result.value {
                    json = JSON(value)
                } else {
                    json = JSON.null
                }
            case .failure(let err):
                print("Error! \(err)")
                json = JSON.null
            }
            response(json)
            
        }
        
        // keep ref
        currentRequest = request
    }
    
    func getAnnotations(_ edges: Edges, filter: Filter, anots: @escaping (_ markers: [MarkerAnnotation], _ totalCount: Int)->()) {
        
        let ne_lat = edges.ne.latitude // 32.158091269627874
        let ne_lng = edges.ne.longitude // 34.88087036877948
        let sw_lat = edges.sw.latitude // 32.146882347101766
        let sw_lng = edges.sw.longitude // 34.858318355382266
        let startDate = Int(filter.startDate.timeIntervalSince1970)
        let endDate = Int(filter.endDate.timeIntervalSince1970)
        
        print("Fetching with filter:\n\(filter.description)")
        
        let params: [String : Any] = [
            "show_markers" : 1, // should always be on to get markers...
            "show_discussions" : 0, // currently app doesn't support discussions...
            
            "ne_lat" : ne_lat,
            "ne_lng" : ne_lng,
            "sw_lat" : sw_lat,
            "sw_lng" : sw_lng,
            
            "zoom"   : 16, // minimum = 16
            "thin_markers" : 1, //not used (server logic determenines this)
            
            "start_date"   : startDate,
            "end_date"     : endDate,
            
            "show_fatal"   : filter.showFatal ? 1 : "",
            "show_severe"  : filter.showSevere ? 1 : "",
            "show_light"   : filter.showLight ? 1 : "",
            
            "accurate" : filter.showAccurate ? 1 : "",
            "approx" : filter.showInaccurate ? 1 : "",
            
            "show_intersection" : filter.showIntersection.value,
            "show_lane" : filter.showLane.value,
            "show_urban" : filter.showUrban.value,
            
            "show_day" : filter.weekday.rawValue,
            "show_holiday" : filter.holiday.rawValue,
            "show_time" : filter.dayTime.rawValue,
            
            "weather" : filter.weather.rawValue,
            
            // New filter options, currently hardcoded
            // TODO: Add these as options in filter with UI
            
            
            "start_time" : 25,
            "end_time" : 25,
            "road" : 0,
            "separation" : 0,
            "surface" : 0,
            "acctype" : 0,
            "controlmeasure" : 0,
            "district" : 0,
            "case_type" : 0
        ]
        
        
        //print("params: \(params)")
        
        cancelRequestIfNeeded()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let response = { (json: JSON) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("getAnnotations response from server ended")
            
            guard json != JSON.null else {
                anots([], 0)
                return
            }

            let markers = self.parseJson(json)



            //Sometimes multiple markers would have the exact same coordinate.
            //This method would arrange the identical markers in a circle around the coordinate.
            //AnnotationCoordinateUtility.mutateCoordinatesOfClashingAnnotations(markers)
            // print("markers:\(markers.count)")

            //let finalMarkers = self.groupMarkersWithColidingCoordinates(markers)
            
            anots(markers, markers.count)
        }
        
        let request = Alamofire.request(
            "http://www.anyway.co.il/markers",
            method: .get,
            parameters: params,
            encoding: URLEncoding.`default`,
            headers: nil
        )
            
            /* Raw response, for debug */
//        request.responseString { response in
//            if let error = response.result.error {
//                println("error: \(error)")
//                return
//            }
//            
//            if let encoded = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
//                println("response: \n###\n\(encoded)\n###") //solve hebrew string bug...
//            } else {
//                println("response: \n###\n\(response.result.value ?? "no response value")\n###")
//            }
//        }
        
        request.responseJSON { responseValue in
            
            let json: JSON
            
            switch responseValue.result {
            case .success:
                if let value = responseValue.result.value {
                    json = JSON(value)
                } else {
                    json = JSON.null
                }
            case .failure(let err):
                print("Error! \(err)")
                json = JSON.null
            }
            response(json)
            
        }
        
        currentRequest = request
        
    }




    func getAnnotationsNew(_ edges: Edges, filter: Filter, anots: (( [NewMarker]?)->Void )? ){

        let ne_lat = edges.ne.latitude // 32.158091269627874
        let ne_lng = edges.ne.longitude // 34.88087036877948
        let sw_lat = edges.sw.latitude // 32.146882347101766
        let sw_lng = edges.sw.longitude // 34.858318355382266
        let startDate = Int(filter.startDate.timeIntervalSince1970)
        let endDate = Int(filter.endDate.timeIntervalSince1970)

        print("Fetching with filter:\n\(filter.description)")

        let params: [String : Any] = [
            "show_markers" : 1, // should always be on to get markers...
            "show_discussions" : 0, // currently app doesn't support discussions...
            "ne_lat" : ne_lat,
            "ne_lng" : ne_lng,
            "sw_lat" : sw_lat,
            "sw_lng" : sw_lng,
            "zoom"   : 16, // minimum = 16
            "thin_markers" : 1, //not used (server logic determenines this)
            "start_date"   : startDate,
            "end_date"     : endDate,
            "show_fatal"   : filter.showFatal ? 1 : "",
            "show_severe"  : filter.showSevere ? 1 : "",
            "show_light"   : filter.showLight ? 1 : "",
            "accurate" : filter.showAccurate ? 1 : "",
            "approx" : filter.showInaccurate ? 1 : "",
            "show_intersection" : filter.showIntersection.value,
            "show_lane" : filter.showLane.value,
            "show_urban" : filter.showUrban.value,
            "show_day" : filter.weekday.rawValue,
            "show_holiday" : filter.holiday.rawValue,
            "show_time" : filter.dayTime.rawValue,
            "weather" : filter.weather.rawValue,

            // New filter options, currently hardcoded
            // TODO: Add these as options in filter with UI
            "start_time" : 25,
            "end_time" : 25,
            "road" : 0,
            "separation" : 0,
            "surface" : 0,
            "acctype" : 0,
            "controlmeasure" : 0,
            "district" : 0,
            "case_type" : 0
        ]


        //print("params: \(params)")
        cancelRequestIfNeeded()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let request = Alamofire.request(
            "http://www.anyway.co.il/markers",
            //method: .get,
            parameters: params
            //encoding: URLEncoding.`default`,
            //headers: nil
        )

        var markers:NewMarkers? = nil

        let task = request.responseString(completionHandler: { (response: DataResponse<String>) in

            switch response.result {
                case .success:
                    if let jsonString = response.result.value ,let jsonData = jsonString.data(using: .utf8)  {
                        //print(jsonString)
                        let decoder = JSONDecoder()
                        do {
                            markers = try decoder.decode(NewMarkers.self, from: jsonData)
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let err):
                    print("Error! \(err)")
                }
            anots?(markers?.markers)

//            return Disposables.create {
//                task.cancel()
//            }
            //task.cancel()

        })

        currentRequest = request

    }

    /*
        Checking for coliding Marker group and creating MarkerGroup for them
    */
    fileprivate func groupMarkersWithColidingCoordinates(_ markers: [Marker]) -> [MarkerAnnotation] {
        
        var markerAnnotations = [MarkerAnnotation]()
        
        let annotsDict = AnnotationCoordinateUtility.groupAnnotations(byLocationValue: markers) as! [NSValue:[Marker]]
        for (_ /* coordVal */, annotsAtLocation) in annotsDict {
            if annotsAtLocation.count > 1 {
                let group = MarkerGroup(markers: annotsAtLocation)!
                //print("Added markerGroup of \(group.markers.count) markers at \(coordVal)")
                markerAnnotations.append(group)
            } else {
                markerAnnotations.append(annotsAtLocation.first!)
            }
        }
        
        return markerAnnotations
    }
    
    /*
        Parsing server JSON response to [Marker], ignoring coliding markers
    */
    fileprivate func parseJson(_ json: JSON) -> [Marker] {

        var annots = [Marker]()
        
        if let markers = json["markers"].array {
            
            for marker in markers {

                let lat = marker["latitude"].number!.doubleValue
                let lng = marker["longitude"].number!.doubleValue
                let coord = CLLocationCoordinate2DMake(lat, lng)
                
                let address = marker["address"].string ?? ""
                let content = marker["description"].string ?? ""
                let title = marker["title"].string ?? ""
                
                let created: Date
                if let createdRaw = marker["created"].string {
                    let form = DateFormatter()
                    form.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    created = form.date(from: createdRaw) ?? Date(timeIntervalSince1970: 0)
                } else {
                    created = Date(timeIntervalSince1970: 0)
                }
                
                let id = Int(marker["id"].string ?? "") ?? 0
                let accuracy = marker["locationAccuracy"].number ?? 0
                let severity = marker["severity"].number ?? 0
                let subtype = marker["subtype"].number ?? 0
                let type = marker["type"].number ?? 0
                
                let mView = Marker(coord: coord, address: address, content: content, title: title, created: created, id: id, accuracy: accuracy.intValue, severity: severity.intValue, subtype: subtype.intValue, type: type.intValue)
                
                mView.roadShape = marker["roadShape"].intValue
                mView.cross_mode = marker["cross_mode"].intValue
                mView.secondaryStreet = marker["secondaryStreet"].stringValue
                mView.cross_location = marker["cross_location"].intValue
                mView.one_lane = marker["one_lane"].intValue
                mView.speed_limit = marker["speed_limit"].intValue
                mView.weather = marker["weather"].intValue
                mView.provider_code = marker["provider_code"].intValue
                mView.road_object = marker["road_object"].intValue
                mView.didnt_cross = marker["didnt_cross"].intValue
                mView.object_distance = marker["object_distance"].intValue
                mView.road_sign = marker["road_sign"].intValue
                mView.intactness = marker["intactness"].intValue
                mView.junction = marker["secondaryStreet"].stringValue
                mView.road_control = marker["road_control"].intValue
                mView.road_light = marker["road_light"].intValue
                mView.multi_lane = marker["multi_lane"].intValue
                mView.dayType = marker["dayType"].intValue
                mView.unit = marker["unit"].intValue
                mView.road_width = marker["road_width"].intValue
                mView.cross_direction = marker["cross_direction"].intValue
                mView.roadType = marker["roadType"].intValue
                mView.road_surface = marker["road_surface"].intValue
                mView.mainStreet = marker["secondaryStreet"].stringValue
                
                
                annots.append(mView)
            }
            
        }
        
        return annots
    }
}




