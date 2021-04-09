.DEVICE atmega32
.EQU PORTC  = $15
.EQU DDRC   = $14
.EQU PINC   = $13
.EQU PORTD  = $12
.EQU SREG   = $3f   ;Status Register
.EQU ADCSRA = $06   ;ADC    Control Register
.EQU OCR2   = $23   ;Timer2 Output Compare Register
.EQU TCNT2  = $24   ;Timer2 Counter
.EQU TCCR2  = $25   ;Timer2 Control Register
.EQU TCNT0  = $32   ;Timer0 Counter
.EQU TCCR0  = $33   ;Timer0 Control Register
.EQU TIFR   = $38   ;Timer  Interrupt Flag Register
.EQU TIMSK  = $39   ;Timer  Interrupt Mask Register
.EQU GIFR   = $3A   ;
.EQU GICR   = $3B   ;
.EQU OCR0   = $3C   ;Timer0 Output Compare Register
.CSEG
rjmp RESET ;0
rjmp EXT_INT0 ;1
rjmp EXT_INT1 ;2
RETI ;3
RETI ;4
RETI ;5
RETI ;6
RETI ;7
RETI ;8
RETI ;9
RETI ;A
RETI ;B
RETI ;C
RETI ;D
RETI ;E
RETI ;F
RETI ;10
RETI ;11
rjmp INT2 ;12
RETI ;13
RETI ;14
rjmp main ;15
main:
  IN   r16, ADCSRA
  SBRC r16, 7
  rjmp CODE4        ;if ADC ON then write symbols to LCD
  rjmp main         ;infinite loop

EXT_INT0:           ;Uout = Uin/4
  EOR r28, r30      ;r28[0]++ (INT0BIT++)
  SBRC r28, 0
  rjmp phase42      ;if r28[0] (INT0BIT) == 1 then phase102
  1phase4:          ;Uout = Uin/4 by 1 phase
    CLR r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TCNT2, r16  ;TCNT2 = 0
    OUT TCCR2, r16  ;TCCR2 = 0
    OUT TIFR,  r16  ;TIFR = 0
    LDI r16,   $C0
    OUT OCR0,  r16  ;OCR0  = 192
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
    RETI

  phase42:          ;Uout = Uin/4 by 2 phases
    CLR r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TCNT2, r16  ;TCNT2 = 0
    OUT TCCR2, r16  ;TCCR2 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
    LDI r16,   $D6
    OUT OCR0,  r16  ;OCR0  = 230.4~230
    LDI r16,   $79 
    OUT TCCR0, r16  ;TCCR0 = 01111001
    RETI

EXT_INT1:           ;Uout = Uin/10
  EOR r29, r30      ;r29[0]++ (INT1BIT++)
  SBRC r29, 0
  rjmp phase102     ;if r29[0] (INT1BIT) == 1 then phase102
  1phase10:         ;Uout = Uin/10 by 1 phase
    CLR r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
    LDI r16,   $81  ;TCNT2 = 129
    OUT TCNT2, r16
    LDI r16,   $D   ;OCR0  = 224
    OUT OCR0,  r16
    LDI r16,   $D   ;OCR2  = 224
    OUT OCR2,  r16
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
    OUT TCCR2, r16  ;TCCR2 = 01111001
    RETI

  phase102:         ;Uout = Uin/10 by 2 phases
    CLR r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
    LDI r16,   $81
    OUT TCNT2, r16  ;TCNT2 = 129
    LDI r16,   $E3
    OUT OCR0,  r16  ;OCR0  = 243
    OUT OCR2,  r16  ;OCR2  = 243
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
    OUT TCCR2, r16  ;TCCR2 = 01111001
    RETI

INT2:               ;ADC ON/OFF
  EOR  r31, r30     ;r31[0]++ (ADCBIT++)
  LDI  r16, $EF
  SBRC r31, 0
  OUT ADCSRA, r16   ;if r31[0] (ADCBIT) == 1 then ADCSRA = 0xEF -> ADC ON
  CLR  r16
  SBRS r31, 0
  OUT ADCSRA, r16   ;if r31[0] (ADCBIT) == 0 then ADCSRA = 0x0  -> ADC OFF
  RETI

CODE4:              ;protocol of writing symbols to LCD
  INC  r27          ;counter  of written to LDC symbols
  MOV  r16, r18
  ANDI r16, $f0
  ORI  r16, 1
  OUT  PORTC, r16
  SBI  PORTC, 2     ;write strobe to PORTC
  CBI  PORTC, 2     ;write strobe to PORTC
  ;rcall del
  CPI  r27, $04
  BREQ SHIFT        ;if there were 4 written symbols then shift pointer to start of LCD 
  RET

SHIFT:              ;SHIFT LCD pointer to start
  LDI r16, $02
  OUT PORTC, r18    ;write 0x02   to PORTC
  SBI PORTC, 2      ;write strobe to PORTC
  CBI PORTC, 2      ;write strobe to PORTC
  CLR r27           ;set written symbols counter to 0
  RET

RESET:
  LDI r30, $01
  SER r16
  OUT DDRC, r16     ;DDRC  = 0xFF
  OUT TIMSK, r30    ;TIMSK = 00000001
  LDI r16, $E0
  OUT GICR, r16     ;GICR  = 11100000
  OUT GIFR, r16     ;GIFR  = 11100000
  CLR r16
  SBI PORTD, 2
  SEI
  rjmp main
  
  
  
;155 str CLI PORTC, 2 ???
