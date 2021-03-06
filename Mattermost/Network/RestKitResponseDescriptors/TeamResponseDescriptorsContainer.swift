//
//  TeamResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func initalLoadResponseDescriptor() -> RKResponseDescriptor
    static func teamListingsResponseDescriptor() -> RKResponseDescriptor
    static func initalLoadConfigResponseDescriptor() -> RKResponseDescriptor
    static func invitationResponseDescriptor() -> RKResponseDescriptor
}

final class TeamResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}

// MARK: - Response Descriptors
extension TeamResponseDescriptorsContainer: ResponseDescriptors {
    static func initalLoadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: TeamMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: TeamPathPatternsContainer.initialLoadPathPattern(),
                                    keyPath: "teams",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func teamListingsResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: TeamMappingsContainer.emptyMapping(),
                                    method: .GET,
                                    pathPattern: TeamPathPatternsContainer.teamListingsPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func initalLoadConfigResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: TeamMappingsContainer.initialLoadConfigMapping(),
                                    method: .GET,
                                    pathPattern: TeamPathPatternsContainer.initialLoadPathPattern(),
                                    keyPath: "client_cfg",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func invitationResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: TeamMappingsContainer.invitationMapping(),
                                    method: .POST,
                                    pathPattern: TeamPathPatternsContainer.teamInviteMembers(),
                                    keyPath: "invites",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
