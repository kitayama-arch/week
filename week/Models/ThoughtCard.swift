//
//  ThoughtCard.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

@Observable class ThoughtCard: Identifiable, ObservableObject {
    let id: UUID
    var content: String
    let date: Date
    weak var weeklyRecord: WeeklyRecord?

    init(id: UUID = UUID(), content: String, date: Date, weeklyRecord: WeeklyRecord? = nil) {
        self.id = id
        self.content = content
        self.date = date
        self.weeklyRecord = weeklyRecord
    }
}

