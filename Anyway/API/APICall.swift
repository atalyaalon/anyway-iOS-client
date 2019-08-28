//
//  APICall.swift
//  FaceEmotion
//
//  Created by Yigal Omer on 08/07/2019.
//  Copyright © 2019 YigalOmer. All rights reserved.
//

import Foundation
import Alamofire

public class APICall {

    public var endpoint: APIEndPoint
    public var allHttpHeaders: [String: String]
    public var allParameters: [String: Any]
    public var httpBody: Data?

    public init(endpoint: APIEndPoint) {
        self.endpoint          = endpoint
        self.allHttpHeaders    = [:]
        self.allParameters     = [:]
    }

    public func add(header: String, value: String) {
        allHttpHeaders[header] = value
    }

    public func add(param: String, value: Any) {
        allParameters[param] = value
    }

    public func add(params: [String: Any]) {
        allParameters.merge(dict: params)
    }

    public func add(httpBody: Data) {
        self.httpBody = httpBody
    }

    public func set(params: [String: Any]) {
        allParameters = params
    }
}
