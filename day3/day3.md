
## 3日目 32ビットモード突入とC言語導入

- [x] さあ本当のIPLを作ろう(harib00a)

IPL=初期プログラムローダ

entryプログラムを以下のようにする

```
entry:
		MOV		AX,0			; レジスタ初期化
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; ディスクを読む
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; シリンダ0を指定
		MOV		DH,0			; ヘッド0を指定
		MOV		CL,2			; セクタ番号を指定
		MOV		AH,0x02			; ディスク読み込み
		MOV		AL,1			; 処理するセクタ数
		MOV		BX,0
		MOV		DL,0x00			; ドライブ番号を指定、Aドライブ
		INT		0x13			; ディスクBIOS呼び出し
		JC		err
```

JCは`jump if carry`の略、carryフラグが1だったらジャンプせよ

- [x] エラーになったらやり直そう(harib00b)


`entry`を以下のように変更
JNCは条件ジャンプ命令、「jump if not carry」キャリーフラグが0ならジャンプ
JAEも条件ジャンプ「jump if above or equal」大きいか等しければジャンプ

```
entry:
		MOV		AX,0			; レジスタ初期化
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; ディスクを読む
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; シリンダ0を指定
		MOV		DH,0			; ヘッド0を指定
		MOV		CL,2			; セクタ番号を指定
		MOV		SI,0			; 失敗回数を数えるレジスタ

retry:
		MOV		AH,0x02			; ディスク読み込み
		MOV		AL,1			; 処理するセクタ数
		MOV		BX,0
		MOV		DL,0x00			; ドライブ番号を指定、Aドライブ
		INT		0x13			; ディスクBIOS呼び出し
		JNC		fin				; エラーが起きなければfinへ
		ADD		SI,1			; SIに1を足す
		CMP		SI,5			; SIを5と比較
		JAE		err				; SI >= 5 だったらerrへ
		MOV		AH,0x00
		MOV		DL,0x00			; Aドライブを指定
		INT		0x13			; ドライブのリセット
		JMP 	retry
```

- [x] 18セクタまで読んでみる(harib00c)

`next`を追加してretryに`JNC next`入れて呼ぶ
JBEは「jump if below or equal」小さいか等しければジャンプ
C0-H0-S2〜C0-H0-S18までの512x17=8704バイトをメモリ番地0x8200~0xa3ffに読み込んだ

```
next:
		MOV		AX,ES			; アドレスを0x200進める
		ADD		AX,0x0020
		MOV		ES,AX			; ADD ES, 0x020という命令がないのでこうしている
		ADD		CL,1			; CLに1を足す
		CMP		CL,18			; CLと18を比較
		JBE		readloop		; CL <= 18 だったらreadloopへ
```

- [x] 10シリンダ分を読み込んでみる(harib00d)

nextを以下のように
JB=「jump if below」小さければジャンプしろ

```
next:
		MOV		AX,ES			; アドレスを0x200進める
		ADD		AX,0x0020
		MOV		ES,AX			; ADD ES, 0x020という命令がないのでこうしている
		ADD		CL,1			; CLに1を足す
		CMP		CL,18			; CLと18を比較
		JBE		readloop		; CL <= 18 だったらreadloopへ
		MOV     CL,1
		ADD     DH,1
		CMP     DH,2
		JB      readloop        ; DH < 2だったらreadloopへ
		MOV     DH,0
		ADD     CH,1
		CMP     CH,CYLS
		JB      readloop        ; CH < CYLSだったらreadloopへ
```

先頭に定数を追加

```
CYLS    EQU     10
```

- [x] OS本体を書き始めてみる(harib00e)

haribote.asmファイルを作成

```asm
fin:
		HLT
		JMP 	fin
```

Makefileを以下記事のように編集
https://qiita.com/pollenjp/items/8fcb9573cdf2dc6e2668

mformatとmcopyコマンドで起動用フロッピーディスクを作成する

```
mformat - add an MSDOS filesystem to a low-level formatted floppy disk
mcopy - copy MSDOS files to/from Unix
```

0x00002600にファイル名が、0x00004200にファイルの内容(haribote.sys)が格納されていることがわかる

```shell
$ cat haribote.img | xxd | grep -e 00002600 -e 00004200
00002600: 4841 5249 424f 5445 5359 5320 1800 784e  HARIBOTESYS ..xN
00004200: f4eb fd00 0000 0000 0000 0000 0000 0000  ................
```

- [x] ブートセクタからOS本体を実行させてみる(harib00f)

ディスクの0x00004200にあるプログラムをどうやって実行するか？
現在のプログラムは0x00008000にくるようにディスクをメモリに読み込んでいるので、8000+4200=c200にあるはず

haribote.asmにORGを追加

```asm
		ORG		0xc200			; このプログラムがどこに読み込まれるのか
```

ipl.asmからharibote.sysを実行するように追加

```asm
		JMP		0xc200
```

- [x] OS本体の動作を確認してみる(harib00g)

haribote.nasを以下のように変更して画面モードを切り替える

```asm
		ORG		0xc200			; このプログラムがどこに読み込まれるのか
        MOV     AL,0x13         ; VGAグラフィックス, 320x200 8bitカラーをセット
        MOV     AH,0x00         ; 画面モード切り替えのBIOS命令
        INT     0x10
```

make runして画面が真っ黒になったらOK

- [x] 32ビットモードへの準備(harib00h)

32ビットモードだと32ビットのレジスタも使えるし保護機能も使えるので32ビットモードにする
ただBIOSは16ビット用の機械語で書いているので処理を書ききる、キーボードの状態を取得しておく

```asm
; BOOT_INFO関係
CYLS    EQU     0x0ff0  ; ブートセクタが設定する
LEDS    EQU     0xfff1
VMODE   EQU     0xfff2  ; 色数に関する情報、何ビットカラーか
SCRNX   EQU     0xfff4  ; 解像度のX
SCRNY   EQU     0xfff6  ; 解像度のY
VRAM    EQU     0xfff8  ; グラフィックバッファの開始番地

		ORG		0xc200			; このプログラムがどこに読み込まれるのか
        MOV     AL,0x13         ; VGAグラフィックス, 320x200 8bitカラー
        MOV     AH,0x00
        INT     0x10
        MOV     BYTE [VMODE],8  ; 画面モードをメモする
        MOV     WORD [SCRNX],320
        MOV     WORD [SCRNY],240
        MOV     DWORD [VRAM],0x000a0000

; キーボードの状態をBIOSに教えてもらう
        MOV     AH,0x02
        INT     0x16            ; keyboard BIOS
        MOV     [LEDS],AL
```

画面モードに関する情報をメモリにメモしておく
VRAM=ビデオラム、画面用のメモリ


- [x] ついにC言語導入へ(harib00i)

asmhead.nasを写経する
bootpack.cを作る
リンカスクリプト`har.ld`を作る=オブジェクトファイルを生成してアセンブラとくっつける

- [x] とにかくHLTしたい(harib00j)

`nasmfunc.asm`ファイルを作成して`io_hlt`関数をアセンブラで定義
`io_halt`関数をbootpack.cから呼ぶようにする
