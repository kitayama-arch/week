//
//  GoalCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI
import MCEmojiPicker

struct GoalCardView: View {
    @Binding var weeklyRecord: WeeklyRecord
    @State private var isPickerPresented: Bool = false

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
                Divider()
                    .frame(height: 40)
                TextField("今週の目標を入力", text: $weeklyRecord.goal)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    GoalCardView(weeklyRecord: .constant(WeeklyRecord.sampleData))
}