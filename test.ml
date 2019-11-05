open OUnit2
open Ship
open Board
open Commands
open Player

module Player = PlayerMaker

module Board = BoardMaker

module Ship = ShipMaker


let board = Board.make_board 10 10
let ship_destroyer = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub = Ship.create [(2,1);(3,1)]
let player_1 = Player.init_player [ship_sub;ship_destroyer] board "Jon"

let test_ship_compare name ship1 ship2 expected_output = 
  name >:: 
  (fun _ ->
     assert_equal expected_output (Ship.compare ship1 ship2))

let ship_tests = [
  test_ship_compare "Tests two ships which are not equal" 
    ship_destroyer ship_sub GL

]

let board_tests = []

let command_tests = []

let player_tests = []

let suite = "test suite" >::: 
            List.flatten [ship_tests;board_tests;command_tests]

let _ = run_test_tt_main suite
