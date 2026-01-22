PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           
config RSTOSC = HFINTOSC_64MHZ 
config WDTE = OFF              
	
PSECT   code, abs
   
; Vecteur de reset =============================================================
org     0x000
goto init 
   
; Vecteur d'interruption haute priorite ========================================
org     0x008
goto High_ISR 

; Vecteur d'interruption basse priorite ========================================
org     0x018
goto Low_ISR 

; Programme principal ==========================================================
org 0x100   

init: 
    ; desactiver le mode analogique sur RB0 (LD0)
    banksel ANSELB
    bcf ANSELB,0,1                  ; RB0 en digital

    ; Configurer RB0 comme sortie du module PWM => PPS
    ; le module PWM3 peut sortir sur RB0 par RB0PPS
    ; Valeur 0x0C => PWM3OUT
    banksel RB0PPS
    movlw 0x0C                      ; PWM3 -> RB0
    movwf RB0PPS,1

    ; Configurer Timer2 comme base de temps du PWM
    ; On veut F_PWM = 125 Hz
    ; Formule : Fout = Fosc/(4 * prescaler * (PR2+1))
    ; Choix : prescaler = 64 → PR2 = 49
    banksel T2CLKCON
    movlw 0x01                       ; Clock = Fosc/4 = 16 MHz
    movwf T2CLKCON,1

    banksel T2CON
    movlw 0b00000110                 ; TMR2 prescaler = 1:64
    movwf T2CON,1

    banksel T2PR
    movlw 49                         ; PR2 = 49 -> 125 Hz
    movwf T2PR,1

    ; conf PWM3 module
    ; PWM3DCH:PWM3DCL = rapport cyclique * 4 bits
    ; duty = 20% => 0.20 * 200 = 40 => 40<<2 = 160 (0x00A0)
    banksel PWM3DCH
    movlw 0x00                       ; MSB
    movwf PWM3DCH,1

    movlw 0xA0                       ; LSB
    movwf PWM3DCL,1

    ; Activer PWM3
    ; PWM3EN = 1
    banksel PWM3CON
    bsf PWM3CON,7,1                  ; Activation PWM3

    ; Démarrer Timer2 (la PWM dépend de Timer2)
    banksel T2CON
    bsf T2CON,7,1                    ; TMR2ON = 1

    goto loop

loop:
    ; infinite loop
    goto loop

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end
