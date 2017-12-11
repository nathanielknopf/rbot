# rbot - A Rubik's Cube Solving Robot, Implemented on a Nexys 4 FPGA
## 6.111 Fall 2017 Final Project - Jacob Swiezy, Nathaniel Knopf

### Overview
There's a robot. It can turn a Rubik's Cube, and has two color sensors. One at the FDL corner sticker (front bottom left), and one at the FD edge sticker (front bottom). By turning observing the colors at these locations while a scrambled Rubik's Cube is turned, the starting state of the Rubik's Cube can be determined. This information is stored in a 162 bit register called "cubestate."

A module called solving algorithm then uses "cubestate" to generate a series of moves to solve the Rubik's Cube using an implementation of the human algorithm called "The Beginner's Method" (or "Green Cross"). This is accomplished through the use of a FSM where the state represents the step of the method being executed. In each state, different patterns are identified, and corresponding sequences of moves to manipulate the Rubik's Cube in desired way are exported by the solving algorithm module.

The sequencing module then collects these moves and sends them to the robot, which executes them on the Rubik's Cube to solve it.