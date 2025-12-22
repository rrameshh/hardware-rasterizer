VFLAGS = -O3 --x-assign fast --x-initial fast --noassert
SDL_CFLAGS := $(shell sdl2-config --cflags)
SDL_LDFLAGS := $(shell sdl2-config --libs)

all: run

run: obj_dir/Vtop
	./obj_dir/Vtop

obj_dir/Vtop: top.sv vga.sv rasterizer.sv main_triangle.cpp
	verilator $(VFLAGS) --cc --exe --build \
		top.sv vga.sv rasterizer.sv main_triangle.cpp \
		-CFLAGS "$(SDL_CFLAGS)" -LDFLAGS "$(SDL_LDFLAGS)" \
		-o Vtop

clean:
	rm -rf obj_dir

.PHONY: all clean run