//
//  PostPlaylistViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import Foundation
import RxSwift
import AVFoundation

final class PostPlaylistViewModel : BaseViewModelProtocol {
    let player = AVPlayer()
    let disposeBag = DisposeBag()
    var selectedSongList : [SongInfo] = [] {
        didSet{
            selectedSongListSubject.onNext(selectedSongList)
        }
    }
    private let selectedSongListSubject : BehaviorSubject<[SongInfo]> = BehaviorSubject(value: [])
    
    struct Input {
        let titleInputText : PublishSubject<String>
        let postPlaylistButtonTap : PublishSubject<Void>
        let selectedBgImageData : PublishSubject<Data?>
        let searchMusicButtonTap : PublishSubject<Void>
        let addPhotoButtonTap : PublishSubject<Void>
        let removeItemIndex : PublishSubject<Int>
    }
    
    struct Output {
        let errorMessage : PublishSubject<String>
        let isLoading : PublishSubject<Bool>
        let uploadComplete : PublishSubject<Bool>
        let pushToSearchMusicVC : PublishSubject<Void>
        let selectedSongList : BehaviorSubject<[SongInfo]>
        let presentPhotoLibrary : PublishSubject<Void>
        let invalidMessage : PublishSubject<String?>
    }
    
    func transform(input : Input) -> Output {
        let errorMessageSubject = PublishSubject<String>()
        let isLoadingSubject = PublishSubject<Bool>()
        let uploadSuccessFiles = PublishSubject<[String]>()
        let uploadCompleteSubject = PublishSubject<Bool>()
        let invalidMessageSubject = PublishSubject<String?>()
        let readyToPostSubject = PublishSubject<Void>()
        
        //노래 리스트 중 삭제할 index
        input.removeItemIndex
            .bind(with: self) { owner, index in
                owner.selectedSongList.remove(at: index)
            }
            .disposed(by: disposeBag)
        
        
        input.postPlaylistButtonTap
            .withLatestFrom(Observable.combineLatest(input.titleInputText, input.selectedBgImageData))
            .withUnretained(self)
            .map{ (owner, params:(String,Data?)) in
                let title = params.0
                let imageData = params.1
                return owner.postValidation(title: title, imageData: imageData)
            }
            .bind(with: self) { (owner, validationPassed:PlaylistPostValidation) in
                if validationPassed == .validationPassed  {
                    //readyToPost에 void 값 전달
                    readyToPostSubject.onNext(())
                }else {
                    //invalidMessageSubject 에 텍스트 전달
                    invalidMessageSubject.onNext(validationPassed.invalidMessage)
                }
            }
            .disposed(by: disposeBag)
        
        
        //1️⃣ 파일 업로드
        readyToPostSubject
            .withLatestFrom(input.selectedBgImageData)
            .flatMap{ imageData in
                isLoadingSubject.onNext(true)
                return NetworkManager.shared.uploadImage(imageData: imageData!)
            }
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self, onNext: { owner, result in
                
                switch result{
                case .success(let value) :
                    print("🌸success🌸",value)
                    uploadSuccessFiles.onNext(value.files)
                case .failure(let error as FetchError) :
                    isLoadingSubject.onNext(false)
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
            })
            .disposed(by: disposeBag)
        
        
        //2️⃣파일 업로드 성공했으면 게시물 업로드
        uploadSuccessFiles
            .withLatestFrom(Observable.combineLatest(input.titleInputText, uploadSuccessFiles))
            .withUnretained(self)
            .map{ (owner, params:(String,[String])) in
                let title = params.0
                let files = params.1
                
                let content = ""
                let content1 = owner.convertSongInfoToString(index: 0)
                let content2 = owner.convertSongInfoToString(index: 1)
                let content3 = owner.convertSongInfoToString(index: 2)
                let content4 = owner.convertSongInfoToString(index: 3)
                let content5 = owner.convertSongInfoToString(index: 4)
                let productId = ProductId.playlist
                
                let PostPlaylistBodyData = PostPlaylistQuery(title: title, content: content, content1: content1, content2: content2, content3: content3, content4: content4, content5: content5, product_id: productId, files: files)
                
                return PostPlaylistBodyData
            }
            .flatMap{ BodyData in // 게시물 업로드
                return NetworkManager.shared.postPlaylist(body: BodyData)
            } //⭐️ api fetch에서 반환하는 single은 error나 complete을 방출하지 않음 & 메인스레드에서 동작하도록 -> driver로 변환
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self, onNext: { owner, result in
                isLoadingSubject.onNext(false)
                
                switch result{
                case .success(let postResponse) :
                    print("🌸success🌸",postResponse)
                    uploadCompleteSubject.onNext(true)
                case .failure(let error as FetchError) :
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
                
            })
            .disposed(by: disposeBag)
        
        return Output(errorMessage : errorMessageSubject,  isLoading : isLoadingSubject, uploadComplete: uploadCompleteSubject, pushToSearchMusicVC: input.searchMusicButtonTap, selectedSongList:selectedSongListSubject, presentPhotoLibrary: input.addPhotoButtonTap, invalidMessage: invalidMessageSubject)
    }
    
    private func convertSongInfoToString(index : Int) -> String?  {
        guard index < selectedSongList.count else{return nil}
        
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
    
    private func postValidation(title: String,imageData : Data?) -> PlaylistPostValidation {
        
        guard title.count >= PlaylistPostValidation.minTitleTextCount else {
            return PlaylistPostValidation.invalidTitleTextCount
        }
        guard imageData != nil else{
            return PlaylistPostValidation.invalidBgImage
        }
        guard selectedSongList.count >= PlaylistPostValidation.minMusicCount &&
                selectedSongList.count <= PlaylistPostValidation.maxMusicCount else{
            return PlaylistPostValidation.invalidMusicCount
        }
                
        return PlaylistPostValidation.validationPassed
    }
}

