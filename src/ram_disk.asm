          .include "io.inc65"
					.include "ewoz.asm"

          .autoimport	on
        	.case		on
        	.debuginfo	off
        	.importzp	sp, sreg, regsave, regbank
        	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
        	.macpack	longbranch


					.import _acia_init
					.import _acia_putc
					.import _acia_getc
					.import _acia_puts
					.import _lcd_w_reg
					.import _acia_put_newline
          .import _print_f

					.export _print_help
					.export _bootloader_

radek = tmp4

					.segment "RODATA"
msg_0:			.byte "APPARTUS P65 Bootloader", $00
msg_1:			.byte "Cekam na data", $00
msg_2:			.byte "Pro napovedu stiskni H, bez CR LF.", $00
msg_3:			.byte "w = kazdy nasledujici byte zapise do pameti na pozici h6000 - h7FFF. Po prijeti vsech bytu se novy program spusti z pameti.", $00
msg_4:			.byte "r = posle na seriovou linku data z pameti h6000 - h7FFF.", $00
msg_6:			.byte "m = spusti EWOZ Monitor.", $00
msg_5:			.byte "s = Spusti program z pozice reset vectoru nacteneho programu na adrese h7FFC,hFFD.", $00
msg_7:			.byte "Priklady prikazu pro EWOZ monitor:", $00
msg_8:			.byte "FFF0 vypise HEX hodnotu na adrese pameti hFFF0", $00
msg_9:			.byte "2000:FF zapise FF do pameti na adresu h2000", $00
msg_10:			.byte "2000.200F vypise HEX hodnoty z adres h2000-h200F", $00
msg_11:			.byte "Cisla 0-2 zmeni banku do ktere se program bude nahravat", $00
msg_12:			.byte "Cekam na data do BANK!", $00



					.segment "CODE"

_bootloader_:	JSR _acia_put_newline
				LDA #<(msg_0)
				LDX #>(msg_0)
        JSR _print_f

				LDA #<(msg_2)
				LDX #>(msg_2)
        JSR _print_f

_loop:			JSR _acia_getc

				CMP #'w'
				BEQ _start_write
        CMP #'W'
        BEQ _start_write_BANK

				CMP #'r'
				BEQ _start_read
        CMP #'R'
				BEQ _start_read_BANK

				CMP #'H'
				BEQ _start_help

				CMP #'s'
				BEQ _start_program
        CMP #'S'
				BEQ _start_program_BANK

				CMP #'m'
				BEQ _start_ewoz

        CMP #'0'
				BEQ _switch_b0

        CMP #'1'
        BEQ _switch_b1

        CMP #'2'
				BEQ _switch_b2

        CMP #'3'
        BEQ _switch_b3

        CMP #'4'
        BEQ _switch_b4

        CMP #'5'
        BEQ _switch_b5

        CMP #'6'
        BEQ _switch_b6

        CMP #'7'
        BEQ _switch_b7

				JMP	_loop

_start_program:	JMP (RAMDISK_RESET_VECTOR)
_start_program_BANK:	JMP (BANKDISK_RESET_VECTOR)
_start_ewoz:	JMP _EWOZ
_start_help:	JMP _print_help
_start_read:	JMP _read_RAM
_start_read_BANK:	JMP _read_BANK
_start_write:	JMP _write_to_RAM
_start_write_BANK:	JMP _write_to_BANK

_switch_b0: LDA #0
            STA $CE00
            JMP _loop
_switch_b1: LDA #1
            STA $CE00
            JMP _loop
_switch_b2: LDA #2
            STA $CE00
            JMP _loop
_switch_b3: LDA #3
            STA $CE00
            JMP _loop
_switch_b4: LDA #4
            STA $CE00
            JMP _loop
_switch_b5: LDA #5
            STA $CE00
            JMP _loop
_switch_b6: LDA #6
            STA $CE00
            JMP _loop
_switch_b7: LDA #7
            STA $CE00
            JMP _loop

_print_help:
                LDA #<(msg_3)
				        LDX #>(msg_3)
JSR _print_f
				LDA #<(msg_4)
				LDX #>(msg_4)
JSR _print_f
				LDA #<(msg_5)
				LDX #>(msg_5)
JSR _print_f
				LDA #<(msg_6)
				LDX #>(msg_6)
JSR _print_f
				LDA #<(msg_7)
				LDX #>(msg_7)
JSR _print_f
				LDA #<(msg_8)
				LDX #>(msg_8)
JSR _print_f
				LDA #<(msg_9)
				LDX #>(msg_9)
JSR _print_f
				LDA #<(msg_10)
				LDX #>(msg_10)
JSR _print_f
        LDA #<(msg_11)
        LDX #>(msg_11)
JSR _print_f
				JMP _loop



_write_to_RAM:	LDA #<(msg_1)
				LDX #>(msg_1)
				JSR _acia_puts

				LDY #0
				LDA #<(RAMDISK)
				LDX #>(RAMDISK)
				STA ptr1
				STX ptr1 + 1

@write:			JSR _acia_getc
				;JSR _lcd_putc
				STA (ptr1), Y
				INY
				CPY #$0
				BNE @end
				INX
				STX ptr1 + 1
				CPX #$80
				BNE @end
				JMP (RAMDISK_RESET_VECTOR)
@end:			JMP @write

_go_loop:		JMP _loop

_read_RAM:
				LDY #0
				LDA #<(RAMDISK)
				LDX #>(RAMDISK)
				STA ptr1
				STX ptr1 + 1
@read:			LDA (ptr1),Y
				JSR _acia_putc
				INY
				CPY #$0
				BNE @read
				INX
				STX ptr1 + 1
				CPX #$80
				BEQ _go_loop
@end:			JMP @read


_write_to_BANK:	LDA #<(msg_12)
				LDX #>(msg_12)
				JSR _acia_puts

				LDY #0
				LDA #<(BANKDISK)
				LDX #>(BANKDISK)
				STA ptr1
				STX ptr1 + 1

@write_BANK:			JSR _acia_getc
				;JSR _lcd_putc
				STA (ptr1), Y
				INY
				CPY #$0
				BNE @end_BANK
				INX
				STX ptr1 + 1
				CPX #$C0
				BNE @end_BANK
				JMP (BANKDISK_RESET_VECTOR)
@end_BANK:			JMP @write_BANK



_read_BANK:
				LDY #0
				LDA #<(BANKDISK)
				LDX #>(BANKDISK)
				STA ptr1
				STX ptr1 + 1
@read_BANK:			LDA (ptr1),Y
				JSR _acia_putc
				INY
				CPY #$0
				BNE @read_BANK
				INX
				STX ptr1 + 1
				CPX #$C0
				BEQ _go_loop
@end_BANK:			JMP @read_BANK
