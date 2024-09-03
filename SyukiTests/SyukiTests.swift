//
//  SyukiTests.swift
//  SyukiTests
//
//  Created by Ta-MacbookAir on 2024/09/03.
//

import XCTest
@testable import syuki // アプリのターゲット名に置き換える

class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var testDate: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager()
        // テスト用の日付を設定（例: 2024年8月15日）
        testDate = Calendar.current.date(from: DateComponents(year: 2024, month: 8, day: 15))!
    }

    override func tearDownWithError() throws {
        coreDataManager = nil
        testDate = nil
        try super.tearDownWithError()
    }

    func testFetchCurrentWeekRecord() throws {
        // 1. テストデータの準備
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfWeek(for: testDate)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        _ = coreDataManager.createWeeklyRecord(startDate: startOfWeek, endDate: endOfWeek, goal: "テスト目標", emoji: "😀")

        // 2. fetchCurrentWeekRecord() を実行
        // テスト用の日付を渡す
        let fetchedWeeklyRecord = coreDataManager.fetchCurrentWeekRecord(for: testDate)

        // 3. 結果の検証
        XCTAssertNotNil(fetchedWeeklyRecord, "現在の週のレコードが取得できない")
        XCTAssertEqual(fetchedWeeklyRecord?.startDate, startOfWeek, "開始日が一致しない")
        XCTAssertEqual(fetchedWeeklyRecord?.endDate, endOfWeek, "終了日が一致しない")
    }
}
