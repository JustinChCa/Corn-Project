open OUnit2
open Ship
open Board
open Commands

<<<<<<< Updated upstream
module S = ShipMaker
module B = BoardMaker

let ship_tests = []

let board_tests = []

let command_tests = []

let suite = "search test suite" >::: 
            List.flatten [ship_tests;board_tests;command_tests]

let _ = run_test_tt_main suite
=======
module Player = PlayerMaker

module Board = BoardMaker

module Ship = ShipMaker



let board = Board.make_board 10 10
let ship_destroyer = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub = Ship.create [(2,1);(3,1)]



let player_tests = [

]


let suite = "test suite" >::: List.flatten [


  ]

let _ = run_test_tt_main suite 
>>>>>>> Stashed changes
