#!/bin/bash

readonly WEBHOOK_URL="https://discord.com/api/webhooks/xxxxxx/xxxxxx"

timestamp=$(date '+%Y/%m/%d %H:%M')
time=$(echo $timestamp | awk '{print $2}')
time_title="$(date '+%Y-%m-%d').csv"
echo "Checking if file exists: ./csv/$time_title"

# ファイルが存在するかを確認し、存在しない場合はヘッダー行を追加して作成
if [ ! -f "./csv/$time_title" ]; then
	    echo "File does not exist. Creating file and adding header."
	        echo "時刻,アップロード速度,ダウンロード速度" > "./csv/$time_title"
	else
		    echo "File already exists."
fi
file_count=$(ls -1 ./csv/*.csv | wc -l)

if [ $file_count -gt 6 ]; then
          ls -1t *.csv | tail -n +7 | xargs rm
fi
speedtest > tmp.txt
dl=$(cat tmp.txt | sed 's/ /_/g' | grep -E "Download" | sed 's/Download:_//g' | sed 's/_/ /g')
up=$(cat tmp.txt | sed 's/ /_/g' | grep -E "Upload" | sed 's/Upload:_//g' | sed 's/_/ /g')
sv=$(cat tmp.txt | sed 's/ /_/g' | grep -E "Hosted_by" | sed 's/Hosted_by_//g' | sed 's/_/ /g')
echo "$time,$(echo $up | awk '{print $1}'),$(echo $dl | awk '{print $1}')" >> ./csv/$time_title

curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"スピードチェッカー\",\"content\": \"サーバの通信速度を計測しました。（$timestamp）\",\"embeds\": [{
          \"title\": \"スピードテスト結果\",
	  \"color\": 5620992,
          \"fields\": [
	      {
		\"name\": \"サーバ\",
		\"value\": \"$sv\"
	      },
	      {
		\"name\": \"アップロード速度\",
		\"value\": \"$up\"
	      },
	      {
		\"name\": \"ダウンロード速度\",
		\"value\": \"$dl\"
	      }
	  ]
	}
      ]
    }" \
  "$WEBHOOK_URL"
rm tmp.txt

current_hour=$(date '+%H')
current_minute=$(date '+%M')
if [ "$current_hour" -eq 23 ] && [ "$current_minute" -ge 30 ]; then
#if [ "$current_hour" -eq 14 ]; then
        # Pythonスクリプトを実行
        python3 plot_speed.py

        # 画像ファイルのパス
        image_path="./plot/speed_over_time.png"

        # 画像をPOSTリクエストでDiscordに送信
        curl -X POST "$WEBHOOK_URL" \
                -F "content=今日のグラフデータ @everyone" \
                -F "file=@$image_path" > /dev/null 2>&1
fi