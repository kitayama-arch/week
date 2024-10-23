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
        let startDate = calendar.date(byAdding: .day, value: -49, to: today)!
        
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(20)), count: 7), spacing: 4) {
                ForEach(0..<49) { index in
                    if let date = calendar.date(byAdding: .day, value: index, to: startDate) {
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
