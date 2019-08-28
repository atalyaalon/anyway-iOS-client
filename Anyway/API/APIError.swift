//
//  APIError.swift
//  FaceEmotion
//
//  Created by Yigal Omer on 08/07/2019.
//  Copyright © 2019 YigalOmer. All rights reserved.
//

import Foundation

public struct APIError: Error, LocalizedError {
    public enum ErrorKind {
        case invalidAPICall
        case invalidResponse
        case faceNotDetected
        case unknown
    }

    public let message: String
    public let kind: ErrorKind
    public let error: Error?
    public let httpStatusCode: Int

    public var errorDescription: String? {
        return message
    }

    public init(message: String, kind: ErrorKind, httpStatusCode: Int, error: Error? = nil) {
        self.message = message
        self.kind = kind
        self.httpStatusCode = httpStatusCode
        self.error = error
    }
    public init(message: String, kind: ErrorKind) {
        self.message = message
        self.kind = kind
        self.httpStatusCode = -999
        self.error = nil
    }
}
