(**Testing Plan:

   We tested the core modules such as Player, Ship, Commands, Board, and some 
   of the AI module. We focused on testing the core commands that were heavily 
   utilized by other functions (which we could not test, more on that
   later) that were dependenant upon the functionality of these core functions. 
   In testing these core functions such as ship attacking, ship placement, ship
   creations, player creations, etc in their respective modules, we could 
   guarantee that the underlying mechanisms for the battleship game were indeed 
   working, and if those core functions worked, then we could easily test the
   other functions that relied on them by manually playing the game. This would
   prove their correctness since we have already guaranteed that the underlying
   functions have worked by the test cases provided in this OUnit file. This is 
   true for modules and functions such as Graphics, Client, Server, and AI 
   functions. We can't test the display and the server or AI randomness
   so we instead tested the underlying mechanisms that those functions used. 

   In creating these test cases, we utilized a black box approach. Just from
   the specification of what the functions are supposed to do, we tested various 
   valid inputs and invalid inputs for each function against the appropriate
   outputs. Additionally, we did make use of some glass box testing by testing
   the specific exception messages that should be raised when a function 
   encounters some extremely unlikely scenario, which we could only know by 
   looking at the actual code.


*)
open OUnit2
open Command
open Ship
open Board




module Player = Player.PlayerMaker

module Board = Board.BoardMaker

module Ship = Ship.ShipMaker


let board = Board.create 10 10
let ship_destroyer = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub = Ship.create [(2,1);(3,1)]
let ship_overlap = Ship.create[(2,1)]
let player = Player.create [ship_destroyer; ship_sub] board "player 1"


let test_board_placement name board ship lst= 
  ignore (Board.place_ship board ship );
  name >:: (fun _ -> assert_equal lst (Board.taken board lst))

let test_player_isalive name expected_output player = 
  name >:: (fun _ -> assert_equal expected_output (Player.alive player))


let test_board_size name expected_output board = 
  name >:: (fun _ -> assert_equal expected_output (Board.columns board))


let ship_attack_test name coordinate ship =  
  name >:: (fun _ ->   ignore (Ship.hit coordinate ship); assert_equal false 
               (Ship.calive coordinate ship))

let exception_test name exc func = 
  name >:: (fun _ -> assert_raises exc func)

let ship_isalive_test name expected_output ship = 
  name >:: (fun _ -> assert_equal expected_output 
               (print_endline "is_aliver asserT"; Ship.alive ship))

let ship_health_test name expected_output ship = 
  name >:: (fun _ -> assert_equal expected_output (Ship.health ship) 
               ~printer:string_of_int)

let ship_coordinates_test name expected_output ship = 
  name >:: (fun _ -> assert_equal expected_output (Ship.coordinates ship))

let ship_size_test name expected_output ship =
  name >:: (fun _ -> assert_equal expected_output (Ship.size ship))

let player_getships_test name expected_output player = 
  name >:: (fun _ -> assert_equal expected_output (Player.get_ships player))

let player_getname_test name expected_output player =
  name >:: (fun _ -> assert_equal expected_output (Player.get_name player))

let player_getboard_test name expected_output player =
  name >:: (fun _ -> assert_equal expected_output (Player.get_board player))

let command_orientation_test name expected_output str = 
  name >:: (fun _ -> assert_equal expected_output (Command.orientation str))

let command_coord_test name expected_output str = 
  name >:: (fun _ -> assert_equal expected_output (Command.find_coords str)
               ~printer:(fun x -> match x with | v1,v2 -> 
                   "("^string_of_int v1^","^string_of_int v2^")"))

let board_getcoor_test name expected_output board coor = 
  name >:: (fun _ -> assert_equal expected_output (Board.get_coor board coor))

let board_placeship_test name expected_output ship = 
  name >:: (fun _ -> let board = Board.create 10 10 in assert_equal
               expected_output (Board.place_ship board ship))

(** decapracated.*)
let board_exception_test name = 
  name >:: (fun _ ->
      let board = Board.create 10 10 in
      let _ = Board.place_ship board ship_destroyer in 
      assert_raises (Invalid_argument "Ship is overlapping with another.") 
        (fun () -> Board.place_ship board ship_destroyer)
    )

let board_get_largest name expected_output ships = 
  name >:: (fun _ -> assert_equal expected_output (Ship.get_largest ships 0) 
               ~printer:string_of_int)

let ai_initboard_test name expected_output ai = 
  name >:: (fun _ -> assert_equal expected_output (Ai.AiMaker.get_board ai))


let sink_ship_test name= 
  name >:: (fun _ -> 

      ignore (Ship.hit (1,1) ship_destroyer); 

      assert_equal false  (Ship.calive (1,1) ship_destroyer); 
      assert_equal true (Ship.alive ship_destroyer);
      assert_equal 2 (Ship.health ship_destroyer);
      assert_equal true (Player.alive player);

      ignore (Ship.hit (1,2) ship_destroyer); 
      assert_equal false  (Ship.calive (1,2) ship_destroyer);
      assert_equal true  (Ship.alive ship_destroyer);
      assert_equal 1 (Ship.health ship_destroyer);

      ignore (Ship.hit (1,3) ship_destroyer ); 
      assert_equal false  (Ship.calive (1,3) ship_destroyer);
      assert_equal false  (Ship.calive (1,1) ship_destroyer);
      assert_equal false  (Ship.calive (1,2) ship_destroyer);
      assert_equal false  (Ship.alive ship_destroyer);
      assert_equal 0 (Ship.health ship_destroyer);

      ignore (Ship.hit (2,1) ship_sub);
      assert_equal false (Ship.calive (2,1) ship_sub);
      assert_equal true (Ship.alive ship_sub);

      ignore (Ship.hit (3,1) ship_sub );

      assert_equal false (Ship.calive (2,1) ship_sub);
      assert_equal false (Ship.calive (3,1) ship_sub);
      assert_equal false (Ship.alive ship_sub);
      assert_equal false (Player.alive player))

let ship_alive_sub = Ship.create [(1,1);(1,2)]
let ship_alive_destroyer = Ship.create [(3,2);(4,2);(5,2)]
let ship_alive_overlap = Ship.create [(1,1)]

let ship_attacked ()= 
  let ship = Ship.create [(0,0)] in 
  ignore (Ship.hit (0,0) ship); Ship.hit (0,0) ship

let ship_missed () = 
  let create_board = (Board.create 10 10) in 
  let _ = Ship.create [(0,0)] |> Board.place_ship create_board  in 
  ignore (Board.hit create_board (2,2)) ; Board.hit create_board (2,2)

let ship_tests = [
  ship_size_test "size with destroyer is 3" 3 ship_destroyer;
  ship_size_test "size with sub is 2" 2 ship_sub;
  ship_size_test "ship with no size; edge case" 0 (Ship.create []);
  ship_coordinates_test "tests the accuracy of the ship_destroyer coordinates" 
    [(1,1);(1,2);(1,3)] ship_destroyer;
  ship_coordinates_test "tests the accuracy of the ship_sub coordinates" 
    [(2,1);(3,1)] ship_sub;

  sink_ship_test  "Tests the ship hit commands as well as the ship alive 
  commands; after every hit, it checks to see that it indeed was hit. 
  Also verifies the ship health is the corrent output after every hit.
  Additionally also tests player commands due to the nature of mutability.";
  board_get_largest "tests the length of the largest ship inside an empty ship
  list; should be 0 " 0 [];

  board_get_largest "tests the length of the largest ship inside a ship
  list of 1; should be 2 " 2 [ship_alive_sub];

  board_get_largest "tests the length of the largest ship inside a ship
  list of 3. Edge case: ship list which contains overlapping ships. 
  The result should be 3" 3 [ship_alive_sub;
                             ship_alive_destroyer;ship_alive_overlap];

  exception_test "tests that an exception Hitted is raised when a player 
  attacks a coordinate that has already been attacked before." 
    (Hitted("This spot has already been hit")) (fun () -> ship_attacked ());

  exception_test "tests that an exception Missed is raised when a player 
  misses a coordinate that has already been missed before." 
    (Missed("You have already missed this spot.")) (fun () -> ship_missed ())






]


let board_1 () = 
  let board = Board.create 10 10 in 
  ignore (Board.place_ship board ship_destroyer); 
  board

let ai_tests = [
  ai_initboard_test "tests the initialization function of the AI module; checks
  to see if the correct board is returned when given two different boards" board 
    (Ai.AiMaker.ai_init 3 (board_1 ()) board [ship_destroyer]);
  ai_initboard_test "tests the initialization function of the AI module; checks
  to see if the correct board is returned when given two duplicate boards"
    (board_1 ()) (Ai.AiMaker.ai_init 3 (board_1 ()) (board_1 ()) 
                    [ship_destroyer])





]

let overlap_board () = 
  let board = Board.create 10 10 in 
  let ship = Ship.create [(1,1)] in 
  ignore (Board.place_ship board ship); 
  Board.taken board [(1,1)]

let already_missed () = 
  let board = Board.create 10 10 in 
  let ship = Ship.create [(1,1)] in 
  let _ = Board.place_ship board ship in 
  ignore (Board.hit board (1,1) ); Board.hit board (1,1)


let board_tests = [
  test_board_size "Tests board config of 10x10 board" 10 (Board.create 10 10);
  test_board_size "Tests extreme board config of 70x70 board" 70 
    (Board.create 70 70);


  board_placeship_test "tests placing down a ship that does not overlap
  and is not out of bounds." ship_destroyer ship_destroyer;
  board_placeship_test "tests placing down a small ship w/o
  issues." ship_sub ship_sub;
  board_getcoor_test "tests when theres a ship at coordinate (1,1) in the board"
    (Some ship_destroyer) (board_1 ()) (1,1);

  board_getcoor_test "tests when the same ship at a different coordinate (1,2). 
 Should return a Ship.t option." (Some ship_destroyer) (board_1 ()) (1,2);

  board_getcoor_test "tests when theres not a ship at coordinate (5,8) in the 
  board and theres another ship on the board."
    (None) (board_1 ()) (5,8);

  exception_test "tests whether get_coor will throw an out of bounds exception
  when given a coordinate (100,8)" (Invalid_argument("index out of bounds")) 
    (fun () -> Board.get_coor (board_1 ()) (100,8));

  exception_test "tests whether get_coor will throw an out of bounds exception
  when given a negative coord (-2,8)" (Invalid_argument("index out of bounds")) 
    (fun () -> Board.get_coor (board_1 ()) (-2,8));

  test_board_placement "Tests whether a coordinate on the board, which does not
  overlap with any ship, can be placed. Should return the list of ints [(5,2)]." 
    (Board.create 10 10) ship_destroyer [(5,2)];


  exception_test "tests whether an exception will be thrown, given a ship
     already on the board with the desired coords" 
    (Taken("Ship is overlapping with another.")) (fun () -> overlap_board ());

  exception_test "tests whether an exception will be thrown, when attacking a 
  ship thats already been attacked at the coordinate (1,1)" 
    (Hitted("This spot has already been hit")) (fun () -> already_missed ())


]

let ship_dead () =
  let ship = Ship.create [(0,0)] in 
  let board = Board.create 1 1 in
  let placed_ship = Board.place_ship board ship in 
  ignore (Board.hit board (0,0)); placed_ship 

let player_tests = [
  player_getships_test "player has only one ship of coordinate (1,1) in the 
  default empty player; tests if the function returns this ship." 
    [Ship.create [(1,1)]] Player.empty;

  player_getships_test "player has ship_destroyer and ship_sub ships; tests if
  the function returns these two ships." 
    [ship_destroyer; ship_sub] player;

  player_getships_test "player has no ships; tests if it returns no ships as 
  it's supposed to." 
    [] (Player.create [] (Board.create 1 1) "test");

  player_getboard_test "player has a board of size 10x10, checks to see if the
  function Player.get_board returns a board of size 10x10 from the player." 
    board player;

  player_getboard_test "empty player has a default board of size 1x1, checks to
  see if Player.get_board returns a board of size 1x1" 
    (Board.create 1 1) Player.empty; 

  player_getname_test "player has a name of 'player 1', tests to see if the 
  function Player.get_name returns the correct player name" "player 1" player;

  player_getname_test "expected to return an empty string; this
  is an edge case test" "" (Player.create [] (Board.create 1 1) "");

  test_player_isalive "tests whether a player with no ships in the board, 
  is alive; should be false" false (Player.create [] (Board.create 1 1) "p1");

  test_player_isalive "tests whether a player with one remaining ship is alive; 
  should return true" true (Player.create [ship_alive_sub] 
                              (Board.create 1 1) "p1");

  test_player_isalive "tests whether a player with one dead ship on the board is
  alive; should return false" false (Player.create [ship_dead ()] 
                                       (Board.create 1 1) "p1")




]

let command_tests = [
  command_coord_test "tests an ordinary, regular coordinate string" (0,4) "a5";
  command_coord_test "tests an ordinary coordinate string with all 
  caps" (0,4) "A5";
  command_coord_test "tests a regular coordinate string with all 
  caps and spaces before the coord; edge case" (0,4) "                A5";
  command_coord_test "tests a regular coordinate string with all 
  caps and spaces before and after the coord; edge case" (0,4) "       A5   ";
  command_coord_test "tests the boundaries on the last letter of the alphabet;
   edge case" (25,25) "Z26";
  command_coord_test "edge case where there are random special characters
  in the middle; should return (25,25) still." (25,25) "Z----26";

  "tests a string thats not a coordinate" >:: 
  (fun _ -> assert_raises 
      (BadCoord "Bad coordinates, must be in the form of L.#.") 
      (fun () -> Command.find_coords "lol"));

  command_coord_test "tests a string whose coordinates involve two letters at 
  the start; should return (27,5)" 
    (27,5) "ab6";

  command_orientation_test "Tests orientation vertical orientation; 
    should return false" false "vertical";
  command_orientation_test "tests vertical orientation with string 'v'; 
  should return false." false "v";
  command_orientation_test "tests horizontal orientation with string 'h'; 
  should return true." true "h";
  command_orientation_test "Tests horizontal orientation; full word; 
    should return true" true "horizontal";
  command_orientation_test "Tests vertical orientation with white space;
    should return false" false "    vertical    ";

  exception_test "tests whether an exception will be thrown, given a bad input
  to the command orientation function" 
    (Invalid_argument("Vertical or Horizontal only.")) 
    (fun () -> Command.orientation "lol");

  exception_test "tests whether an exception will be thrown, given an empty
     string to the command orientation function" 
    (Invalid_argument("Vertical or Horizontal only.")) 
    (fun () -> Command.orientation "")






]

let suite = "test suite" >::: 
            List.flatten [ship_tests;board_tests;player_tests;
                          command_tests;ai_tests]

let _ = run_test_tt_main suite
