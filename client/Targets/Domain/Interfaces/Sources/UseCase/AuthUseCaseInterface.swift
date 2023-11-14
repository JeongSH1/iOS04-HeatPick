//
//  AuthUseCaseInterface.swift
//  DomainInterfaces
//
//  Created by 홍성준 on 11/14/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import Combine
import Foundation
import DomainEntities

public protocol AuthUseCaseInterface: AnyObject {
    
    func requestSignIn(token: String) -> AnyPublisher<AuthToken, Error>
    
}
