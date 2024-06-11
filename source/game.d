import std.stdio;
import std.conv;
import std.string;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import constants;

import scene;
import scene_geowar;
import config;

import sdl_util;
import shape;
import mouse_util;


/*
  Game은 SDL2 윈도를 책임지는 메인 프레임워크이다.
  sdl_available : SDL 이 사용가능한지 알려주는 플래그
  scene : 장면 객체
  window: SDL_Window 객체의 포인터 
  renderer: window의 렌더러 객체 포인터 

 */
class Game {
  
  bool sdl_available;
  string current_scene;
  Scene[string] scene;

  SDL_Window* window;
  SDL_Renderer* renderer;

  bool ended;
  bool paused;
  
  uint current_time;
  uint last_time;

  WindowConfig wc;
  FontConfig fc;

  bool[SDL_Scancode] key_pressed;
  bool[SDL_Scancode] key_released;
  bool[SDL_Scancode] key_hold;

  Mouse mouse;

  this() {
    this.wc = new WindowConfig();
    this.fc = new FontConfig();
    this.sdl_available = false;
    this.ended = false;
    this.paused = false;
    this.mouse = new Mouse();

  }

  void game_init(string path) {

    this.sdl_available = init_sdl();
    load_config(path);

    if(this.sdl_available) {
      SDL_Init(SDL_INIT_VIDEO);

      this.window = 
	SDL_CreateWindow(
			 "SDL2 D Game Engine", 
			 SDL_WINDOWPOS_UNDEFINED, 
			 SDL_WINDOWPOS_UNDEFINED, 
			 cast(int)this.wc.width, cast(int)this.wc.height, 0);
      if(!this.window) {
	writeln("GAME::GAME_INIT::Cannot make Window");
	this.sdl_available = false;
      } else {
	this.renderer = 
	  SDL_CreateRenderer(
			     this.window, -1, 
			     SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if(!this.renderer) {
	  writeln("Game::GAME_INIT::Cannot make Renderer");
	  this.sdl_available = false;
	}
	SDL_SetRenderDrawBlendMode(this.renderer, SDL_BLENDMODE_BLEND);
      }
      this.current_scene = "geowar";
      this.scene[this.current_scene] = new SceneGeoWar(this, "./assets/config.txt");
      this.scene[this.current_scene].scene_init();
    }
  }

  private void load_config(string path) {
    File file = File(path, "r");
    scope(exit) {
      if(file.isOpen()) {
	file.close();
      }
    }

    while(!file.eof()) {
      string line = strip(file.readln());
      // writeln("read line -> |", line, line.length);

      if(line.length > 0) {
	string[] tokens = line.split(" ");
      
	if(tokens[0].toLower() == "window") {
	  float width = to!float(tokens[1]);
	  float height = to!float(tokens[2]);

	  this.wc.width = width;
	  this.wc.height = height;
	} else if(tokens[0].toLower() == "font") {
	
	  this.fc.path = tokens[1];
	  this.fc.size = to!int(tokens[2]);
	  this.fc.r = to!ubyte(tokens[3]);
	  this.fc.g = to!ubyte(tokens[4]);
	  this.fc.b = to!ubyte(tokens[5]);

	  this.fc.font =  TTF_OpenFont(("./" ~ this.fc.path).toStringz, this.fc.size);
	} 
      }
    }
  }

  void game_quit() {
    if(this.sdl_available) {
      if(this.renderer) {

	SDL_DestroyRenderer(this.renderer);
      }

      if(this.window) {
	SDL_DestroyWindow(this.window);
      }
      
      TTF_Quit();
      Mix_Quit();
      IMG_Quit();
      SDL_Quit();
    }
  }


  void event_loop() {
    SDL_Event event;
    this.key_pressed.clear();
    this.key_released.clear();
    while(SDL_PollEvent(&event)) {
      switch(event.type) {
      case SDL_QUIT:
	this.ended = true;
	break;
      case SDL_KEYDOWN:
	this.key_hold[event.key.keysym.sym] = true;
	this.key_released[event.key.keysym.sym] = false;
	this.key_pressed[event.key.keysym.sym] = true;
	break;
      case SDL_KEYUP:
	this.key_hold[event.key.keysym.sym] = false;
	this.key_released[event.key.keysym.sym] = true;
	this.key_pressed[event.key.keysym.sym] = false;
	break;
      case SDL_MOUSEMOTION:
	this.mouse.x = event.motion.x;
	this.mouse.y = event.motion.y;
	break;
      case SDL_MOUSEBUTTONDOWN:
	if(event.button.button == SDL_BUTTON_LEFT) {
	  this.mouse.lbutton_down = true;
	}
	if(event.button.button == SDL_BUTTON_RIGHT) {
	  this.mouse.rbutton_down = true;
	}
	break;
      case SDL_MOUSEBUTTONUP:
	if(event.button.button == SDL_BUTTON_LEFT) {
	  this.mouse.lbutton_down = false;
	}
	if(event.button.button == SDL_BUTTON_RIGHT) {
	  this.mouse.rbutton_down = false;
	}
	break;
      default:
	// do nothing
	break;
      }
    }
  }

  void game_run() {
    this.last_time = SDL_GetTicks();

    while(!this.ended) {
      this.current_time = SDL_GetTicks();

      float dt = cast(float)(this.current_time - this.last_time) / 50.0;
      this.event_loop();

      if((SDLK_ESCAPE in this.key_pressed) !is null 
	 && this.key_pressed[SDLK_ESCAPE] == true) {
	this.ended = true;
      }

      this.update(dt);
      this.render();
      this.last_time = this.current_time;
      SDL_Delay(1000 / 30); // 30 FPS
    }
  }

  void update(float dt) {
    // 경과된 Tick을 계산한다.
    this.scene[this.current_scene].update(dt);
    
  }



  void render() {
    // clear screen
    SDL_SetRenderDrawColor(this.renderer, 0x00, 0x00, 0x00, 0xff);
    SDL_RenderClear(this.renderer);



    // draw screen
    this.scene[this.current_scene].render();

    SDL_RenderPresent(this.renderer);
  }

}
