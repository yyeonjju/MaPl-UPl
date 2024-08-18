//
//  LoginViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import RxSwift

final class LoginViewModel : BaseViewModelProtocol {
    let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input : Input) -> Output {
        
        print("❤️LoginViewModel --> transform")
        return Output()
    }
}
