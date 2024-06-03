import std.stdio;
import std.string;
import std.conv;
import std.algorithm;

import config: WindowConfig, FontConfig;
import shape: Rectangle, Circle, Shape;
import types: Rect;

import constants;
import game;

import bindbc.sdl;

class Scene {
  Shape[] shapes;
  Game game;
    
  this(Game game) {
    this.game = game;
  }
  
  void scene_init() {
    File file = File("./assets/config.txt", "r");
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
      
	if(tokens[0].toLower() == "circle") {
	
	  Circle circ = new Circle();
	  circ.name = tokens[1];
	  circ.x = to!int(tokens[2]);
	  circ.y = to!int(tokens[3]);
	  circ.sx = to!int(tokens[4]);
	  circ.sy = to!int(tokens[5]);
	  circ.r = to!int(tokens[6]);
	  circ.g = to!int(tokens[7]);
	  circ.b = to!int(tokens[8]);
	  circ.radius = to!int(tokens[9]);

	  this.shapes ~= circ;

	} else if(tokens[0].toLower() == "rectangle") {
	  Rectangle rect = new Rectangle();
	  rect.name = tokens[1];
	  rect.x = to!int(tokens[2]);
	  rect.y = to!int(tokens[3]);
	  rect.sx = to!int(tokens[4]);
	  rect.sy = to!int(tokens[5]);
	  rect.r = to!int(tokens[6]);
	  rect.g = to!int(tokens[7]);
	  rect.b = to!int(tokens[8]);
	  rect.width = to!int(tokens[9]);
	  rect.height = to!int(tokens[10]);

	  this.shapes ~= rect;
	}

      }
    }

  }

  void show_configs() {
    foreach(shape; this.shapes) {
      if(typeid(shape) == typeid(Rectangle)) {
	writeln("Rectangle name -> ", (cast(Rectangle)shape).name);
      } else if(typeid(shape) == typeid(Circle)) {
	writeln("Circle name -> ", (cast(Circle)shape).name);
      }
    }
  }

  void update(float dt) {
    foreach(shape; this.shapes) {
      
      shape.update(dt);
    }
    
    
  }

  void render() {
    foreach(shape; this.shapes) {
      if(typeid(shape) == typeid(Rectangle)) {

	Rectangle rect = cast(Rectangle)shape;

	int font_width = 0;
	int font_height = 0;
	
	TTF_SizeText(this.game.fc.font, rect.name.toStringz, &font_width, &font_height);

	// shape 의 가운데에 TTF 노출
	int margin_left = (rect.width - font_width) / 2;
	int margin_top = (rect.height - font_height) / 2;

	SDL_Color* font_color = new SDL_Color(cast(ubyte)(rect.r), cast(ubyte)rect.g, cast(ubyte)rect.b, 255);
	SDL_Color* bg_color = new SDL_Color(0,0,0, 255);
	Rect bound = rect.get_local_bound();
	SDL_Rect* dest_rect = new SDL_Rect(bound.x + margin_left, bound.y + margin_top, bound.w, bound.h);

	//writeln("BOUND::", bound.x + margin_left, bound.y + margin_top);
	//writeln("BOUND::", bound.w, bound.h);
	SDL_Surface* font_surface = 
	  TTF_RenderText_Shaded(
				this.game.fc.font, 
				rect.name.toStringz, 
				*font_color, 
				*bg_color);
	SDL_Texture* text_texture = 
	  SDL_CreateTextureFromSurface(this.game.renderer, font_surface);


	SDL_FreeSurface(font_surface);

	SDL_RenderCopy(this.game.renderer, text_texture, null, dest_rect);
      }
    }
  }
}
