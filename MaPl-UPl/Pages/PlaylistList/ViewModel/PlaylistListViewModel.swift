//
//  PlaylistListViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/19/24.
//

import Foundation
import RxSwift

final class PlaylistListViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    
    struct Input {
        let addButtonTap : PublishSubject<Void>
    }
    
    struct Output {
        let pushToPostPlaylistVC : PublishSubject<Void>
    }
    
    func transform(input : Input) -> Output {
        
        
        
        return Output(pushToPostPlaylistVC: input.addButtonTap)
    }
    
}
