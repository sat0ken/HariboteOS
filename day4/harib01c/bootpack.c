extern void io_hlt(void);
extern void write_mem8(int addr, int data);
void HariMain(void)
{
    int i;
    char *p;    // 変数pはBYTE用の番地
    for (i = 0xa0000; i <= 0xaffff; i++) {
        p = (char *) i;
        *p = i & 0x0f;
        // write_mem8(i, i & 0x0f);の代わりになる
    }
    for (;;) {
        io_hlt();
    }
}