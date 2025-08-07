//
//  WeeklyRecord.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/08/12.
//

import Foundation
import Combine

class WeeklyRecord: ObservableObject, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    @Published var thoughts: [ThoughtCard]
    @Published var reflection: String
    @Published var goal: String
    @Published var nextWeekGoal: String
    @Published var emoji: String
    @Published var nextWeekEmoji: String
    @Published var isReflectionCompleted: Bool
    
    var description: String {
            return "WeeklyRecord(id: \(id), startDate: \(startDate), endDate: \(endDate), goal: \(goal), emoji: \(emoji), nextWeekGoal: \(nextWeekGoal), nextWeekEmoji: \(nextWeekEmoji))"
        }
    
    init(id: UUID, startDate: Date, endDate: Date, thoughts: [ThoughtCard], reflection: String, goal: String, nextWeekGoal: String, emoji: String, nextWeekEmoji: String, isReflectionCompleted: Bool = false ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.thoughts = thoughts
        self.reflection = reflection
        self.goal = goal
        self.nextWeekGoal = nextWeekGoal
        self.emoji = emoji
        self.nextWeekEmoji = nextWeekEmoji
        self.isReflectionCompleted = isReflectionCompleted
    }
    
    func update(from newRecord: WeeklyRecord) {
        self.thoughts = newRecord.thoughts
        self.reflection = newRecord.reflection
        self.goal = newRecord.goal
        self.nextWeekGoal = newRecord.nextWeekGoal
        self.emoji = newRecord.emoji
        self.nextWeekEmoji = newRecord.nextWeekEmoji
        self.isReflectionCompleted = newRecord.isReflectionCompleted
    }
}
