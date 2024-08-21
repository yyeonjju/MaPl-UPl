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
    case tokenRefresh
    
    case postPlaylist(query : PostPlaylistQuery)
    case updloadImage
    
    var accessToken : String {
        UserInfoManager().userInfo?.access ?? ""
    }
    var refreshToken : String{
        UserInfoManager().userInfo?.refresh ?? ""
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
        case .tokenRefresh :
            return APIURL.tokenRefresh
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login, .postPlaylist, .updloadImage:
            return .post
        case .tokenRefresh :
            return .get
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
        case .tokenRefresh :
            return nil
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
    
    
    
    var header: [String: String] { // 엑세스토큰은 alamofire interceptor adapt()에서 추가
        switch self {
        case .login:
            return [
                HeaderKey.contentType: HeaderValue.applicationJson,
                HeaderKey.sesacKey : HeaderValue.sesacKey
            ]
        case .postPlaylist:
            return [
                HeaderKey.contentType: HeaderValue.applicationJson,
                HeaderKey.sesacKey : HeaderValue.sesacKey
            ]
        case .updloadImage :
            return [
                HeaderKey.contentType: HeaderValue.multipartFormData,
                HeaderKey.sesacKey : HeaderValue.sesacKey
            ]
        case .tokenRefresh :
            return [
                HeaderKey.sesacKey : HeaderValue.sesacKey,
                HeaderKey.refresh : refreshToken
            ]
            
        }
    }
    
}






