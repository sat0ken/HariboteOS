extern void io_hlt(void);

void HariMain(void)
{
fin:
    io_hlt();   // これでnasmfunc.asmのio_hltが実行される
    goto fin;
}