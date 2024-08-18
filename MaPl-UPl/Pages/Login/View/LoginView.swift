//
//  LoginView.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit
import SnapKit

final class LoginView : BaseView {
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인"
        label.font = Font.title
        return label
    }()
    
    let emailTextField = {
        let textField = NormalOutlineTextField(placeholder:"이메일")
        textField.text = "ha2@ha2.com"
        return textField
    }()
    
    let passwordTextField = {
        let textField = NormalOutlineTextField(placeholder:"비밀번호")
        textField.text = "hahaha"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginButton: UIButton = MainNormalButton(title: "로그인")
    
    let signButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입하러가기", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()

    
    // MARK: - ConfigureUI
    override func configureSubView() {
        [titleLabel, emailTextField, passwordTextField, loginButton, signButton]
            .forEach{
                addSubview($0)

            }
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.right.equalTo(emailTextField)
            make.height.equalTo(44)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.left.right.equalTo(emailTextField)
        }
        
//        signButton.snp.makeConstraints { make in
//            make.top.equalTo(loginButton.snp.bottom).offset(40)
//            make.left.right.equalTo(emailTextField)
//            make.height.equalTo(44)
//        }
    }

}

