//
//  NetworkManager.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import Alamofire
import RxSwift

enum FetchError : Error {
    case fetchEmitError // 만에 하나 리턴한 single에러 에러를 방출했을떄 발생하는 에러
    
    case urlRequestError
    case failedRequest
    case noData
    case invalidResponse
    case failResponse(code : Int, message : String)
    case invalidData
    
    
    var errorMessage : String{
        switch self {
        case .fetchEmitError :
            return "알 수 없는 에러입니다."
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
        }
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
    
    
    private func fetch<M : Decodable>(fetchRouter : Router, model : M.Type) -> Single<Result<M,Error>> {
        
        let single = Single<Result<M,Error>>.create { single in
            do {
                let request = try fetchRouter.asURLRequest()
                print("💚 url", request.url)
                
                AF.request(request)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: model.self) { response in
                    print("💚statusCode", response.response?.statusCode)
                    
                    //response.error 로 에러를 판별하면 거기에서 캐치되어 밑으로 진행되지 않아서
                    //statusCode가 nil값인걸로 request 에러 걸러주기
                    guard let statusCode = response.response?.statusCode else {
                        return single(.success(.failure(FetchError.failedRequest)))
                    }
                    
                    guard let data = response.data else {
                        return single(.success(.failure(FetchError.noData)))
                    }
                    
                    guard response.response != nil else {
                        return single(.success(.failure(FetchError.invalidResponse)))
                    }
                    
                    
                    if statusCode != 200 {
                        var errorMessage: String?
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                            errorMessage = json["message"]
                        }

                        print("errorMessage -> ", errorMessage)
                        return single(.success(.failure(FetchError.failResponse(code: statusCode, message: errorMessage ?? ""))))
                    }
                    
                    
                    
                    switch response.result {
                    case .success(let value):
                        return single(.success(.success(value)))
                        
                    case .failure(let failure):
                        return single(.success(.failure(FetchError.invalidData)))
                    }
                    
                }
            }catch {
                print("asURLRequest -", error)
                return single(.success(.failure(FetchError.urlRequestError))) as! Disposable
            }
            
            return Disposables.create()
        }
        
        return single

        
    }

}


extension NetworkManager {
    
    func login(email: String, password: String) -> Single<Result<LoginResponse,Error>>  {
        let body = LoginQuery(email: email, password: password)
        let fetchRouter = Router.login(query: body)
        
        return fetch(fetchRouter: fetchRouter, model : LoginResponse.self)
    }
    
}
