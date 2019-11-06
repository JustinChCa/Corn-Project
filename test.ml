open OUnit2
open Commands


module Player = Player.PlayerMaker

module Board = Board.BoardMaker

module Ship = Ship.ShipMaker


let board = Board.make_board 10 10
let ship_destroyer = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub = Ship.create [(2,1);(3,1)]

let ship_destroyer_a = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub_a = Ship.create [(2,1);(3,1)]
let player_a = Player.init_player [ship_destroyer_a; ship_sub_a] board "player a"


let player = Player.init_player [ship_destroyer; ship_sub] board "player 1"



open Ship


let ship_attack_test name coordinate ship =  
  hit coordinate ship;
  name >:: (fun _ -> assert_equal false  (calive coordinate ship))




let ship_tests = [

  "is_empty against empty" >:: 
  (fun _ -> assert_equal true (is_empty (empty ()) ));
  "is empty against nonempty" >:: 
  (fun _ -> assert_equal false (is_empty ship_sub));

  "size with empty is 0" >:: (fun _ -> assert_equal 0 (size (empty ())));
  "size with destroyer is 3" >:: 
  (fun _ -> assert_equal 3 (size ship_destroyer));
  "size with sub is 2" >:: (fun _ -> assert_equal 2 (size ship_sub));

  "Comprehensive Test Suite for Player and Ship Module" >:: (fun _ ->   
      assert_equal true (Player.is_alive player);
      hit (1,1) ship_destroyer; 
      assert_equal false  (calive (1,1) ship_destroyer); 
      assert_equal true (alive ship_destroyer);
      hit (1,2) ship_destroyer; 
      assert_equal false  (calive (1,2) ship_destroyer);
      assert_equal true  (alive ship_destroyer);

      hit (1,3) ship_destroyer; 
      assert_equal false  (calive (1,3) ship_destroyer);

      assert_equal false  (calive (1,1) ship_destroyer);
      assert_equal false  (calive (1,3) ship_destroyer);
      assert_equal false  (alive ship_destroyer);
      assert_equal true (Player.is_alive player);

      hit (2,1) ship_sub;
      assert_equal false (calive (2,1) ship_sub);
      assert_equal true (alive ship_sub);
      assert_equal true (Player.is_alive player);
      hit (3,1) ship_sub;
      assert_equal false (calive (2,1) ship_sub);
      assert_equal false (calive (3,1) ship_sub);
      assert_equal false (alive ship_sub);
      assert_equal false (Player.is_alive player))
  ;






  (* test_ship_compare "Tests two ships which are not equal" 
     ship_destroyer ship_sub GL *)

]
open Board

let board_tests = [
  "Board Test" >:: 
  (fun _ -> 
     place_ship_h board ship_destroyer_a;
     place_ship_v board ship_sub_a;
     assert_equal true  (calive (1,1) ship_destroyer_a); 

     hit board (1,1);
     assert_equal false  (calive (1,1) ship_destroyer_a); 
     assert_equal true (alive ship_destroyer_a);
     assert_equal true (Player.is_alive player_a);

     hit board (1,2) ; 
     assert_equal false  (calive (1,2) ship_destroyer_a);
     assert_equal true  (alive ship_destroyer_a);

     hit board (1,3) ; 
     assert_equal false  (calive (1,3) ship_destroyer_a);

     assert_equal false  (calive (1,1) ship_destroyer_a);
     assert_equal false  (calive (1,3) ship_destroyer_a);
     assert_equal false  (alive ship_destroyer_a);
     assert_equal true (Player.is_alive player_a);

     hit board (2,1) ;
     assert_equal false (calive (2,1) ship_sub_a);
     assert_equal true (alive ship_sub_a);
     assert_equal true (Player.is_alive player_a);
     hit board (3,1) ;
     assert_equal false (calive (2,1) ship_sub_a);
     assert_equal false (calive (3,1) ship_sub_a);
     assert_equal false (alive ship_sub_a);
     assert_equal false (Player.is_alive player_a)    )






]

let command_tests = []

let player_tests = []

let suite = "test suite" >::: 
            List.flatten [ship_tests;board_tests;command_tests]

let _ = run_test_tt_main suite
