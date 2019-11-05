open OUnit2
open Commands


module Player = Player.PlayerMaker

module Board = Board.BoardMaker

module Ship = Ship.ShipMaker

let board = Board.make_board 10 10
let ship_destroyer = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub = Ship.create [(2,1);(3,1)]
let player = Player.init_player [ship_destroyer; ship_sub] board "player 1"

open Ship
let ship_tests = [

  "is_empty against empty" >:: (fun _ -> assert_equal true (is_empty empty));
  "is empty against nonempty" >:: 
  (fun _ -> assert_equal false (is_empty ship_sub));

  "size with empty is 0" >:: (fun _ -> assert_equal 0 (size empty));
  "size with destroyer is 3" >:: (fun _ -> assert_equal 3 (size ship_destroyer));
  "size with sub is 2" >:: (fun _ -> assert_equal 2 (size ship_sub));



]

let board_tests = []

let command_tests = []

let player_tests = []

let suite = "test suite" >::: 
            List.flatten [ship_tests;board_tests;command_tests]

let _ = run_test_tt_main suite
