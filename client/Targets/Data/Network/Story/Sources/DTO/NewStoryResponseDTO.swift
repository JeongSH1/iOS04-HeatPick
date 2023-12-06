//
//  NewStoryResponseDTO.swift
//  StoryAPI
//
//  Created by jungmin lim on 11/21/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import Foundation

import DomainEntities

public struct NewStoryResponseDTO: Decodable {
    
    let storyId: Int
    let badge: BadgeExpResponseDTO
    
    public struct BadgeExpResponseDTO: Decodable {
        let badgeName: String
        let prevExp: Int
        let nowExp: Int
        
        public init(badgeName: String, prevExp: Int, nowExp: Int) {
            self.badgeName = badgeName
            self.prevExp = prevExp
            self.nowExp = nowExp
        }
        
    }
    
    public init(storyId: Int, badge: BadgeExpResponseDTO) {
        self.storyId = storyId
        self.badge = badge
    }
    
    public func toDomain() -> (Story, BadgeExp) {
        return (Story(id: storyId, storyContent: nil), BadgeExp(name: badge.badgeName, prevExp: badge.prevExp, nowExp: badge.nowExp))
    }
}
