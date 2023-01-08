; Khrome Crypt v0.3 Unpacker
; Coded by dR.No // Delirium Tremens Group

model tiny
.code
.386
org 100h

Begin:
        mov     dx,offset Msg
        call    write
        mov     si,81h
        lodsb
        cmp     al,0Dh
        jne     FileOk
        mov     dx,offset Usage
        jmp     short write

FileOk:
        push    si si
        pop     cx di

@Str:
        mov     al,[di]
        cmp     al,0Dh
        je      _EndStr
        inc     di
        loop    @Str

_EndStr:
        mov     ax,2400h
        stosw
        mov     dx,si
        mov     ax,3D02h
        int     21h
        jnc     NoErr
        mov     dx,offset not_found
        jmp     short Write

NoErr:
        xchg    bx,ax
        mov     dx,offset Process
        call    write
        mov     dx,si
        int     21h
        xor     cx,cx
        xor     dx,dx
        mov     ax,4200h
        int     21h
        mov     ah,3Fh
        mov     dx,offset Buf
        mov     cx,-1
        int     21h

        mov     bp,offset Buf
        mov     di,bp
        cmp     DWord Ptr [bp+22h],6F72684Bh
        je      CryptOk
        mov     dx,offset NotCrypt

Write:
        mov     ah,09
        int     21h
        ret

CryptOk:
        mov     bp,ax
        mov     cx,bp
        sub     cx,484h
        add     dx,3A0h
        push    cx dx
        mov     cx,ax
        mov     ah,3Eh
        int     21h


        pusha

;fuck

        mov     cx,0BAh
        add     di,bp
        push    di
        sub     di,cx
        mov     dx,word ptr [Buf+44h]

@PreDecode:
        mov     al,[di]
        xor     al,dh
        xor     al,dl
        add     al,dh
        stosb
        loop    @PreDecode
        pop     di


        mov     ax,[di-06Fh]
        xor     dx,dx
        mov     bx,offset Buf+3A0h
        mov     cx,[di-60h]
        push    bx cx

@PreDecode1:
        xor     [bx],al
        add     [bx],ah
        xor     [bx],dl
        inc     dl
        inc     bx
        loop    @PreDecode1

        mov     ax,[di-06Dh]
        xor     dx,dx
        pop     cx bx

@Decode:
        add     byte ptr [bx],10h
        xor     [bx],al
        xor     [bx],ah
        add     byte ptr [bx],0AAh
        push    cx
        mov     cx,dx
        shl     cx,2
        sub     [bx],cl
        pop     cx
        inc     bx
        inc     dx
        loop    @Decode

        popa

        mov     dx,offset _Out
        mov     ax,3C02h
        xor     cx,cx
        int     21h

        xchg    bx,ax

        pop     dx cx
        mov     ah,40h
        int     21h

        mov     ah,3Eh
        int     21h
        mov     dx,offset Oki
        jmp     write
Msg             db              0dh,0ah,'Khrome Crypt v0.3 Unpacker Coded by dR.No // ViP // DTg // PMP',0dh,0ah,24h
Usage           db              0dh,0ah,'Usage: UP-KHRMC <FiLE-2-UNP>',0dh,0ah,24h
Not_found       db              'File not found',0dh,0ah,24h
NotCrypt        db              0dh,0ah,'Specified file is not crypted with Khrome Crypt v0.3',0dh,0ah,24h
Process         db              'Unpacking the file: $'
Oki             db              '... completed!',0dh,0ah,24h
_Out            db              'UNPACKED.COM',0
Buf:
End Begin