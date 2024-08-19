//
//  PostPlaylistViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import Foundation
import RxSwift
import AVFoundation


let selectedSongList = [
    SongInfo(id: "1731352615", title: "Holssi", artistName: "IU", previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/15/5c/59/155c5998-2dba-0490-ca3e-0199550e7ace/mzaf_16966546463465591542.plus.aac.p.m4a"), genreNames: ["K-Pop", "Music", "Pop", "Hip-Hop/Rap", "Korean Hip-Hop"], artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/3e/43/d2/3e43d2dc-acd4-5db6-9ae7-99299a044584/cover_KM0019422_1.jpg/300x300bb.jpg", duration: 190.787),
    SongInfo(id: "1488300930", title: "Blueming", artistName: "IU", previewURL: URL(string:"https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/99/56/19/995619c5-5310-d3b0-de45-0ff352bc58d9/mzaf_11001517585085545132.plus.aac.p.m4a"), genreNames: ["K-Pop", "Music", "Pop", "Rock"], artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/b8/b8/18/b8b81899-a984-be85-5656-ec1f2fc10227/5_Love_poem.jpg/300x300bb.jpg", duration: 217.053),
    SongInfo(id: "1590459636", title: "strawberry moon", artistName: "IU", previewURL: URL(string:"https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/fc/a9/ce/fca9ceb0-60df-9dd1-baca-f942c94f6209/mzaf_8422933462990544080.plus.aac.p.m4a"), genreNames: ["K-Pop", "Music", "Pop", "Rock"], artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/61/ac/6c/61ac6cf8-f016-5fbb-79b0-8cfa51da855b/cover.jpg/300x300bb.jpg", duration: 205.333),
    SongInfo(id: "1550907178", title: "Celebrity", artistName: "IU", previewURL: URL(string:"https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/fb/84/16/fb841699-b745-ccfd-b5be-9e0279561b68/mzaf_17749661702764415321.plus.aac.p.m4a"), genreNames: ["K-Pop", "Music", "Pop"], artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/02/32/09/02320995-35fb-e63f-fb52-76595b70ed45/1.jpg/300x300bb.jpg", duration: 195.533),
    SongInfo(id: "1511885178", title: "eight (feat. SUGA)", artistName: "IU", previewURL: URL(string:"https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/3e/9f/5c/3e9f5c5f-e9fc-5c20-e1ed-6509b07e579f/mzaf_18162240657437875369.plus.aac.p.m4a)"), genreNames: ["K-Pop", "Music", "Pop", "Rock"], artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/6b/65/4d/6b654d71-ed85-c6c4-8fe2-ef3d8e9f2ee0/cover_-.jpg/300x300bb.jpg", duration: 167.573),
]








final class PostPlaylistViewModel : BaseViewModelProtocol {
    let player = AVPlayer()
    let disposeBag = DisposeBag()
    
    struct Input {
        let postPlaylistButtonTap : PublishSubject<Void>
        let selectedBgImageData : PublishSubject<Data>
    }
    
    struct Output {
        
    }
    
    func transform(input : Input) -> Output {
        let uploadSuccessFiles = PublishSubject<[String]>()
        
        
        //1️⃣ 파일 업로드
        input.postPlaylistButtonTap
            .withLatestFrom(input.selectedBgImageData)
            .flatMap{ imageData in
                NetworkManager.shared.uploadImage(imageData: imageData)
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self, onNext: { owner, result in
                
                switch result{
                case .success(let value) :
                    print("🌸success🌸",value)
                    uploadSuccessFiles.onNext(value.files)
                case .failure(let error as FetchError) :
                    print("🌸failure🌸", error.errorMessage)
                default:
                    print("default")
                    
                }
            })
            .disposed(by: disposeBag)
        
        
        //2️⃣파일 업로드 성공했으면 게시물 업로드
        uploadSuccessFiles
            .withUnretained(self)
            .map{ owner, files in
                let title = "플리 제목 \(Int.random(in: 0...100))"
                let content = ""
                let content1 = owner.encodeSongInfo(index: 0)
                let content2 = owner.encodeSongInfo(index: 1)
                let content3 = owner.encodeSongInfo(index: 2)
                let content4 = owner.encodeSongInfo(index: 3)
                let content5 = owner.encodeSongInfo(index: 4)
                let productId = "playlist"
                
                let PostPlaylistBodyData = PostPlaylistQuery(title: title, content: content, content1: content1, content2: content2, content3: content3, content4: content4, content5: content5, product_id: productId, files: files)
                
                return PostPlaylistBodyData
            }
            .flatMap{ BodyData in // 게시물 업로드
                NetworkManager.shared.postPlaylist(body: BodyData)
            } //⭐️ api fetch에서 반환하는 single은 error나 complete을 방출하지 않음 & 메인스레드에서 동작하도록 -> driver로 변환
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self, onNext: { owner, result in
                //                isLoadingSubject.onNext(false)
                
                switch result{
                case .success(let postResponse) :
                    print("🌸success🌸",postResponse)
                case .failure(let error as FetchError) :
                    print("🌸failure🌸", error.errorMessage)
                default:
                    print("default")
                    
                }
                
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    private func encodeSongInfo(index : Int) -> String?  {
        guard index<selectedSongList.count else{return nil}
        
        let songInfo = selectedSongList[index]
        
        //먼저 데이터 형태로 인코딩
        let encodedSongData = try? JSONEncoder().encode(songInfo)
        guard let encodedSongData else{
            return nil
        }
        //string형태로 변환
        let stringFormatSongInfo = String(decoding: encodedSongData, as: UTF8.self)
        
        return stringFormatSongInfo
        
    }
}
