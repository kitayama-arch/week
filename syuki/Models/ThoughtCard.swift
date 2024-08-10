//
//  ThoughtCard.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import Foundation

struct ThoughtCard: Identifiable {
    let id: UUID // UUID型のidを持つ
    var content: String
    let date: Date
    var items: [String]

    init(id: UUID = UUID(), content: String, date: Date, items: [String]) {
        self.id = id
        self.content = content
        self.date = date
        self.items = items
    }
}

