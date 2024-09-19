//
//  StorageManager.swift
//  Game
//
//  Created by Hayyim on 17/09/2024.
//

import Foundation

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let key = "someKey"

    func save(_ data: UserDataInfo) {
        
        guard let encodeData = try? JSONEncoder().encode(data)
        else { return }
        
        userDefaults.set(encodeData, forKey: key)
    }
    
    func fatchStatistics() -> UserDataInfo {
        
        guard let data = userDefaults.object(forKey: key) as? Data
        else { return UserDataInfo() }
        
        guard let statistics = try? JSONDecoder().decode(UserDataInfo.self, from: data)
        else { return UserDataInfo() }
        
        return statistics
    }
    
    
}
