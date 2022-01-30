;controls a single motor toy robot through a L9110s motor controller
;a universal remote set up to send Sony 12 bit codes is used
;I used a Sony TV setting
;runs the toy forward (both wheels driven) when UP key on remote is pushed
;runs the toy left (right wheel forward, left wheel not driven) when LEFT key on remote is pushed
;runs the toy right (left wheel forward, right wheel not driven) when RIGHT key on remote is pushed
;stops toy when OK(ENTER) key is pressed
;keys 0 - 9 set the motor speed (9 = full speed or 100% duty cycle)
;the motor is run at full speed in reverse(100% duty cycle) so the cam indexing isn't slowed down 
;ir sensor on C.3 (physical leg 4)
;L9110s_IA on C.1 (physical leg 6)
;L9110s_IB on C.2 (physical leg 5)

;sony ir codes
;UP   116
;DOWN 117
;LEFT 52
;RIGHT 51
;ENTER 101

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

symbol NUMOFINDEXES = 3
symbol DEBOUNCETARGET = 3



;variables
symbol debounce_flag = bit0
symbol ir_cmd = b4
symbol motor_state	= b5;0 = motor stopped / 1 = motor running forward / 2 = motor running reverse
symbol current_dir = b6
symbol new_dir = b7
symbol debounce_cnt = b8
symbol temp = b9
symbol pwm_val_hi = w13
symbol pwm_val_lo = w12

symbol CAM_SWITCH = pinC.4

#terminal 4800				; Use the terminal for display

high C.1'
'high C.2
pwm_val_hi = 400	' 100 per cent duty cycle with period of 99
pwm_val_lo = 0
pwmout PWMDIV64,C.2, 99, pwm_val_hi	'hi
motor_state = 0
current_dir = 0
new_dir = current_dir


main:
irin C.3,ir_cmd				; Read IR key press
sertxd( "Key code = ", #ir_cmd, cr, lf )	; Report which key was pressed

select case ir_cmd
	case UP		;forward
		if motor_state <> 0 then gosub motorStop
		new_dir = 0
		gosub gotoNewDirection
	case LEFT
		if motor_state <> 0 then gosub motorStop
		new_dir = 2
		gosub gotoNewDirection
	case RIGHT
		if motor_state <> 0 then gosub motorStop
		new_dir = 1
		gosub gotoNewDirection
	case ENTER	;stop
		gosub motorStop
	case 0 to 10
		gosub motorSpeed
	else
	
	endselect

goto main				; Repeat


motorIndex:
;start the motor in reverse and wait for the switch to be hi for 3 passes then low for 3 passes
	gosub motorReverse
	debounce_flag = 1
	debounce_cnt = 0
	do
		if CAM_SWITCH != 0 then
			inc debounce_cnt
			if debounce_cnt > DEBOUNCETARGET then
				debounce_flag = 0
			endif
		else
			debounce_cnt = 0
		endif
	loop while debounce_flag = 1

	debounce_flag = 1
	debounce_cnt = 0
	
	do
		if CAM_SWITCH = 0 then
			inc debounce_cnt
			if debounce_cnt > DEBOUNCETARGET then
				debounce_flag = 0
			endif
		else
			debounce_cnt = 0
		endif
	loop while debounce_flag = 1

	gosub motorStop
	return
gotoNewDirection:
	do while current_dir <> new_dir
		gosub motorIndex
		inc current_dir
		if current_dir = NUMOFINDEXES then
			current_dir = 0
		endif
	loop 
	gosub motorForward
	return
	
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
	pwmduty C.2,0
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