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
    case getPosts(productId : String, nextCursor : String)
    case getImageData(filePath : String)
    case likePost (query : LikeModel, postId : String)
    case getPlaylistInfo(id : String)
    
    
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
        case .getPosts :
            return APIURL.getPosts
        case .getImageData(let filePath) :
            return "/\(filePath)"
        case .likePost(let query, let postId) :
            return APIURL.likePost(postId)
        case .getPlaylistInfo(let id):
            return "\(APIURL.getPlaylistInfo)/\(id)"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login, .postPlaylist, .updloadImage, .likePost:
            return .post
        case .tokenRefresh, .getPosts, .getImageData, .getPlaylistInfo :
            return .get
        }
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getPosts(let productId, let nextCursor) :
            return[
                URLQueryItem(name: "next", value: nextCursor),
                URLQueryItem(name: "limit", value: "5"),
                URLQueryItem(name: "product_id", value: productId),
            ]
        default :
            return []
        }

    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        
        switch self {
        case .tokenRefresh :
            return nil
        case .login(let query):
            do{
                let data = try encoder.encode(query)
                return data
            }catch{
                return nil
            }
        case .postPlaylist(let query):
            do{
                let data = try encoder.encode(query)
                return data
            }catch{
                return nil
            }
        case .likePost(let query, let postId) :
            do{
                let data = try encoder.encode(query)
                return data
            }catch{
                return nil
            }
        case .updloadImage, .getPosts, .getImageData, .getPlaylistInfo:
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
        case .postPlaylist, .likePost :
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
        case .getPosts, .getImageData, .getPlaylistInfo:
            return [
                HeaderKey.sesacKey : HeaderValue.sesacKey
            ]
        }
    }
    
}






