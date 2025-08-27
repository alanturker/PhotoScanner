//
//  GroupedAssets.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Foundation

struct GroupedAssets: Codable {
    private var groupedAssetIds: [String: [String]] = [:]
    private var otherAssetIds: [String] = []
    
    mutating func addAsset(_ assetId: String, to group: PhotoGroup?) {
        if let group = group {
            groupedAssetIds[group.rawValue, default: []].append(assetId)
        } else {
            otherAssetIds.append(assetId)
        }
    }
    
    func assetIds(for group: PhotoGroup) -> [String] {
        groupedAssetIds[group.rawValue] ?? []
    }
    
    var otherAssetIds_public: [String] {
        otherAssetIds
    }
    
    func count(for group: PhotoGroup) -> Int {
        assetIds(for: group).count
    }
    
    var otherCount: Int {
        otherAssetIds.count
    }
    
    var nonEmptyGroups: [PhotoGroup] {
        PhotoGroup.allCases.filter { count(for: $0) > 0 }
    }
    
    var hasOthers: Bool {
        otherCount > 0
    }
    
    func getAllGroupItems() -> [GroupItem] {
        var items: [GroupItem] = []
        
        for group in nonEmptyGroups {
            let item = GroupItem(
                type: .group(group),
                count: count(for: group),
                assetIds: assetIds(for: group)
            )
            items.append(item)
        }
        
        if hasOthers {
            let item = GroupItem(
                type: .other,
                count: otherCount,
                assetIds: otherAssetIds
            )
            items.append(item)
        }
        
        return items
    }
}
