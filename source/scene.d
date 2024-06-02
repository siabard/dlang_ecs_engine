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
  WindowConfig wc;
  FontConfig fc;
    
  this() {
    this.wc = new WindowConfig();
    this.fc = new FontConfig();
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
      
	if(tokens[0].toLower() == "window") {
	  int width = to!int(tokens[1]);
	  int height = to!int(tokens[2]);

	  this.wc.width = width;
	  this.wc.height = height;
	} else if(tokens[0].toLower() == "font") {
	
	  this.fc.path = tokens[1];
	  this.fc.size = to!int(tokens[2]);
	  this.fc.r = to!int(tokens[3]);
	  this.fc.g = to!int(tokens[4]);
	  this.fc.b = to!int(tokens[5]);
	} else if(tokens[0].toLower() == "circle") {
	
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
    
    writeln("Window Width -> |", this.wc.width);
    writeln("Window height -> |", this.wc.height);

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

  void render(SDL_Renderer *renderer) {
    foreach(shape; this.shapes) {
      shape.render(renderer);
    }
  }
}
