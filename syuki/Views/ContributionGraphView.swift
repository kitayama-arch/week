//
//  ContributionGraphView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/10/24.
//

import SwiftUI

struct ContributionGraphView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    private func getContributionCount(for date: Date) -> Int {
        return dataManager.weeklyRecords.flatMap { record in
            record.thoughts.filter { thought in
                Calendar.current.isDate(thought.date, inSameDayAs: date)
            }
        }.count
    }
    
    private func getColor(for count: Int) -> Color {
        switch count {
        case 0:
            return Color.gray.opacity(0.1)
        case 1:
            return Color.accentColor.opacity(0.2)
        case 2...3:
            return Color.accentColor.opacity(0.4)
        case 4...5:
            return Color.accentColor.opacity(0.6)
        default:
            return Color.accentColor.opacity(0.8)
        }
    }
    
    var body: some View {
        let calendar = Calendar.current
        let today = Date()
        // 表示する週数を12週間に増やす（84日分）
        let startDate = calendar.date(byAdding: .day, value: -83, to: today)!
        
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(20)), count: 12), spacing: 4) {
            // 12列×7行のグリッドを作成（84マス）
            ForEach(0..<84) { index in
                // インデックスを行と列に変換
                let row = index % 7
                let col = index / 7
                // 新しいインデックスを計算（右下から左上に向かって）
                let newIndex = col + (6 - row) * 12
                
                if let date = calendar.date(byAdding: .day, value: newIndex, to: startDate) {
                    let count = getContributionCount(for: date)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(getColor(for: count))
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding()
        .background(Color.card)
        .cornerRadius(8)
    }
}

#Preview {
    ContributionGraphView()
}
