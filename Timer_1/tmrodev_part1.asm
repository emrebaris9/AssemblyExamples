INCLUDE<P16F877.INC>
COUNTER1    EQU 0X21	;for delay counters
COUNTER2    EQU 0X22	 
TMR0COUNT   EQU 0X23	;for timer counters
TMR1COUNT   EQU 0X24	
NUM_1	    EQU 0X25	;numbers
NUM_2	    EQU 0X26

ORG 0X00	;origin adress
GOTO START
ORG 0X04	;interrupt address
GOTO INT

INT
	BTFSC INTCON,T0IF   ; timer0 flag control
	CALL INT1
	BTFSC PIR1,TMR1IF   ; timer1 flag control
	CALL INT2
	RETFIE

INT1
	BCF INTCON,T0IF	    ;flag-down
	MOVLW D'6'	    
	MOVWF TMR0
	DECFSZ TMR0COUNT,F  
	RETFIE
	MOVLW D'25'	    ;timer0-computed counter value
	MOVWF TMR0COUNT	
	INCF NUM_1,F
	MOVLW 0X0A
	SUBWF NUM_1,W
	BTFSC STATUS,Z
	CLRF NUM_1
	RETFIE
INT2
	BCF PIR1,TMR1IF
	MOVLW 0X3C
	MOVWF TMR1H
	MOVLW 0XB0
	MOVWF TMR1L
	DECFSZ TMR1COUNT,F
	RETFIE
	MOVLW D'5'	    ;timer1-computed counter value
	MOVWF TMR1COUNT
	INCF NUM_2,F	
	MOVLW 0X0A
	SUBWF NUM_2,W
	BTFSC STATUS,Z
	CLRF NUM_2
	RETFIE

START
	BANKSEL TRISB
	CLRF PORTB 
	CLRF PORTC
	
	MOVLW B'00000101'   ;scale value of 64
	MOVWF OPTION_REG
	MOVLW B'10100000'   ; gie, tmroie
	MOVWF INTCON
	BSF PIE1,0	    ;tmr1ie

	BANKSEL PORTB
	CLRF PORTB 
	CLRF PORTC

	MOVLW D'6'	    ;in the 256-6 = 6 value
	MOVWF TMR0
	
	MOVLW D'25'	    ; computed counter value 
	MOVWF TMR0COUNT

	MOVLW 0X3C
	MOVWF TMR1H	    ;tmr1 high value
	MOVLW 0XB0
	MOVWF TMR1L	    ;tmr1 low value

	MOVLW D'5'	    ; tmr1 computed counter value
	MOVWF TMR1COUNT

	BCF PIR1,0	    ;at normal this flag have a logical 1

	MOVLW B'00100001'   ;scale value of 4--- first 4 bit for prescaler value
	MOVWF T1CON	    ;transfer to 

	CLRF NUM_1
	CLRF NUM_2

MAIN			    ;infinity loop
	BCF	PORTC,3	    ;clear the third bit of portc for set right area of 7seg
	MOVF	NUM_1,W	    ;num_1 value transferring to register
	CALL	LOOKUP	    ;take value of num_1 on the lookup table
	BSF	PORTC,2	    ;set the second bit of portc for clear this area
	MOVWF	PORTB	    ;show num_1 value on display
	CALL	DELAY	
	CLRF	PORTB	    ;clear for next wave
;----------------------------------------------------------------------------------
	BCF	PORTC,2	    ;clear the second bit of portc for set left area of 7seg	       
	MOVF	NUM_2,W	    ;num_1 value transferring to register   
	CALL	LOOKUP	    ;take value of num_1 on the lookup table
	BSF	PORTC,3	    ;set the third bit of portc for clear this area
	MOVWF	PORTB	    ;show on display
	CALL	DELAY
	CLRF	PORTB	    ;clear for next
GOTO MAIN

DELAY
    MOVLW 0X10
    MOVWF COUNTER1
    D1
    MOVLW 0X10
    MOVWF COUNTER2
    D2
    DECFSZ COUNTER2,F
    GOTO D2
    DECFSZ COUNTER1,F
    GOTO D1
    RETURN
LOOKUP
    ADDWF   PCL,F
    RETLW   B'00111111' 
    RETLW   B'00000110' 
    RETLW   B'01011011' 
    RETLW   B'01001111' 
    RETLW   B'01100110' 
    RETLW   B'01101101' 
    RETLW   B'01111101' 
    RETLW   B'00000111' 
    RETLW   B'01111111'
    RETLW   B'01101111' 
END