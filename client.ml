open Unix

type socket =
  | Socket of (inet_addr * int)

module Client = struct 



  let create_socket_connection ip port= 
    let addr = ip |> inet_addr_of_string in 
    let socket = Unix.ADDR_INET (addr, port) in socket


  let rec prompt_connection ()= 
    print_endline "\nPlease Type in the ip address...\n";
    let ip = read_line() in 
    print_endline "\nPlease Type in the port....\n";

    match int_of_string (read_line()) with 
    | t -> begin 
        match create_socket_connection ip t with 
        | k -> k
        | exception Failure k ->
          print_endline "no connection. try again.\n"; prompt_connection ()

      end

    | exception Failure j -> 
      print_endline "Bad port. Please Re-type\n";
      prompt_connection ()


  let shutdown_connection inchan =
    Unix.shutdown (Unix.descr_of_in_channel inchan) Unix.SHUTDOWN_SEND 



  let client_fun_test ic oc = 
    try
      while true do  
        print_string  "Request : " ;
        flush oc ;
        output_string oc ((input_line ic)^"\n") ;
        flush oc ;
        let r = input_line ic 
        in Printf.printf "Response : %s\n\n" r;
        if r = "END" then ( shutdown_connection ic ; raise Exit) ;
      done
    with 
      Exit -> exit 0
    | exn -> shutdown_connection ic ; raise exn  ;;

  let connect () =
    let socket = prompt_connection () in
    let (ic,oc) = open_connection socket in
    client_fun_test ic oc;
    shutdown_connection ic

  (* match Unix.fork() with
     | 0 -> print_endline "in progress"
     | _ ->  print_endline "in progress" *)




  let disconnect socc =
    failwith "unimplemented"

  let update_local_game () = 
    failwith "unimplemented"

  let update_to_server () =
    failwith "unimplemented"




end