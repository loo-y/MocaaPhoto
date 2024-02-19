//
//  Item.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/2/19.
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
