.DEVICE atmega8
.EQU PORTC = $15
.EQU DDRC  = $14
.EQU PINC  = $13
.EQU SREG  = $3f
.EQU ADCSRA =$06
.EQU OCR2   =$23
.EQU TCNT2  =$24
.EQU TCCR2  =$25
.EQU TCNT0  =$32
.EQU TCCR0  =$33
.EQU TIFR   =$38
.EQU TIMSK  =$39
.EQU OCR0   =$3C  
.CSEG
rjmp RESET

main:
  IN r16, ADCSRA
  SBRC r16, 7
  rjmp CODE4
  rjmp main; infinite loop

INT0: ;Uout = Uin/4
  EOR r28, r30 ;INT0BIT++;
  SBRC r28, 0
  rjmp phase42
  1phase4:
    CLR r16
    OUT TCNT0, r16
    OUT TCNT2, r16
    OUT TCCR2, r16
    OUT TIFR,  r16
    LDI r16,   $C0   ;OCR0  = 192 192 = 0xC0 timer2 counter
    OUT OCR0,  r16
    LDI r16,   $79   ;TCCR0 = 01111001
    OUT TCCR0, r16
    LDI r16,   $01   ;TIMSK = 00000001
    OUT TIMSK, r16
    RETI

  phase42:
    CLR r16
    OUT TCNT0, r16
    OUT TCNT2, r16
    OUT TCCR2, r16
    OUT TIFR,  r16
    LDI r16,   $D6  ;OCR0  = 230.4 230 = 0xD6
    OUT OCR0,  r16
    LDI r16,   $79  ;TCCR0 = 01111001
    OUT TCCR0, r16
    LDI r16,   $01  ;TIMSK = 00000001
    OUT TIMSK, r16
    RETI

INT1: ;Uout = Uin/10
  EOR r29, r30 ;INT1BIT++;
  SBRC r29, 0
  rjmp phase102
  1phase10:
    CLR r16
    OUT TCNT0, r16
    OUT TIFR,  r16
    LDI r16,   $81  ;TCNT2 = 129 129 = 0x81
    OUT TCNT2, r16
    LDI r16,   $D   ;OCR0  = 224 224 = 0xD
    OUT OCR0,  r16
    LDI r16,   $D   ;OCR2  = 224 224 = 0xD
    OUT OCR2,  r16
    LDI r16,   $79
    OUT TCCR0, r16  ;TCCR0 = 01111001
    OUT TCCR2, r16  ;TCCR2 = 01111001
    LDI r16,   $01  ;TIMSK = 00000001
    OUT TIMSK, r16
    RETI

  phase102:
    CLR r16
    OUT TCNT0, r16
    OUT TIFR,  r16
    LDI r16,   $81  ;TCNT2 = 129 129 = 0x81
    OUT TCNT2, r16
    LDI r16,   $E3  ;OCR0  = 243 243 = 0xE3
    OUT OCR0,  r16
    OUT OCR2,  r16  ;OCR2  = 243 243 = 0xE3
    LDI r16,   $79  ;TCCR0 = 01111001
    OUT TCCR0, r16
    OUT TCCR2, r16  ;TCCR2 = 01111001
    LDI r16,   $01  ;TIMSK = 00000001
    OUT TIMSK, r16
    RETI

INT2: ;ADC ON
  EOR  r31, r30; ADCBIT++
  LDI  r16, $EF
  SBRS r31, 0
  OUT ADCSRA, r16
  CLR  r16
  SBRC r31, 0
  OUT ADCSRA, r16
  RETI

CODE4:
  inc  r27
  mov  r16, r18
  andi r16, $f0
  ori  r16, 1
  out  PORTC, r16
  sbi  PORTC, 2
  cbi  PORTC, 2
  ;rcall del
  CPI  r27, $04
  BREQ SHIFT
  ret

SHIFT:
  LDI r16, $02
  OUT PORTC, r18
  SBI PORTC, 2
  CBI PORTC, 2
  clr r27
  ret

RESET:
  LDI r30, $01
  SER r16
  OUT DDRC, r16
  SEI
  rjmp main
  
  
  
  ;155 str CLI PORTC, 2 ???
