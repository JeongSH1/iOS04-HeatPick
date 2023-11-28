//
//  MyProfileResponseDTO.swift
//  MyAPI
//
//  Created by 홍성준 on 11/23/23.
//  Copyright © 2023 codesquad. All rights reserved.
//

import Foundation
import DomainEntities

public struct MyProfileResponseDTO: Decodable {
    
    public let username: String
    public let profileURL: String?
    public let followerCount: Int
    public let storyCount: Int
    public let experience: Int
    public let maxExperience: Int
    public let mainBadge: MyProfileBadgeResponseDTO
    public let storyList: [MyProfileStoryResponseDTO]
    
}

public struct MyProfileBadgeResponseDTO: Decodable {
    let badgeId: Int
    let badgeName: String
    let badgeExp: Int
    let emoji: String
}

public struct MyProfileStoryResponseDTO: Decodable {
    public let storyId: Int
    public let title: String
    public let content: String
    public let storyImages: [String]
    public let likeCount: Int
    public let createAt: String // 2023-11-23T03:11:58.868Z
}

public extension MyProfileResponseDTO {
    
    func toDomain() -> MyPage {
        return .init(
            userName: username,
            profileImageURL: profileURL,
            followerCount: followerCount,
            storyCount: storyCount,
            experience: experience,
            maxExperience: maxExperience,
            mainBadge: mainBadge.toDomain(),
            stories: storyList.map { $0.toDomain() }
        )
    }
    
}

public extension MyProfileBadgeResponseDTO {
    
    func toDomain() -> MyPageBadge {
        return .init(
            id: badgeId,
            name: badgeName,
            experience: badgeExp,
            emoji: emoji
        )
    }
    
}

public extension MyProfileStoryResponseDTO {
    
    func toDomain() -> MyPageStory {
        return .init(
            storyId: storyId,
            title: title, 
            content: content,
            thumbnailImageURL: nil,
            likeCount: likeCount
        )
    }
}
