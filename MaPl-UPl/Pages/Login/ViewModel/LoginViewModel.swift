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
        let errorMessage : PublishSubject<String>
        let loginSuccess : PublishSubject<Void>
        let isLoading : PublishSubject<Bool>
    }
    
    func transform(input : Input) -> Output {
        let errorMessageSubject = PublishSubject<String>()
        let loginSuccessSubject = PublishSubject<Void>()
        let isLoadingSubject = PublishSubject<Bool>()
        
        input.loginButtonTap
            .withLatestFrom(Observable.combineLatest(input.emailInputText, input.passwordInputText))
            .flatMap{ (emali, password) in
                isLoadingSubject.onNext(true)
                
                return NetworkManager.shared.login(email: emali, password: password)
            } //⭐️ api fetch에서 반환하는 single은 error나 complete을 방출하지 않음 & 메인스레드에서 동작하도록 -> driver로 변환
            .asDriver(onErrorJustReturn: .failure(FetchError.fetchEmitError))
            .drive(with: self, onNext: { owner, result in
                isLoadingSubject.onNext(false)
                
                switch result{
                case .success(let loginResponse) :
                    print("🌸success🌸",loginResponse)
                    owner.userInfo = loginResponse //유저디폴트에 유저 정보 저장(토큰 포함)
                    print("🌸success - userInfo🌸",owner.userInfo)
                    loginSuccessSubject.onNext(())
                case .failure(let error as FetchError) :
                    print("🌸failure🌸", error.errorMessage)
                    errorMessageSubject.onNext(error.errorMessage)
                default:
                    print("default")
                    
                }
            })
            .disposed(by: disposeBag)

        return Output(errorMessage : errorMessageSubject, loginSuccess : loginSuccessSubject, isLoading : isLoadingSubject)
    }
}
