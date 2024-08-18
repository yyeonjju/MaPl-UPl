//
//  LoginModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation

//decode : 로그인에 대한 응답
//encode : userDegaults에 저장
struct LoginResponse : Codable {
    let id: String
    let email: String
    let nick: String
    let profile: String?
    let access: String
    let refresh: String
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email, nick
        case profile = "profileImage"
        case access = "accessToken"
        case refresh = "refreshToken"
    }
}
