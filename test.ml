open OUnit2
open Command


module Player = Player.PlayerMaker

module Board = Board.BoardMaker

module Ship = Ship.ShipMaker


let board = Board.create 10 10
let ship_destroyer = Ship.create [(1,1);(1,2);(1,3)]
let ship_sub = Ship.create [(2,1);(3,1)]
let player = Player.create [ship_destroyer; ship_sub] board "player 1"
<<<<<<< HEAD
=======


>>>>>>> 9af00e5761a0d4513e4522364ae4aab3d3752beb

open Ship

let ship_attack_test name coordinate ship =  
  hit coordinate ship;
  name >:: (fun _ -> assert_equal false  (calive coordinate ship))

let ship_tests = [
  "size with destroyer is 3" >:: 
  (fun _ -> assert_equal 3 (size ship_destroyer));
  "size with sub is 2" >:: (fun _ -> assert_equal 2 (size ship_sub));

<<<<<<< HEAD
  "Comprehensive Test Suite for Player and Ship Module" >:: (fun _ ->   
      assert_equal true (Player.alive player);
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
      assert_equal true (Player.alive player);

      hit (2,1) ship_sub;
      assert_equal false (calive (2,1) ship_sub);
      assert_equal true (alive ship_sub);
      assert_equal true (Player.alive player);
      hit (3,1) ship_sub;
      assert_equal false (calive (2,1) ship_sub);
      assert_equal false (calive (3,1) ship_sub);
      assert_equal false (alive ship_sub);
      assert_equal false (Player.alive player))
  ;






  (* test_ship_compare "Tests two ships which are not equal" 
     ship_destroyer ship_sub GL *)

]
open Board

let board_tests = [
  "Board Test" >:: 
  (fun _ -> 
     place_ship board ship_destroyer_a;
     place_ship board ship_sub_a;
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
     assert_equal false (Player.is_alive player_a) )



    "(1,1)" >:: (fun _ ->   hit (1,1) ship_destroyer; 
                  assert_equal false  (calive (1,1) ship_destroyer); 
                  assert_equal true (alive ship_destroyer);
                  hit (1,2) ship_destroyer; 
                  assert_equal false  (calive (1,2) ship_destroyer);
                  assert_equal true  (alive ship_destroyer);

                  hit (1,3) ship_destroyer; 
                  assert_equal false  (calive (1,3) ship_destroyer);
=======
  (* ship_attack_test "attacks (1,1) coordinate on destroyer" (1,1) ship_destroyer;
     ship_attack_test "attacks (1,2) coordinate on destroyer" (1,2) ship_destroyer *)

  "(1,1)" >:: (fun _ ->   hit (1,1) ship_destroyer; 
                assert_equal false  (calive (1,1) ship_destroyer); 
                assert_equal true (alive ship_destroyer);
                hit (1,2) ship_destroyer; 
                assert_equal false  (calive (1,2) ship_destroyer);
                assert_equal true  (alive ship_destroyer);

                hit (1,3) ship_destroyer; 
                assert_equal false  (calive (1,3) ship_destroyer);

                assert_equal false  (calive (1,1) ship_destroyer);
                assert_equal false  (calive (1,3) ship_destroyer);
                assert_equal false  (alive ship_destroyer));]

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
>>>>>>> 9af00e5761a0d4513e4522364ae4aab3d3752beb

                  assert_equal false  (calive (1,1) ship_destroyer);
                  assert_equal false  (calive (1,3) ship_destroyer);
                  assert_equal false  (alive ship_destroyer));]

let board_tests = []

let command_tests = []

let player_tests = []

let suite = "test suite" >::: 
            List.flatten [ship_tests;board_tests;command_tests]

let _ = run_test_tt_main suite
