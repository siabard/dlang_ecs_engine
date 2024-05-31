import std.stdio;
import std.conv;
import std.string;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import scene;

class Game {
  
  bool sdl_available;
  Scene scene;

  this() {
    this.scene = new Scene();
    this.sdl_available = false;
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
    }


    this.scene.scene_init();

    return this.sdl_available;
  }

  void game_quit() {
    if(this.sdl_available) {
      SDL_Quit();
    }
  }

  void render() {
    this.scene.show_configs();
  }

}
