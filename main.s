.DEVICE atmega32
.EQU DDRB   = $17
.EQU PORTC  = $15
.EQU DDRC   = $14
.EQU PINC   = $13
.EQU PORTD  = $12
.EQU DDRD   = $11
.EQU SREG   = $3f   ;Status  Register
.EQU ADCSRA = $06   ;ADC     Control Register
.EQU OCR2   = $23   ;Timer2  Output Compare Register
.EQU TCNT2  = $24   ;Timer2  Counter
.EQU TCCR2  = $25   ;Timer2  Control Register
.EQU TCNT0  = $32   ;Timer0  Counter
.EQU TCCR0  = $33   ;Timer0  Control Register
.EQU TIFR   = $38   ;Timer   Interrupt Flag Register
.EQU TIMSK  = $39   ;Timer   Interrupt Mask Register
.EQU GIFR   = $3A   ;General Interrupt Flag Register
.EQU GICR   = $3B   ;General Interrupt Control Register
.EQU OCR0   = $3C   ;Timer0  Output Compare Register
.EQU MCUCR  = $35   ;MCU     Control Register
.EQU SPL    = $3D   ;Stack Low  Part
.EQU SPH    = $3E   ;Stack High Part
.CSEG
.ORG $00
rjmp RESET    ;1
.ORG $02
rjmp EXT_INT0 ;2
.ORG $04
rjmp EXT_INT1 ;3
.ORG $06
RETI          ;4
.ORG $08
RETI          ;5
.ORG $A
RETI          ;6
.ORG $C
RETI          ;7
.ORG $E
RETI          ;8
.ORG $10
RETI          ;9
.ORG $12
RETI          ;10
.ORG $14
RETI          ;11
.ORG $16
RETI          ;12
.ORG $18
RETI          ;13
.ORG $1A
RETI          ;14
.ORG $1C
RETI          ;15
.ORG $1E
RETI          ;16
.ORG $20
RETI          ;17
.ORG $22
RETI          ;18
.ORG $24
RETI          ;19
.ORG $26
RETI          ;20
.ORG $28
rjmp main     ;21
main:
  rjmp main         ;infinite loop

EXT_INT0:           ;Uout = Uin/4
  EOR r28, r30      ;r28[0]++ (INT0BIT++)
  SBRS r28, 0
  rjmp phase42      ;if r28[0] (INT0BIT) == 0 then phase42
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
    RETI

  phase42:          ;Uout = Uin/4 by 2 phases
    CLR r16
    OUT TCCR0, r16  ;TCCR0 = 0
    OUT TCCR2, r16  ;TCCR2 = 0
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
    LDI r16,   $80
    OUT TCNT2, r16  ;TCNT2 = $FF/2
    LDI r16,   $E0
    OUT OCR0,  r16  ;OCR0 = 224
    OUT OCR2,  r16  ;OCR2 = 224
    LDI r16,   $79
    OUT TCCR2, r16  ;TCCR2 = 01111001
    OUT TCCR0, r16  ;TCCR0 = 01111001
    RETI

EXT_INT1:           ;Uout = Uin/10
  EOR r29, r30      ;r29[0]++ (INT1BIT++)
  SBRS r29, 0
  rjmp phase102     ;if r29[0] (INT1BIT) == 0 then phase102
  phase10:          ;Uout = Uin/10 by 1 phase
    CLR r16
    OUT TCCR0, r16  ;TCCR0 = 0
    OUT TCCR2, r16  ;TCCR2 = 0
    OUT TCNT0, r16  ;TCNT0 = 0
    OUT TIFR,  r16  ;TIFR  = 0 
    LDI r16,   $E6  
    OUT OCR0,  r16  ;OCR0  = 230
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
    RETI

  phase102:         ;Uout = Uin/10 by 2 phases
    CLR r16
    OUT TCCR0, r16  ;TCCR0 = 0
    OUT TCCR2, r16  ;TCCR2 = 0
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
    RETI


RESET:
  LDI r30,   $01
  SBI DDRB,  3       ;DDRB [3] = 1 Direction for OC0
  SBI PORTD, 2       ;PORTD[2] = 1 Virtual resistor for INT0 button
  SBI PORTD, 3       ;PORTD[3] = 1 Virtual resistor for INT1 button
  SBI DDRD,  7       ;DDRD [7] = 1 Direction for OC2
  LDI r16,   $E0
  OUT GICR,  r16     ;GICR  = 11100000
  LDI r16,   $02
  OUT SPH,   r16     ;Stack high byte initialized
  LDI r16,   $5f
  OUT SPL,   r16     ;Stack low byte initialized
  CLR r16
  OUT MCUCR, r16     ;MCUCR = 0
  SEI                ;Allow interrupts
  rjmp main
