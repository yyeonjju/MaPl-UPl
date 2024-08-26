//
//  PlaylistDetailViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/26/24.
//

import Foundation
import RxSwift

final class PlaylistDetailViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    

    var songsInfoData : [SongInfo]? {
        didSet {
            guard let songsInfoData else{return}
            songsInfoDataSubject.onNext(songsInfoData)
        }
    }
    
    let songsInfoDataSubject = PublishSubject<[SongInfo]>()
    
    struct Input {
        let playlistData : Observable<PlaylistResponse>
    }
    
    struct Output {
        let songInfoData : PublishSubject<[SongInfo]>
    }
    
    func transform(input : Input) -> Output {
        input.playlistData
            .bind(with: self) { owner, data in
                
                let songsInfo = [data.content1, data.content2, data.content3, data.content4,  data.content5]
                    .compactMap{$0}
                    .map{
                        stringToDecodedModel(string: $0, model: SongInfo.self)
                    }
                    .compactMap{$0}
                
                owner.songsInfoData = songsInfo
            }
            .disposed(by: disposeBag)
        
        
        return Output(songInfoData : songsInfoDataSubject)
    }
}
