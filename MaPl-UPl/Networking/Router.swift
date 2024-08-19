//
//  Router.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import Alamofire

enum Router {
    
    case login(query : LoginQuery)
    case postPlaylist(query : PostPlaylistQuery, token : String)
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
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login, .postPlaylist:
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
        case .postPlaylist(let query, let token):
            let encoder = JSONEncoder()
            do{
                let data = try encoder.encode(query)
                return data
            }catch{
                return nil
            }
        }
    }
    
    
    
    var header: [String: String] {
        switch self {
        case .login:
            return [
                HeaderKey.contentType: HeaderValue.applicationJson,
                HeaderKey.sesacKey : HeaderValue.sesacKey
            ]
        case .postPlaylist(let query, let token):
            return [
                HeaderKey.contentType: HeaderValue.applicationJson,
                HeaderKey.sesacKey : HeaderValue.sesacKey,
                HeaderKey.authorization : token
            ]
            
        }
    }
    
}






