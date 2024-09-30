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
                .fill(Color.card)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            HStack {
                Button(action: {
                    isPickerPresented.toggle()
                }) {
                    ZStack {
                        Text(weeklyRecord.emoji)
                            .blur(radius: 10).opacity(0.5)
                            .font(.largeTitle)
                        Text(weeklyRecord.emoji)
                            .font(.largeTitle)
                    }
                }
                .emojiPicker(isPresented: $isPickerPresented, selectedEmoji: $weeklyRecord.emoji)
                .onChange(of: weeklyRecord.emoji) { oldValue, newValue in
                    dataManager.updateWeeklyRecord(weeklyRecord: weeklyRecord)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1.5, height: 40)
                    .cornerRadius(1)
                
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
