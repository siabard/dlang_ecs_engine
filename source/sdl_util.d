import bindbc.sdl;
import bindbc.loader;

import loader = bindbc.loader.sharedlib;
import std.stdio;
import std.conv;
import std.string;

bool init_sdl() {
  bool result = false;

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
      return result;
    }


    result = true;

    // Image
    
    SDLImageSupport image_ret = loadSDLImage();
    if(image_ret == SDLImageSupport.noLibrary) {
      result = false;
      writeln("NO IMAGE is supported");
    }
    IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
    

    SDLMixerSupport mixer_ret = loadSDLMixer();
    if(mixer_ret == SDLMixerSupport.noLibrary) {
      result = false;
      writeln("NO MIXER is supported");
    }
    Mix_Init(MIX_INIT_MP3 | MIX_INIT_OGG);


    SDLTTFSupport ttf_ret = loadSDLTTF();
    if(ttf_ret == SDLTTFSupport.noLibrary) {
      result = false;
      writeln("NO TTF is supported");
    }
    TTF_Init();
    
    return result;
}
