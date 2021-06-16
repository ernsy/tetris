# Tetris
Solution to the DRW trading coding challenge done in Elixir.

Intended to be used from the command line, will read from stdin and output to stdout ex:

`./tetris < input.txt > output.txt`

The lines of the input file are seperated by commas. Every element in the list is letter 
representing the shape and an integer. The integer is the column in which the shape is dropped.
The ouput is the maximum height of the final game board.

## Installation

Unfortunately Elixir does require Erlang to be installed to run escripts.
The tetris escript binary has been included, but it will require that Erlang 24 is installed on the host machine.
Should that version of Erlang not be available the script can be compiled by running the following command 
from the root directory of the project. This will however require that Elixir package for the OS is installed 
which contains the mix build tool

`mix escript.build` 

and then ran with:

`./tetris < input.txt > output.txt`

where input.txt has input like
```
Q0
Q0,Q1
``` 

## Testing

To tun the doc and unit tests simply run the following command from the root dir of this project.

`mix test`

The output will be several lines showing test inputs and the a visual representation of the final game grid.
A `1` in the grid represents a block being present.

```
Test input:
 ["Q0", "I2", "I6", "I0", "I6", "I6", "Q2", "Q4"]
Game grid:
[0, 0, 1, 1, 0, 0, 0, 0, 0, 0]
[0, 0, 1, 1, 0, 0, 0, 0, 0, 0]
[1, 1, 0, 0, 1, 1, 1, 1, 1, 1]
...

Finished in 0.06 seconds (0.00s async, 0.06s sync)
2 doctests, 1 test, 0 failures
```

