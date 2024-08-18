//
//  LoginViewController.swift
//  MaPl-UPl
//
//  Created by 하연주 on 8/18/24.
//

import UIKit

final class LoginViewController : BaseViewController<LoginView, LoginViewModel> {
    // MARK: - UI
    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm.transform(input: LoginViewModel.Input())
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
