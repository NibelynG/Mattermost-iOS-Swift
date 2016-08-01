//
//  MappingUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


final class MappingUtils {}

private protocol TeamMethods: class {
    static func containsSingleTeam(mappingResult: RKMappingResult) -> Bool
    static func fetchSiteName(mappingResult: RKMappingResult) -> String?
    static func fetchAllTeams(mappingResult: RKMappingResult) -> [Team]
}

private protocol ChannelMethods: class {
    static func fetchAllChannelsFromList(mappingResult: RKMappingResult) -> [Channel]
}

private protocol PostMethods: class {
    static func isLastPage(mappingResult: RKMappingResult, pageSize: Int) -> Bool
    static func fetchPosts(mappingResult: RKMappingResult) -> [Post]
    static func fetchPostFromUpdate(mappingResult: RKMappingResult) -> Post
}

private protocol UserMethod: class {
    static func fetchUsersFromInitialLoad(mappingResult: RKMappingResult) -> [User]
}

// MARK: - Team
extension MappingUtils: TeamMethods {
    static func containsSingleTeam(mappingResult: RKMappingResult) -> Bool {
        return mappingResult.dictionary()["teams"]?.count == 1
    }
    
    static func fetchSiteName(mappingResult: RKMappingResult) -> String? {
        return (String)(mappingResult.dictionary()["client_cfg"]![PreferencesAttributes.siteName.rawValue])
    }
    
    static func fetchAllTeams(mappingResult: RKMappingResult) -> [Team] {
        return mappingResult.dictionary()["teams"] as! [Team]
    }
    
    static func fetchAllChannels(mappingResult: RKMappingResult) -> [Channel] {
        return mappingResult.array() as! [Channel]
    }
}

extension MappingUtils: PostMethods {
    static func fetchPosts(mappingResult: RKMappingResult) -> [Post] {
        return mappingResult.array() as! [Post]
    }

    static func fetchPostFromUpdate(mappingResult: RKMappingResult) -> Post {
        return mappingResult.firstObject as! Post
    }
    static func isLastPage(mappingResult: RKMappingResult, pageSize: Int) -> Bool {
        return Int(mappingResult.count) < pageSize
    }
}

extension MappingUtils: UserMethod {
    class func fetchUsersFromInitialLoad(mappingResult: RKMappingResult) -> [User] {
        if let users = mappingResult.dictionary()["direct_profiles"] {
            return users as! [User]
        }
        return []
    }
}

extension MappingUtils: ChannelMethods {
    static func fetchAllChannelsFromList(mappingResult: RKMappingResult) -> [Channel] {
        return mappingResult.dictionary()["channels"] as! [Channel]
    }
}