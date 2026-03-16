//
//  ReflectionView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/08/11.
//

import SwiftUI
import UIKit

struct ReflectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State var weeklyRecord: WeeklyRecord
    @State private var selectedTab: ReflectionSheetTab = .reflection
    @State private var activeInput: ReflectionActiveInput?
    @State private var reflectionEditorHeight: CGFloat = 84
    @State private var isSavingReflection = false
    @GestureState private var sheetDragTranslation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let naturalContentHeight = selectedTab == .reflection ? reflectionEditorHeight + 20 : 80
            let naturalSheetHeight = naturalContentHeight + 82
            let maxSheetHeight = max(176, geometry.size.height * 0.5)
            let collapsedSheetHeight = min(naturalSheetHeight, maxSheetHeight)
            let liftHeight = min(max(0, -sheetDragTranslation), max(0, maxSheetHeight - collapsedSheetHeight))
            let currentHeight = collapsedSheetHeight + liftHeight
            
            ZStack(alignment: .bottom) {
                Color.background
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissKeyboard()
                    }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        GoalView(goal: weeklyRecord.goal, emoji: weeklyRecord.emoji)
                        HStack {
                            Text("記録")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(weeklyRecord.thoughts.count)")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.accentColor.opacity(0.8), Color.accentColor]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Capsule())
                        }
                        ThoughtsListView(thoughts: weeklyRecord.thoughts)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, currentHeight + 40)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
                
                ReflectionBottomSheet(
                    selectedTab: $selectedTab,
                    activeInput: $activeInput,
                    weeklyRecord: weeklyRecord,
                    reflectionEditorHeight: $reflectionEditorHeight,
                    onSave: saveReflection
                )
                .frame(maxWidth: .infinity)
                .frame(height: currentHeight, alignment: .top)
                .background {
                    TopRoundedSheetShape(cornerRadius: 28)
                        .fill(Color.white)
                }
                .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: -4)
                .contentShape(Rectangle())
                .simultaneousGesture(sheetInteractionGesture)
                .animation(.spring(response: 0.28, dampingFraction: 0.86), value: currentHeight)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationTitle("振り返り")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: selectedTab) { _, newValue in
            guard activeInput != nil else { return }
            DispatchQueue.main.async {
                activeInput = newValue == .reflection ? .reflection : .nextGoal
            }
        }
    }
    
    private func saveReflection() {
        guard !isSavingReflection else { return }
        isSavingReflection = true
        weeklyRecord.isReflectionCompleted = true
        dataManager.updateWeeklyRecord(weeklyRecord: weeklyRecord)
        dataManager.loadWeeklyRecords()
        dataManager.loadCurrentWeekRecord()
        Task { @MainActor in
            await playReflectionCompletionHaptic()
            dismiss()
        }
    }
    
    private func dismissKeyboard() {
        guard activeInput != nil else { return }
        activeInput = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private var sheetInteractionGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($sheetDragTranslation) { value, state, _ in
                guard abs(value.translation.height) > abs(value.translation.width) else { return }
                state = value.translation.height
            }
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                
                if abs(horizontal) > abs(vertical), abs(horizontal) > 36 {
                    handleSheetTabSwipe(horizontal)
                    return
                }
                
                if vertical < -28 {
                    activeInput = selectedTab == .reflection ? .reflection : .nextGoal
                } else if vertical > 34, activeInput != nil {
                    dismissKeyboard()
                }
            }
    }
    
    private func handleSheetTabSwipe(_ horizontalTranslation: CGFloat) {
        let targetTab: ReflectionSheetTab?
        
        if horizontalTranslation < 0 {
            targetTab = selectedTab == .reflection ? .nextGoal : nil
        } else {
            targetTab = selectedTab == .nextGoal ? .reflection : nil
        }
        
        guard let targetTab else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        selectedTab = targetTab
        generator.selectionChanged()
    }
    
    @MainActor
    private func playReflectionCompletionHaptic() async {
        let soft = UIImpactFeedbackGenerator(style: .soft)
        let rigid = UIImpactFeedbackGenerator(style: .rigid)
        let final = UIImpactFeedbackGenerator(style: .medium)
        
        soft.prepare()
        rigid.prepare()
        final.prepare()
        
        soft.impactOccurred(intensity: 0.55)
        try? await Task.sleep(nanoseconds: 55_000_000)
        soft.impactOccurred(intensity: 0.72)
        try? await Task.sleep(nanoseconds: 60_000_000)
        rigid.impactOccurred(intensity: 0.9)
        try? await Task.sleep(nanoseconds: 95_000_000)
        final.impactOccurred(intensity: 1.0)
        try? await Task.sleep(nanoseconds: 40_000_000)
    }
}

private enum ReflectionSheetTab: String, CaseIterable, Identifiable {
    case reflection
    case nextGoal
    
    var id: String { rawValue }
    
    var title: LocalizedStringKey {
        switch self {
        case .reflection:
            "振り返り"
        case .nextGoal:
            "来週の目標"
        }
    }
}

private enum ReflectionActiveInput {
    case reflection
    case nextGoal
}

private struct TopRoundedSheetShape: Shape {
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            ).cgPath
        )
    }
}

private struct ReflectionBottomSheet: View {
    @Binding var selectedTab: ReflectionSheetTab
    @Binding var activeInput: ReflectionActiveInput?
    @ObservedObject var weeklyRecord: WeeklyRecord
    @Binding var reflectionEditorHeight: CGFloat
    let onSave: () -> Void
    
    private var reflectionCompleted: Bool {
        !weeklyRecord.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var nextGoalCompleted: Bool {
        !weeklyRecord.nextWeekGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ReflectionSheetHeader(
                selectedTab: $selectedTab,
                reflectionCompleted: reflectionCompleted,
                nextGoalCompleted: nextGoalCompleted,
                onSave: onSave
            )
            .padding(.top, 14)
            .padding(.bottom, 4)
            
            ScrollView {
                Group {
                    if selectedTab == .reflection {
                        ReflectionEditorView(
                            reflection: $weeklyRecord.reflection,
                            isFirstResponder: activeInputBinding(for: .reflection),
                            measuredHeight: $reflectionEditorHeight
                        )
                    } else {
                        NextGoalCardView(
                            nextWeekGoal: $weeklyRecord.nextWeekGoal,
                            nextWeekEmoji: $weeklyRecord.nextWeekEmoji,
                            isFirstResponder: activeInputBinding(for: .nextGoal),
                            pickerArrowDirection: .down,
                            pickerCustomHeight: 260
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .overlay(alignment: .top) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 5)
                .padding(.top, 10)
        }
    }
    
    private func activeInputBinding(for input: ReflectionActiveInput) -> Binding<Bool> {
        Binding(
            get: { activeInput == input },
            set: { isFocused in
                activeInput = isFocused ? input : nil
            }
        )
    }
}

private struct ReflectionSheetHeader: View {
    @Binding var selectedTab: ReflectionSheetTab
    let reflectionCompleted: Bool
    let nextGoalCompleted: Bool
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            Picker("振り返り入力", selection: $selectedTab.animation(.spring(response: 0.24, dampingFraction: 0.9))) {
                Text("振り返り")
                    .foregroundColor(foregroundColor(for: .reflection, completed: reflectionCompleted))
                    .tag(ReflectionSheetTab.reflection)
                
                Text("来週の目標")
                    .foregroundColor(foregroundColor(for: .nextGoal, completed: nextGoalCompleted))
                    .tag(ReflectionSheetTab.nextGoal)
            }
            .pickerStyle(.segmented)
            .frame(width: 220)
            .padding(.vertical, 6)
            
            HStack {
                Spacer()
                Button(action: onSave) {
                    Text("保存")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private func foregroundColor(for tab: ReflectionSheetTab, completed: Bool) -> Color {
        if selectedTab == tab || completed {
            return .accentColor
        }
        return .secondary
    }
}

struct GoalView: View {
    let goal: String
    let emoji: String
    
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
                ZStack {
                    Text("\(emoji)")
                        .font(.largeTitle)
                        .blur(radius: 10).opacity(0.5)
                    Text("\(emoji)")
                        .font(.largeTitle)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1.5, height: 40)
                    .cornerRadius(1)
                
                Text("\(goal)")
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct ThoughtsListView: View {
    let thoughts: [ThoughtCard]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(thoughts, id: \.id) { thought in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        )
                    HStack {
                        Text(thought.content)
                            .padding()
                            .background(Color.card)
                            .font(.subheadline)
                            .cornerRadius(8)
                        Spacer()
                    }
                }
            }
        }
    }
}

private struct ReflectionEditorView: View {
    @Binding var reflection: String
    @Binding var isFirstResponder: Bool
    @Binding var measuredHeight: CGFloat
    
    private let placeholder = String(localized: "どんな一週間でしたか？")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                    )
                
                if reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
                
                GrowingTextView(
                    text: $reflection,
                    placeholder: placeholder,
                    isFirstResponder: $isFirstResponder,
                    measuredHeight: $measuredHeight
                )
                .frame(height: measuredHeight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
            .clipped()
        }
    }
}

private struct GrowingTextView: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    @Binding var isFirstResponder: Bool
    @Binding var measuredHeight: CGFloat
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.accessibilityLabel = placeholder
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.accessibilityLabel = placeholder
        if isFirstResponder, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder, uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
        Self.recalculateHeight(view: uiView, result: $measuredHeight)
    }
    
    static func dismantleUIView(_ uiView: UITextView, coordinator: Coordinator) {
        uiView.delegate = nil
    }
    
    static func recalculateHeight(view: UITextView, result: Binding<CGFloat>) {
        let fittingSize = CGSize(width: view.bounds.width, height: .greatestFiniteMagnitude)
        let nextSize = max(view.sizeThatFits(fittingSize).height, 64)
        if result.wrappedValue != nextSize {
            DispatchQueue.main.async {
                result.wrappedValue = nextSize
            }
        }
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextView
        
        init(_ parent: GrowingTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            GrowingTextView.recalculateHeight(view: textView, result: parent.$measuredHeight)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFirstResponder = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFirstResponder = false
        }
    }
}

#Preview {
    let sampleDataManager = DataManager.shared
    let sampleWeeklyRecord = WeeklyRecord(
        id: UUID(),
        startDate: Date(),
        endDate: Date().addingTimeInterval(7*24*60*60),
        thoughts: [
            ThoughtCard(content: "アイデア1", date: Date()),
            ThoughtCard(content: "アイデア2", date: Date())
        ],
        reflection: "",
        goal: "アプリを完成させる",
        nextWeekGoal: "",
        emoji: "😀",
        nextWeekEmoji: "💡"
    )
    sampleDataManager.currentWeeklyRecord = sampleWeeklyRecord
    return ReflectionView(weeklyRecord: sampleWeeklyRecord)
        .environmentObject(sampleDataManager)
}
