<!--
これは演習用のサンプルであり、実際に読み込まれる指示ではない。
そのため CLAUDE.md という名前を避けてある。この名前で置くと、
Claude Code がサブディレクトリの指示として読み込んでしまう。
-->

# my-app

このプロジェクトは Web アプリケーションです。とても大切なプロジェクトなので、
コードは読みやすく、保守しやすく書いてください。品質を最優先にしてください。

## ディレクトリ構成

```
src/
├── components/     コンポーネント
├── pages/          ページ
├── hooks/          カスタムフック
├── utils/          ユーティリティ
├── api/            API クライアント
├── types/          型定義
└── styles/         スタイル
tests/              テスト
public/             静的ファイル
```

## 使用している技術

- React 18
- TypeScript 5
- Vite
- Vitest
- Tailwind CSS
- React Router
- Zustand
- axios
- date-fns
- zod

## コーディング規約

- 変数名はわかりやすくつけること
- 関数は短く保つこと
- コメントを適切に書くこと
- DRY 原則を守ること
- SOLID 原則を意識すること
- マジックナンバーを使わないこと
- インデントは半角スペース2つ
- セミコロンは必ず付ける
- import は ES modules を使う（require ではなく）
- 型は any を使わず、必ず具体的に書く
- コンポーネントは関数コンポーネントで書く
- state は Zustand で管理する
- 日付の操作は date-fns を使う
- バリデーションは zod を使う

## テストについて

テストはとても重要です。必ずテストを書いてください。
テストは Vitest を使って書きます。テストファイルは対象ファイルと同じ場所に
`.test.ts` という名前で置きます。テストを書いたら実行して、通ることを確認してください。
カバレッジも意識してください。IMPORTANT: テストは必ず書いてください。

## リリース手順

1. main ブランチが最新であることを確認する
2. `npm version patch` でバージョンを上げる
3. CHANGELOG.md を更新する。前回のタグからのコミットを見て、
   ユーザーに影響のある変更を Added / Changed / Fixed に分類して書く
4. `npm run build` でビルドする
5. ビルド結果を dist/ で確認する
6. `git push --follow-tags` でタグごとプッシュする
7. GitHub の Releases で、CHANGELOG の該当部分を貼ってリリースを作る
8. Slack の #release チャンネルに通知する

## API について

API のベース URL は環境変数 `VITE_API_BASE` で設定します。
ローカル開発ではデフォルトで `http://localhost:3000` を見ます。
エンドポイントの一覧は API ドキュメントを参照してください。
認証は Bearer トークンで、`Authorization` ヘッダに入れます。
トークンは localStorage の `auth_token` キーに保存されています。
リフレッシュトークンの扱いは複雑なので、`src/api/auth.ts` を読んでください。

## その他

- IMPORTANT: コミット前に必ず `npm run lint` を実行してください
- IMPORTANT: main には直接コミットしないでください
- IMPORTANT: 生成されたファイルは編集しないでください
- パフォーマンスに気をつけてください
- アクセシビリティにも配慮してください
- セキュリティを意識してください
