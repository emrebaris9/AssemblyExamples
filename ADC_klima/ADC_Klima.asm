#INCLUDE    <P16F877A.INC>
    ORG	0X00
    CALL    HAZIRLIK
UST_SATIR
    MOVLW   0X01
    CALL    KOMUT_ISLE
    MOVLW   0X80
    CALL    KOMUT_ISLE
    CLRF    HARFCEK
LOOP1
    MOVF    HARFCEK,W	; HARFCEK=0 
    CALL    LOOKUP	; S HARF? GEL
    XORLW   0X00	; 0000 0000 XOR 0000 0000 = 0000 0000 STATUS Z=1 
    BTFSC   STATUS,Z	; RETLW 0X00 SICAKLIK = DERECEY? YAZMAYA G?T
    GOTO    LOOP2
    CALL    KARAKTER_ISLE
    INCF    HARFCEK
    GOTO    LOOP1
LOOP2
    CALL    ISI_AL
    CALL    HEX_TO_DEC
    CALL    ATAMA
    GOTO    ALT_SATIR
ALT_SATIR
    MOVLW   0XC0
    CALL    KOMUT_ISLE
    INCF    HARFCEK,F
LOOP3
    MOVF    HARFCEK, W
    CALL    LOOKUP
    XORLW   0X00
    BTFSC   STATUS,Z
    GOTO    REFERANS_AL
    CALL    KARAKTER_ISLE
    INCF    HARFCEK
    GOTO    LOOP3
REFERANS_AL
    MOVF    REFERANS,W
    MOVWF   TEMP
    CALL    HEX_TO_DEC
    CALL    ATAMA
KONTROL
    BTFSC   PORTC,0
    GOTO    ARTTIR
    BTFSC   PORTC,1
    GOTO    AZALT
KARSILASTIR
    MOVF    REFERANS,W
    SUBWF   SICAKLIK,W
    BTFSC   STATUS,C
    GOTO    MOTOR_ON
    GOTO    MOTOR_OFF
MOTOR_ON
    BSF	    PORTC,2
    GOTO    KONTROL
MOTOR_OFF
    BCF	    PORTC,2
    GOTO    KONTROL
    ARTTIR
	INCF	REFERANS,F
	MOVF	REFERANS,W
	MOVWF	TEMP
	MOVLW	0X01
	MOVWF	KOMUT_ISLE
	GOTO	UST_SATIR
   AZALT 
	DECF	REFERANS,F
	MOVF	REFERANS,W
	MOVWF	TEMP
	MOVLW	0X01
	MOVWF	KOMUT_ISLE
	GOTO	UST_SATIR

HAZIRLIK
    HARFCEK	EQU 0X20
    SAYAC1	EQU 0X21
    SAYAC2	EQU 0X22
    TEMP	EQU 0X24
    BIRLER	EQU 0X25
    ONLAR	EQU 0X26
    YUZLER	EQU 0X27    
    DEGER	EQU 0X28
    REFERANS	EQU 0X29
    SICAKLIK	EQU 0X30
    BANKSEL TRISB ;PORTB �IKI? YAPILDI
    CLRF    TRISB
    MOVLW   B'00000011'
    MOVWF   TRISC
    
    BANKSEL PORTB
    CLRF    PORTB
    CLRF    PORTC
    MOVLW   D'24'
    MOVWF   REFERANS
    BANKSEL ADCON1 ; ADC HAZIRLANDI.
    MOVLW   B'10001110' ;ADFM- SAGA DAYALI & 1110 = AN0 A
    MOVWF   ADCON1
    BANKSEL ADCON0
    MOVLW   B'11000001' ; Dahili VE ADC A�ILDI...
    MOVWF   ADCON0
    
    MOVLW   0X02 ; LCD AYARLANDI..
    CALL    KOMUT_ISLE
    MOVLW   0X28
    CALL    KOMUT_ISLE
    MOVLW   0X0C
    CALL    KOMUT_ISLE
    MOVLW   0X01
    CALL    KOMUT_ISLE
    RETURN
    
KOMUT_ISLE
    MOVWF   DEGER	; 1011 0110
    SWAPF   DEGER,W	; 0110 1011
    ANDLW   0X0F	; 0000 1111
    MOVWF   PORTB	; 0000 1011
    BCF	    PORTB,4	    
    CALL    PULSE
    ;------------------------------ 
    MOVF    DEGER,W	;1011 0110
    ANDLW   0X0F	;0000 1111
    MOVWF   PORTB	;0000 0110
    BCF	    PORTB,4
    CALL    PULSE
    RETURN
 
KARAKTER_ISLE
    MOVWF   DEGER
    SWAPF   DEGER,W
    ANDLW   0X0F
    MOVWF   PORTB
    BSF	    PORTB,4
    CALL    PULSE
    
    MOVF    DEGER,W
    ANDLW   0X0F
    MOVWF   PORTB
    BSF	    PORTB,4 ;RS-SET
    CALL    PULSE
    RETURN
    
 

ISI_AL
    BANKSEL ADCON0
    BSF	  ADCON0,2 ; ADC AKTIF ET.
    BTFSC   ADCON0,2    
    GOTO    $-1       ; ADCON0,2 S? CLR OLANA KADAR DON 
    BANKSEL ADRESH
    RRF	    ADRESH, F	; 8 B?TE SIGDIRMAK ICIN 1 BITI KAYDIRARAK GOZ ARDI ETMEK	
    BANKSEL ADRESL
    RRF	    ADRESL, W	; ADRES LOWA 1 B?T KAYIYOR
    BANKSEL TEMP
    MOVWF   SICAKLIK
    MOVWF   TEMP
    RETURN
 
HEX_TO_DEC
    CLRF    YUZLER
    CLRF    ONLAR
    CLRF    BIRLER
    YUZLER_KONT
    MOVLW   D'100'
    SUBWF   TEMP, W
    BTFSS   STATUS,C
    GOTO    ONLAR_KONT
    INCF    YUZLER, F
    MOVLW   D'100'
    SUBWF   TEMP, F
    GOTO    YUZLER_KONT
    
ONLAR_KONT      ;ONCE gecici CIKARMA ARDINDAN asil CIKARTMA
    MOVLW   D'10'	; 22C  W=10 ----------- 2C  
    SUBWF   TEMP, W	; 22-10= 12 ------------ 2-10= -2
    BTFSS   STATUS, C	; TASMA OLMADI C=1 ----- C=0
    GOTO    BIRLER_KONT
    INCF    ONLAR, F	; ONLAR 0+1= 1
    MOVLW   D'10'	; W=10
    SUBWF   TEMP, F	; 22-10= 12---- TEMP=2
    GOTO    ONLAR_KONT
    
BIRLER_KONT
    MOVF    TEMP,W  ; 2C
    MOVWF   BIRLER
    RETURN
    
    
ATAMA
    MOVF    YUZLER, W
    ADDLW   D'48'
    CALL    KARAKTER_ISLE
    
    MOVF    ONLAR, W
    ADDLW   D'48'	;(4+48 = 52) LCD DE 4 YAZAR 	
    CALL    KARAKTER_ISLE
    
    MOVF    BIRLER, W
    ADDLW   D'48'
    CALL    KARAKTER_ISLE
    
    MOVLW   D'223'
    CALL    KARAKTER_ISLE
    
    MOVLW   'C'
    CALL    KARAKTER_ISLE
    
    RETURN

PULSE	;DUSEN KENAR
	BSF PORTB,5
	CALL GECIKME
	BCF PORTB,5
	CALL GECIKME	; VERIYI GONDERDIKTEN SONRA ISLEMEK ICIN YAPILIR
RETURN

GECIKME   ;1,2 MS   20*20*3=
	MOVLW 0X20
	MOVWF SAYAC1
D1
	MOVLW 0X20
	MOVWF SAYAC2
D2
	DECFSZ SAYAC2,F
	GOTO D2
	DECFSZ SAYAC1,F
	GOTO D1
RETURN
    
LOOKUP
    ADDWF   PCL,F
    RETLW   'S'
    RETLW   'I'
    RETLW   'C'
    RETLW   'A'
    RETLW   'K'
    RETLW   'L'
    RETLW   'I'
    RETLW   'K'
    RETLW   ':'
    RETLW   0X00 ;SICAKLIGA GEC
    RETLW   'R'
    RETLW   'E'
    RETLW   'F'
    RETLW   'E'
    RETLW   'R'
    RETLW   'A'
    RETLW   'N'
    RETLW   'S'
    RETLW   ':'
    RETLW   0X00
    
END