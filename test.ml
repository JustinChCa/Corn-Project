open OUnit2
open Ship
open Board
open Commands

module S = ShipMaker
module B = BoardMaker

let ship_tests = []

let board_tests = []

let command_tests = []

let suite = "search test suite" >::: 
            List.flatten [ship_tests;board_tests;command_tests]

let _ = run_test_tt_main suite