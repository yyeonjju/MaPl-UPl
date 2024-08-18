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
        let loginButtonTap : PublishSubject<Void>
        let emailInputText : Observable<String>
        let passwordInputText : PublishSubject<String>
    }
    
    struct Output {
        
    }
    
    func transform(input : Input) -> Output {
        input.loginButtonTap
            .withLatestFrom(Observable.combineLatest(input.emailInputText, input.passwordInputText))
            .map{ (emali, password) in
                print("🌸emali", emali)
                print("🌸password", password)

                return NetworkManager.shared.login(email: emali, password: password)
            }
            .bind { _ in
                print("🌸loginButtonTap")
            }
            .disposed(by: disposeBag)
        
            
        
        print("❤️LoginViewModel --> transform")
        return Output()
    }
}
