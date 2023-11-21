//
//  HomeAPI.swift
//  HomeAPI
//
//  Created by 홍성준 on 11/21/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import Foundation
import BaseAPI
import NetworkAPIKit

public enum HomeAPI {
    case recommend
}

extension HomeAPI: Target {
    
    public var baseURL: URL {
        return URL(string: NetworkHost.base)!
    }
    
    public var path: String {
        switch self {
        case .recommend: return "/story/recommend"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .recommend: return .get
        }
    }
    
    public var header: NetworkHeader {
        return .authorized
    }
    
    public var task: Task {
        switch self {
        case .recommend: return .plain
        }
    }
    
}
