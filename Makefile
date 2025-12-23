VFLAGS = -O3 --x-assign fast --x-initial fast --noassert
SDL_CFLAGS := $(shell sdl2-config --cflags)
SDL_LDFLAGS := $(shell sdl2-config --libs)

RTL_FILES = graphics_type.sv \
			top.sv \
            vga.sv \
			depth_sorter.sv \
            rotation.sv \
            projection.sv \
            scene_objects.sv \
            rasterizer.sv

all: run

run: obj_dir/Vtop
	./obj_dir/Vtop

obj_dir/Vtop: $(RTL_FILES) main_triangle.cpp
	verilator $(VFLAGS) --cc --exe --build \
		--top-module top \
		$(RTL_FILES) main_triangle.cpp \
		-CFLAGS "$(SDL_CFLAGS)" -LDFLAGS "$(SDL_LDFLAGS)" \
		-o Vtop

clean:
	rm -rf obj_dir

.PHONY: all clean run