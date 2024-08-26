//
//  PostPlaylistModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import Foundation

struct PostPlaylistQuery : Encodable {
    let title : String
    let content : String
    let content1 : String?
    let content2 : String?
    let content3 : String?
    let content4 : String?
    let content5 : String?
    let product_id : String
    let files : [String]

}

struct PlaylistResponse : Decodable, Hashable {
    
    let post_id : String
    let product_id : String
    
    let title : String
    let content : String
    let content1 : String?
    let content2 : String?
    let content3 : String?
    let content4 : String?
    let content5 : String?
    
    let createdAt : String
    let creator : Creator

    let files : [String]
    
    var likes : [String]
    let likes2 : [String]
    let hashTags : [String]
    let buyers : [String]
    let comments : [Comment]
}

struct Creator : Decodable, Hashable{
    let user_id : String
    let nick : String?
    let profileImage : String?
}

struct Comment : Decodable, Hashable {
    let comment_id : String
    let content : String
    let createdAt : String
    let creator : Creator
}

