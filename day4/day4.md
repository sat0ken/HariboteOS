## 4日目 C言語と画面表示の練習

- [x] C言語からメモリに書き込みたい(harib01a)

`write_mem8`関数を追加
`write_mem(0x1234, 0x56)`のように使い動作的には、`MOVE BYTE[0x1234],0x56`をやらせたい

```asm
write_mem8:             # void write_mem8(int addr, int data);
    movl 4(%esp), %ecx  # esp+4にaddrが入っているのでそれをecxに読み込む
    movb 8(%esp), %al   # esp+8にdataが入っているのでそれをalに読み込む
    mov %al, (%ecx)
    ret
```