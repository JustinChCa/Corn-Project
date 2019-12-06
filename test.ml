(**Testing in our system is a bit unorthodox due to the fact that it's sorta 
   difficult to test mutability using OUnit2. That is why some test cases have 
   many assert statements, this is done to guarantee that OUnit does them in 
   this particular order. (Required for our battleship game to simulate turns).

   We tested the core functions that we could test such as our ship attacks, 
   ship placements, ship creations, player creations, board creations, etc. 
   We could not for example test functions that were dependant on user input 
   from the terminal, or dependant upon a server running/ client communicating 
   with the server or that printed the player boards onto the terminal.
   So, we instead relied on making sure that the core commands worked. If we
   could guarantee that our core commands worked, which every other function 
   that we could not necessarily test relied upon in some capacity, then we 
   know that our game does in fact work as it should and thus, should be 
   correct. So, we thus focused on testing those core commands that we could 
   test.  *)

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

let sink_ship_test = 
  "Tests the ship hit commands as well as the ship alive commands; after every
  hit, it checks to see that it indeed was hit. Also verifies the ship
  health is the corrent output after every hit.
  Additionally also tests player commands due to the nature of mutability." 
  >:: (fun _ -> 

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


let ship_tests = [
  ship_size_test "size with destroyer is 3" 3 ship_destroyer;
  ship_size_test "size with sub is 2" 2 ship_sub;
  ship_size_test "ship with no size; edge case" 0 (Ship.create []);
  ship_coordinates_test "tests the accuracy of the ship_destroyer coordinates" 
    [(1,1);(1,2);(1,3)] ship_destroyer;
  ship_coordinates_test "tests the accuracy of the ship_sub coordinates" 
    [(2,1);(3,1)] ship_sub;

  sink_ship_test

]

open Board


let board_tests = [
  test_board_size "Tests board config of 10x10 board" 10 (Board.create 10 10);
  test_board_size "Tests board config of 20x20 board" 20 (Board.create 20 20);

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
  "tests a string thats not a coordinate" >:: 
  (fun _ -> assert_raises 
      (BadCoord "Bad coordinates, must be in the form of L.#.") 
      (fun () -> Command.find_coords "lol"))





]

let suite = "test suite" >::: 
            List.flatten [ship_tests;board_tests;player_tests;command_tests]

let _ = run_test_tt_main suite
