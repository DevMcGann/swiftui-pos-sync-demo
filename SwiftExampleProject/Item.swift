//
//  Item.swift
//  SwiftExampleProject
//
//  Created by Gabriel Mc Gann on 13/04/2026.
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
