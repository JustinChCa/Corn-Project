open OUnit2
open Ship
open Board
open Commands

module Player = PlayerMaker

module Board = BoardMaker

module Ship = ShipMaker

let board = Board.make_board 10 10
let ship_destroyer = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub = Ship.create [(2,1);(3,1)]


let ship_tests = []

let board_tests = []

let command_tests = []

let player_tests = []

let suite = "test suite" >::: 
            List.flatten [ship_tests;board_tests;command_tests]

let _ = run_test_tt_main suite
