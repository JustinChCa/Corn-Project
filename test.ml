(**Testing in our system is a bit unorthodox due to the fact that it's sorta 
   difficult to test mutability using OUnit2. That is why some test cases have 
   many assert statements, this is done to guarantee that OUnit does them in 
   this particular order. (Required for our battleship game to simulate turns).

   Testing Plan:

   We tested the core functions that we could test such as our ship attacks, 
   ship placements, ship creations, player creations, board creations, etc. 
   We could not for example test functions that were dependant on user input 
   from the terminal, or dependant upon a server running/ client communicating 
   with the server or that printed the player boards onto the terminal. This
   also includes our graphics and AI which cannot be tested by test cases.
   So, we instead relied on making sure that the core commands worked. If we
   could guarantee that our core commands worked, which every other function 
   that we could not necessarily test relied upon in some capacity, then we 
   know that our game does in fact work as it should and thus, should be 
   correct. So, we thus focused on testing those core commands that we could 
   test. We also extensively tested every other piece of functionality by
   playing our game numerous times. *)

open OUnit2
open Command


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

open Ship

let ship_attack_test name coordinate ship =  
  name >:: (fun _ ->   hit coordinate ship; assert_equal false 
               (calive coordinate ship))

let exception_test name exc func = 
  name >:: (fun _ -> assert_raises exc func)

let ship_isalive_test name expected_output ship = 
  name >:: (fun _ -> assert_equal expected_output 
               (print_endline "is_aliver asserT"; alive ship))

let ship_health_test name expected_output ship = 
  name >:: (fun _ -> assert_equal expected_output (health ship) 
               ~printer:string_of_int)

let ship_coordinates_test name expected_output ship = 
  name >:: (fun _ -> assert_equal expected_output (coordinates ship))

let ship_size_test name expected_output ship =
  name >:: (fun _ -> assert_equal expected_output (size ship))

let player_getships_test name expected_output player = 
  name >:: (fun _ -> assert_equal expected_output (Player.get_ships player))

let player_getname_test name expected_output player =
  name >:: (fun _ -> assert_equal expected_output (Player.get_name player))

let player_getboard_test name expected_output player =
  name >:: (fun _ -> assert_equal expected_output (Player.get_board player))

let command_orientation_test name expected_output str = 
  name >:: (fun _ -> assert_equal expected_output (Command.orientation str))

let command_coord_test name expected_output str = 
  name >:: (fun _ -> assert_equal expected_output (Command.find_coords str))

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

let sink_ship_test name= 
  name >:: (fun _ -> 

      hit (1,1) ship_destroyer; 

      assert_equal false  (calive (1,1) ship_destroyer); 
      assert_equal true (alive ship_destroyer);
      assert_equal 2 (health ship_destroyer);
      assert_equal true (Player.alive player);

      hit (1,2) ship_destroyer; 
      assert_equal false  (calive (1,2) ship_destroyer);
      assert_equal true  (alive ship_destroyer);
      assert_equal 1 (health ship_destroyer);

      hit (1,3) ship_destroyer; 
      assert_equal false  (calive (1,3) ship_destroyer);
      assert_equal false  (calive (1,1) ship_destroyer);
      assert_equal false  (calive (1,2) ship_destroyer);
      assert_equal false  (alive ship_destroyer);
      assert_equal 0 (health ship_destroyer);

      hit (2,1) ship_sub;
      assert_equal false (calive (2,1) ship_sub);
      assert_equal true (alive ship_sub);

      hit (3,1) ship_sub;

      assert_equal false (calive (2,1) ship_sub);
      assert_equal false (calive (3,1) ship_sub);
      assert_equal false (alive ship_sub);
      assert_equal false (Player.alive player))

let ship_alive_sub = Ship.create [(1,1);(1,2)]
let ship_alive_destroyer = Ship.create [(3,2);(4,2);(5,2)]
let ship_alive_overlap = Ship.create [(1,1)]

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
                             ship_alive_destroyer;ship_alive_overlap]

]

open Board

let board_1 () = 
  let board = Board.create 10 10 in 
  ignore (Board.place_ship board ship_destroyer); 
  board



let board_tests = [
  test_board_size "Tests board config of 10x10 board" 10 (Board.create 10 10);
  test_board_size "Tests board config of 20x20 board" 20 (Board.create 20 20);


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

]



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

  test_player_isalive "tests whether a player with no ships is alive; should
  return false" false (Player.create [] (Board.create 1 1) "p1");

  test_player_isalive "tests whether a player with one remaining ship is alive; 
  should return true" true (Player.create [ship_alive_sub] 
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
  command_coord_test "tests the boundaries; edge case" (0,25) "a26";
  command_coord_test "tests the boundaries; edge case" (25,25) "Z26";
  command_coord_test "edge case where there are random special characters
  in the middle; should return (25,25) still." (25,25) "Z----26";

  "tests a string thats not a coordinate" >:: 
  (fun _ -> assert_raises 
      (BadCoord "Bad coordinates, must be in the form of L.#.") 
      (fun () -> Command.find_coords "lol"));
  command_orientation_test "Tests orientation vertical orientation; 
    should return true" true "vertical";
  command_orientation_test "tests vertical orientation with string 'v'; 
  should return true." true "v";
  command_orientation_test "tests horizontal orientation with string 'h'; 
  should return false." false "h";
  command_orientation_test "Tests horizontal orientation; full word; 
    should return false" false "horizontal";
  command_orientation_test "Tests vertical orientation with white space;
    should return true" true "    vertical    ";

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
            List.flatten [ship_tests;board_tests;player_tests;command_tests]

let _ = run_test_tt_main suite
