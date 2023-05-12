.arch i486              # 486の命令まで使いたい

.text

.global io_hlt

.global write_mem8

io_hlt:                 # void io_hlt(void);
    hlt
    ret

write_mem8:             # void write_mem8(int addr, int data);
    movl 4(%esp), %ecx  # esp+4にaddrが入っているのでそれをecxに読み込む
    movb 8(%esp), %al   # esp+8にdataが入っているのでそれをalに読み込む
    mov %al, (%ecx)
    ret
