INCLUDE<P16F877.INC>
SAYAC1 EQU 0X21
SAYAC2 EQU 0X22
ORG 0X00
BANKSEL TRISC
CLRF TRISC
BANKSEL PORTC
CLRF PORTC
BANKSEL SPBRG 
MOVLW D'51'
MOVWF SPBRG
BANKSEL TXSTA
MOVLW B'00100100'
MOVWF TXSTA
BANKSEL RCSTA
MOVLW B'10000000'
MOVWF RCSTA
DONGU
BTFSS PIR1,TXIF
GOTO DONGU
MOVLW 'S'
MOVWF TXREG
CALL GECIKME
MOVLW 'O'
MOVWF TXREG
CALL GECIKME
MOVLW 'S'
MOVWF TXREG
CALL GECIKME
GOTO DONGU
GECIKME
MOVLW 0XFF
MOVWF SAYAC1
DONGU1
MOVLW 0XFF
MOVWF SAYAC2
DONGU2
DECFSZ SAYAC2,F
GOTO DONGU2
DECFSZ SAYAC1,F
GOTO DONGU1
RETURN
END