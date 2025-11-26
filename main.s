; ==============================================================================
; Le Bouton B0 est connecté au port RA7
; Le Bouton B1 est connecté au port RA6
; L'état logique dès que B0 ou B1 est enfoncé est 0
; ==============================================================================
PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog timer
	
PSECT   code, abs
   
; Variables en mémoire =========================================================
msb equ 0x20                   ; MSB du compteur de délai
lsb equ 0x21                   ; LSB du compteur de délai
leds equ 0x22                  ; Position actuelle du chenillard (0-7)
direction equ 0x23             ; Direction -> 0=montant, 1=descendant
led_pattern equ 0x24           ; Motif LED à afficher
counter equ 0x25               ; Compteur temporaire
 
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

; Initialisation ===============================================================
init:
    banksel TRISC
    clrf TRISC              ; PORTC en sortie
    
    banksel LATC
    clrf LATC               ; Éteindre toutes les LEDs
    
    banksel ANSELC
    clrf ANSELC             ; PORTC en mode digital
    
    banksel TRISA
    bsf TRISA, 6            ; RA6 en entrée (B1)
    bsf TRISA, 7            ; RA7 en entrée (B0)
    
    banksel WPUA
    bsf WPUA, 6             ; Pull-up sur RA6
    bsf WPUA, 7             ; Pull-up sur RA7
    
    banksel ANSELA
    bcf ANSELA, 6           ; RA6 en mode digital
    bcf ANSELA, 7           ; RA7 en mode digital
    
    banksel leds
    clrf leds               ; Position initiale : LED 0
    clrf direction          ; Direction initiale : montante (0)
    
; Boucle principale ============================================================
loop:
    call check_buttons      ; Vérifier l'état des boutons
    call update_chenillard  ; Mettre à jour le chenillard
    call soft_delay         ; Attendre 65536 itérations
    goto loop               ; Boucle infinie

;routine : Vérification de l'état des boutons
check_buttons:
    banksel PORTA
    
    btfsc PORTA, 7          ; Skip si RA7 = 0 (B0 appuyé)
    goto check_b1           ; B0 non appuyé, vérifier B1
    
    banksel direction
    clrf direction          ; direction = 0
    goto check_buttons_end
    
check_b1:
    banksel PORTA
    btfsc PORTA, 6          ; Skip si RA6 = 0 (B1 appuyé)
    goto check_buttons_end  ; B1 non appuyé
    
    banksel direction
    movlw 1
    movwf direction         ; direction = 1
    
check_buttons_end:
    return

; Sous-routine : MàJ du chenillard
update_chenillard:
    banksel leds
    movlw 1
    movwf led_pattern       ; Commencer avec 0b00000001
    
    movf leds, W
    movwf counter           ; counter = nombre de décalages
    
    movf counter, F
    btfsc STATUS, 2         ; Z=1 si counter=0
    goto display_led
    
shift_loop:
    bcf STATUS, 0           
    rlcf led_pattern, F     ; Décalage à gauche
    decfsz counter, F       ; Décrémenter compteur
    goto shift_loop
    
display_led:
    banksel LATC
    movf led_pattern, W
    movwf LATC              ; Allumer la LED correspondante sur PORTC
    
    banksel direction
    movf direction, W
    btfsc STATUS, 2         ; Z=1 si direction=0 (montant)
    goto ascending
    goto descending
    
ascending:
    banksel leds
    incf leds, F            ; leds++
    movlw 8
    cpfseq leds             ; Si leds == 8
    goto update_end
    clrf leds               ; Retour à 0
    goto update_end
    
descending:
    banksel leds
    movf leds, W
    btfsc STATUS, 2         ; Z=1 si leds=0
    goto wrap_to_7
    decf leds, F            ; leds--
    goto update_end
    
wrap_to_7:
    movlw 7
    movwf leds              ; Aller à 7
    
update_end:
    return

; Sous-routine : Délai logiciel (65536 itérations)
soft_delay:
    banksel lsb
    clrf lsb                ; LSB = 0
    clrf msb                ; MSB = 0
    
delay_loop:
    incf lsb, F             
    btfss STATUS, 2         ; Skip si overflow (LSB = 0 après 255)
    goto delay_loop         ; Pas d'overflow, continuer
    
    incf msb, F             
    btfss STATUS, 2         ; Skip si MSB = 0 (overflow complet)
    goto delay_loop         ; Continuer
    
    return

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end
