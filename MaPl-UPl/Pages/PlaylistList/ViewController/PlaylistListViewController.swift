//
//  PlaylistListViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import RxSwift

final class PlaylistListViewController : BaseViewController<PlaylistListView, PlaylistListViewModel> {
    
    override func viewDidLoad() {
        view.backgroundColor = .gray3
    }
    
    
}


final class PlaylistListView : BaseView {
    
}

final class PlaylistListViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input : Input) -> Output {
        return Output()
    }
    
}
