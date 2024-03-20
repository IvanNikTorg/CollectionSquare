//
//  MChat.swift
//  CollectionSquare
//
//  Created by user on 14.03.2024.
//

import Foundation

struct MItem: Identifiable, Hashable {
    var id: String
    var name: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MItem, rhs: MItem) -> Bool {
        lhs.id == rhs.id
    }
}
