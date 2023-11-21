//
//  SearchAfterStoryDashboardViewController.swift
//  SearchImplementations
//
//  Created by 이준복 on 11/21/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import ModernRIBs
import UIKit

protocol SearchAfterStoryDashboardPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class SearchAfterStoryDashboardViewController: UIViewController, SearchAfterStoryDashboardPresentable, SearchAfterStoryDashboardViewControllable {

    weak var listener: SearchAfterStoryDashboardPresentableListener?
}
