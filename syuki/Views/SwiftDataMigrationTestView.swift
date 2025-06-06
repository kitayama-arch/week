//
//  SwiftDataMigrationTestView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2025/04/12.
//

import SwiftUI

struct SwiftDataMigrationTestView: View {
    @State private var testResults: String = "テストを実行するには「テスト開始」ボタンをタップしてください。"
    @State private var isRunningTest: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("SwiftData移行テスト")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text("このツールはCoreDataからSwiftDataへの移行をテストします。テスト結果はこの画面に表示されます。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                Button(action: runTest) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("テスト開始")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isRunningTest)
                .padding(.bottom, 16)
                
                Text("テスト結果")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Text(testResults)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private func runTest() {
        isRunningTest = true
        
        // バックグラウンドスレッドでテストを実行
        DispatchQueue.global(qos: .userInitiated).async {
            let tester = SwiftDataMigrationTest()
            let results = tester.runTest()
            
            // メインスレッドで結果を更新
            DispatchQueue.main.async {
                testResults = results
                isRunningTest = false
            }
        }
    }
}

#Preview {
    SwiftDataMigrationTestView()
}
