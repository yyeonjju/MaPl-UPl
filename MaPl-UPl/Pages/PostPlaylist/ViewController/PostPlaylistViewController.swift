//
//  PostPlaylistViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift

final class PostPlaylistViewController : BaseViewController<PostPlaylistView, PostPlaylistViewModel> {
    
    override func viewDidLoad() {
        view.backgroundColor = .pointPink
    }
    
    
}


final class PostPlaylistView : BaseView {
    
}

final class PostPlaylistViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input : Input) -> Output {
        return Output()
    }
    
}
