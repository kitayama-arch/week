//
//  SyukiTests.swift
//  SyukiTests
//
//  Created by Ta-MacbookAir on 2024/09/03.
//

import XCTest
import CoreData
@testable import syuki // アプリのターゲット名に置き換える

class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var testDate: Date!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // テスト用に inMemory を true で初期化
        coreDataManager = CoreDataManager(inMemory: true)
        
        testDate = Calendar.current.date(from: DateComponents(year: 2024, month: 8, day: 15))!
    }
    
    override func tearDownWithError() throws {
        coreDataManager = nil
        testDate = nil
        try super.tearDownWithError()
    }
    
    func testFetchCurrentWeekRecord_WhenRecordExists() throws {
        // 1. テストデータの準備
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: testDate)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        // CoreDataManagerのメソッドを使用してWeeklyRecordを作成
        _ = coreDataManager.createWeeklyRecord(startDate: startOfWeek, endDate: endOfWeek, goal: "テスト目標", emoji: "😀")
        
        // 2. fetchCurrentWeekRecord() を実行
        let fetchedWeeklyRecord = coreDataManager.fetchCurrentWeekRecord(for: testDate)
        
        // 3. 結果の検証
        XCTAssertNotNil(fetchedWeeklyRecord, "現在の週のレコードが取得できない")
        
        // 4. startDateとendDateの比較
        let fetchedStartDateComponents = calendar.dateComponents([.year, .month, .day], from: fetchedWeeklyRecord!.startDate!)
        let expectedStartDateComponents = calendar.dateComponents([.year, .month, .day], from: startOfWeek)
        XCTAssertEqual(fetchedStartDateComponents, expectedStartDateComponents, "開始日が一致しない")
        
        let fetchedEndDateComponents = calendar.dateComponents([.year, .month, .day], from: fetchedWeeklyRecord!.endDate!)
        let expectedEndDateComponents = calendar.dateComponents([.year, .month, .day], from: endOfWeek)
        XCTAssertEqual(fetchedEndDateComponents, expectedEndDateComponents, "終了日が一致しない")
    }
}
