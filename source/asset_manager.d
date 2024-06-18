module asset_manager;
import std.string;

/*
  Assets are external files that are loaded iinto memory to be used in the game
  
  Textures   texture_name   path
  Animations
  Sounds
  Fonts

  "Load Once, Use Often"

  Load assets that are defined in an external configuration file
*/

import bindbc.sdl;
import animation;

import std.stdio;

class AssetManager {
  SDL_Texture*[string] textures;
  TTF_Font*[string] fonts;
  Mix_Chunk*[string] sounds;
  Mix_Music*[string] musics;
  Animation[string] animations;
  ~this() {
    foreach(value; this.textures.byValue) {
      if(value !is null) {
	SDL_DestroyTexture(value);
      }
    }

    foreach(value; this.fonts.byValue) {
      if(value !is null) {
	TTF_CloseFont(value);
      }
    }

    foreach(value; this.sounds.byValue) {
      if(value !is null) {
	Mix_FreeChunk(value);
      }
    }

    foreach(value; this.musics.byValue) {
      if(value !is null) {
	Mix_FreeMusic(value);
      }
    }
  }

  void add_texture(string name, string path, SDL_Renderer* renderer) {
    auto texture = IMG_LoadTexture(renderer, ("./" ~ path).toStringz);
    if(texture !is null) {
      writeln("texture: ", name , "  path: ", "./" ~ path);
      this.textures[name] = texture;
    } else {
      writeln("texture: ", name , "  is null on path: ", "./" ~ path);
    }
  }

  void add_sound(string name, string path) {
    auto wave = Mix_LoadWAV(("./" ~ path).toStringz);

    if(wave !is null) {
      this.sounds[name] = wave;
    }
  }

  void add_music(string name, string path) {
    auto music = Mix_LoadMUS(("./" ~ path).toStringz);

    if(music !is null) {
      this.musics[name] = music;
    }
  }

  void add_font(string name, string path, int size) {
    auto font = TTF_OpenFont(("./" ~ path).toStringz, size);

    if(font !is null) {
      this.fonts[name] = font;
    }
  }

  void add_animation(string name, string texture_name, uint frame_count, int animation_speed) {
    writeln("animation name :", name, " texture ", texture_name);
    this.animations[name] = new Animation(
					  this.textures[texture_name], 
					  frame_count, animation_speed);
  }

  SDL_Texture* get_texture(string name) {
    return this.textures[name];
  }

  TTF_Font* get_font(string name) {
    return this.fonts[name];
  }

  Mix_Chunk* get_sound(string name) {
    return this.sounds[name];
  }

  Mix_Music* get_music(string name) {
    return this.musics[name];
  }

  Animation get_animation(string name) {
    return this.animations[name];
  }
}
