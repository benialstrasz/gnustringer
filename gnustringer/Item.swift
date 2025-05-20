//
//  Item.swift
//  gnustringer
//
//  Created by Benedikt Gottstein on 20.05.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
