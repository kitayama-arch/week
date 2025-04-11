//
//  SettingView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/10/01.
//

import SwiftUI
import StoreKit
import CoreData
import UIKit

struct SettingView: View {
    @State private var showTutorial = false
    @State private var showPurchaseView = false
    @State private var showingExportAlert = false
    @State private var exportAlertTitle = ""
    @State private var exportAlertMessage = ""
    @State private var exportedFileURL: URL? = nil
    
    // フィードバックとプライバシーポリシーのURLを定義
    private let feedbackURL: String
    private let privacyPolicyURL: String
    @Environment(\.requestReview) var requestReview
    
    init() {
        // 言語に応じてURLを設定
        if Locale.current.language.languageCode?.identifier == "ja" {
            
            self.feedbackURL = "https://forms.gle/P37hSuQbonvAzck99"
            self.privacyPolicyURL = "https://drive.google.com/file/d/1J3rL7Rr3k_HTctSGwDrCEgn8i-EH_RzY/view?usp=sharing"
        } else {
            self.feedbackURL = "https://forms.gle/zXyNryof6r4DzmmLA"
            self.privacyPolicyURL = "https://drive.google.com/file/d/1mVGyMKKtu-DF2D9O2AsIMT8YcfHlvW7W/view?usp=sharing"
        }
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        premiumSection
                        
                        settingSection(title: "ご意見・ご要望") {
                            settingLink(icon: "square.and.pencil", text: "フィードバックを送信", url: feedbackURL)
                        }
                        
                        #if DEBUG
                        // 開発者ツールセクションを追加
                        settingSection(title: "開発者ツール") {
                            Button(action: {
                                // データパスを表示（リリースビルド用）
                                let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                                let dbPath = appSupportDir?.appendingPathComponent("Model.sqlite").path
                                print("CoreDataストアのパス: \(dbPath ?? "不明")")
                                
                                // アラートに表示
                                self.exportAlertTitle = "データパス"
                                self.exportAlertMessage = "CoreDataストアのパス: \(dbPath ?? "不明")\n\nこのパスをコピーして、開発用ビルドでデータをエクスポートする際に使用してください。"
                                self.showingExportAlert = true
                                
                                // クリップボードにコピー
                                UIPasteboard.general.string = dbPath
                            }) {
                                settingRow(icon: "square.and.arrow.up", text: "データパスを表示")
                            }
                            
                            Button(action: {
                                exportData()
                            }) {
                                settingRow(icon: "square.and.arrow.up", text: "データをエクスポート")
                            }
                        }
                        #endif
                        
                        settingSection(title: "アプリについて") {
                            Button(action: {
                                requestReview()
                            }) {
                                settingRow(icon: "star", text: "アプリを評価する")
                            }
                            
                            settingLink(icon: "lock.shield", text: "プライバシーポリシー", url: privacyPolicyURL)
                            
                            Button(action: {
                                showTutorial = true
                            }) {
                                settingRow(icon: "info.circle", text: "チュートリアルを表示")
                            }
                            
                            HStack {
                                Text("バージョン")
                                Spacer()
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "不明")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("設定")
        .foregroundColor(.primary)
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $showPurchaseView) {
            PurchaseView()
        }
        .alert(exportAlertTitle, isPresented: $showingExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportAlertMessage)
        }
    }
    
    private func exportData() {
        // ユーザーにデータストアの選択を促す
        let alert = UIAlertController(
            title: "データエクスポート",
            message: "どのデータをエクスポートしますか？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "現在のデータ", style: .default) { _ in
            self.exportFromCurrentStore()
        })
        
        alert.addAction(UIAlertAction(title: "リリースビルドのデータ", style: .default) { _ in
            self.showReleaseDataPathInput()
        })
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        
        // アラートを表示
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    /// リリースビルドのデータパスを入力するためのアラートを表示
    private func showReleaseDataPathInput() {
        let alert = UIAlertController(
            title: "リリースビルドのデータパス",
            message: "リリースビルドのデータパスを入力してください。\n例: /var/mobile/Containers/Data/Application/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/Library/Application Support/Model.sqlite",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "データパス"
            textField.text = UserDefaults.standard.string(forKey: "LastReleaseDataPath")
        }
        
        alert.addAction(UIAlertAction(title: "エクスポート", style: .default) { _ in
            if let path = alert.textFields?.first?.text, !path.isEmpty {
                // パスを保存
                UserDefaults.standard.set(path, forKey: "LastReleaseDataPath")
                
                // パスからURLを作成
                let storeURL = URL(fileURLWithPath: path)
                
                // データをエクスポート
                self.exportFromStoreURL(storeURL)
            } else {
                // パスが空の場合
                self.exportAlertTitle = "エクスポート失敗"
                self.exportAlertMessage = "有効なデータパスを入力してください。"
                self.showingExportAlert = true
            }
        })
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        
        // アラートを表示
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    /// リリースビルドのデータパスを探す
    private func findReleaseStoreURL() -> URL? {
        let fileManager = FileManager.default
        
        // 現在のバンドルID
        let currentBundleID = Bundle.main.bundleIdentifier ?? ""
        print("現在のバンドルID: \(currentBundleID)")
        
        // リリースビルドのバンドルID（.debugを取り除く）
        let releaseBundleID = currentBundleID.replacingOccurrences(of: ".debug", with: "")
        print("リリースビルドのバンドルID: \(releaseBundleID)")
        
        // 現在のアプリコンテナのUUID
        let currentAppContainerUUID = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path.components(separatedBy: "/").dropLast().last ?? ""
        print("現在のアプリコンテナUUID: \(currentAppContainerUUID)")
        
        // アプリのコンテナディレクトリを探す
        let containerURLs = fileManager.urls(for: .applicationDirectory, in: .userDomainMask)
        print("コンテナディレクトリ: \(containerURLs)")
        
        // アプリサポートディレクトリを取得
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        print("アプリサポートディレクトリ: \(appSupportDir)")
        
        // ライブラリディレクトリを取得
        guard let libraryDir = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return nil
        }
        print("ライブラリディレクトリ: \(libraryDir)")
        
        // ドキュメントディレクトリを取得
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        print("ドキュメントディレクトリ: \(documentsDir)")
        
        // 現在のアプリコンテナのパス
        let currentAppContainerPath = documentsDir.deletingLastPathComponent().path
        print("現在のアプリコンテナパス: \(currentAppContainerPath)")
        
        // 親ディレクトリ（すべてのアプリコンテナを含む）
        let parentDir = documentsDir.deletingLastPathComponent().deletingLastPathComponent()
        print("親ディレクトリ: \(parentDir.path)")
        
        // すべてのアプリコンテナを探索
        do {
            let allContainers = try fileManager.contentsOfDirectory(at: parentDir, includingPropertiesForKeys: nil, options: [])
            print("見つかったコンテナ数: \(allContainers.count)")
            
            // 現在のコンテナ以外のコンテナを探す
            for containerURL in allContainers {
                // 現在のコンテナはスキップ
                if containerURL.path == currentAppContainerPath {
                    print("現在のコンテナをスキップ: \(containerURL.path)")
                    continue
                }
                
                print("コンテナを確認中: \(containerURL.path)")
                
                // このコンテナ内のApplication Supportディレクトリを確認
                let potentialStoreURL = containerURL.appendingPathComponent("Library/Application Support/Model.sqlite")
                print("確認中: \(potentialStoreURL.path)")
                
                if fileManager.fileExists(atPath: potentialStoreURL.path) {
                    // このコンテナのInfo.plistを確認してバンドルIDを確認
                    let infoPlistURL = containerURL.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
                    
                    if fileManager.fileExists(atPath: infoPlistURL.path),
                       let infoPlistData = try? Data(contentsOf: infoPlistURL),
                       let infoPlist = try? PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any],
                       let mcmMetadata = infoPlist["MCMMetadataIdentifier"] as? String {
                        
                        print("コンテナのバンドルID: \(mcmMetadata)")
                        
                        // リリースビルドのバンドルIDと一致するか確認
                        if mcmMetadata == releaseBundleID {
                            print("リリースビルドのCoreDataストアを発見: \(potentialStoreURL.path)")
                            return potentialStoreURL
                        }
                    }
                    
                    // バンドルIDが確認できない場合は、一旦保存しておく
                    print("潜在的なCoreDataストアを発見: \(potentialStoreURL.path)")
                    return potentialStoreURL
                }
            }
        } catch {
            print("ディレクトリ探索中にエラー: \(error)")
        }
        
        // 標準的なパスも確認
        let possiblePaths = [
            // 標準的なパス
            appSupportDir.appendingPathComponent("Model.sqlite"),
            
            // リリースビルドのパス
            appSupportDir.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Library/Application Support/Model.sqlite"),
            
            // 親ディレクトリを探索
            appSupportDir.deletingLastPathComponent().appendingPathComponent("Application Support/Model.sqlite"),
            libraryDir.appendingPathComponent("Application Support/Model.sqlite"),
            
            // グループコンテナを探索
            appSupportDir.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Group Containers").appendingPathComponent(releaseBundleID).appendingPathComponent("Library/Application Support/Model.sqlite"),
            
            // ドキュメントディレクトリの親から探索
            documentsDir.deletingLastPathComponent().appendingPathComponent("Library/Application Support/Model.sqlite")
        ]
        
        for path in possiblePaths {
            print("パスを確認中: \(path.path)")
            if fileManager.fileExists(atPath: path.path) {
                // 現在のパスと同じでないことを確認
                if path.path != appSupportDir.appendingPathComponent("Model.sqlite").path {
                    print("リリースビルドのCoreDataストアを発見: \(path.path)")
                    return path
                } else {
                    print("現在のビルドのCoreDataストアなのでスキップ: \(path.path)")
                }
            }
        }
        
        return nil
    }
    
    /// 現在のビルドのCoreDataストアからエクスポート
    private func exportFromCurrentStore() {
        do {
            // CoreDataの共有コンテナを使用
            let container = CoreDataManager.sharedPersistentContainer
            let context = container.viewContext
            
            // ThoughtCardEntityをフェッチ
            let thoughtCardFetchRequest: NSFetchRequest<ThoughtCardEntity> = ThoughtCardEntity.fetchRequest()
            let thoughtCards = try context.fetch(thoughtCardFetchRequest)
            
            // WeeklyRecordEntityをフェッチ
            let weeklyRecordFetchRequest: NSFetchRequest<WeeklyRecordEntity> = WeeklyRecordEntity.fetchRequest()
            let weeklyRecords = try context.fetch(weeklyRecordFetchRequest)
            
            createExportFile(thoughtCards: thoughtCards, weeklyRecords: weeklyRecords)
        } catch {
            // エラー時の処理
            exportAlertTitle = "エクスポート失敗"
            exportAlertMessage = "データのエクスポート中にエラーが発生しました: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }
    
    /// 指定されたストアURLからデータをエクスポート
    private func exportFromStoreURL(_ storeURL: URL) {
        // パスの存在確認
        if !FileManager.default.fileExists(atPath: storeURL.path) {
            print("指定されたパスにファイルが存在しません: \(storeURL.path)")
            
            // 可能性のあるパスを探索して表示
            let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            print("現在のアプリサポートディレクトリ: \(appSupportDir?.path ?? "不明")")
            
            // 親ディレクトリを探索
            if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let parentDir = documentsDir.deletingLastPathComponent().deletingLastPathComponent()
                print("親ディレクトリ: \(parentDir.path)")
                
                // 可能であれば親ディレクトリの内容を表示
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: parentDir, includingPropertiesForKeys: nil, options: [])
                    print("見つかったディレクトリ数: \(contents.count)")
                    for url in contents {
                        print("ディレクトリ: \(url.path)")
                    }
                } catch {
                    print("親ディレクトリの探索中にエラー: \(error)")
                }
            }
            
            // エラーアラートを表示
            exportAlertTitle = "エクスポート失敗"
            exportAlertMessage = "指定されたパスにファイルが存在しません。\n\nパス: \(storeURL.path)\n\n正しいパスを入力してください。"
            showingExportAlert = true
            return
        }
        
        do {
            // CoreDataモデルを読み込む
            guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
                print("CoreDataモデルが見つかりません")
                exportAlertTitle = "エクスポート失敗"
                exportAlertMessage = "CoreDataモデルが見つかりませんでした"
                showingExportAlert = true
                return
            }
            
            guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
                print("CoreDataモデルを読み込めませんでした")
                exportAlertTitle = "エクスポート失敗"
                exportAlertMessage = "CoreDataモデルを読み込めませんでした"
                showingExportAlert = true
                return
            }
            
            // 永続ストアコーディネーターを作成
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            // 既存のストアを開く（読み取り専用で）
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSReadOnlyPersistentStoreOption: true])
            
            // マネージドオブジェクトコンテキストを作成
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            
            // ThoughtCardEntityをフェッチ
            let thoughtCardFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ThoughtCardEntity")
            let thoughtCards = try context.fetch(thoughtCardFetchRequest)
            print("取得したThoughtCardの数: \(thoughtCards.count)")
            
            // WeeklyRecordEntityをフェッチ
            let weeklyRecordFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeeklyRecordEntity")
            let weeklyRecords = try context.fetch(weeklyRecordFetchRequest)
            print("取得したWeeklyRecordの数: \(weeklyRecords.count)")
            
            createExportFile(thoughtCards: thoughtCards, weeklyRecords: weeklyRecords)
        } catch {
            print("リリースビルドのデータ読み込み中にエラーが発生しました: \(error)")
            exportAlertTitle = "エクスポート失敗"
            exportAlertMessage = "リリースビルドのデータ読み込み中にエラーが発生しました: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }
    
    /// エクスポートファイルを作成
    private func createExportFile(thoughtCards: [NSManagedObject], weeklyRecords: [NSManagedObject]) {
        do {
            // エクスポートデータの作成
            var exportData: [String: Any] = [:]
            
            // ThoughtCardのエクスポート
            var thoughtCardExportArray: [[String: Any]] = []
            for card in thoughtCards {
                var cardDict: [String: Any] = [:]
                
                if let id = card.value(forKey: "id") as? UUID {
                    cardDict["id"] = id.uuidString
                }
                
                if let content = card.value(forKey: "content") as? String {
                    cardDict["content"] = content
                }
                
                if let date = card.value(forKey: "date") as? Date {
                    cardDict["date"] = date.timeIntervalSince1970
                }
                
                if let weeklyRecord = card.value(forKey: "weeklyRecord") as? NSManagedObject, 
                   let weeklyRecordId = weeklyRecord.value(forKey: "id") as? UUID {
                    cardDict["weeklyRecordId"] = weeklyRecordId.uuidString
                }
                
                thoughtCardExportArray.append(cardDict)
            }
            
            // WeeklyRecordのエクスポート
            var weeklyRecordExportArray: [[String: Any]] = []
            for record in weeklyRecords {
                var recordDict: [String: Any] = [:]
                
                if let id = record.value(forKey: "id") as? UUID {
                    recordDict["id"] = id.uuidString
                }
                
                if let startDate = record.value(forKey: "startDate") as? Date {
                    recordDict["startDate"] = startDate.timeIntervalSince1970
                }
                
                if let endDate = record.value(forKey: "endDate") as? Date {
                    recordDict["endDate"] = endDate.timeIntervalSince1970
                }
                
                if let goal = record.value(forKey: "goal") as? String {
                    recordDict["goal"] = goal
                }
                
                if let reflection = record.value(forKey: "reflection") as? String {
                    recordDict["reflection"] = reflection
                }
                
                if let nextWeekGoal = record.value(forKey: "nextWeekGoal") as? String {
                    recordDict["nextWeekGoal"] = nextWeekGoal
                }
                
                if let emoji = record.value(forKey: "emoji") as? String {
                    recordDict["emoji"] = emoji
                }
                
                if let nextWeekEmoji = record.value(forKey: "nextWeekEmoji") as? String {
                    recordDict["nextWeekEmoji"] = nextWeekEmoji
                }
                
                if let isReflectionCompleted = record.value(forKey: "isReflectionCompleted") as? Bool {
                    recordDict["isReflectionCompleted"] = isReflectionCompleted
                }
                
                weeklyRecordExportArray.append(recordDict)
            }
            
            // 全データをまとめる
            exportData["thoughtCards"] = thoughtCardExportArray
            exportData["weeklyRecords"] = weeklyRecordExportArray
            exportData["exportDate"] = Date().timeIntervalSince1970
            exportData["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            
            // JSONに変換
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            
            // ファイルに保存
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = dateFormatter.string(from: Date())
            let fileURL = documentsDir.appendingPathComponent("syuki_export_\(dateString).json")
            
            try jsonData.write(to: fileURL)
            
            // 成功時の処理
            exportedFileURL = fileURL
            exportAlertTitle = "エクスポート成功"
            exportAlertMessage = "データが正常にエクスポートされました。\nファイル: \(fileURL.lastPathComponent)\n\nファイルはドキュメントディレクトリに保存されました。"
            
        } catch {
            // エラー時の処理
            exportAlertTitle = "エクスポート失敗"
            exportAlertMessage = "データのエクスポート中にエラーが発生しました: \(error.localizedDescription)"
        }
        
        showingExportAlert = true
    }
    
    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("プレミアム機能")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack {
                Button(action: {
                    showPurchaseView = true
                }) {
                    HStack {
                        Image(systemName: "star.circle")
                            .frame(width: 30)
                        Text("プレミアムにアップグレード")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                    }
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(8)
            .shadow(color: .accent.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
        }
    }
    
    private func settingSection<Content: View>(title: LocalizedStringResource, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack {
                content()
            }
            .padding()
            .background(Color.card)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func settingLink(icon: String, text: LocalizedStringResource, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            settingRow(icon: icon, text: text)
        }
    }
    
    private func settingRow(icon: String, text: LocalizedStringResource) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.primary)
            Text(text)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.footnote)
        }
        .padding(.vertical, 8)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
