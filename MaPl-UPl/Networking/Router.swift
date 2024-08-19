//
//  Router.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import Alamofire

struct UserInfoManager {
    @UserDefaultsWrapper(key: .userInfo) var userInfo : LoginResponse?
}

enum Router {
    case login(query : LoginQuery)
    case postPlaylist(query : PostPlaylistQuery)
    case updloadImage
    
    var accessToken : String {
        print("====        accessToken      ===", UserInfoManager().userInfo?.access)
        return UserInfoManager().userInfo?.access ?? ""
    }
}

extension Router: TargetType {

    var baseURL: String {
        return APIURL.baseURL + APIURL.version
    }
    
    var path: String {
        switch self {
        case .login:
            return APIURL.login
        case .postPlaylist:
            return APIURL.postPlaylist
        case .updloadImage:
            return APIURL.updloadImage
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login, .postPlaylist, .updloadImage:
            return .post
        }
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .login(let query):
            let encoder = JSONEncoder()
            do{
                let data = try encoder.encode(query)
                return data
            }catch{
                return nil
            }
        case .postPlaylist(let query):
            let encoder = JSONEncoder()
            do{
                let data = try encoder.encode(query)
                return data
            }catch{
                return nil
            }
        case .updloadImage:
            return nil
        }
    }
    
    
    
    var header: [String: String] {
        switch self {
        case .login:
            return [
                HeaderKey.contentType: HeaderValue.applicationJson,
                HeaderKey.sesacKey : HeaderValue.sesacKey
            ]
        case .postPlaylist(let query):
            return [
                HeaderKey.contentType: HeaderValue.applicationJson,
                HeaderKey.sesacKey : HeaderValue.sesacKey,
                HeaderKey.authorization : accessToken
            ]
        case .updloadImage :
            return [
                HeaderKey.contentType: HeaderValue.multipartFormData,
                HeaderKey.sesacKey : HeaderValue.sesacKey,
                HeaderKey.authorization : accessToken
            ]
            
        }
    }
    
}






