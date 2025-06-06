//
//  ThoughtCardEntity.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2025/04/12.
//

import Foundation
import SwiftData

@Model public class ThoughtCardEntity {
    @Attribute(.unique) var id: UUID
    var content: String
    var date: Date
    
    @Relationship(.cascade) var weeklyRecord: WeeklyRecordEntity?
    
    public init(id: UUID = UUID(), content: String, date: Date) {
        self.id = id
        self.content = content
        self.date = date
    }
}
