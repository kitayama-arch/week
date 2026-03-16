//
//  ArchiveView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI
import UIKit

struct ArchiveView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var dataManager = DataManager.shared
    let resetToken: Int
    
    @Namespace private var archiveTabNamespace
    @State private var selectedWeeklyRecord: WeeklyRecord?
    @State private var searchText = ""
    @State private var isSearchFieldActive = false
    @State private var selectedTab: ArchiveTab = .you
    @State private var skipNextTabChangeFeedback = false
    @State private var currentDayAnchor = Calendar.current.startOfDay(for: Date())
    
    private let dayChangeTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var archiveData: ArchiveDataSnapshot {
        ArchiveDataSnapshot(records: dataManager.weeklyRecords, currentDayAnchor: currentDayAnchor)
    }
    
    private var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isSearching: Bool {
        !searchQuery.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissSearchKeyboard()
                }
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    NativeSearchBar(
                        text: $searchText,
                        isEditing: $isSearchFieldActive,
                        placeholder: String(localized: "記録・目標・振り返りを検索")
                    )
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    ArchiveCapsuleTabBar(
                        tabs: ArchiveTab.allCases,
                        selectedTab: $selectedTab,
                        namespace: archiveTabNamespace
                    )
                    .padding(.top, 12)
                    .padding(.horizontal)
                }
                
                if isSearching {
                    SearchResultsContainerView(
                        results: archiveData.searchResults(matching: searchQuery),
                        searchQuery: searchQuery,
                        resetToken: resetToken,
                        onSelect: { record in
                            dismissSearchKeyboard()
                            selectedWeeklyRecord = record
                        },
                        onBackgroundTap: dismissSearchKeyboard
                    )
                    .padding(.top, 16)
                    .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    TabView(selection: $selectedTab) {
                        YouArchivePage(
                            randomThoughts: archiveData.archivalThoughtItems,
                            initialRandomThoughtID: archiveData.randomThought?.id,
                            dailySelectionKey: archiveData.dailySelectionKey,
                            goalEmojiBubbleItems: Array(archiveData.goalEmojiBubbleItems.prefix(8)),
                            recentReflectionRecords: Array(archiveData.recentReflectionRecords.prefix(3)),
                            mostActiveRecords: Array(archiveData.mostActiveRecords.prefix(3)),
                            resetToken: resetToken,
                            onSelectRecord: { selectedWeeklyRecord = $0 },
                            onBackgroundTap: dismissSearchKeyboard
                        )
                        .tag(ArchiveTab.you)
                        
                        TimelineArchivePage(
                            sortedRecords: archiveData.sortedRecords,
                            resetToken: resetToken,
                            onSelect: { selectedWeeklyRecord = $0 },
                            onBackgroundTap: dismissSearchKeyboard
                        )
                        .tag(ArchiveTab.timeline)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 12)
                    .ignoresSafeArea(.container, edges: .bottom)
                    .onChange(of: selectedTab) { _, _ in
                        if skipNextTabChangeFeedback {
                            skipNextTabChangeFeedback = false
                        } else {
                            triggerSelectionFeedback()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedWeeklyRecord) { record in
            WeeklyRecordDetailView(weeklyRecord: record)
        }
        .onChange(of: resetToken) { _, _ in
            searchText = ""
            selectedWeeklyRecord = nil
            skipNextTabChangeFeedback = true
            selectedTab = .you
            dismissSearchKeyboard()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            refreshCurrentDayAnchor()
        }
        .onReceive(dayChangeTimer) { _ in
            refreshCurrentDayAnchor()
        }
    }
    
    private func dismissSearchKeyboard() {
        isSearchFieldActive = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    private func refreshCurrentDayAnchor() {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        guard startOfToday != currentDayAnchor else { return }
        currentDayAnchor = startOfToday
    }
}

#Preview {
    ArchiveView(resetToken: 0)
}
