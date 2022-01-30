#terminal 4800				; Use the terminal for display
main:
irin C.3,b2				; Read IR key press
sertxd( "Key code = ", #b2, cr, lf )	; Report which key was pressed
goto main