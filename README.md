# rbot
6.111 Fall 2017 Final Project - Rubik's Cube Solving Robot
Jacob Swiezy, Nathaniel Knopf

## How to Use this Project
Don't. Like seriously, this is *totally* fucked, man.

## How this Project Works
It doesn't.

#### But actually?
There's a robot. It can turn a Rubik's Cube, and has two color sensors. One at the FDL corner sticker, and one at the FD edge sticker. By turning a scrambled Rubik's Cube and paying attention to what those sensors say, the robot can figure out what the scrambled state of the Rubik's Cube is. This information is stored in a 162 bit register called "cubestate."

A module called solving algorithm then generates a series of moves to solve the Rubik's Cube using a bastardization of the human-y method called "The Beginner's Method" (also called "Green Cross").

The robot collects these moves and then executes them, and provided that it doesn't jam up the cube (there is no feedback here) the Rubik's Cube gets solved. Hopefully.
