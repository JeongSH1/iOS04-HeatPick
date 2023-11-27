//
//  SearhResultSearchAfterUseCaseInterface.swift
//  DomainInterfaces
//
//  Created by 이준복 on 11/24/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import Foundation
import DomainEntities

public protocol SearhResultSearchAfterUseCaseInterface {
    
    func fetchResult(searchText: String) async -> Result<SearchResult, Error>
    func fetchStory(searchText: String) async -> Result<[SearchStory], Error>
    func fetchUser(searchText: String) async -> Result<[SearchUser], Error>
    
}
