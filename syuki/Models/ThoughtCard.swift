//
//  ThoughtCard.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

class ThoughtCard: Identifiable, ObservableObject {
    let id: UUID
    @Published var content: String
    let date: Date
    weak var weeklyRecord: WeeklyRecord?

    init(id: UUID = UUID(), content: String, date: Date, weeklyRecord: WeeklyRecord? = nil) {
        self.id = id
        self.content = content
        self.date = date
        self.weeklyRecord = weeklyRecord
    }
}

