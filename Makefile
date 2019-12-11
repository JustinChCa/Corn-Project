MODULES=authors ship board gui player command ai client ClientEngine server main main2 
OBJECTS=$(MODULES:=.cmo)
MLS=$(MODULES:=.ml)
MLIS=$(MODULES:=.mli)
TEXT=main.byte
GRAPHIC=main2.byte
TEST=test.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)'
PKGS=unix,oUnit,str,ANSITerminal,graphics,camlimages.png,camlimages.graphics
SERVER=server.byte

default: build
	utop

build:
	$(OCAMLBUILD) $(OBJECTS)

play-text:
	$(OCAMLBUILD) $(TEXT) && ./$(TEXT)

play-graph:
	$(OCAMLBUILD) $(GRAPHIC) && ./$(GRAPHIC)
	
test:
	$(OCAMLBUILD) -tag debug $(TEST) && ./$(TEST)

bisect-test:
	BISECT_COVERAGE=YES $(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST) -runner sequential

bisect: clean bisect-test
	bisect-ppx-report -I _build -html report bisect0001.out

zip:
	zip -r bs_src.zip *.ml* _tags Makefile Install.md assets
	
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
	rm -rf bs_src.zip doc.public doc.private report bisect*.out

server:
	$(OCAMLBUILD) $(SERVER) && ./$(SERVER)



