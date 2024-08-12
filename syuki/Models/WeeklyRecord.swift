//
//  WeeklyRecord.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/12.
//

import Foundation

struct WeeklyRecord: Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    var thoughts: [ThoughtCard]
    var reflection: String
    var goal: String
    var nextWeekGoal: String
    
    init(id: UUID, startDate: Date, endDate: Date, thoughts: [ThoughtCard], reflection: String, goal: String, nextWeekGoal: String) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.thoughts = thoughts
        self.reflection = reflection
        self.goal = goal
        self.nextWeekGoal = nextWeekGoal
    }
}
