//
//  StorageService.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Foundation

protocol StorageServiceProtocol {
    func save<T: Codable>(_ object: T, to fileName: String) async throws
    func load<T: Codable>(_ type: T.Type, from fileName: String) async throws -> T?
    func delete(fileName: String) async throws
}

final class StorageService: StorageServiceProtocol {
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func save<T: Codable>(_ object: T, to fileName: String) async throws {
        let url = documentsDirectory.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    func load<T: Codable>(_ type: T.Type, from fileName: String) async throws -> T? {
        let url = documentsDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    func delete(fileName: String) async throws {
        let url = documentsDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
