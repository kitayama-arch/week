//
//  WeeklyRecordEntity.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2025/04/12.
//

import Foundation
import SwiftData

@Model public class WeeklyRecordEntity {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var goal: String
    var emoji: String
    var reflection: String
    var nextWeekGoal: String
    var nextWeekEmoji: String
    var isReflectionCompleted: Bool
    
    @Relationship(.cascade) var thoughts: [ThoughtCardEntity]?
    
    public init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        goal: String,
        emoji: String,
        reflection: String = "",
        nextWeekGoal: String = "",
        nextWeekEmoji: String = "",
        isReflectionCompleted: Bool = false
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.goal = goal
        self.emoji = emoji
        self.reflection = reflection
        self.nextWeekGoal = nextWeekGoal
        self.nextWeekEmoji = nextWeekEmoji
        self.isReflectionCompleted = isReflectionCompleted
        self.thoughts = []
    }
}
