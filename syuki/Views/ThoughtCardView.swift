//
//  ThoughtCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ThoughtCardView: View {
    @ObservedObject var thoughtCard: ThoughtCard // 親ビューからバインディングされたThoughtCardデータ
    @ObservedObject var dataManager: DataManager // 共有インスタンスを受け取る(UIのみだから保持する必要がない)
    @State private var showingOptions = false
    @FocusState private var isFocused: Bool
    @State private var cursorPosition: Int = 0
    @Binding var focusedThoughtCardID: UUID?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
            HStack {
                TextEditor(text: $thoughtCard.content)
                    .focused($isFocused)
                    .padding(.leading, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, minHeight: textEditorHeight)
                    .focused($isFocused)
                    .onChange(of: thoughtCard.content) { oldValue, newValue in
                        dataManager.updateThoughtCard(thoughtCard: thoughtCard, newContent: newValue)
                    }
                    .onAppear {
                        isFocused = focusedThoughtCardID == thoughtCard.id
                        focusedThoughtCardID = nil // フォーカス処理が完了したら nil に戻す
                    }
                VStack {
                    Button(action: { showingOptions = true }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(10)
                    }
                    .confirmationDialog("確認", isPresented: $showingOptions) {
                        Button("削除") {
                            dataManager.deleteThoughtCard(thoughtCard: thoughtCard)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    // TextEditorの高さを動的に計算するプロパティ
    private var textEditorHeight: CGFloat {
        let estimatedSize = thoughtCard.content.size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
        return max(50, estimatedSize.height + 20)
    }
}

struct ThoughtCardView_Previews: PreviewProvider {
    @State static var sampleCard = ThoughtCard(id: UUID(), content: "サンプル", date: Date())
    @State static var focusedThoughtCardID: UUID?
    
    static var previews: some View {
        ThoughtCardView(thoughtCard: sampleCard, dataManager: DataManager.shared, focusedThoughtCardID: $focusedThoughtCardID)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
