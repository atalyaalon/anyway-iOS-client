//
//  APIHttpMethod.swift
//  FaceEmotion
//
//  Created by Yigal Omer on 08/07/2019.
//  Copyright © 2019 YigalOmer. All rights reserved.
//

import Foundation
import Alamofire

public enum APIHttpMethod: String {

    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case options = "OPTIONS"
    case head = "HEAD"
    case trace = "TRACE"
    case connect = "CONNECT"

    var supportsMultipart: Bool {
        switch self {
        case .post, .put, .patch, .connect:
            return true
        case .get, .delete, .head, .options, .trace:
            return false
        }
    }
}

public typealias APIEndPointInfo = (method: APIHttpMethod, path: String)

public protocol APIEndPoint {

    var info: APIEndPointInfo { get }
}

public final class Response {

    public let statusCode: Int
    public let data: Data
    public let request: URLRequest?
    public let response: HTTPURLResponse?

    public init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode
        self.data 		= data
        self.request 	= request
        self.response 	= response
    }
}
