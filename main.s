;.DEVICE atmega32
;.EQU PORTC  = $15
;.EQU DDRC   = $14
;.EQU PINC   = $13
;.EQU PORTD  = $12
;.EQU SREG   = $3f   ;Status Register
;.EQU ADCSRA = $06   ;ADC    Control Register
;.EQU OCR2   = $23   ;Timer2 Output Compare Register
;.EQU TCNT2  = $24   ;Timer2 Counter
;.EQU TCCR2  = $25   ;Timer2 Control Register
;.EQU TCNT0  = $32   ;Timer0 Counter
;.EQU TCCR0  = $33   ;Timer0 Control Register
;.EQU TIFR   = $38   ;Timer  Interrupt Flag Register
;.EQU TIMSK  = $39   ;Timer  Interrupt Mask Register
;.EQU GIFR   = $3A   ;
;.EQU GICR   = $3B   ;
;.EQU OCR0   = $3C   ;Timer0 Output Compare Register
;.EQU DDRB   = $17
;.EQU DDRD   = $11
;.EQU MCUCR  = $35
;.EQU SPL   = $3D
;.EQU SPH  = $3E
.CSEG
rjmp RESET ;0
RETI;
rjmp EXT_INT0 ;2
RETI;
rjmp EXT_INT1 ;4
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
RETI ;12
RETI ;13
RETI ;14
rjmp main ;15
main:
  rjmp main         ;infinite loop

EXT_INT0:           ;Uout = Uin/4
  EOR r28, r30      ;r28[0]++ (INT0BIT++)
  SBRS r28, 0
  rjmp phase42      ;if r28[0] (INT0BIT) == 1 then phase102
  phase4:           ;Uout = Uin/4 by 1 phase
    CLR r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TCNT2, r16  ;TCNT2 = 0
    OUT TCCR2, r16  ;TCCR2 = 0
    OUT TIFR,  r16  ;TIFR = 0
    LDI r16,   $C0
    OUT OCR0,  r16  ;OCR0  = 192
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
	SEI
    RETI

  phase42:          ;Uout = Uin/4 by 2 phases
    CLR r16
	OUT TCCR0, r16
	OUT TCCR2, r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
	LDI r16,   $80
    OUT TCNT2, r16  ;TCNT2 = $FF/2
    LDI r16,   $E0
    OUT OCR0,  r16  ;OCR0  = 224
	OUT OCR2,  r16
    LDI r16,   $79
	OUT TCCR2, r16
    OUT TCCR0, r16  ;TCCR0 = 01111001
	SEI
    RETI

EXT_INT1:           ;Uout = Uin/10
  EOR r29, r30      ;r29[0]++ (INT1BIT++)
  SBRS r29, 0
  rjmp phase102     ;if r29[0] (INT1BIT) == 1 then phase102
  phase10:          ;Uout = Uin/10 by 1 phase
    CLR r16
	OUT TCCR0, r16
	OUT TCCR2, r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
    LDI r16,   $E6  ;OCR0  = 230
    OUT OCR0,  r16
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
	SEI
    RETI

  phase102:         ;Uout = Uin/10 by 2 phases
    CLR r16
	OUT TCCR0, r16
	OUT TCCR2, r16
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
    LDI r16,   $80
    OUT TCNT2, r16  ;TCNT2 = 0xFF/2
    LDI r16,   $F3
    OUT OCR0,  r16  ;OCR0  = 243
    OUT OCR2,  r16  ;OCR2  = 243
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
    OUT TCCR2, r16  ;TCCR2 = 01111001
	SEI
    RETI


RESET:
  LDI r30, $01
  SER r16
  ;OUT DDRC, r16     ;DDRC  = 0xFF
  SBI DDRB, 3
  SBI PORTD, 2
  SBI PORTD, 3
  SBI DDRD, 7
  OUT TIMSK, r30    ;TIMSK = 00000001
  LDI r16, $0F
  ;OUT MCUCR, r16    ;MCUCE = 00001111
  LDI r16, $E0
  OUT GICR, r16     ;GICR  = 11100000
  LDI r16, $5f
  OUT SPL, r16
  LDI r16, $08
  OUT SPH, r16
  CLR r16
  SEI
  rjmp main
