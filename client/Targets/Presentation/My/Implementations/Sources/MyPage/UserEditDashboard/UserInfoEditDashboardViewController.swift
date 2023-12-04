//
//  UserInfoEditDashboardViewController.swift
//  MyImplementations
//
//  Created by 이준복 on 11/30/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import UIKit
import PhotosUI
import ModernRIBs
import CoreKit
import DesignKit
import BasePresentation

protocol UserInfoEditDashboardPresentableListener: AnyObject {
    func didTapBack()
    func didTapEditButton()
    func profileImageViewDidChange(_ imageData: Data)
    func usernameValueChanged(_ username: String)
    func didTapUserBadgeView(_ badgeId: Int)
}

final class UserInfoEditDashboardViewController: BaseViewController, UserInfoEditDashboardPresentable, UserInfoEditDashboardViewControllable {
    
    weak var listener: UserInfoEditDashboardPresentableListener?
    
    private enum Constant {
        static let topOffset: CGFloat = 10
        static let bottomOffset: CGFloat = -topOffset
        enum NavigationView {
            static let title = "프로필 변경"
        }
    }
    
    private let userEditProfileView = UserInfoEditProfileView()
    private let userEditBasicInformationView = UserInfoEditBasicInformationView()
    private let userInfoEditBadgeView = UserInfoEditBadgeView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let editButton = ActionButton()
    
    func setupUserInfoBadgeView(models: [UserBadgeViewModel]) {
        userInfoEditBadgeView.setup(models: models)
    }
    
    override func setupLayout() {
        [navigationView, scrollView, editButton].forEach(view.addSubview)
        scrollView.addSubview(stackView)
        [userEditProfileView, userEditBasicInformationView, userInfoEditBadgeView].forEach(stackView.addArrangedSubview)
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: Constants.navigationViewHeight),
            
            scrollView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: editButton.topAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor, constant: Constant.bottomOffset),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leadingOffset),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.traillingOffset),
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constant.bottomOffset),
            editButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight)
        ])
    }
    
    override func setupAttributes() {
        view.backgroundColor = .hpWhite
        
        navigationView.do {
            $0.setup(model: .init(
                title: Constant.NavigationView.title,
                leftButtonType: .back,
                rightButtonTypes: [])
            )
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        userEditProfileView.do {
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        userEditBasicInformationView.do {
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        userInfoEditBadgeView.do {
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.do {
            $0.contentInset = .zero
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        stackView.do {
             $0.axis = .vertical
             $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        editButton.do {
            $0.setTitle("변경하기", for: .normal)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = Constants.cornerRadiusMedium
            $0.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func bind() {
        
    }
    
}

private extension UserInfoEditDashboardViewController {
    
    @objc func didTapEditButton() {
        listener?.didTapEditButton()
    }
    
}

extension UserInfoEditDashboardViewController: NavigationViewDelegate {
    
    func navigationViewButtonDidTap(_ view: NavigationView, type: NavigationViewButtonType) {
        guard case .back = type else { return }
        listener?.didTapBack()
    }
    
}

extension UserInfoEditDashboardViewController: UserInfoEditProfileViewDelegate {
    
    func profileImageViewDidTap() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
}

extension UserInfoEditDashboardViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            DispatchQueue.main.async { [weak self] in
                guard let image = image as? UIImage,
                      let imageData = image.pngData() else { return }
                self?.userEditProfileView.setup(image: image)
                self?.listener?.profileImageViewDidChange(imageData)
            }
        }
    }
    
}


extension UserInfoEditDashboardViewController: UserInfoEditBasicInformationViewDelegate {
    
    func usernameValueChanged(_ username: String) {
        listener?.usernameValueChanged(username)
    }
    
}


extension UserInfoEditDashboardViewController: UserInfoEditBadgeViewDelegate {
    
    func didTapUserBadgeView(_ badgeId: Int) {
        listener?.didTapUserBadgeView(badgeId)
    }
    
}
 
