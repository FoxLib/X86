VINC=/usr/share/verilator/include
WARN=-Wall -Wno-unused -Wno-width -Wno-caseincomplete
WCC=-Wno-unused-result -Wno-format-overflow

#all:
#all: icarus
all: icarus tbc
	./tb
tblog:
	./tb -d > tb.log
tbrun:
	./tb
icarus:
	iverilog -g2005-sv -DICARUS=1 -o tb.qqq tb.v ps2.v core88.v pctl.v sd.v
	vvp tb.qqq >> /dev/null
tbc: verilate
	g++ -o tb -O3 $(WCC) -I$(VINC) tb.cc $(VINC)/verilated.cpp \
	obj_dir/Vvga__ALL.a \
	obj_dir/Vps2__ALL.a \
	obj_dir/Vcore88__ALL.a \
	obj_dir/Vpctl__ALL.a \
	obj_dir/Vsd__ALL.a \
	-lSDL2
verilate:
	verilator $(WARN) -cc vga.v
	verilator $(WARN) -cc ps2.v
	verilator $(WARN) -cc core88.v
	verilator $(WARN) -cc pctl.v
	verilator $(WARN) -cc sd.v
	cd obj_dir && make -f Vvga.mk
	cd obj_dir && make -f Vps2.mk
	cd obj_dir && make -f Vcore88.mk
	cd obj_dir && make -f Vpctl.mk
	cd obj_dir && make -f Vsd.mk
wave:
	gtkwave tb.gtkw
video:
	ffmpeg -framerate 70 -r 60 -i out/record.ppm -vf "scale=w=1280:h=800,pad=width=1920:height=1080:x=320:y=140:color=black" -sws_flags neighbor -sws_dither none -f mp4 -q:v 0 -vcodec mpeg4 -y record.mp4
clean:
	rm -rf obj_dir tb out record.mp4 bios/bios.bin bios/bios.hex tb.log
