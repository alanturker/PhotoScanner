//
//  ScanProgress.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Foundation

struct ScanProgress: Codable {
    let totalAssets: Int
    let processedAssets: Int
    let processedAssetIds: Set<String>
    
    var percentage: Double {
        guard totalAssets > 0 else { return 0 }
        return Double(processedAssets) / Double(totalAssets)
    }
    
    var isComplete: Bool {
        processedAssets >= totalAssets
    }
    
    var formattedProgress: String {
        let percentage = Int(self.percentage * 100)
        return "\(processedAssets)/\(totalAssets) (\(percentage)%)"
    }
}
