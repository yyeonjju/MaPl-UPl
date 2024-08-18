//
//  LoginViewModel.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import Foundation
import RxSwift

final class LoginViewModel : BaseViewModelProtocol {
    @UserDefaultsWrapper(key : .userInfo) var userInfo : LoginResponse?
    
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
            .flatMap{ (emali, password) in
                NetworkManager.shared.login(email: emali, password: password)
            } //⭐️ api fetch에서 반환하는 single은 error나 complete을 방출하지 않음 -> driver로 변환
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self, onNext: { owner, result in
                switch result{
                case .success(let loginResponse) :
                    print("🌸success🌸",loginResponse)
                    //유저디폴트에 유저 정보 저장(토큰 포함)
                    owner.userInfo = loginResponse
                    print("🌸success - userInfo🌸",owner.userInfo)
                case .failure(let error as FetchError) :
                    print("🌸failure🌸", error.errorMessage)
                default:
                    print("default")
                    
                }
            })
            .disposed(by: disposeBag)

        return Output()
    }
}
