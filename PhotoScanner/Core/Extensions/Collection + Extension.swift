//
//  Collection + Subscript.swift
//  PhotoScanner
//
//  Created by Turker Alan on 27.08.2025.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
