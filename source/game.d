import std.stdio;
import std.conv;
import std.string;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import constants;

import scene;


/*
  Game은 SDL2 윈도를 책임지는 메인 프레임워크이다.
  sdl_available : SDL 이 사용가능한지 알려주는 플래그
  scene : 장면 객체
  window: SDL_Window 객체의 포인터 
  renderer: window의 렌더러 객체 포인터 

 */
class Game {
  
  bool sdl_available;
  Scene scene;

  SDL_Window* window;
  SDL_Renderer* renderer;

  bool ended;
  
  uint current_time;
  uint last_time;


  this() {
    this.scene = new Scene(this);
    this.sdl_available = false;
    this.ended = false;
  }

  bool game_init() {

    
    SDLSupport ret = loadSDL();
    if(ret != sdlSupport) {
      /* 
	 Error Handling. 
      */
      writeln("GAME::GAME_INIT::Cannot initialize SDL2"); 
      foreach(info; loader.errors) {
	writefln("%s => %s", fromStringz(info.error), fromStringz(info.message));
      }

      string msg;
      if(ret == SDLSupport.noLibrary) {
	msg = ("This application requires the SDL library.");
      } else {
	SDL_version version_;
	SDL_GetVersion(&version_);

	msg = "SDL version is " ~
	  to!string(version_.major) ~ "." ~
	  to!string(version_.minor) ~ "." ~
	  to!string(version_.patch);

      }


      writeln("GAME::GAME_INIT::" ~ msg);
      return this.sdl_available;
    }


    this.sdl_available = true;
    if(this.sdl_available) {
      SDL_Init(SDL_INIT_VIDEO);

      this.window = 
	SDL_CreateWindow(
			 "SDL2 D Game Engine", 
			 SDL_WINDOWPOS_UNDEFINED, 
			 SDL_WINDOWPOS_UNDEFINED, 
			 GAME_WIDTH, GAME_HEIGHT, 0);
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
      }

    }

    // Image
    //auto image_ret = loadSDLImage();
    //writeln(image_ret);

    SDLMixerSupport mixer_ret = loadSDLMixer();
    //writeln(mixer_ret);

    SDLTTFSupport ttf_ret = loadSDLTTF();
    //writeln(ttf_ret);

    this.scene.scene_init();

    return this.sdl_available;
  }

  void game_quit() {
    if(this.sdl_available) {
      if(this.renderer) {

	SDL_DestroyRenderer(this.renderer);
      }

      if(this.window) {
	SDL_DestroyWindow(this.window);
      }
      
      SDL_Quit();
    }
  }


  void event_loop() {
    SDL_Event event;
    while(SDL_PollEvent(&event)) {
      switch(event.type) {
      case SDL_QUIT:
	this.ended = true;
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
      float dt = cast(float)(this.last_time - this.current_time) / 1000.0;
      this.event_loop();

      this.update(dt);
      this.render();
      SDL_Delay(1000 / 30); // 30 FPS
      this.last_time = this.current_time;
    }
  }

  void update(float dt) {
    // 경과된 Tick을 계산한다.
    this.scene.update(dt);
    
  }



  void render() {
    // clear screen
    SDL_SetRenderDrawColor(this.renderer, 0x00, 0xc0, 0xc0, 0xff);
    SDL_RenderClear(this.renderer);



    // draw screen
    this.scene.render();

    SDL_RenderPresent(this.renderer);
  }

}
