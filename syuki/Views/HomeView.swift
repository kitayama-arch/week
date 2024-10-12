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
    @State private var isButtonPressed = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var isKeyboardVisible = false
    @State private var scrollProxy: ScrollViewProxy?
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    
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
                Color.background
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.closeKeyboard()
                        print("背景がタップされました")
                    }
                if let currentWeeklyRecord = dataManager.currentWeeklyRecord {
                    VStack {
                        // カスタムナビゲーションバー
                        VStack {
                            ZStack {
                                VStack(spacing: 5) {
                                    Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundStyle(.gray.opacity(0.8))
                                        .overlay(
                                            Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundColor(.BW)
                                                .opacity(0.11)
                                                .offset(x: 0.5, y: 0.5)
                                        )
                                        .overlay(
                                            Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundColor(.BW)
                                                .opacity(0.1)
                                                .offset(x: -0.5, y: -0.5)
                                        )
                                    HStack(spacing: 8) {
                                        ForEach(0..<7) { index in
                                            if index == getCurrentDayIndex() {
                                                Capsule()
                                                    .fill(Color.accentColor)
                                                    .frame(width: 24, height: 6)
                                            } else {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 6, height: 6)
                                            }
                                        }
                                    }
                                }
                                HStack {
                                    HStack(spacing: 10) {
                                        Button {
                                            showSettingView = true
                                        } label: {
                                            Image(systemName: "gearshape")
                                                .font(.title)
                                                .foregroundStyle(.gray.opacity(0.8))
                                        }
                                        Button {
                                            showArchiveView = true
                                        } label: {
                                            Image(systemName: "archivebox")
                                                .font(.title)
                                                .foregroundStyle(.gray.opacity(0.8))
                                        }
                                    }
                                    
                                    Spacer()
                                    Button(action: {
                                        if isSunday {
                                            reflectionWeeklyRecord = currentWeeklyRecord
                                            showReflectionView = true
                                        } else {
                                            showAlert = true
                                        }
                                    }) {
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        isSunday ? Color.accentColor.opacity(0.8) : Color.gray.opacity(0.4),
                                                        isSunday ? Color.accentColor : Color.gray.opacity(0.6)
                                                    ]),
                                                    //                                                    gradient: Gradient(colors: [
                                                    //                                                        Color.grayout.opacity(0.8), Color.grayout.opacity(1)
                                                    //                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .overlay(
                                                Text("振り返り")
                                                    .font(.headline)
                                                    .foregroundColor(.white.opacity(0.9))
                                            )
                                            .frame(width: 100, height: 40)
                                    }
                                    //                                    .shadow(color: .grayout.opacity(0.5), radius: 12, x: 0.0, y: 4)
                                    .shadow(color: isSunday ? .accent.opacity(0.7) : .gray.opacity(0.7), radius: 12, x: 0.0, y: 4)
                                }
                                .padding(.horizontal)
                            }
                            GoalCardView(weeklyRecord: currentWeeklyRecord)
                                .environmentObject(dataManager)
                        }
                        
                        ZStack {
                            ScrollView {
                                ScrollViewReader { proxy in
                                    VStack {
                                        Spacer()
                                        ForEach(Array(currentWeeklyRecord.thoughts.enumerated()), id: \.element.id) { index, thoughtCard in
                                            ThoughtCardView(
                                                thoughtCard: thoughtCard,
                                                dataManager: dataManager,
                                                focusedThoughtCardID: $focusedThoughtCardID
                                            )
                                            .padding(.horizontal)
                                            .padding(.top, 5)
                                            .id(index)
                                        }
                                        Spacer(minLength: 120)
                                    }
                                    .onAppear {
                                        scrollProxy = proxy
                                    }
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
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Capsule()
                                            .fill(.ultraThinMaterial.opacity(0.75))
                                            .frame(width: 60, height: 130)
                                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30)
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [.white.opacity(0.6), .white.opacity(0.2)]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 0.5
                                                    )
                                            )
                                        
                                        VStack(spacing: 10) {
                                            Button(action: {
                                                withAnimation {
                                                    scrollProxy?.scrollTo(currentWeeklyRecord.thoughts.count - 1, anchor: .bottom)
                                                }
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.clear)
                                                        .frame(width: 60, height: 60)
                                                    Image(systemName: "arrowtriangle.down.fill")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.white)
                                                        .scaleEffect(1.0, anchor: .center)
                                                        .scaleEffect(y: 0.8, anchor: .center)
                                                }
                                            }
                                            
                                            Button(action: {
                                                buttonTapped()
                                            }) {
                                                ZStack {
                                                    Image("gradient")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 50, height: 50)
                                                        .clipShape(Circle())
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 30, weight: .medium))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: 60, height: 130)  // ZStackのサイズを明示的に指定
                                    .scaleEffect(buttonScale)
                                    .opacity(isKeyboardVisible ? 0.7 : 1.0)
                                }
                                .padding()
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                                isKeyboardVisible = true
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                                isKeyboardVisible = false
                            }
                        }
                        .onTapGesture {
                            UIApplication.shared.closeKeyboard()
                            print("カード間の空白部分がタップされました")
                        }
                        .ignoresSafeArea(.container, edges: .bottom)
                        if !sceneDelegate.isPremium {
                            Spacer()
                            AdMobBannerView()
                                .frame(width: 320, height: 50)
                        }
                    }
                } else {
                    // currentWeeklyRecord が nil の場合：振り返り未完了の状態を表示
                    VStack {
                        Spacer()
                        Text("前の週の振り返りがまだ完了していません。")
                            .font(.system(.title, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button(action: {
                            if let previousWeeklyRecord = dataManager.getPreviousWeeklyRecord() {
                                reflectionWeeklyRecord = previousWeeklyRecord
                                showReflectionView = true
                            }
                        }) {
                            Text("振り返りを行う")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.95))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.accentColor.opacity(0.8), Color.accentColor]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                )
                        }
                        .shadow(color: .accent.opacity(0.6), radius: 10, x: 0.0, y: 0.0)
                        Spacer()
                        if !sceneDelegate.isPremium {
                            AdMobBannerView()
                                .frame(width: 320, height: 50)
                        }
                    }
                    .padding()
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
                Text("それまでの間日々の出来事や思考を記録してみてください。")
            }
        }
    }
    
    private func buttonTapped() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1)) {
            buttonScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1)) {
                buttonScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            createNewThoughtCard()
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
    private func getCurrentDayIndex() -> Int {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        // 日曜日が0、月曜日が1、...、土曜日が6となるように調整
        return (today + 5) % 7
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    HomeView()
}
