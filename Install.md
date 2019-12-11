-----------------------------INSTRUCTIONS FOR SINGLEPLAYER ------------------------------------------------------------
First, launch a terminal in the directory of the battleship game.

There are two ways of playing this game: the first is make play-graph which boots up the game using graphics. This is relatively easy to follow along with, just follow the on screen instructions. The second is through typing in make make play-text, which loads up the traditional text based version of our game. In both cases, you should be able to follow the on screen instructions for playing the game.

If you'd like in-depth instructions for playing the game, see the "in depth instructions for singleplayer" below, though this may not be necessary.




----------------------------- INSTRUCTIONS FOR MULTIPLAYER -----------------------------------------------------------------
To run the multiplayer set up on one computer (as that's how it's currently configured.):

First, you need to launch three terminals in the directory of battleship.

For the first terminal, type in "make server". This will initialize the server with your private/local ip address. 

For the next two terminals, type in "make client". If this server is running, you wll connect to the server and a waiting screen will be displayed.

The first turn belongs to the player who connected first, in your case, it will be the first terminal that connected to the server.
They will be prompted to set up their 3 ships. To place a ship down, type in the coordinate followed by the orientation (with a space between the coord and the orientation.) The orientation may be typed as either "v" or "vertical" or "h" or "horizontal". 
Example: "A3 v" or "A3 vertical" or "a3 vertical" etc. This will repeat for each of the three ships to configure.

After setting up your ships, the next player will be prompted to place down their ships.

Once both players have set up their ships, the first player will be allowed to attack first. 

To attack, simply type in the coordinate that you wish to attack.
 Example: "a5" or "A5" 

After you have attacked, the other player is prompted to attack and the first player is told to wait.
Rinse and repeat until there is a winner. (When all of a players ships have been destroyed.)


Extra Notes: 
If you type in multiple commands when its not your turn i.e. if you type for example a5, a6, a7 when its the other persons turn to hit,
then those commands will be sent in that order when it is your turn. This is a bug we plan to fix in the next sprint.



------------------- IN DEPTH INSTRUCTIONS FOR SINGLEPLAYER -----------------------------------

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

---LONG INSTRUCTIONS FOR SINGLEPLAYER --

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


