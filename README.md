# SalesTracker

ビジネスの売上・SNS・口コミを一元管理するiOSアプリです。


## 概要
個人ビジネスの各種データをiPhone/iPadで手軽に管理・可視化するアプリです。
売上の週別入力から月別グラフ表示、InstagramフォロワーやGoogle Maps口コミ数の
推移管理まで、ビジネスに必要な情報をダッシュボードで一括確認できます。

## 機能
- **ダッシュボード**：売上・フォロワー数・口コミ数の概要を一画面で確認
- **売上管理**：週別売上を入力し、月別合計・グラフで推移を可視化
- **Instagram管理**：フォロワー数・フォロー中の推移をグラフで管理
- **口コミ管理**：Google Mapsの口コミ数推移をグラフで管理

## 使用技術
- Swift / SwiftUI
- SwiftData（ローカルデータ保存）
- Swift Charts（グラフ描画）
- Xcode 26

## 動作環境
- iOS 26以上
- iPhone / iPad対応

## 現在の制約・今後の展望
- Instagram・Google Mapsのデータは現在**手動入力**
  - 今後：Instagram Graph API連携で自動取得を検討
  - 今後：Google Places API連携で口コミ数自動取得を検討
- データはローカル保存のみ

## 開発背景
Swiftの学習を兼ねて、実際に使えるビジネス管理ツールとして開発。
SwiftUIのデータバインディング・SwiftDataによる永続化・Swift Chartsによる
グラフ描画など、iOSアプリ開発の基礎を実践的に学ぶために作成しました。
