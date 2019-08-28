//
//  ErrorHandler.swift
//  FaceEmotion
//
//  Created by Yigal Omer on 10/07/2019.
//  Copyright © 2019 YigalOmer. All rights reserved.
//

import Foundation

public enum ErrorHandlerResult: Int {
    case ignore, retry
}

public typealias ErrorHandlerCompletion = (_ result: ErrorHandlerResult, _ delay: TimeInterval) -> Void

public enum AlertErrorType {
    case networkError
    case serviceIsDownError
    case generalError
}

public enum AlertActionType {
    case settings
    case feedback
    case retry
    case cancel
}

public protocol ErrorHandler {
    func handle(_ error: Error, completion: @escaping ErrorHandlerCompletion)
}
