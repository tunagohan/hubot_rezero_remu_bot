# hubot_rezero_remu_bot
Hubotシリーズ。Re:ゼロから始める異世界生活のレムBotです

## API 取得

- https://cse.google.com/cse/all
- https://console.developers.google.com/apis/library/customsearch.googleapis.com

HUBOT_GOOGLE_CSE_ID: カスタム検索エンジン ID
HUBOT_GOOGLE_CSE_KEY: Custom Search API を叩く権限を持つ API Key


## env 設定

```
export HUBOT_SLACK_TOKEN=
```

## 起動方法

```
$ coffee --nodejs --inspect node_modules/.bin/hubot --adapter slack
```
