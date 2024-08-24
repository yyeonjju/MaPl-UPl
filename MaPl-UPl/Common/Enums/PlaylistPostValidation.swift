//
//  PlaylistPostValidation.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/24/24.
//

import Foundation

enum PlaylistPostValidation{
    static let minTitleTextCount = 3
    static let minMusicCount = 1
    static let maxMusicCount = 5
    
    //invalid
    case invalidTitleTextCount //제목이 3글자 이상이어야합니다
    case invalidBgImage // 배경이미지를 선택해야합니다.
    case invalidMusicCount //1개 이상 5개 이하의 음악을 선택해야합니다.
    
    //valid
    case validationPassed
    
    
    var invalidMessage : String? {
        switch self {
        case .invalidTitleTextCount:
           return "제목이 3글자 이상이어야합니다"
        case .invalidBgImage:
            return "배경이미지를 선택해야합니다."
        case .invalidMusicCount:
            return "1개 이상 5개 이하의 음악을 선택해야합니다."
        case .validationPassed :
            return nil
            
        }
    }
    
}
