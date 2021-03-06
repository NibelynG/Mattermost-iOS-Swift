//
//  FileResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func uploadResponseDescriptor() -> RKResponseDescriptor
    static func getInfoResponseDescriptor() -> RKResponseDescriptor
}

final class FileResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}


//ResponseDescriptors
extension FileResponseDescriptorsContainer: ResponseDescriptors {
    static func uploadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: FileMappingsContainer.uploadMapping(),
                                    method: .POST,
                                    pathPattern: FilePathPatternsContainer.uploadPathPattern(),
                                    keyPath: "filenames",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.successful))
    }
    static func getInfoResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: FileMappingsContainer.getInfoMapping(),
                                    method: .GET,
                                    pathPattern: FilePathPatternsContainer.getInfoPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
