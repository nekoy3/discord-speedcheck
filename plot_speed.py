import os
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import font_manager
from datetime import datetime

csv_dir = './csv'
plot_dir = './plot'

# ディレクトリ内で最も新しいCSVファイルを取得
latest_file = max([os.path.join(csv_dir, f) for f in os.listdir(csv_dir) if f.endswith('.csv')], key=os.path.getctime)

# ファイル名を表示（デバッグ用）
print(f"Latest CSV file: {latest_file}")

# CSVファイルを読み込む
df = pd.read_csv(latest_file)

# 時刻列をdatetime型に変換
df['時刻'] = pd.to_datetime(df['時刻'], format='%H:%M')

# font
font_path = '/usr/share/fonts/truetype/fonts-japanese-gothic.ttf'
font_prop = font_manager.FontProperties(fname=font_path)

# プロットの作成
plt.figure(figsize=(10, 5))

# アップロード速度のプロット
plt.plot(df['時刻'], df['アップロード速度'], label='アップロード速度（Mbit/s）', marker='o')

# ダウンロード速度のプロット
plt.plot(df['時刻'], df['ダウンロード速度'], label='ダウンロード速度（Mbit/s）', marker='o')

# グラフのタイトルとラベル
plt.title('速度の時間推移', fontproperties=font_prop)
plt.xlabel('時刻', fontproperties=font_prop)
plt.ylabel('速度', fontproperties=font_prop)
plt.legend(prop=font_prop)

# x軸のフォーマットを変更
plt.gca().xaxis.set_major_formatter(plt.matplotlib.dates.DateFormatter('%H:%M'))

# グリッドを追加
plt.grid(True)

# 画像ファイルとして保存
output_image_path = os.path.join(plot_dir, 'speed_over_time.png')
plt.savefig(output_image_path)

# グラフを表示（必要に応じて）
# plt.show()

