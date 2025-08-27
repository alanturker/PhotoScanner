//
//  GroupItem.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Foundation

struct GroupItem {
    let type: GroupType
    let count: Int
    let assetIds: [String]
    
    enum GroupType {
        case group(PhotoGroup)
        case other
    }
    
    var title: String {
        switch type {
        case .group(let group):
            return "Group \(group.rawValue.uppercased())"
        case .other:
            return "Others"
        }
    }
}
