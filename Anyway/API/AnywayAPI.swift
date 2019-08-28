//
//  API.swift
//  Anyway
//
//  Created by Yigal Omer on 26/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//
import Foundation
//import RxSwift
import Alamofire

public protocol BaseRequestInterceptorType: class {}

public protocol RequestInterceptorType: (RequestRetrier & RequestAdapter & BaseRequestInterceptorType) {
     var userId: String { get set }
     var errorHandler: ErrorHandler? { get set }
}

public protocol AnywayAPI: class {

    var errorHandler: ErrorHandler? { get set }

    //func getAnnotationsRequest(_ apiCall: APICall) //-> Observable<Any>

    //func getAnnotationsRequest(with apiCall: APICall, _ edges: Edges, filter: Filter, anots: (( [NewMarker]?)->Void )? )
}
