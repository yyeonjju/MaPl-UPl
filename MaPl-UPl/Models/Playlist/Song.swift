//
//  Song.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import Foundation

//플레이스트 post할 때 encoding해서 string 형태로 전달
//서버에서 get할 때 decoding해서 SongInfo형태로 사용
struct SongInfo : Codable {
    let id : String
    let title : String
    let artistName : String
    let previewURL : URL?
    
    let genreNames : [String]
    let artworkURL : String
    let duration : Double
}


/*
 //서버에서 데이터 받았을 때 다시 SongInfo 로 디코딩해주려면
 let songInfoData = stringFormatSongInfo.data(using: .utf8)!
 let decodedSongData = try? JSONDecoder().decode(SongInfo.self, from: songInfoData)
 print("✅decodedSongData✅", decodedSongData)
 */
