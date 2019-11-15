open Unix

type request = unit

type response = unit

module MakeServer = struct 

  let port_number = 1400

  let check_connections () = 
    failwith "unimplemented"

  let test_uppercase_service ic oc =
    try while true do    
        let s = input_line ic in 
        let r = String.uppercase s 
        in output_string oc (r^"\n") ; flush oc
      done
    with _ -> Printf.printf "End of text\n" ; flush oc ; exit 0 ;;

  let run_server () = 
    let get_serv_address = 
      match Unix.gethostname () |> Unix.gethostbyname with
      | k -> k.h_addr_list.(0) 
      | exception Not_found -> failwith "Failure to start server."
    in 
    let socket_addr = socket PF_INET SOCK_STREAM 0 in
    try
      bind socket_addr (ADDR_INET(get_serv_address,port_number));
      listen socket_addr 5;
      while true do 
        let (s, caller) = Unix.accept socket_addr 
        in match Unix.fork() with
          0 -> if Unix.fork() <> 0 then exit 0 ; 
          let inchan = Unix.in_channel_of_descr s 
          and outchan = Unix.out_channel_of_descr s 
          in test_uppercase_service inchan outchan ;
          close_in inchan ;
          close_out outchan ;
          exit 0
        | id -> Unix.close s; ignore(Unix.waitpid [] id)

      done;
    with exc -> close socket_addr; raise exc




  let close_connection socc = 
    close socc

  let game_service socc state = 
    failwith "unimplemented"

end 