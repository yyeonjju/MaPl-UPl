//
//  NetworkManager.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import Alamofire

class NetworkManager {
    @UserDefaultsWrapper(key : .userInfo ) var userInfo : LoginResponse?
    
    static let shared = NetworkManager()
    private init() { }
    
    func login(email: String, password: String) {
        
        let url = APIURL.baseURL + "v1/users/login"
        
        let header: HTTPHeaders = [
            HeaderKey.contentType: HeaderValue.applicationJson,
            HeaderKey.sesacKey : HeaderValue.sesacKey
        ]
        
        let parameter = [
            "email": email,
            "password": password
        ]
        
        print("💚💚💚 url", url)
        
        AF.request(url,
                   method: .post,
                   parameters: parameter,
                   encoding: JSONEncoding(),
                   headers: header )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: LoginResponse.self) { [weak self] response in
            print("💚statusCode", response.response?.statusCode)
            
            switch response.result {
            case .success(let value):
                 print("💚login OK", value)
                
                guard let self else{
                    return
                }
                self.userInfo = value
                print("💚userInfo", userInfo)
                
            case .failure(let failure):
                print("Fail", failure)
            }
        }

    }
    
}
