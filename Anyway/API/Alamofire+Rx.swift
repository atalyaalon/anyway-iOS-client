//
//  Alamofire+Rx.swift
//  FaceEmotion
//
//  Created by Yigal Omer on 10/07/2019.
//  Copyright © 2019 YigalOmer. All rights reserved.
//


import Foundation
import Alamofire
import RxSwift

extension DataRequest: ReactiveCompatible {}

extension Reactive where Base: DataRequest {

    func responseString() -> Observable<DataResponse<String>> {
        return Observable.create { [request = base] (observer) -> Disposable in

            let task = request.responseString(completionHandler: { (response: DataResponse<String>) in
                if let error = response.error {
                    observer.onError(error)
                } else {
                    observer.onNext(response)
                    observer.onCompleted()
                }
            })

            return Disposables.create {
                task.cancel()
            }
        }
    }
}

