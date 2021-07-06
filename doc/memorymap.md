# メモリマップ

|開始アドレス|終了アドレス|説明                      |
|------------|------------|--------------------------|
|0x00000500  |0x00007bff  |ブートローダのスタック領域|
|0x00007c00  |0x00007dff  |MBR                       |
|0x00007e00  |0x00007fff  |ブートローダ用メモリ      |
|0x00008000  |0x000087ff  |メモリマップ              |
|0x00008800  |0x????????  |ブートローダ              |

# ブートローダ用メモリ
|アドレス  |サイズ |説明                            |
|----------|-------|--------------------------------|
|0x00007e00|1バイト|起動ディスクのドライブ番号      |
|0x00007e01|2バイト|起動ディスクのシリンダ数        |
|0x00007e03|1バイト|起動ディスクのトラック毎セクタ数|
|0x00007e04|1バイト|起動ディスクのヘッダ数          |
|0x00007e05|2バイト|メモリマップのエントリ数        |