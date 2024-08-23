//
//  SearchMusicViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/23/24.
//

import Foundation
import RxSwift
import MusicKit

final class SearchMusicViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    let isLoadingSubject = PublishSubject<Bool>()
    
    struct Input {
        let viewDidLoadTrigger : Observable<Void>
        let searchButtonTap : Observable<Void>
        let inputText : Observable<String>
    }
    
    struct Output {
        let songInfoList : PublishSubject<[SongInfo]>
        let isLoading : PublishSubject<Bool>
    }
    
    func transform(input : Input) -> Output {
        let songInfoListSubject = PublishSubject<[SongInfo]>()
        
        input.viewDidLoadTrigger
            .bind(with: self) { owner, _ in
                print("❤️ viewDidLoadTrigger")
                owner.requestMusicAuthorization()
            }
            .disposed(by: disposeBag)
        
        
        
        input.searchButtonTap
            .withLatestFrom(input.inputText)
            .withUnretained(self)
            .flatMap{ owner, inputText in
                owner.isLoadingSubject.onNext(true)
                return owner.searchMusic(query: inputText)
            }
            .bind(with : self) {owner, result in
                switch result {
                case .success(let searchValue) :
                    print("❤️ searchValue -> ", searchValue)
                    songInfoListSubject.onNext(searchValue)
                case .failure(let error) :
                    print("search error : ", error)
                }
                
                owner.isLoadingSubject.onNext(false)
            }
            .disposed(by: disposeBag)
        
        return Output(songInfoList: songInfoListSubject, isLoading:isLoadingSubject)
    }
}



extension SearchMusicViewModel {
    
    //⭐️ 앱이 Apple Music의 데이터에 접근할 수 있도록 권한을 요청
    private func requestMusicAuthorization() {
        Task {
            let status = await MusicAuthorization.request()
            if status == .authorized {
                print("Apple Music access authorized")
            } else {
                print("Apple Music access denied")
            }
        }
    }
    
    //⭐️ 검색 결과 요청
    private func searchMusic(query: String) -> Single<Result<[SongInfo], Error>> {
        return Single.create { single in
            Task {
                

                do {
                    var request = MusicCatalogSearchRequest(term: query, types: [Song.self ,Artist.self, Album.self, MusicVideo.self])
                    request.limit = 10
                    request.offset = 1
                    request.includeTopResults = true
                    
                    let response = try await request.response()
                    let songs = response.songs
                
                    
                    let songsInfo = songs.map{
                        SongInfo(
                            id: $0.id.rawValue,
                            title: $0.title,
                            artistName: $0.artistName,
                            previewURL: $0.previewAssets?.first?.url,
                            genreNames: $0.genreNames,
                            artworkURL: $0.artwork?.url(width: 300, height: 300)?.absoluteString ?? "No artwork",
                            duration: $0.duration ?? 0
                        )
                    }

                    single(.success(.success(songsInfo)))

                    print("search end time", Date())
                    
                } catch {
                    single(.success(.failure(error)))
                    
                    print("Error searching music: \(error.localizedDescription)")
                }
            }
            
            return Disposables.create()
        }

    }
    
    

}
