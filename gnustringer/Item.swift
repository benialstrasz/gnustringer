//
//  Item.swift
//  gnustringer
//
//  Created by Benedikt Gottstein on 20.05.2025.
//

import Foundation
import SwiftData

@Model
class RecentFile: Identifiable {
    @Attribute(.unique) var name: String
    var lastUsed: Date

    init(name: String, lastUsed: Date = .now) {
        self.name = name
        self.lastUsed = lastUsed
    }
}

@Model
class RecentDirectory: Identifiable {
    @Attribute(.unique) var path: String
    var lastUsed: Date

    init(path: String, lastUsed: Date = .now) {
        self.path = path
        self.lastUsed = lastUsed
    }
}
