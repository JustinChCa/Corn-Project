This game requires the packages unix, oUnit, str, and ANSITerminal installed.
To run, type "make play" in the directory main.ml is in.

TL;DR

1) Type an integer in the set (0,int_max) to create a square board with this side length.

2) Type player 1's name

3) Set player 1's board with ships. For each ship, repeat 3a-3b.

3a) The player will first choose an orientation for the ship, either "v" or "vertical" or "h" or "horizontal".

3b) The player must choose where the top-left coordinate of the ship will be on the map. This can be written in the form (letter)-(number), where (letter) is from A-Z and (number) is from (1, int_max) starting from the top left corner of the grid. It is not case-sensitive and whitespaces/other symbols can be in between the (letter) and (number).

4) Type player 2's name

5) Set player 2's board with ships. For each ship, repeat 3a-3b.

6) Players take turns attacking each others boards.

7) A player wins once their enemy's ships have all been destroyed.

-----------------------------------------------------------------------------

*INSTRUCTIONS FOR BATTLESHIP*

The first player is brought to the title screen with our graphic and the option to build a square board of a custom side length:

1) Type an integer in the set (0,int_max) to create a board of this size.

(*We plan to limit the min and max size of the board.*)

Then, the first player is prompted to input their name for identification purposes.

2) Type player 1's name

Once a name is given to the game, the game will display the empty board on which the player will place their ships. The ship that will be placed is idenitified at the top of the screen. The player will first give an orientation for the ship.

3) Set player 1's board with ships. For each ship, repeat 3a-3b.

3a) The player will first choose an orientation for the ship, either "v" or "vertical" or "h" or "horizontal".

3b) The player must choose where the top-left coordinate of the ship will be on the map. This can be written in the form (letter)-(number), where (letter) is from A-Z and (number) is from (1, int_max) starting from the top left corner of the grid. It is not case-sensitive and whitespaces/other symbols can be between the (letter) and (number).

When the first player finishes placing all their ships, the game will clear the screen and prompt the second player to interact with the system. First it will prompt the player to give a name then begin the placing ships cycle.

4) Type player 2's name

5) Set player 2's board with ships. For each ship, repeat 3a-3b.

Once the second player is done placing ships, the game prompts the first player to return to the screen and the game's REPL begins.


The player is presented with two boards and a command. The left board is the player's and the right board is the enemy's. The coordinate command is in the same format as before, (letter)-(number). Once the player attacks, the game provides text and visual feedback whether they hit or not and shows the updated boards. Then, the next player takes a turn.

6) Players take turns attacking each others boards.

When one player successfully destroys all enemy ships, once they press enter to continue, the game will provide text based feedback on who the winner was and end the program. 

7) A player wins once their enemy's ships have all been destroyed.