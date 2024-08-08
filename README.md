# dicord-speedcheck
speedtest.netのコマンドを使って通信速度を測定し測定結果を逐次discordのチャンネルに送信する。  
また、毎日通信速度の蓄積データをグラフ化してdiscordのチャンネルに送信する。  
## 環境
OS: Linux Ubuntu 20.04LTS  
~~https://www.speedtest.net/ja/apps/cli~~ のspeedtestとはフォーマットが異なるようなので、**speedtest-cli**を使う。    
https://qiita.com/CloudRemix/items/ad226ea4aa641427e682  
「インストール方法」に沿ってインストール
speedtestを使う場合は、speed.shのフォーマットを訂正する必要がある。  
一応現在想定しているフォーマットは以下。
```
$ speedtest --secure
Retrieving speedtest.net configuration...
Testing from QTnet (115.124.156.111)...
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by 7 BULL (Tokyo) [878.88 km]: 26.206 ms
Testing download speed................................................................................
Download: 335.57 Mbit/s
Testing upload speed......................................................................................................
Upload: 198.09 Mbit/s
```

python3.10  
ライブラリ ... ipafont-gothic要らないかもしれない
```
pip install pandas matplotlib fonts-ipafont-gothic
```
あと日本語フォントをインストールする
```
sudo apt-get install fonts-noto-cjk
```
speed.shとplot_speed.pyを同じ階層に置き、csvディレクトリとplotディレクトリも作成しておく。

## 使い方
```bash
readonly WEBHOOK_URL="https://discord.com/api/webhooks/xxxxxx/xxxxxx
```
speed.sh３行目のWEBHOOK_URLに通知を飛ばすチャンネルのwebhookを入れる  
あとはcrontabで定期的に実行する。以下が想定された周期
```
@reboot cd ~; ./speed.sh
10,50 * * * * cd ~; ./speed.sh
```
30~40分開けないとspeedtestに失敗する気がしている  
グラフデータ表示するときに @everyoneメンションするので。不要であれば  
```bash
curl -X POST "$WEBHOOK_URL" \
                -F "content=今日のグラフデータ @everyone" \
                -F "file=@$image_path" > /dev/null 2>&1
```
のcontent部分を変更する。記憶違いかもしれないが、contentが何も無いとエラー吐いてた記憶があるので、contentを空白にするのはよくないかも。
## 自分用のため
あまり洗練されたデザインじゃないから、なんか適当に使ってね

### /csv
yyyy-mm-dd.csvで、ファイルが6個以上になれば古いファイルを削除する。

### /plot
その日作成したグラフの画像データが生成される。生成毎上書きされる。

### 403 Forbiddenが出る/計測結果が出ない
```
$ speedtest
Retrieving speedtest.net configuration...
Cannot retrieve speedtest configuration
ERROR: HTTP Error 403: Forbidden
```
具体的な原因は調査していないが、連続でspeedtestを実行するとこうなるのかも？
`speedtest -secure`とすることで、回避できる。