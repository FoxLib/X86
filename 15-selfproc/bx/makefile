FILES=main.o cpu.o machine.o
CONF=-lSDL2 -Wall
MAIN=main
TEST=05_block

all: $(FILES)
	g++ $(FILES) $(CONF) -o bx
	cd tests/$(TEST) && make
win: $(FILES)
	g++ $(FILES) -mwindows $(CONF) -o $(MAIN)
%.o: %.cc main.h
	g++ -c $< -O3 -o $@
clean:
	rm -f $(MAIN) $(MAIN).exe *.o
