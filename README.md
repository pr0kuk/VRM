# VRM-Module MC Project
This repository is the 4th semester DREC MIPT Microcontrollers course Project<br>
The Project is a pulse voltage converter, based on ATmega32-16PU, capable of operating in four modes:<br>
*  Uout = Uin/4 - single phase
*  Uout = Uin/4 - dual phase
*  Uout = Uin/10 - single phase
*  Uout = Uin/10 - dual phase

The output voltage is directed to an LC filter, consisting of inductor-220uH and capacitor-47uF.<br>
Actual output voltage is 30% lower than theoretical due to 100 ohm filter loading,<br>lack of feedback, and because of the execution on the breadboard.<br>
For operation, the microcontroller uses two timers: Timer0 (for all modes) and Timer2 (for dual phase mode).<br>
To switch modes, there are two buttons connected to the inputs INT0 and INT1.<br>
Activating the INT0 button toggles between modes 1 and 2, INT2 toggles 3 and 4<br>

Usbasp and Avrdude was used for programming MK, avra was used for compiling program<br>

*Authors: Alexey Shcherbakov & Mikhail Gonzyukh & Irina Pavlova*
