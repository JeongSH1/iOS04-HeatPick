//
//  SearchBeforeRecentSearchesView.swift
//  SearchImplementations
//
//  Created by 이준복 on 11/23/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import UIKit
import DesignKit

protocol searchBeforeRecentSearchesViewDelegate: AnyObject {
    func didTapSearchBeforeRecentSearchesView(text: String?)
}

struct SearchBeforeRecentSearchesViewModel: Decodable {
    let text: String
}

final class searchBeforeRecentSearchesView: UIView {
    
    weak var delegate: searchBeforeRecentSearchesViewDelegate?
    
    private enum Constant {
        static let topOffset: CGFloat = 5
        static let bottomOffset: CGFloat = -topOffset
        static let leadingOffset: CGFloat = 15
        static let trailingOffset: CGFloat = -leadingOffset
    }
    
    private var model: SearchBeforeRecentSearchesViewModel?
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = .bodyRegular
        label.text = "최근 검색어"
        label.textColor = .hpBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfiguration()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfiguration()
        setupViews()
    }

    
    func setup(_ model: SearchBeforeRecentSearchesViewModel) {
        self.model = model
        titleLabel.text = model.text
    }
    
}

private extension searchBeforeRecentSearchesView {
    
    func setupViews() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constant.topOffset),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.leadingOffset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constant.trailingOffset),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constant.bottomOffset),
        ])
    }
    
    func setupConfiguration() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapSearchBeforeRecentSearchesView)
        )
        addGestureRecognizer(tapGesture)
        backgroundColor = .hpGray3
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadiusSmall
    }

}

private extension searchBeforeRecentSearchesView {
    
    @objc func didTapSearchBeforeRecentSearchesView() {
        delegate?.didTapSearchBeforeRecentSearchesView(text: model?.text)
    }
    
}
