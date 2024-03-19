//
//  MSection.swift
//  CollectionSquare
//
//  Created by user on 14.03.2024.
//

import Foundation

struct MSection: Identifiable, Hashable {
    let id: String
    let number: Int
    var items: [MItem]
}

