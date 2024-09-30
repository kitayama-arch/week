//
//  ContentView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var dataManager = DataManager.shared // 共有インスタンスを使用
    @State private var showReflectionView = false
    @State private var showArchiveView = false
    @State private var showSettingView = false
    @State private var reflectionWeeklyRecord: WeeklyRecord?
    @State private var focusedThoughtCardID: UUID?
    @State private var isSunday: Bool = false
    @State private var showAlert = false
    
    private var thoughtsBinding: Binding<[ThoughtCard]>? {
        guard let currentWeeklyRecord = dataManager.currentWeeklyRecord else { return nil }
        return Binding<[ThoughtCard]>(
            get: { currentWeeklyRecord.thoughts },
            set: { dataManager.currentWeeklyRecord?.thoughts = $0 }
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                if let currentWeeklyRecord = dataManager.currentWeeklyRecord {
                    // currentWeeklyRecord が存在する場合：通常のコンテンツを表示
                    VStack {
                        // カスタムナビゲーションバー
                        VStack {
                            ZStack {
                                Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.gray)
                                    .overlay(
                                        Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.white)
                                            .opacity(0.21)
                                            .offset(x: 0.5, y: 0.5)
                                    )
                                    .overlay(
                                        Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.white)
                                            .opacity(0.2)
                                            .offset(x: -0.5, y: -0.5)
                                    )
                                HStack {
                                    HStack(spacing: 20) { // スペーシングを追加
                                        Button {
                                            showArchiveView = true
                                        } label: {
                                            Image(systemName: "archivebox")
                                                .font(.title)
                                                .foregroundStyle(.gray.opacity(0.8))
                                        }
                                        
                                        Button {
                                            showSettingView = true
                                        } label: {
                                            Image(systemName: "gearshape")
                                                .font(.title)
                                                .foregroundStyle(.gray.opacity(0.8))
                                        }
                                    }
                                    
                                    Spacer()
                                    Button(action: {
//                                        if isSunday {
                                            reflectionWeeklyRecord = currentWeeklyRecord
                                            showReflectionView = true
//                                        } else {
//                                            showAlert = true
//                                        
                                    }) {
                                        Text("振り返り")
                                            .font(.headline)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 10)
                                            .foregroundColor(.white.opacity(0.95))
//                                            .background(
//                                                LinearGradient(
//                                                    gradient: Gradient(colors: [
//                                                     Color.accentColor.opacity(0.8),Color.accentColor
//                                                    ]),
//                                                    startPoint: .top,
//                                                    endPoint: .bottom
//                                                )
//                                            )
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        isSunday ? Color.accentColor.opacity(0.8) : Color.gray.opacity(0.8),
                                                        isSunday ? Color.accentColor : Color.gray
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                            )
                                            .cornerRadius(12)
                                    }
                                    .shadow(color: isSunday ? .accent.opacity(0.6) : .clear, radius: 10, x: 0.0, y: 0.0)
//                                            .shadow(color: .accent.opacity(0.6), radius: 10, x: 0.0, y: 0.0)
                                }
                                .padding(.horizontal)
                            }
                            GoalCardView(weeklyRecord: currentWeeklyRecord)
                                .environmentObject(dataManager)
                        }
                        
                        ZStack {
                            ScrollView {
                                ForEach(Array(currentWeeklyRecord.thoughts.enumerated()), id: \.element.id) { index, thoughtCard in
                                    ThoughtCardView(
                                        thoughtCard: thoughtCard,
                                        dataManager: dataManager,
                                        focusedThoughtCardID: $focusedThoughtCardID
                                    )
                                }
                            }
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black, Color.black, Color.black,
                                                                Color.black.opacity(0)]),
                                    startPoint: .init(x: 0.5, y: 0.1),
                                    endPoint: .init(x: 0.5, y: 0)
                                )
                            )
                            // 新しい思考カードを追加するボタン
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        createNewThoughtCard()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 75))
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle (
                                                Color(.white).opacity(0.8),
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.accentColor.opacity(0.8),Color.accentColor
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                    }
                                    .shadow(color: .accent.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                                    .padding()
                                }
                            }
                        }
                    }
                } else {
                    // currentWeeklyRecord が nil の場合：振り返り未完了の状態を表示
                    VStack {
                        Spacer()
                        Text("前の週の振り返りがまだ完了していません。")
                            .font(.title)
                            .padding()
                        Button(action: {
                            if let previousWeeklyRecord = dataManager.getPreviousWeeklyRecord() {
                                reflectionWeeklyRecord = previousWeeklyRecord
                                showReflectionView = true
                            }
                        }) {
                            Text("振り返りを行う")
                                .font(.title2)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                }
            }
            .onReceive(dataManager.$shouldFocusNewCard) { shouldFocus in // shouldFocusNewCard を監視
                if shouldFocus, let currentWeeklyRecord = dataManager.currentWeeklyRecord {
                    // 新しいカードの ID を取得
                    focusedThoughtCardID = currentWeeklyRecord.thoughts.last?.id
                    
                    // shouldFocusNewCard を false に戻す
                    dataManager.shouldFocusNewCard = false
                }
            }
            .onAppear {
                dataManager.loadCurrentWeekRecord()
                updateIsSunday()
                print("HomeView appeared - currentWeeklyRecord.thoughts: \(dataManager.currentWeeklyRecord?.thoughts ?? [])")
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showReflectionView) {
                if let weeklyRecordToReflect = reflectionWeeklyRecord ?? dataManager.currentWeeklyRecord {
                    ReflectionView(weeklyRecord: weeklyRecordToReflect)
                        .environmentObject(dataManager)
                        .onAppear {
                            dataManager.loadCurrentWeekRecord()
                        }
                        .onDisappear {
                            dataManager.loadCurrentWeekRecord()
                        }
                } else {
                    Text("振り返りデータが利用できません")
                }
            }
            .navigationDestination(isPresented: $showArchiveView) {
                ArchiveView()
            }
            .navigationDestination(isPresented: $showSettingView) {
                SettingView()
            }
            .alert("振り返りは日曜日のみ可能です", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("日曜日になると振り返ることができます。")
            }
        }
    }
    
    private func createNewThoughtCard() {
        dataManager.createThoughtCard(content: "", date: Date())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func updateIsSunday() {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        isSunday = today == 1 // 日曜日は1
    }
}

#Preview {
    HomeView()
}
