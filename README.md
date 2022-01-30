# Single-motor-3-function-toy-robot-Picxae-08M2-version
Picaxe basic code and pcb files for a single motor ir controlled 3d printed robot toy. There are 3 files:

IR_motor_3_func.bas is the code that runs the toy.

IR_motor_for_rev.bas take commands from the ir remote and run the motor. It's for testing the board.

ir_test.bas will send commands from the remote to the terminal in the Picaxe IDE. It's for checking the commands the remote is sending. If you can't find a setting in your universal remote that sends the commands the program is expecting, you can change the commands the Picaxe responds to in the IR_motor_3_func.bas program to the commands your remote is sending.
