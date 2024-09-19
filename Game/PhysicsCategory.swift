//
//  PhysicsCategory.swift
//  Game
//
//  Created by Hayyim on 16/09/2024.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let drop: UInt32 = 0x1 << 0
    static let aim: UInt32 = 0x1 << 1
    static let defaultObject: UInt32 = 0x1 << 2
}
