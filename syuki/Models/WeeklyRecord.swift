//
//  WeeklyRecord.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/12.
//

import Foundation

class WeeklyRecord: Identifiable,ObservableObject {
    let id: UUID
    let startDate: Date
    let endDate: Date
    @Published var thoughts: [ThoughtCard]
    @Published var reflection: String
    @Published var goal: String
    @Published var nextWeekGoal: String
    
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

// テスト用のダミーデータ
#if DEBUG
extension WeeklyRecord {
    static let sampleData: WeeklyRecord = WeeklyRecord(
        id: UUID(),
        startDate: Date(),
        endDate: Date(),
        thoughts: [
            ThoughtCard(content: "アイデア1", date: Date(), items: []),
            ThoughtCard(content: "アイデア2", date: Date(), items: [])
        ],
        reflection: "今週は集中できた",
        goal: "アプリを完成させる",
        nextWeekGoal: "新しい機能を追加する"
    )
}
#endif
