;controls a single motor through a L9110s motor controller
;a universal remote set up to send Sony 12 bit codes is used
;I used a Sony TV setting
;runs motor in forward when UP key on remote is pushed
;runs motor in reverse when UP key on remote is pushed
;stops motor when OK(ENTER) key is pressed
;keys 0 - 9 set the motor speed (9 = full speed or 100% duty cycle)
;ir sensor on C.3 (physical leg 4)
;L9110s_IA on C.1 (physical leg 6)
;L9110s_IB on C.2 (physical leg 5)

#terminal 4800				; Use the terminal for display


;#define sim	;unremark this line if you want to test in simulator

;CONSTANTS
#ifndef sim
;ir remote codes
symbol UP = 116
symbol DOWN = 117
SYMBOL LEFT = 52
symbol RIGHT = 51
symbol ENTER = 101
#else
;simulator remote
symbol UP = 16
symbol DOWN = 17
SYMBOL LEFT = 19
symbol RIGHT = 18
symbol ENTER = 37	;+ key in sim
#endif


symbol ir_cmd = b4
symbol motor_state	= b5;0 = motor stopped / 1 = motor running forward / 2 = motor running reverse
symbol temp = b6
symbol pwm_val_hi = w13
symbol pwm_val_lo = w12
high C.1'
'high C.2
pwm_val_hi = 400	' 100 per cent duty cycle with period of 99
pwm_val_lo = 0
pwmout PWMDIV64,C.2, 99, pwm_val_hi	'hi
motor_state = 0

main:
irin C.3,ir_cmd				; Read IR key press
sertxd( "Key code = ", #ir_cmd, cr, lf )	; Report which key was pressed

if ir_cmd = UP then gosub motorForward
if ir_cmd = DOWN then gosub motorReverse
if ir_cmd = ENTER then gosub motorStop

if ir_cmd < 10 then gosub motorSpeed	;number keys 0 - 9 to set speed

goto main				; Repeat

motorForward:
	if motor_state = 1 then doneFor
	gosub motorStop
	low C.1
	'high C.2
	pwmduty C.2,pwm_val_hi
	motor_state = 1
doneFor:
	return
motorReverse:
	if motor_state = 2 then doneRev
	gosub motorStop
	'low C.2
	pwmduty C.2,pwm_val_lo
	high C.1
	motor_state = 2
doneRev:
	return
motorStop:
	high C.1
	'high C.2
	pwmduty C.2,400
	motor_state = 0
	return	
motorSpeed:	'need a value between 0 and 396 (4 * 199) for duty cycle
	lookup ir_cmd,(20,28,38,48,58,67,77,87,100,10),temp
	pwm_val_hi = temp * 4
	pwm_val_lo = 400 - pwm_val_hi
	
	if motor_state = 0 then doneSet
	if motor_state = 1 then
		pwmduty C.2,pwm_val_hi
	elseif motor_state = 2 then
		pwmduty C.2,pwm_val_lo
endif

doneSet:
	sertxd( "pwm = ", #pwm_val_hi, cr, lf )
	return