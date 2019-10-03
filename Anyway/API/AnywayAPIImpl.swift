//
//  APIImpl.swift
//  FaceEmotion
//
//  Created by Yigal Omer on 10/07/2019.
//  Copyright © 2019 YigalOmer. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

public class AnywayAPIImpl { //}: AnywayAPI {

    public var errorHandler: ErrorHandler?
    private let sessionManager: SessionManager

    private let baseUrl = "https://www.anyway.co.il"

    required public init( sessionConfiguration: URLSessionConfiguration ) {
        self.sessionManager = Alamofire.SessionManager(configuration: sessionConfiguration)
    }


    func getAnnotationsRequest(_ edges: Edges, filter: Filter, anotations: (( [NewMarker]?)->Void )? ){

        let apiCall = APICall(endpoint: GetAnnotationEndPoint.markers)

        let ne_lat = edges.ne.latitude // 32.158091269627874
        let ne_lng = edges.ne.longitude // 34.88087036877948
        let sw_lat = edges.sw.latitude // 32.146882347101766
        let sw_lng = edges.sw.longitude // 34.858318355382266
        let startDate = Int(filter.startDate.timeIntervalSince1970)
        let endDate = Int(filter.endDate.timeIntervalSince1970)

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

            "show_rsa" : 0, // TODO YIGAL check 

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

        apiCall.add(params: params)

        let urlRequest = createUrlRequest(for: apiCall)
        let dataRequest: DataRequest = sessionManager.request(urlRequest)

        print("Fetching annotations with filter:\n\(filter.description)")

        //print("params: \(params)")
       // cancelRequestIfNeeded()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var markers:NewMarkers? = nil

        let task = dataRequest.responseString(completionHandler: { (response: DataResponse<String>) in

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
            anotations?(markers?.markers)

            //            return Disposables.create {
            //                task.cancel()
            //            }
            //task.cancel()

        })

        //currentRequest = request
    }

    func reportIncident(_ incidentData: Incident, result: @escaping ( (Bool)->Void ) ) {
        
        let apiCall = APICall(endpoint: ReportIncidentEndPoint.report_incident)
        
        let params: [String : Any] = [
              "longitude": incidentData.longitude,
              "latitude": incidentData.latitude,
              "signs_on_the_road_not_clear" : incidentData.signs_on_the_road_not_clear,
              "signs_problem" : incidentData.signs_problem,
              "pothole" : incidentData.pothole,
              "no_light" : incidentData.no_light,
              "no_sign": incidentData.no_sign,
              "crossing_missing"   : incidentData.crossing_missing,
              "sidewalk_is_blocked" : incidentData.sidewalk_is_blocked, //not used (server logic determenines this)
              "street_light_issue"   : incidentData.street_light_issue,
              "road_hazard"     : incidentData.road_hazard,
              "first_name"   : incidentData.fist_name ?? "",
              "last_name"  : incidentData.fist_name ?? "",
              "email"   : incidentData.email ?? "",
              "phone_number": incidentData.phone_number ?? "",
              "personal_id" : incidentData.id ?? "",
              "problem_descripion" : incidentData.problem_descripion ?? "",
              "image_data" :"bla",
              "send_to_municipality": incidentData.send_to_monicipality,
              "problem_description": incidentData.problem_descripion ?? ""]
        
        apiCall.add(params: params)
        
        apiCall.add(header: "Content-Type", value: "application/json")
    
        
        let urlRequest = createUrlRequest(for: apiCall)
        let dataRequest: DataRequest = sessionManager.request(urlRequest)
        
        print("Sending incident report")
        
        //print("params: \(params)")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
  
//        //let task = dataRequest.response(completionHandler: { (response: DefaultDataResponse) in
        _ = dataRequest.responseString(completionHandler: { (response: DataResponse<String>) in

            switch response.result {
            case .success:

                print("reportIncident Success!")
                if let jsonString = response.result.value   {
                    print(jsonString)
                }
                //let errMsg = String(data: response.data!, encoding: String.Encoding.utf8)!
                result(true)

            case .failure(let err):
                print("reportIncident Failed!")
                print("Error! \(err)")
                debugPrint(err)
                result(false)
            }

        })
    }


 
    private func createUrlRequest(for apiCall: APICall) -> URLRequest {
        let url = URL.init(string: baseUrl)
        var urlRequest = URLRequest(url:((url?.appendingPathComponent(apiCall.endpoint.info.path))!))
        urlRequest.httpMethod = apiCall.endpoint.info.method.rawValue
        urlRequest.httpBody = apiCall.httpBody
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !apiCall.allParameters.isEmpty {
            do {
                if apiCall.endpoint.info.method == .get {
                    let urlEncoding = URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal)
                    urlRequest = try urlEncoding.encode(urlRequest, with: apiCall.allParameters)
                } else {
                    urlRequest = try JSONEncoding.default.encode(urlRequest, withJSONObject: apiCall.allParameters)
                }
            } catch {
                print("Can not encode api call parameters to urlRequest. Error: \(error)")
            }
        }
        
        apiCall.allHttpHeaders.forEach { (key: String, value: String) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        print("urlRequest \(urlRequest)")

        return urlRequest
    }

    private func validateRequest(_ urlRequest: URLRequest) -> DataRequest {
        return sessionManager
            .request(urlRequest)
            .validate({ (optionalRequest, response, optionalData) -> Request.ValidationResult in
                if let _ = response.allHeaderFields["Content-Type"] as? String,
                    200...299 ~= response.statusCode {
                    return .success
                }
                var errorString: String = "Unexpected error"
                if let data = optionalData {
                    do {
                        if let parsedData = try JSONSerialization.jsonObject(with: data) as? [String: Any], let errorStr = parsedData["message"] as? String {
                            errorString = errorStr
                        }
                        print("Error description from server: \(errorString)")
                    } catch {
                        print("Cannot parse server error message: \(error.localizedDescription)")
                    }
                }
                let error = APIError(message: errorString, kind: .invalidResponse, httpStatusCode: response.statusCode)
                return .failure(error)
            })
    }


//    private func executeAPICall(_ urlRequest: URLRequest) -> DataRequest {
//        return sessionManager
//            .request(urlRequest)
//            .validate({ (optionalRequest, response, optionalData) -> Request.ValidationResult in
//                if let _ = response.allHeaderFields["Content-Type"] as? String,
//                    200...299 ~= response.statusCode {
//                    return .success
//                }
//                var errorString: String = "Unexpected error"
//                if let data = optionalData {
//                    do {
//                        if let parsedData = try JSONSerialization.jsonObject(with: data) as? [String: Any], let errorStr = parsedData["message"] as? String {
//                            errorString = errorStr
//                        }
//                        print("Error description from server: \(errorString)")
//                    } catch {
//                        print("Cannot parse server error message: \(error.localizedDescription)")
//                    }
//                }
//                let error = APIError(message: errorString, kind: .invalidResponse, httpStatusCode: response.statusCode)
//                return .failure(error)
//            })
//    }

}


extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
                                                                return nil
        }
        
        return String(data: theJSONData, encoding: .ascii)
    }
}
