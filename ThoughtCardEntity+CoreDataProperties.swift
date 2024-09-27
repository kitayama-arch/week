//
//  ThoughtCardEntity+CoreDataProperties.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/09/28.
//
//

import Foundation
import CoreData


extension ThoughtCardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThoughtCardEntity> {
        return NSFetchRequest<ThoughtCardEntity>(entityName: "ThoughtCardEntity")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var weeklyRecord: WeeklyRecordEntity?

}

extension ThoughtCardEntity : Identifiable {

}
