//
//  ContributionGraphView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/10/24.
//

import SwiftUI

struct ContributionGraphView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    @State private var showPurchaseView = false
    
    private func getContributionCount(for date: Date) -> Int {
        return dataManager.weeklyRecords.flatMap { record in
            record.thoughts.filter { thought in
                !thought.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
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
        let startDate = calendar.date(byAdding: .day, value: -83, to: today)!
        
        ZStack {
            // 既存のグラフ
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(20)), count: 12), spacing: 4) {
                ForEach(0..<84) { index in
                    let row = index / 12
                    let col = index % 12
                    let dayOffset = col * 7 + row
                    
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                        let count = getContributionCount(for: date)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(getColor(for: count))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding()
            
            // ブラーとテキスト
            if !sceneDelegate.isPremium {
                ZStack {
                    // 右から左へのグラデーションブラー
                    Rectangle()
                        .fill(Color.card.opacity(0.98))
                        .blur(radius: 3)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black,Color.black,Color.black,Color.black,Color.black,Color.black,
                                                          Color.black.opacity(0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Tap to Unlock")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.BW.opacity(0.6))
                        )
                }
            }
        }
        .background(Color.card)
        .cornerRadius(8)
        .onTapGesture {
            if !sceneDelegate.isPremium {
                showPurchaseView = true
            }
        }
        .sheet(isPresented: $showPurchaseView) {
            PurchaseView()
        }
    }
}

#Preview {
    ContributionGraphView()
        .environmentObject(SceneDelegate())
}
