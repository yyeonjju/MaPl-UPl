//
//  PlaylistDetailViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/26/24.
//

import Foundation
import RxSwift

final class PlaylistDetailViewModel : BaseViewModelProtocol {
    @UserDefaultsWrapper(key: .userInfo) var userInfo : LoginResponse?
    
    struct PlaylistBasicInfo {
        let title : String
        let editor : String
        let bgImage : String
        let isPurchased : Bool
    }
    
    let disposeBag = DisposeBag()
    var songsInfoData : [SongInfo]? {
        didSet {
            guard let songsInfoData else{return}
            songsInfoDataSubject.onNext(songsInfoData)
        }
    }
    private let songsInfoDataSubject = PublishSubject<[SongInfo]>()
    
    struct Input {
        let playlistId : Observable<String>
        let currentSongIndex : PublishSubject<Int>
    }
    
    struct Output {
        let songsInfoData : PublishSubject<[SongInfo]>
        let playlistBasicInfo : PublishSubject<PlaylistBasicInfo>
        let errorMessage : PublishSubject<String>
        let isLoading : BehaviorSubject<Bool>
        let currentSongIndex : PublishSubject<Int>
    }
    
    func transform(input : Input) -> Output {
        let errorMessageSubject = PublishSubject<String>()
        let isLoadingSubject = BehaviorSubject(value: true)
        let playlistBasicInfoSubject = PublishSubject<PlaylistBasicInfo>()
        
        input.playlistId
            .flatMap { id in
                isLoadingSubject.onNext(true)
                return NetworkManager.shared.getPlaylistInfo(id: id)
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self) { owner, result in
                switch result{
                case .success(let data) :
                    print("🌸success🌸",data)
                    
                    guard let userId = owner.userInfo?.id else{return}
                    
                    let playlistBasicInfo = PlaylistBasicInfo(
                        title: data.title,
                        editor: data.creator.nick ?? "-",
                        bgImage: data.files.first ?? "",
                        isPurchased: data.buyers.contains(userId)
                    )
                    playlistBasicInfoSubject.onNext(playlistBasicInfo)
                    
                    
                    let songsInfo = [data.content1, data.content2, data.content3, data.content4,  data.content5]
                        .compactMap{$0}
                        .map{
                            stringToDecodedModel(string: $0, model: SongInfo.self)
                        }
                        .compactMap{$0}
                    owner.songsInfoData = songsInfo
                    
                case .failure(let error as FetchError) :
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
                isLoadingSubject.onNext(false)
            }
            .disposed(by: disposeBag)
        

        
        return Output(songsInfoData : songsInfoDataSubject, playlistBasicInfo : playlistBasicInfoSubject,errorMessage : errorMessageSubject, isLoading : isLoadingSubject, currentSongIndex : input.currentSongIndex)
    }
}
