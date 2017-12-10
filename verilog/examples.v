// scramble: U F L' U' R F' D L D2 F R B2 L B2 R' F2 R2 B2 U2 R B2    
//                              |----centers-----|----edges----edges----edges----edges----edges----edges----edges----|----corners----corners----corners----corners----corners----corners-|
reg [161:0] cubestate_initial = {Y,Blue,Red,G,O,W,Y,O,Red,Red,Blue,W,G,Red,G,Blue,Y,G,O,Y,W,O,W,G,Red,Blue,O,Blue,Y,W,W,Blue,Y,W,W,G,Blue,Blue,Red,G,Blue,Red,W,Red,O,G,Red,Y,G,O,Y,O,O,Y};

// scramble: F' U2 F2 D2 B' R2 F' D2 F' L2 F2 R' U B' L R B F2 D' U
//                              |----centers-----|----edges----edges----edges----edges----edges----edges----edges----|----corners----corners----corners----corners----corners----corners-|
reg [161:0] cubestate_initial = {Y,Blue,Red,G,O,W,Red,O,G,Blue,Y,Y,Red,G,Red,W,G,O,O,Blue,W,O,Red,Blue,W,W,Blue,Y,Y,G,O,Blue,Red,G,Red,O,W,W,Y,W,G,G,O,Blue,Y,Y,G,Blue,Red,Blue,Y,W,O,Red};

// scramble: U' F2 R2 L F2 B L2 U2 R F' U' B2 R2 L2 D F2 U' L2 B2 U' L2
//                              |----centers-----|----edges----edges----edges----edges----edges----edges----edges----|----corners----corners----corners----corners----corners----corners-|
reg [161:0] cubestate_initial = {Y,Blue,Red,G,O,W,W,Y,G,Blue,O,Blue,Y,G,Red,Red,Red,O,Blue,G,Red,G,O,Y,Y,W,Blue,W,O,W,O,Blue,W,Y,Red,Blue,Blue,Red,Y,G,Red,O,W,W,G,Red,O,Y,O,G,Y,Blue,G,O};