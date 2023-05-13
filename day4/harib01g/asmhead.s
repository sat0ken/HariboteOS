.text
.code16

.set BOTPAK, 0x00280000         # bootpackのロード先
.set DSKCAC, 0x00100000         # ディスクキャッシュの場所
.set DSKCAC0, 0x00008000        # ディスクキャッシュの場所（リアルモード）

# BOOTINFO関係
.set CYLS, 0x0ff0               # ブートセクタが設定する
.set LEDS, 0x0ff1
.set VMODE, 0x0ff2              # 色数に関する情報。何ビットカラーか？
.set SCRNX, 0x0ff4              # 解像度のX
.set SCRNY, 0x0ff6              # 解像度のY
.set VRAM, 0x0ff8               # グラフィックバッファの開始番地

# 画面モードを設定
    movb $0x13, %al             # VGAグラフィックスカラー、320x200x8bitカラー
    movb $0x00, %ah
    int $0x10

    movb $8, (VMODE)            # 画面モードをメモする（C言語が参照する）
    movw $320, (SCRNX)
    movw $200, (SCRNY)
    movl $0x000a0000, (VRAM)

# キーボードのLED状態をBIOSに教えてもらう
    movb $0x02, %ah
    int $0x16
    movb %al, (LEDS)

# PICが一切の割り込みを受け付けないようにする
# AT互換機の仕様ではPICの初期化をするなら、こいつをCLI前にやっておかないとたまにハングアップする
# PICの初期化はあとでやる
    movb $0xff, %al
    outb %al, $0x21
    nop
    outb %al, $0xa1

    cli                         # さらにCPUレベルでも割り込み禁止

# CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定
    call waitkbdout
    movb $0xd1, %al
    outb %al, $0x64
    call waitkbdout
    movb $0xdf, %al
    outb %al, $0x60
    call waitkbdout

# プロテクトモード移行
.arch i486

    lgdt (GDTR0)                # 暫定GDTを設定
    movl %cr0, %eax
    andl $0x7fffffff, %eax      # bit31を0にする（ページング禁止のため）
    orl $0x00000001, %eax       # bit0を1にする（プロテクトモード移行のため）
    movl %eax, %cr0
    jmp pipelineflush

 pipelineflush:
    movw $1*8, %ax              # 読み書き可能セグメント32bit
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

# bootpackの転送
movl $bootpack, %esi            # 転送元
movl $BOTPAK, %edi              # 転送先
movl $512*1024/4, %ecx
call memcpy

# ついでにディスクデータも本来の位置へ転送
# まずはブートセクタから
movl $0x7c00, %esi              # 転送元
movl $DSKCAC, %edi              # 転送先
movl $512/4, %ecx
call memcpy

# 残り全部
movl $DSKCAC0+512, %esi         # 転送元
movl $DSKCAC+512, %edi          # 転送先
movl $0, %ecx
movb (CYLS), %cl
imull $512*18*2/4, %ecx         # シリンダ数からバイト数/4に変換
sub $512/4, %ecx                # IPLの分だけ差し引く
call memcpy

# asmheadでしなければいけないことは全部終わったのであとはbootpackに任せる
# bootpackの起動
movl $BOTPAK, %ebx
movl 16(%ebx), %ecx
add $3, %ecx                    # ECX += 3
SHR $2, %ecx                    # ECX /= 4
jz skip                         # 転送するべきものがない
movl 20(%ebx), %esi             # 転送元
add %ebx, %esi
movl 12(%ebx), %edi             # 転送先
call memcpy

skip:
    mov 12(%ebx), %esp          # スタック初期値
    ljmpl $2*8, $0x0000001b

waitkbdout:
    inb $0x64, %al
    andb $0x02, %al
    jnz waitkbdout              # ANDの結果が0でなければwaitkbdoutへ
    ret

memcpy:
    movl (%esi), %eax
    add $4, %esi
    movl %eax, (%edi)
    add $4, %edi
    sub $1, %ecx
    jnz memcpy                  # 引き算した結果が0でなければwaitkbdoutへ
    ret

.align 16
GDT0:
    .skip 8, 0x00
    .word 0xffff, 0x0000, 0x9200, 0x00cf    # 読み書き可能セグメント32bit
    .word 0xffff, 0x0000, 0x9a28, 0x0047    # 実行可能セグメント 32bit（bootpack用)
    .word 0x0000

GDTR0:
    .word 8*3-1
    .int GDT0

bootpack:
