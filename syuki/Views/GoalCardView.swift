//
//  GoalCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI
import MCEmojiPicker

struct GoalCardView: View {
    @ObservedObject var weeklyRecord: WeeklyRecord
    @State private var isPickerPresented: Bool = false
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(height: 60)
            HStack {
                Button(action: {
                    isPickerPresented.toggle()
                }) {
                    Text(weeklyRecord.emoji)
                        .font(.largeTitle)
                }
                .emojiPicker(isPresented: $isPickerPresented, selectedEmoji: $weeklyRecord.emoji)
                .onChange(of: weeklyRecord.emoji) { oldValue, newValue in
                    dataManager.updateWeeklyRecord(weeklyRecord: weeklyRecord)
                }
                Divider()
                    .frame(height: 40)
                TextField("今週の目標を入力してください", text: $weeklyRecord.goal)
                    .onChange(of: weeklyRecord.goal) { oldValue, newValue in
                        dataManager.updateWeeklyRecord(weeklyRecord: weeklyRecord)
                    }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

#Preview {
    GoalCardView(weeklyRecord: WeeklyRecord.sampleData)
        .environmentObject(DataManager.shared)
}
