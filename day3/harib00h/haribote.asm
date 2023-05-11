; hello-os
; TAB=4

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

fin:
		HLT
		JMP 	fin