//
//  WeeklyRecordEntity+CoreDataProperties.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/09/28.
//
//

import Foundation
import CoreData


extension WeeklyRecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeeklyRecordEntity> {
        return NSFetchRequest<WeeklyRecordEntity>(entityName: "WeeklyRecordEntity")
    }

    @NSManaged public var emoji: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var goal: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isReflectionCompleted: Bool
    @NSManaged public var nextWeekEmoji: String?
    @NSManaged public var nextWeekGoal: String?
    @NSManaged public var reflection: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var thoughts: NSSet?

}

// MARK: Generated accessors for thoughts
extension WeeklyRecordEntity {

    @objc(addThoughtsObject:)
    @NSManaged public func addToThoughts(_ value: ThoughtCardEntity)

    @objc(removeThoughtsObject:)
    @NSManaged public func removeFromThoughts(_ value: ThoughtCardEntity)

    @objc(addThoughts:)
    @NSManaged public func addToThoughts(_ values: NSSet)

    @objc(removeThoughts:)
    @NSManaged public func removeFromThoughts(_ values: NSSet)

}

extension WeeklyRecordEntity : Identifiable {

}
