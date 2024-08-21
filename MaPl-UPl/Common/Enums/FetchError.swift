//
//  FetchError.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/20/24.
//

import Foundation

enum FetchError : Error {
    case fetchEmitError // 만에 하나 리턴한 single에서 에러를 방출했을떄 발생하는 에러
    
    case url
    case urlRequestError
    case failedRequest
    case noData
    case invalidResponse
    case failResponse(code : Int, message : String)
    case invalidData
    
    case noUser
    
    var errorMessage : String {
        switch self {
        case .fetchEmitError :
            return "알 수 없는 에러입니다."
        case .url :
            return "잘못된 url입니다"
        case .urlRequestError:
            return "urlRequest 에러"
        case .failedRequest:
            return "요청에 실패했습니다."
        case .noData:
            return "데이터가 없습니다."
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .failResponse(let errorCode, let message):
            return "\(errorCode)error : \(message)"
        case .invalidData:
            return "데이터 파싱 에러"
        case .noUser :
            return "유저가 명확하지 않습니다."
        }
    }
}
