//
//  GroupType.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Foundation

enum GroupType: Equatable {
    case group(PhotoGroup)
    case other
    
    var title: String {
        switch self {
        case .group(let group):
            return "Group \(group.rawValue.uppercased())"
        case .other:
            return "Others"
        }
    }
}
