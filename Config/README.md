# Config - Firebase設定ファイル

このディレクトリには、Firebaseから取得した実際の `GoogleService-Info.plist` を配置します。

## ローカル開発の手順

1. **Firebase Consoleからダウンロード**
   - https://console.firebase.google.com/
   - プロジェクト: `syuki-fa3ab`
   - アプリ: `com.gmail.iura.smh.week`
   - 「GoogleService-Info.plist」をダウンロード

2. **ファイルを配置**
   - ダウンロードしたファイルを `Config/GoogleService-Info.plist` として保存
   - このパスは `.gitignore` で除外されているため、Git追跡されません

3. **ビルド時の処理**
   - Xcodeのビルドフェーズで `scripts/copy-google-service-info.sh` が自動実行されます
   - このスクリプトが `Config/GoogleService-Info.plist` をアプリバンドルにコピーします

## 注意事項

⚠️ **実際のplistファイルをコミットしないでください**

- APIキーなどの秘密情報が含まれています
- 必要に応じて `Config/GoogleService-Info.plist.example` を更新し、必要なキーの構造を共有してください

## トラブルシューティング

### ビルドエラー: "Missing Config/GoogleService-Info.plist"

上記の手順1-2を実行して、ファイルを配置してください。
