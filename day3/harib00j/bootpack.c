extern void io_hlt(void);

void HariMain(void)
{
fin:
    // ここにHLTを入れたいのだがC言語ではHLTが使えない
    io_hlt();
    goto fin;
}