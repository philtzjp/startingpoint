---
name: google-analytics
description: Google Analytics の組み込み・同意管理（Consent Mode）・Cookie バナーまわりを実装/変更するときに参照する。`analytics_storage` を常に `granted` にする方針、広告関連シグナル (`ad_storage` / `ad_user_data` / `ad_personalization`) の既定値と「同意しない」選択時の更新ルールを定義する。
---

# Google Analytics
1. MUST: Cookie の使用について確認し、同意を得た際に同意シグナルを送信する
2. `analytics_storage` は MUST: 常に `granted` にする（基本的な分析は常に有効）
3. `ad_storage`、`ad_user_data`、`ad_personalization` は SHOULD: デフォルトで `granted` にする
4. IF: ユーザーが「同意しない」を選択; THEN MUST: 広告関連の値を `denied` に更新する
