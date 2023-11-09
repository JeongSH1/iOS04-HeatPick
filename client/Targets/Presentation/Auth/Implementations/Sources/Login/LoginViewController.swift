//
//  LoginViewController.swift
//  AuthImplementations
//
//  Created by jungmin lim on 11/8/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import ModernRIBs
import UIKit
import DesignKit

protocol LoginPresentableListener: AnyObject {
    func naverButtonDidTap()
    func appleButtonDidTap()
}

public final class LoginViewController: UIViewController, LoginPresentable, LoginViewControllable {

    weak var listener: LoginPresentableListener?
    
    private lazy var naverLoginButton: LoginButton = {
        let button = LoginButton()
        button.setup(type: .naver)
        button.addTarget(self, action: #selector(naverButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var appleLoginButton: LoginButton = {
        let button = LoginButton()
        button.setup(type: .apple)
        button.addTarget(self, action: #selector(appleButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: .logoWithSubtitle)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
}

private extension LoginViewController {
    
    func setupViews() {
        view.backgroundColor = .white
        [logoImageView, naverLoginButton, appleLoginButton].forEach { view.addSubview($0) }
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            appleLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            appleLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingOffset),
            appleLoginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.traillingOffset),
            appleLoginButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight),
            
            naverLoginButton.bottomAnchor.constraint(equalTo: appleLoginButton.topAnchor, constant: -padding),
            naverLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingOffset),
            naverLoginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.traillingOffset),
            naverLoginButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight),
            
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingOffset),
            logoImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.traillingOffset),
            logoImageView.bottomAnchor.constraint(equalTo: naverLoginButton.topAnchor)
        ])
    }
    
}

private extension LoginViewController {
    
    @objc func naverButtonDidTap() {
        listener?.naverButtonDidTap()
    }
    
    @objc func appleButtonDidTap() {
        listener?.appleButtonDidTap()
    }
}
