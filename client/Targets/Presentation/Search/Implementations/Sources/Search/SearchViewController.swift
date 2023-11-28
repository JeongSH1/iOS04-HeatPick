//
//  SearchViewController.swift
//  SearchImplementations
//
//  Created by 이준복 on 2023/11/13.
//  Copyright © 2023 codesquad. All rights reserved.
//

import UIKit

import CoreKit
import DesignKit
import DomainEntities
import BasePresentation

import NMapsMap
import ModernRIBs

protocol SearchPresentableListener: AnyObject {
    func didTapCurrentLocation()
    func attachSearchResult()
    func didTapStory(storyID: Int)
}

public final class SearchViewController: UIViewController, SearchPresentable, SearchViewControllable {

    private enum Constant {
        enum TabBar {
            static let title = "검색"
            static let image = "magnifyingglass"
        }
        
        enum SearchTextField {
            static let placeholder = "위치, 장소 검색"
            static let topSpacing: CGFloat = 35
        }
        
        enum ShowSearchHomeListButton {
            static let image = "chevron.up"
            static let length: CGFloat = 45
            static let offset: CGFloat = -25
        }
        
    }
    
    weak var listener: SearchPresentableListener?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var searchTextField: SearchTextField = {
        let textField = SearchTextField()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchTextFieldDidTap))
        textField.addGestureRecognizer(tapGesture)
        
        textField.placeholder = Constant.SearchTextField.placeholder
        textField.clipsToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadiusMedium
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var showSearchHomeListButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.image = UIImage(systemName: Constant.ShowSearchHomeListButton.image)
        button.configuration?.baseForegroundColor = .hpBlue1
        button.configuration?.baseBackgroundColor = .hpWhite
        button.clipsToBounds = true
        button.layer.cornerRadius = Constant.ShowSearchHomeListButton.length / 2
        
        button.addTarget(self, action: #selector(showSearchHomeListButtonDidTap), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var storyView: SearchMapStoryView = {
        let storyView = SearchMapStoryView()
        storyView.isHidden = true
        storyView.layer.cornerRadius = Constants.cornerRadiusMedium
        storyView.layer.borderColor = UIColor.hpGray3.cgColor
        storyView.layer.borderWidth = 1
        storyView.translatesAutoresizingMaskIntoConstraints = false
        storyView.addTapGesture(target: self, action: #selector(storyViewDidTap))
        return storyView
    }()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTabBar()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTabBar()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func appendDashboard(_ viewControllable: ViewControllable) {
        let viewController = viewControllable.uiviewController
        addChild(viewController)
        stackView.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func removeDashboard(_ viewControllable: ViewControllable) {
        let viewController = viewControllable.uiviewController
        stackView.removeArrangedSubview(viewController.view)
        viewController.removeFromParent()
    }
    
    func showStoryView(model: SearchMapStoryViewModel) {
        storyView.setup(model: model)
        storyView.isHidden = false
    }
    
    func hideStoryView() {
        guard storyView.isHidden == false else { return }
        storyView.isHidden = true
    }
    
}

private extension SearchViewController {
    
    @objc func storyViewDidTap() {
        guard let storyID = storyView.storyID else { return }
        listener?.didTapStory(storyID: storyID)
    }
    
}

private extension SearchViewController {
    func setupTabBar() {
        // TODO: tag 수정
        tabBarItem = .init(
            title: Constant.TabBar.title,
            image: .init(systemName: Constant.TabBar.image),
            tag: 1
        )
    }
    
    func setupViews() {
        view.backgroundColor = .hpWhite
        [stackView, searchTextField, showSearchHomeListButton, storyView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.SearchTextField.topSpacing),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingOffset),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.traillingOffset),
            searchTextField.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight),
            
            showSearchHomeListButton.widthAnchor.constraint(equalToConstant: Constant.ShowSearchHomeListButton.length),
            showSearchHomeListButton.heightAnchor.constraint(equalToConstant: Constant.ShowSearchHomeListButton.length),
            showSearchHomeListButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constant.ShowSearchHomeListButton.offset),
            showSearchHomeListButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constant.ShowSearchHomeListButton.offset),
            
            storyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leadingOffset),
            storyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.traillingOffset),
            storyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
}

private extension SearchViewController {
    
    @objc func searchTextFieldDidTap() {
        listener?.attachSearchResult()
    }
    
    @objc func showSearchHomeListButtonDidTap() {
        listener?.didTapCurrentLocation()
    }
    
}
