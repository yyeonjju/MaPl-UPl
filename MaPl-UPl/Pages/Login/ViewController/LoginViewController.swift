//
//  LoginViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class LoginViewController : BaseViewController<LoginView, LoginViewModel> {
    // MARK: - UI
    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
    }
    // MARK: - SetupBind
    private func setupBind() {
        let loginButtonTap = PublishSubject<Void>()
        
        //❓❓❓Observable.just로 전달하는 것과 PublishSubject로 바인딩 시켜 전달하는 것 중 어떤게 좋은 방법일까?
        let emailInputText = viewManager.emailTextField.rx.text.orEmpty
            .flatMap{Observable.just($0)}
        let passwordInputText = PublishSubject<String>()
        
        let input = LoginViewModel.Input(
            loginButtonTap:loginButtonTap,
            emailInputText: emailInputText,
            passwordInputText : passwordInputText
        )
        let output = vm.transform(input: input)
        
        viewManager.loginButton.rx.tap
            .bind(to: loginButtonTap)
            .disposed(by: disposeBag)
        
        viewManager.passwordTextField.rx.text.orEmpty
            .bind(to: passwordInputText)
            .disposed(by: disposeBag)
        
        
        //output
        output.errorMessage
            .bind(with: self) { owner, message in
                owner.view.makeToast(message, position: .top)
            }
            .disposed(by: disposeBag)
        
        output.loginSuccess
            .bind(with: self) { owner, _ in
                ///루트뷰 변경
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                sceneDelegate?.changeRootViewController(to: PlaylistListViewController())
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .bind(with: self) { owner, isLoading in
                owner.viewManager.loginButton.isEnabled = !isLoading
                owner.viewManager.loginButton.setTitle(isLoading ? "loading..." : "로그인", for: .normal)
            }
            .disposed(by: disposeBag)
        
    }

    
    // MARK: - SetupDelegate
    // MARK: - AddTarget
    private func setupAddTarget() {
    }
    // MARK: - EventSelector
    // MARK: - SetupUI
    // MARK: - APIFetch
    // MARK: - PageTransition
    
}
