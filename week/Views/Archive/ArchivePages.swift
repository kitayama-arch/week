//
//  ArchivePages.swift
//  week
//
//  Created by Codex on 2026/03/16.
//

import SwiftUI

struct TimelineArchivePage: View {
    let sortedRecords: [WeeklyRecord]
    let resetToken: Int
    let onSelect: (WeeklyRecord) -> Void
    let onBackgroundTap: () -> Void
    
    private let topID = "timeline-top"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)
                    
                    if sortedRecords.isEmpty {
                        ArchiveEmptyStateView(
                            title: String(localized: "記録はまだありません"),
                            message: String(localized: "記録が増えると、ここに週ごとのアーカイブが並びます。")
                        )
                        .padding(.horizontal)
                        .padding(.top, 12)
                    } else {
                        ContributionGraphView()
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(sortedRecords) { weeklyRecord in
                                WeeklyRecordCardView(weeklyRecord: weeklyRecord)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onSelect(weeklyRecord)
                                    }
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .mask(ArchiveTopFadeMask())
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.container, edges: .bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onBackgroundTap()
                }
            )
            .onChange(of: resetToken) { _, _ in
                withAnimation {
                    proxy.scrollTo(topID, anchor: .top)
                }
            }
        }
    }
}

struct YouArchivePage: View {
    let randomThoughts: [ArchiveThoughtItem]
    let initialRandomThoughtID: String?
    let dailySelectionKey: String
    let goalEmojiBubbleItems: [GoalEmojiBubbleItem]
    let recentReflectionRecords: [WeeklyRecord]
    let mostActiveRecords: [WeeklyRecord]
    let resetToken: Int
    let onSelectRecord: (WeeklyRecord) -> Void
    let onBackgroundTap: () -> Void
    
    private let topID = "you-top"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)
                    
                    PickupHeroSection(
                        thoughts: randomThoughts,
                        initialThoughtID: initialRandomThoughtID,
                        dailySelectionKey: dailySelectionKey,
                        onSelectRecord: onSelectRecord
                    )
                    .padding(.horizontal)
                    
                    GoalEmojiBubbleSection(
                        title: String(localized: "今週の絵文字"),
                        subtitle: String(localized: "自分が選びがちな気分やテーマが、だんだん見えてきます。"),
                        items: goalEmojiBubbleItems
                    )
                    .padding(.horizontal)
                    
                    PickupReflectionSection(
                        title: String(localized: "直近の振り返り"),
                        subtitle: String(localized: "最近書いた振り返りをまとめて見返せます。"),
                        records: recentReflectionRecords,
                        onSelectRecord: onSelectRecord
                    )
                    .padding(.horizontal)
                    
                    PickupWeeklySection(
                        title: String(localized: "記録が多かった週"),
                        subtitle: String(localized: "思考がよく動いていた週を見つけ直せます。"),
                        records: mostActiveRecords,
                        onSelectRecord: onSelectRecord
                    )
                    .padding(.horizontal)
                }
                .padding(.top, 4)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .mask(ArchiveTopFadeMask())
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.container, edges: .bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onBackgroundTap()
                }
            )
            .onChange(of: resetToken) { _, _ in
                withAnimation {
                    proxy.scrollTo(topID, anchor: .top)
                }
            }
        }
    }
}
