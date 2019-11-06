#directory "_build";;
#load_rec "board.cmo";;
#load_rec "ship.cmo";;
#load_rec "player.cmo";;

module Player = Player.PlayerMaker
module Board = Board.BoardMaker
module Ship = Ship.ShipMaker

let board10 = Board.make_board 10 10;;
let board5 = Board.make_board 5 5;;
let board47 = Board.make_board 4 7;;

let lst5 = [(5,7);(6,7);(7,7);(8,7);(9,7)]
let lst4 = [(3,7);(3,7);(3,8);(3,9)]
let lst3 = [(1,1);(1,2);(1,3)]
let lst2 = [(2,1);(3,1)]
let lstbad = [(6,5);(6,6);(6,7);(6,8)]

let ship5 = Ship.create lst5
let ship4 = Ship.create lst4
let ship3 = Ship.create lst3
let ship2 = Ship.create lst2
let shipbad = Ship.create lstbad

let player1 = Player.init_player 
    [ship5;ship4;ship3;ship2] board10 "player 1"

