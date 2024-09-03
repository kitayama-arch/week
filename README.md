- **Syukiアプリ要件定義書**
    
    ### 概要
    
    Syukiは、ユーザーがぼーっと思考を書き連ね、週単位で振り返りと目標設定を行うアプリです。記録をアーカイブし、次週の目標を設定することで、日記が続かない人でも自己成長を促進します。
    
    流れる日々を記録する
    
    少しでも前に進む
    
    自分と比べる
    
    ### ターゲットユーザー
    
    - **日記が続かない人**: 週単位で思考を整理するためのツールとして利用。
    - **自己成長を目指す人**: 自分の中で幸せを作りたい人が、次週の目標を設定し、それを達成するためのモチベーションツールとして利用。
    
    ### 使用シーン
    
    - **週末のリフレクションタイム**: 一週間を振り返り、次週の目標を設定。
    - **日常の合間**: 思考を整理するためのツールとして利用。
    
    ### デザイン哲学
    
    - **構造化**: 思考を箇条書きで構造化。
    - **柔軟性**: ユーザーが自由に思考を記録し、目標を設定。
    - 有機的:小さなアニメーションで生活に則したもの
    
    ### デザインの要素（マーケター目線）
    
    1. **視覚的魅力**
        - **カラーパレット**: 穏やかで落ち着いた色合い（例: パステルカラー、ニュートラルカラー）
        - **タイポグラフィ**: 読みやすさを重視したシンプルでモダンなフォント
        - **アイコンとグラフィック**: ユーザーの行動を促す直感的なアイコンと、気持ちを落ち着かせるグラフィック
    2. **ユーザー体験**
        - **シンプルなナビゲーション**: 主要な機能へのアクセスが容易な直感的なナビゲーション
        - **迅速なアクセス**: 思考記録、振り返り、目標設定にスムーズにアクセスできる
        - **ユーザーガイド**: 初回使用時にアプリの使い方を簡単に説明するガイド
    3. **エンゲージメント**
        - **プッシュ通知**: 振り返りや目標設定のタイミングをリマインドする通知
        - **パーソナライズ**: ユーザーの使用履歴に基づくパーソナライズされたメッセージやアドバイス
        - **ソーシャルシェア**: 達成した目標や振り返りをSNSでシェアする機能
    4. **ブランドイメージ**
        - **ロゴとブランドアイデンティティ**: シンプルで覚えやすいロゴ、統一感のあるブランドイメージ
        - **ブランドメッセージ**: 「自己成長」「幸せの創造」をテーマにしたメッセージをアプリ全体で伝える
    
    ### システム設計
    
    ### アーキテクチャ
    
    - **クライアントサイド**: SwiftUIを用いたiOSアプリ
    - **データ保存**: Core Dataを利用したローカルデータベース
    - **バージョン管理**: GitHubを利用
    
    ### 主要コンポーネント
    
    - **ユーザーインターフェース (UI)**
        - ホーム・思考記録画面
        - 振り返り・目標設定画面
        - アーカイブ画面
        
        ### ホーム・思考記録画面
        
        - **概要**: アプリ起動時に表示される画面。ユーザーが今週の目標と思考をカード形式で記録する。
        - **要素**:
            - **今週の目標カード**:
                - 今週の目標を直接入力・編集できるカード。
            - **思考記録カード**:
                - 思考を直接入力・編集できるカード。
            - **アーカイブへのアクセスボタン**:
                - アーカイブ画面への遷移。
        
        ### UIフロー図
        
        1. **ホーム・思考記録画面**
            - 今週の目標カード
            - 思考記録カード
            - アーカイブへのアクセスボタン（→ アーカイブ画面）
        2. **振り返り・目標設定画面**
            - 今週の思考表示フィールド
            - 振り返り入力フィールド
            - 今週の目標表示フィールド
            - 次週の目標入力フィールド
            - 戻るボタン（→ ホーム画面）
        3. **アーカイブ画面**
            - 週ごとの記録リスト
            - 選択した週の詳細表示
            - 戻るボタン（→ ホーム画面）
        
        ### UI配置例
        
        ### ホーム・思考記録画面
        
        ```
        +--------------------------------------------------+
        | Syuki                                            |
        +--------------------------------------------------+
        | 今週の目標                                       |
        | [今週の目標を入力するカード]                      |
        +--------------------------------------------------+
        | 思考記録                                         |
        | [思考を記録するカード1]                           |
        | [思考を記録するカード2]                           |
        | [思考を記録するカード3]                           |
        | ...                                              |
        +--------------------------------------------------+
        | [アーカイブ]                                      |
        +--------------------------------------------------+
        
        ```
        
        ### 振り返り・目標設定画面
        
        ```
        +--------------------------------------------------+
        | 振り返りと目標設定                                 |
        +--------------------------------------------------+
        | 今週の思考                                        |
        | - 思考1                                           |
        | - 思考2                                           |
        | - 思考3                                           |
        +--------------------------------------------------+
        | 振り返り                                          |
        | [振り返り入力フィールド]                           |
        +--------------------------------------------------+
        | 今週の目標                                        |
        | - 目標1                                           |
        +--------------------------------------------------+
        | 次週の目標                                        |
        | [次週の目標入力フィールド]                         |
        +--------------------------------------------------+
        | [戻る]                                            |
        +--------------------------------------------------+
        
        ```
        
        ### アーカイブ画面
        
        ```
        +--------------------------------------------------+
        | アーカイブ                                        |
        +--------------------------------------------------+
        | 週ごとの記録リスト                                |
        | - 2024/06/01 - 2024/06/07                         |
        | - 2024/06/08 - 2024/06/14                         |
        | - 2024/06/15 - 2024/06/21                         |
        +--------------------------------------------------+
        | 選択した週の詳細表示                              |
        | - 思考1                                           |
        | - 思考2                                           |
        | - 振り返り                                        |
        | - 目標                                            |
        +--------------------------------------------------+
        | [戻る]                                            |
        +--------------------------------------------------+
        
        ```
        
        このUI配置を基に、具体的な画面デザインを進めていきましょう。ユーザーが入力内容を離れる際に自動保存される仕組みを実装することで、保存ボタンをなくすことが可能です。
        
    
    ### データモデル
    
    - **思考カード (ThoughtCard)**
        - `id`: UUID
        - `content`: String
        - `date`: Date
        - `items`: [String]
    - **週の記録 (WeeklyRecord)**
        - `id`: UUID
        - `startDate`: Date
        - `endDate`: Date
        - `thoughts`: [ThoughtCard]
        - `reflection`: String
        - `goal`: String
    
    ### データ管理
    
    - **Core Data**
        - **エンティティ**
            - `ThoughtCardEntity`
                - `id`: UUID
                - `content`: String
                - `date`: Date
                - `items`: [String]
            - `WeeklyRecordEntity`
                - `id`: UUID
                - `startDate`: Date
                - `endDate`: Date
                - `thoughts`: [ThoughtCardEntity]
                - `reflection`: String
                - `goal`: String
    
    ### ロジック層
    
    - **データ操作**
        - データの作成、読み取り、更新、削除 (CRUD)
        - 思考カードと週の記録の関連付け
        - 週単位のデータフィルタリングとソート
    - **ビジネスロジック**
        - ユーザーの入力データのバリデーション
        - 振り返りと目標設定の自動リマインダー
        - ユーザーの思考カードの分析と統計
    
    ### フローチャート
    
    1. **アプリ起動**
        - ホーム・思考記録画面を表示。
        - ローカルデータベースからデータを読み込み。
    2. **思考記録**
        - ユーザーが思考カードを追加。
        - データベースに保存。
    3. **振り返りと目標設定**
        - ユーザーが週の終わりに振り返りと目標を入力。
        - データベースに保存。
    4. **アーカイブ閲覧**
        - ユーザーがアーカイブ画面で過去の週を選択。
        - 選択された週の詳細を表示。
    
    ### 技術要件
    
    - **言語**: Swift
    - **UIフレームワーク**: SwiftUI
    - **データ保存**: Core Data
    - **バージョン管理**: GitHub
    
    ### 開発プロセス
    
    1. **要件定義**
    2. **ワイヤーフレームとUIデザイン**
    3. **データモデル設計**
    4. **UI実装**
    5. **データベース実装**
    6. **ビジネスロジック実装**
    7. **テスト**
    8. **リリース準備**
- アーキテクチャ
    
    ![Appデザイン Eraser Diagram Export.svg](https://prod-files-secure.s3.us-west-2.amazonaws.com/1f8d926f-a2be-496a-bdcc-782e0447c647/91c3fad5-ad72-40b9-8eb9-f87711a33dab/App%E3%83%86%E3%82%99%E3%82%B5%E3%82%99%E3%82%A4%E3%83%B3_Eraser_Diagram_Export.svg)
    
- 計画
    
    # スプリント1: 基本構造とホーム画面
    
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   └── HomeView.swift
    │   └── Models/
    │       └── ThoughtCard.swift
    
    # スプリント2: 思考カード機能の追加
    
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   └── ThoughtCardView.swift
    │   ├── Models/
    │   │   └── ThoughtCard.swift
    │   ├── ViewModels/
    │   │   └── ThoughtCardViewModel.swift
    │   └── Services/
    │       └── DataManager.swift
    
    # スプリント3: Core Data統合と振り返り機能
    
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   ├── ThoughtCardView.swift
    │   │   └── ReflectionView.swift
    │   ├── Models/
    │   │   ├── ThoughtCard.swift
    │   │   └── WeeklyRecord.swift
    │   ├── ViewModels/
    │   │   ├── ThoughtCardViewModel.swift
    │   │   └── WeeklyRecordViewModel.swift
    │   ├── Services/
    │   │   └── DataManager.swift
    │   └── CoreData/
    │       ├── Syuki.xcdatamodeld/
    │       │   └── Syuki.xcdatamodel
    │       └── CoreDataManager.swift
    
    # スプリント4: アーカイブ機能とユーティリティの追加
    
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   |── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   ├── ThoughtCardView.swift
    │   │   ├── ReflectionView.swift
    │   │   └── ArchiveView.swift
    │   ├── Models/
    │   │   ├── ThoughtCard.swift
    │   │   └── WeeklyRecord.swift
    │   ├── ViewModels/
    │   │   ├── ThoughtCardViewModel.swift
    │   │   └── WeeklyRecordViewModel.swift
    │   ├── Services/
    │   │   └── DataManager.swift
    │   ├── Utilities/
    │   │   ├── DateFormatter.swift
    │   │   └── Constants.swift
    │   └── CoreData/
    │       ├── Syuki.xcdatamodeld/
    │       │   └── Syuki.xcdatamodel
    │       └── CoreDataManager.swift
    
    # スプリント5: 設定機能とテストの追加
    
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   ├── ThoughtCardView.swift
    │   │   ├── ReflectionView.swift
    │   │   ├── ArchiveView.swift
    │   │   └── SettingsView.swift
    │   ├── Models/
    │   │   ├── ThoughtCard.swift
    │   │   └── WeeklyRecord.swift
    │   ├── ViewModels/
    │   │   ├── ThoughtCardViewModel.swift
    │   │   └── WeeklyRecordViewModel.swift
    │   ├── Services/
    │   │   └── DataManager.swift
    │   ├── Utilities/
    │   │   ├── DateFormatter.swift
    │   │   └── Constants.swift
    │   └── CoreData/
    │       ├── Syuki.xcdatamodeld/
    │       │   └── Syuki.xcdatamodel
    │       └── CoreDataManager.swift
    ├── SyukiTests/
    └── SyukiUITests/
    
    ## スプリントごとのディレクトリ構成
    
    ### スプリント1: 基本構造とホーム画面
    
    ```
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   └── HomeView.swift
    │   └── Models/
    │       └── ThoughtCard.swift
    
    ```
    
    - `ThoughtCard` モデルは定義されているが、まだデータ保存機能は未実装
    
    ### スプリント2: 思考カード機能の追加
    
    ```
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   └── ThoughtCardView.swift
    │   ├── Models/
    │   │   └── ThoughtCard.swift
    │   ├── ViewModels/
    │   │   └── ThoughtCardViewModel.swift
    │   └── Services/
    │       └── DataManager.swift
    
    ```
    
    - `ThoughtCardView` が追加され、`HomeView` で複数表示
    - `ThoughtCardViewModel` でデータバインディング
    - `DataManager` でCore Dataとの連携によるデータ保存・読み込み・削除
    
    ### スプリント3: 振り返り機能の実装
    
    ```
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   ├── ThoughtCardView.swift
    │   │   └── ReflectionView.swift
    │   │   └── ArchiveView.swift  // 追加
    │   ├── Models/
    │   │   ├── ThoughtCard.swift
    │   │   └── WeeklyRecord.swift // 追加
    │   ├── ViewModels/
    │   │   ├── ThoughtCardViewModel.swift
    │   │   └── WeeklyRecordViewModel.swift // 追加
    │   ├── Services/
    │   │   └── DataManager.swift
    │   └── CoreData/
    │       ├── Syuki.xcdatamodeld/
    │       │   └── Syuki.xcdatamodel
    │       └── CoreDataManager.swift
    
    ```
    
    - `ReflectionView` と `ArchiveView` が追加
    - `WeeklyRecord` モデルと `WeeklyRecordViewModel` が追加
    - `DataManager` が `WeeklyRecord` の操作に対応
    
    ### スプリント4: アーカイブ機能とユーティリティ
    
    ```
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   ├── ThoughtCardView.swift
    │   │   ├── ReflectionView.swift
    │   │   └── ArchiveView.swift
    │   ├── Models/
    │   │   ├── ThoughtCard.swift
    │   │   └── WeeklyRecord.swift
    │   ├── ViewModels/
    │   │   ├── ThoughtCardViewModel.swift
    │   │   └── WeeklyRecordViewModel.swift
    │   ├── Services/
    │   │   └── DataManager.swift
    │   ├── Utilities/     // 追加
    │   │   ├── DateFormatter.swift
    │   │   └── Constants.swift
    │   └── CoreData/
    │       ├── Syuki.xcdatamodeld/
    │       │   └── Syuki.xcdatamodel
    │       └── CoreDataManager.swift
    
    ```
    
    - `Utilities` ディレクトリが追加され、`DateFormatter` と `Constants` が配置
    
    ### スプリント5: 設定機能とテストの追加
    
    ```
    Syuki/
    ├── Syuki/
    │   ├── SyukiApp.swift
    │   ├── Info.plist
    │   ├── Assets.xcassets/
    │   ├── Preview Content/
    │   ├── Views/
    │   │   ├── HomeView.swift
    │   │   ├── ThoughtCardView.swift
    │   │   ├── ReflectionView.swift
    │   │   ├── ArchiveView.swift
    │   │   └── SettingsView.swift // 追加
    │   ├── Models/
    │   │   ├── ThoughtCard.swift
    │   │   └── WeeklyRecord.swift
    │   ├── ViewModels/
    │   │   ├── ThoughtCardViewModel.swift
    │   │   └── WeeklyRecordViewModel.swift
    │   ├── Services/
    │   │   └── DataManager.swift
    │   ├── Utilities/
    │   │   ├── DateFormatter.swift
    │   │   └── Constants.swift
    │   └── CoreData/
    │       ├── Syuki.xcdatamodeld/
    │       │   └── Syuki.xcdatamodel
    │       └── CoreDataManager.swift
    ├── SyukiTests/      // 追加
    └── SyukiUITests/    // 追加
    
    ```
    
    - `SettingsView` が追加
    - テスト用のディレクトリ `SyukiTests` と `SyukiUITests` が追加
    
    ### スプリント6: 最終調整とリリース準備
    
    - スプリント5のディレクトリ構成から変更なし。
    - アプリの最終調整、テスト、リリース準備を行う
    
- Todo
    
    # Syukiアプリ 開発TODOリスト
    
    ## スプリント1: 基本構造��ホーム画面 (1-2週間)
    
    - [x]  プロジェクトの初期設定
        - [x]  Xcodeでプロジェクトを作成
        - [x]  GitHubリポジトリの設定
        - [x]  .gitignoreファイルの作成
    - [x]  基本的なディレクトリ構造の作成
    - [x]  `ThoughtCard`モデルの基本実装
    - [x]  `HomeView`の実装
        - [x]  基本的なUIレイアウト
        - [x]  ナビゲーションの設定
    - [x]  アプリアイコンの作成とAssets.xcassetsへの追加
    - [x]  基本的なカラースキームの設定
    
    ## スプリント2: 思考カード機能の追加 (1-2週間)
    
    ### フェーズ1：思考カードのUIと表示 (2-3日)
    
    - [x]  **`ThoughtCardView` の完成**:
        - [x]  前回のスプリントで作成した `ThoughtCardView` をベースに、必要があれば微調整を加える。
        - [x]  この時点では、`ThoughtCardView` はダミーデータを表示するだけでOK。
    - [x]  **`HomeView` で複数カードを表示**:
        - [x]  `HomeView` に `ThoughtCard` の配列（ダミーデータ）を用意し、`ForEach` を使って複数の `ThoughtCardView` をリスト表示する。
    
    ### フェーズ2：データ入力と動的な表示 (3-4日)
    
    - [x]  **`ThoughtCard` 構造体作成**:
        - [x]  `id` (UUID), `content` (String), `date` (Date) プロパティを持つ `ThoughtCard` 構造体を作成。
    - [x]  **`ThoughtCardView` をデータと連携**:
        - [x]  `ThoughtCardView` が `ThoughtCard` を受け取れるようにプロパティを追加し、`@Binding` で連携する。
        - [x]  `TextEditor` の `text` プロパティと、`ThoughtCard` の `content` をバインディングする。
    - [x]  **`HomeView` で動的にカードを表示**:
        - [x]  `HomeView` の `ThoughtCard` 配列に、初期データ（空の `ThoughtCard` など）を追加する。
        - [x]  ユーザーがテキストを入力すると、`ThoughtCard` の `content` が更新され、動的にUIに反映されるようにする。
    
    ## スプリント2: 思考カード機能の追加 (1-2週間)
    
    ### フェーズ3: データ保存と読み込み (3-4日)
    
    - [x]  **Core Data エンティティ作成**:
        - [x]  `ThoughtCard` エンティティを作成し、`id` (UUID), `content` (String), `date` (Date) 属性を定義。
    - [x]  **`CoreDataManager` の作成**:
        - [x]  `CoreDataManager.swift` ファイルを作成し、`CoreDataManager` クラスを定義する。
        - [x]  `persistentContainer` を用いて、Core Dataスタックを初期化する。
        - [x]  以下のCRUD操作を実装する。
            - [x]  `createThoughtCard(content: String, date: Date) -> ThoughtCard`: 新しい `ThoughtCard` エンティティを作成し、`content` と `date` を設定して保存する。作成した `ThoughtCard` エンティティを返す。
            - [x]  `readThoughtCards() -> [ThoughtCard]` : 保存されている全ての `ThoughtCard` エンティティを取得し、`ThoughtCard` の配列として返す。
            - [x]  `updateThoughtCard(thoughtCard: ThoughtCard, newContent: String)`: 指定された `thoughtCard` の `content` を `newContent` で更新して保存する。
            - [x]  `deleteThoughtCard(thoughtCard: ThoughtCard)`: 指定された `thoughtCard` を削除する。
            - [x]  必要に応じて、エラー処理を追加する。
    - [x]  **`DataManager` の作成**:
        - [x]  `DataManager.swift` ファイルを作成し、`DataManager` クラスを定義する。
        - [x]  `CoreDataManager` のインスタンスをプロパティとして保持する。
            - [x]  `private let coreDataManager = CoreDataManager()` のように宣言
        - [x]  `CoreDataManager` のCRUD操作を呼び出す、以下の関数を定義する。
            - [x]  `createThoughtCard(content: String, date: Date) -> ThoughtCard`
            - [x]  `readThoughtCards() -> [ThoughtCard]`
            - [x]  `updateThoughtCard(thoughtCard: ThoughtCard, newContent: String)`
            - [x]  `deleteThoughtCard(thoughtCard: ThoughtCard)`
            - [x]  必要に応じて、データ加工やバリデーション処理などを追加する。
    - [x]  **データの保存と読み込みを実装**:
        - [x]  `HomeView` に `DataManager` のインスタンスを追加。
            - [x]  `@StateObject private var dataManager = DataManager()` のように宣言
        - [x]  `HomeView` の `onAppear` モディファイア内で、`dataManager.readThoughtCards()` を呼び出して、`ThoughtCard` 配列を初期化する。
        - [x]  `ThoughtCardView` で `TextEditor` の `onCommit` コールバックを利用し、テキスト編集が完了したタイミングで `dataManager.updateThoughtCard()` または `dataManager.createThoughtCard()` を呼び出してデータを保存する。
        - [x]  `ThoughtCardView` に削除ボタンを追加し、タップ時に `dataManager.deleteThoughtCard()` を呼び出す。
    
    **ポイント**
    
    - 各クラスの役割を明確に分離し、依存関係を整理する。
    - `CoreDataManager` はCore Dataの操作に集中し、`DataManager` はアプリのロジックに集中する。
    - データの保存は、ユーザーがテキスト編集を確定したタイミングで行うようにする。
    
    ### フェーズ4: 新規カード作成と削除 (1-2日)
    
    - [x]  **新規カード作成**:
        - [x]  `HomeView` に「新規作成ボタン」を追加し、タップ時に `ThoughtCard` 配列に新しいデータを追加する処理を実装する。
    - [x]  **カードの削除**:
        - [x]  `onDelete()` モディファイアを使って、リストからカードをスワイプで削除する機能を実装する。
        - [x]  `DataManager` を使って、削除に対応する処理を実装する。
    
    ## スプリント3：振り返り機能の実装 (2-3週間)
    
    ### フェーズ1: 振り返り画面のUI構築 (2-3日)

    - [x] **`WeeklyRecord` 構造体の作成**:
    - [x] `Models` フォルダ内に `WeeklyRecord.swift` ファイルを作成
    - [x] `id`, `startDate`, `endDate`, `thoughts`, `reflection`, `goal`, `nextWeekGoal` プロパティを持つ構造体を定義

    - [x] **ダミーデータの作成**:
    - [x] テスト用の `WeeklyRecord` インスタンスを作成

    - [x] **個別のUIコンポーネントの作成**:
    - [x] `Views` フォルダ内に `ReflectionView.swift` ファイルを作成し、その中に `GoalView`, `ThoughtsListView`, `ReflectionInputView` コンポーネントを実装する

    - [x] **`ReflectionView.swift` ファイルの作成と実装**:
    - [x] `Views` フォルダ内に新しいSwiftUIビューファイルを作成
    - [x] `WeeklyRecord` を受け取るプロパティを追加
    - [x] 作成した個別のUIコンポーネントを組み合わせてビューを構築
    - [x] ナビゲーションタイトルの設定
    - [x] 保存ボタンの配置（機能実装は後のフェーズで行う）

    - [x] **`HomeView` からの画面遷移の実装**:
    - [x] `HomeView.swift` を開き、`ReflectionView` へのナビゲーションリンクを追加

    - [x] **プレビュー機能の実装**:
    - [x] 各UIコンポーネントのプレビューを追加
    - [x] `ReflectionView` のプレビューを追加し、ダミーデータでテスト
    
    ### フェーズ2: `WeeklyRecord` との連携 (3-4日)
    - [x]  **`ReflectionView` の更新**:
        - [x] `@State var weeklyRecord: WeeklyRecord` を `@ObservedObject var weeklyRecord: WeeklyRecord` に変更する。

    - [x] **`WeeklyRecord` の更新**:
        - [x] `WeeklyRecord.swift` を開き、構造体をクラスに変更する。
        - [x] `ObservableObject` プロトコルに準拠させる。
        - [x] 変更可能なプロパティに `@Published` 属性を追加する。

    - [x] **UI要素とのバインディング**:
        - [x] `GoalView` を更新し、`weeklyRecord.goal` とバインディングする。
        - [x] `ThoughtsListView` を更新し、`weeklyRecord.thoughts` とバインディングする。
        - [x] `ReflectionInputView` を更新し、`$weeklyRecord.reflection` とバインディングする。

    - [x] **新しいUI要素の追加**:
        - [x] `NextWeekGoalInputView` を作成し、`$weeklyRecord.nextWeekGoal` とバインディングする。

    - [x] **保存ボタンの機能実装**:
        - [x] 保存ボタンのアクションを実装し、`weeklyRecord` の変更を保存する処理を追加する。

    - [x] **プレビューの更新**:
        - [x] `ReflectionView` のプレビューを更新し、`ObservedObject` を使用するように変更する。

    ### フェーズ3: 振り返りデータの保存と読み込み (4-5日)
    
    - [x]  **`WeeklyRecordEntity` 作成**:
        - [x]  Core Dataに `WeeklyRecord` を保存するためのエンティティを作成。
    - [x]  **CoreDataManager の実装**:
        - [x]  Core Dataスタックのセットアップ
        - [x]  ThoughtCardEntity と WeeklyRecordEntity を操作するためのCRUD操作を実装
            - [x]  createThoughtCard(), readThoughtCards(), updateThoughtCard(), deleteThoughtCard()
            - [x]  createWeeklyRecord(), readWeeklyRecords(), updateWeeklyRecord(), deleteWeeklyRecord()
    - [x]  **`DataManager` にCRUD操作を追加**:
        - [x]  `WeeklyRecordEntity` を操作するための関数を `DataManager` に追加。
    - [x]  **`ReflectionView` でデータ保存**:
        - [x]  画面遷移時や保存ボタン押下時に、`DataManager` を使って `WeeklyRecord` データを保存。
    
    ### フェーズ4: アーカイブ機能の実装 (3-4日)

    - [x]  **`ArchiveView` のUI構築**:
        - [x]  `List` ビューを使って、過去の `WeeklyRecord` を週ごとに表示する。
            - [x]  各週の表示には、開始日と終了日を表示する (例: "2024/07/08 - 2024/07/14")
        - [x]  `NavigationLink` を使って、各週の `WeeklyRecord` をタップすると詳細画面に遷移できるようにする

    ### フェーズ5: 詳細表示機能 (3-4日)

    - [x]  **`WeeklyRecordDetailView` のUI構築**:
        - [x]  `WeeklyRecord` の内容を表示する新しい SwiftUI View (`WeeklyRecordDetailView`) を作成する
        - [x]  `WeeklyRecordDetailView` に、以下の情報を表示する
            - [x]  週の目標 (`goal`)
            - [x]  メモの内容 (`thoughts`)
            - [x]  振り返り (`reflection`)
            - [x]  来週の目標 (`nextWeekGoal`) 
    - [x] **`ArchiveView` からの画面遷移**:
        - [x]  `ArchiveView` の `NavigationLink` に、`WeeklyRecordDetailView` を設定し、選択された `WeeklyRecord` を渡す

    ### フェーズ6: データ取得処理の実装 (2-3日)
    - [x]  **`DataManager` に取得ロジックを追加**:
        - [x]  `WeeklyRecord` データを日付順に取得する処理を `DataManager` に追加する (例: `readWeeklyRecords()` )
    - [x]  **`ArchiveView` でデータ表示**:
        - [x]  `DataManager` から取得した `WeeklyRecord` データを、`ArchiveView` の `List` に表示する
    - [x] **`WeeklyRecordDetailView` でデータ表示**:
        - [x]  `WeeklyRecordDetailView` で、渡された `WeeklyRecord` の内容を表示する

     ### フェーズ7: 現在の週の記録のみHomeViewに表示 (2-3日)

    - [ ] **`DataManager` に取得ロジックを追加**:
        - [ ]  現在の週の `WeeklyRecord` データを取得する処理を `DataManager` に追加する (例: `fetchCurrentWeekRecord()` )
    - [ ]  **`HomeView` でデータ表示**:
        - [ ]  `DataManager` から取得した `WeeklyRecord` データを、`HomeView` に表示する。

    ### フェーズ8: データ永続化のテスト (2-3日)
    - 🎯 **目標**: `DataManager` のCRUD操作が正しく動作し、データが永続的に保存・読み込みできることを確認する
    - [ ]  **テストケース作成**:
        - [ ]  `DataManager` の各CRUD操作をテストするケースを作成する。
    - [ ]  **テスト実施**:
        - [ ]  アプリを起動し、思考カードの作成、編集、削除、振り返りの入力、アーカイブの表示などを実行し、データが正しく保存・読み込まれているかを確認する。

    ## スプリント5: 設定画面 (1週間)

    - [ ] **`SettingsView` の実装**:
        - [ ]  `SettingsView` を作成し、以下の設定項目を追加
            - [ ]  **フィードバック**: アプリに関する意見や要望を送信 (例: メール送信機能、Webフォームへの遷移)
            - [ ]  **開発者情報**: 開発者のウェブサイトやSNSへのリンクを表示
            - [ ]  **評価**: App Store の評価ページへ遷移

    - [ ] **`HomeView` の更新**:
        - [ ]  設定画面へのナビゲーションリンクを追加 (例: 歯車アイコンのボタン)

    ## スプリント6: UI見直し (1-2週間)

    - 🎯 **目標**: アプリ全体のUIを見直し、より使いやすく、美しいデザインにする

    - 🔨 **タスク**:
        - [ ]  **デザインの検討**: 
            - [ ]  参考となるアプリやデザインを調査
            - [ ]  アプリ全体のカラースキーム、フォント、レイアウトなどを検討
        - [ ]  **各画面のUI改善**:
            - [ ]  `HomeView`, `ThoughtCardView`, `ReflectionView`, `ArchiveView`, `WeeklyRecordDetailView` などのUIを見直し、改善する
        - [ ]  **アニメーションの追加**: 
            - [ ]  必要に応じて、アニメーションを追加し、UIに動きを与える

    ## スプリント7: 最終調整とリリース準備 (1-2週間)

    - [ ]  バグ修正とパフォーマンス最適化
    - [ ]  ユーザーフィードバックの収集と分析
    - [ ]  アプリストアの説明文とスクリーンショットの準備
    - [ ]  プライバシーポリシーの作成
    - [ ]  アプリのバージョン管理設定
    - [ ]  TestFlightを使用したベータテスト
    - [ ]  App Store Connectでのアプリ提出準備
    - [ ]  アプリのリリース

 

    ## 継続的なタスク

    - [ ]  コードレビューと最適化
    - [ ]  ドキュメンテーションの更新
    - [ ]  ユーザーフィードバックの収集と分析
    - [ ]  次期アップデートの計画立案