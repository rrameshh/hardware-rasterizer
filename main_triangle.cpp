#include <stdio.h>
#include <SDL.h>
#include <verilated.h>
#include "Vtop.h"

const int H_RES = 640;
const int V_RES = 480;

typedef struct Pixel {
    uint8_t a, b, g, r;
} Pixel;

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL init failed.\n");
        return 1;
    }

    Pixel screenbuffer[H_RES * V_RES];

    SDL_Window* sdl_window = SDL_CreateWindow(
        "Rasterizer", 
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, 
        H_RES, V_RES, 
        SDL_WINDOW_SHOWN
    );
    
    SDL_Renderer* sdl_renderer = SDL_CreateRenderer(
        sdl_window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
    );
    
    SDL_Texture* sdl_texture = SDL_CreateTexture(
        sdl_renderer, 
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_TARGET, 
        H_RES, V_RES
    );

    const Uint8* keyb_state = SDL_GetKeyboardState(NULL);

    printf("Rasterizer running. Press Q to quit.\n");

    Vtop* top = new Vtop;
    
    // Reset
    top->rst = 1;
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
    top->rst = 0;
    top->clk = 0;
    top->eval();

    uint64_t frame_count = 0;
    uint64_t start_ticks = SDL_GetPerformanceCounter();

    while (1) {
        // Clock cycle
        top->clk = 1;
        top->eval();
        top->clk = 0;
        top->eval();

        // Update screenbuffer
        if (top->de) {
            if (top->sx < H_RES && top->sy < V_RES) {
                int idx = top->sy * H_RES + top->sx;
                screenbuffer[idx].a = 0xFF;
                screenbuffer[idx].r = top->sdl_r;
                screenbuffer[idx].g = top->sdl_g;
                screenbuffer[idx].b = top->sdl_b;

            
            }
        }

        // Update display once per frame
        if (top->sy == V_RES && top->sx == 0) {
            SDL_Event e;
            if (SDL_PollEvent(&e)) {
                if (e.type == SDL_QUIT) break;
            }
            if (keyb_state[SDL_SCANCODE_Q]) break;

            SDL_UpdateTexture(sdl_texture, NULL, screenbuffer, H_RES * sizeof(Pixel));
            SDL_RenderClear(sdl_renderer);
            SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, NULL);
            SDL_RenderPresent(sdl_renderer);
            
            frame_count++;
        }
    }

    // Print FPS
    uint64_t end_ticks = SDL_GetPerformanceCounter();
    double duration = (double)(end_ticks - start_ticks) / SDL_GetPerformanceFrequency();
    printf("Frames per second: %.1f\n", frame_count / duration);

    top->final();
    SDL_DestroyTexture(sdl_texture);
    SDL_DestroyRenderer(sdl_renderer);
    SDL_DestroyWindow(sdl_window);
    SDL_Quit();
    
    return 0;
}