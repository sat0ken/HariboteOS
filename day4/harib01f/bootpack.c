extern void io_hlt(void);
extern void io_cli(void);
extern void io_out8(int port, int data);
extern int io_load_eflags(void);
extern void io_store_eflags(int eflags);

extern void init_palette(void);
extern void set_palette(int start, int end, unsigned char *rgb);

void HariMain(void)
{
    int i;
    char *p;        // 変数pはBYTE [...]用の番地
    init_palette(); // パレットを設定
    p = (char *) 0xa0000; // 番地を代入
    for (i = 0; i <= 0xffff; i++) {
        *(p + i) = i & 0x0f;
    }
    for (;;) {
        io_hlt();
    }
}

void init_palette(void)
{
    // staticをつけるとDB命令となり48バイトですむ
    // unsigned = 0~255
    static unsigned char table_rgb[16 * 3] = {
        0x00, 0x00, 0x00,   // 0: 黒
        0xff, 0x00, 0x00,   // 1: 明るい赤
        0x00, 0xff, 0x00,   // 2: 明るい緑
        0xff, 0xff, 0x00,   // 3: 明るい黄色
        0x00, 0x00, 0xff,   // 4: 明るい青
        0xff, 0x00, 0xff,   // 5: 明るい紫
        0x00, 0xff, 0xff,   // 6: 明るい水色
        0xff, 0xff, 0xff,   // 7: 白
        0xc6, 0xc6, 0xc6,   // 8: 明るい灰色
        0x84, 0x00, 0x00,   // 9: 暗い赤
        0x00, 0x84, 0x00,   // 10: 暗い緑
        0x84, 0x84, 0x00,   // 11: 暗い黄色
        0x00, 0x00, 0x84,   // 12: 暗い青
        0x84, 0x00, 0x84,   // 13: 暗い紫
        0x00, 0x84, 0x84,   // 14: 暗い水色
        0x84, 0x84, 0x84,   // 15: 暗い灰色
    };
    set_palette(0, 15, table_rgb);
    return;
}

void set_palette(int start, int end, unsigned char *rgb)
{
    int i, eflags;
    eflags = io_load_eflags();      // 32ビットのEFLAGSの値を読み込む。9ビット目の割り込み許可フラグの値を見るため
    io_cli();                       // 許可フラグを0にして割り込み禁止にする。CLIはclear interrupt flagの略
    io_out8(0x03c8, start);     // ビデオDAコンバータにパレット番号を書き込む
    for (i = start; i <= end; i++) {
        io_out8(0x03c9, rgb[0] / 4);
        io_out8(0x03c9, rgb[1] / 4);
        io_out8(0x03c9, rgb[2] / 4);
        rgb += 3;
    }
    io_store_eflags(eflags);         // 割り込み許可フラグを元に戻す
    return;
}