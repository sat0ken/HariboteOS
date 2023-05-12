.text
.code16

# 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

jmp entry
.byte 0x90
.ascii "HELLOIPL"
.word 512               # 1セクタの大きさ（512にしなければならない）
.byte 1                 # クラスタの大きさ（1セクタにしなければならない）
.word 1                 # FATがどこから始まるか（普通は1セクタ目からにする）
.byte 2                 # FATの個数（2にしなければならない）
.word 224               # ルートディレクトリの大きさ（普通は224エントリにする)
.word 2880              # このドライブの大きさ（2880セクタにしなければならない）
.byte 0xf0              # メディアのタイプ（0xf0にしなければならない）
.word 9                 # FAT領域の長さ（9セクタにしなければならない）
.word 18                # 1トラックにいくつのセクタがあるか（18にしなければならない）
.word 2                 # ヘッドの数（2にしなければならない）
.int 0                  # パーティションを使っていないのでここは必ず0
.int 2880               # このドライブの大きさをもう一度書く
.byte 0,0,0x29          # よくわからないけどこの値にしておくといいらしい
.int 0xffffffff         # たぶんボリュームシリアル番号
.ascii "HELLO-OS   "    # ディスクの名前（11バイト）
.ascii "FAT12   "       # フォーマットの名前（8バイト）
.skip 18,0              # とりあえず18バイトあけておく

.set CYLS, 10           # シリンダを読む回数を定数で定義
.set _CYLS, 0xff0

# これより以下がプログラム本体

entry:
    movw $0, %ax        # レジスタ初期化
    movw %ax, %ss
    movw $0x7c00, %sp
    movw %ax, %ds

    # ディスクを読む
    movw $0x0820, %ax
    movw %ax, %es
    movb $0, %ch        # シリンダ0を指定
    movb $0, %dh        # ヘッド0を指定
    movb $2, %cl        # セクタ2を指定

readloop:
    movw $0, %si        # 失敗回数を数えるレジスタ

retry:
    movb $0x02, %ah     # AH=0x02 : ディスク読み込み
    movb $1, %al        # 1セクタ
    movw $0, %bx
    movb $0x00, %dl     # Aドライブ
    int $0x13           # ディスクBIOS呼び出し
    jnc next            # エラーが起きなければnextへ
    add $1, %si         # SIに1を足す
    cmp $5, %si         # SIを5と比較
    jae error           # SI >= 5 だったらerrorへ

    # reset drive
    movb $0x00, %ah
    movb $0x00, %dl     # Aドライブを指定
    int $0x13           # ドライブのリセット

    jmp entry

next:
    movw %es, %ax       # アドレス0x200進める
    add $0x20, %ax      # 512 / 16 = 0x20
    movw %ax, %es       # ADD ES, 0x020という命令がないのでこうしている
    add $1, %cl         # CLに1を足す
    cmp $18, %cl        # CLと18を比較
    jbe readloop        # CL <= 18だったらreadloopへ

    movb $1, %cl
    add $1, %dh
    cmp $2, %dh
    jb readloop         # DH < 2だったらreadloopへ

    movb $0, %dh
    add $1, %ch
    cmp $CYLS, %ch
    jb readloop         # CH < CYLSだったらreadloopへ

# 読み終わったのでharibote.sysを実行する
    movb $CYLS, (_CYLS)
    jmp 0xc200          # haribote.sysの番地へ飛ぶ

fin:
    hlt                 # 何かあるまでCPUを停止させる
    jmp fin             # 無限ループ

error:
    movw $msg, %si

putloop:
    movb (%si), %al
    addw $1, %si        # SIに1を足す
    cmpb $0, %al
    je fin
    movb $0x0e, %ah     # 1文字表示ファンクション
    movw $15, %bx       # カラーコード
    int $0x10           # ビデオBIOS呼び出し
    jmp putloop

 msg:
    .string "\nload error\n\n"

  .org 0x01fe
  .byte 0x55, 0xaa











