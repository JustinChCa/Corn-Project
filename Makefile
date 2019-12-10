MODULES=authors ship board gui player command ai client ClientEngine server engine main main2
OBJECTS=$(MODULES:=.cmo)
MLS=$(MODULES:=.ml)
MLIS=$(MODULES:=.mli)
MAIN=engine.byte
TEST=test.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)'
PKGS=unix,oUnit,str,ANSITerminal,graphics,camlimages.png,camlimages.graphics
SERVER=server.byte
CLIENT=client.byte
GRAPHIC=main2.byte
default: build
	utop

build:
	$(OCAMLBUILD) $(OBJECTS)

play:
	$(OCAMLBUILD) $(MAIN) && ./$(MAIN)
	
test:
	$(OCAMLBUILD) -tag debug $(TEST) && ./$(TEST)

bisect-test:
	BISECT_COVERAGE=YES $(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST) -runner sequential

check:
	bash checkenv.sh && bash checktypes.sh
	
finalcheck: check
	bash checkzip.sh
	bash finalcheck.sh

bisect: clean bisect-test
	bisect-ppx-report -I _build -html report bisect0001.out

zip:
	zip bs_src.zip *.ml* _tags Makefile Install.md bs.txt
	
docs: docs-public docs-private
	
docs-public: build
	mkdir -p doc.public
	ocamlfind ocamldoc -I _build -package $(PKGS) \
		-html -stars -d doc.public $(MLIS)

docs-private: build
	mkdir -p doc.private
	ocamlfind ocamldoc -I _build -package $(PKGS) \
		-html -stars -d doc.private \
		-inv-merge-ml-mli -m A -hide-warnings $(MLIS) $(MLS)

clean:
	ocamlbuild -clean
	rm -rf bs_src.zip

server:
	$(OCAMLBUILD) $(SERVER) && ./$(SERVER)

client:
	$(OCAMLBUILD) $(CLIENT) && ./$(CLIENT)

graphics: 
	$(OCAMLBUILD) $(GRAPHIC) && ./$(GRAPHIC)


