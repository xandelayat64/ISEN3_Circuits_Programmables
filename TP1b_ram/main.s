;la LED LD0 est reliée au port RC0
;les LED LDx sont reliées aux ports RCx

PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer

PSECT   code, abs
   
lsb equ 0x20
msb equ 0x21
leds equ 0x22
   
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
    clrf LATC
    clrf 0x20
    clrf 0x21
    movf lsb, 0x00  ;initialisation de l'octet de poid faible
    movf msb, 0x00  ;initialisation de l'octet de poid fort
    movf 0x23, 0x00
    movf leds, 0x00
    
    clrf TRISC	    ;config des sorties du port C
    
    ;movwf msb
    ;call led
    call loop_lsb
    goto loop
    
led:
    ;movwf msb
    movff msb, PORTC	;envoyer la valeur de l'octet msb et l'envoyer au PORTC afin d'alluer les LEDs correspondantes
    return
    
loop_lsb:
    infsnz lsb	    ;incrementer le bit de poid faible, continue la loop si bit != 0
    return	    ;arrêter la loop_lsb
    goto loop_lsb   ;continuer la loop_lsb
    
    
loop:
    ; Boucle infinie
    incf msb		;incrémentation de l'octet de poid fort
    call led
    
    ;appels de boucles pour prolonger le temps d'attente
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    call loop_lsb
    goto loop

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end
