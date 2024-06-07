import std.stdio;
import std.string;
import std.conv;
import std.algorithm;

import config;
import shape: Rectangle, Circle, Shape, render_circle;
import types: Rect;

import constants;
import entity;
import game;

import bindbc.sdl;

import component;
import types;

import num_util;

class Scene {
  Shape[] shapes;
  Game game;
  EntityManager entities;
  Entity player;

  PlayerSpec ps;
  EnemySpec es;
  BulletSpec bs;
    
  this(Game game) {
    this.game = game;
    this.entities = new EntityManager();
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
	  circ.x = to!float(tokens[2]);
	  circ.y = to!float(tokens[3]);
	  circ.sx = to!float(tokens[4]);
	  circ.sy = to!float(tokens[5]);
	  circ.r = to!ubyte(tokens[6]);
	  circ.g = to!ubyte(tokens[7]);
	  circ.b = to!ubyte(tokens[8]);
	  circ.radius = to!float(tokens[9]);

	  this.shapes ~= circ;

	} else if(tokens[0].toLower() == "rectangle") {
	  Rectangle rect = new Rectangle();
	  rect.name = tokens[1];
	  rect.x = to!float(tokens[2]);
	  rect.y = to!float(tokens[3]);
	  rect.sx = to!float(tokens[4]);
	  rect.sy = to!float(tokens[5]);
	  rect.r = to!ubyte(tokens[6]);
	  rect.g = to!ubyte(tokens[7]);
	  rect.b = to!ubyte(tokens[8]);
	  rect.width = to!float(tokens[9]);
	  rect.height = to!float(tokens[10]);

	  this.shapes ~= rect;
	} else if(tokens[0].toLower() == "player") {
	  this.ps = new PlayerSpec();

	  this.ps.sr = to!int(tokens[1]);
	  this.ps.cr = to!int(tokens[2]);
	  this.ps.speed = to!float(tokens[3]);
	  this.ps.fr = to!ubyte(tokens[4]);
	  this.ps.fg = to!ubyte(tokens[5]);
	  this.ps.fb = to!ubyte(tokens[6]);
	  this.ps.or = to!ubyte(tokens[7]);
	  this.ps.og = to!ubyte(tokens[8]);
	  this.ps.ob = to!ubyte(tokens[9]);
	  this.ps.ot = to!ubyte(tokens[10]);
	} else if(tokens[0].toLower() == "enemy") {
	  this.es = new EnemySpec();

	  this.es.sr = to!int(tokens[1]);
	  this.es.cr = to!int(tokens[2]);
	  this.es.smin = to!float(tokens[3]);
	  this.es.smax = to!float(tokens[4]);
	  this.es.or = to!ubyte(tokens[5]);
	  this.es.og = to!ubyte(tokens[6]);
	  this.es.ob = to!ubyte(tokens[7]);
	  this.es.ot = to!int(tokens[8]);
	  this.es.vmin = to!int(tokens[9]);
	  this.es.vmax = to!int(tokens[10]);
	  this.es.l = to!int(tokens[11]);
	  this.es.sp = to!int(tokens[12]);

	} else if(tokens[0].toLower() == "bullet") {
	  this.bs = new BulletSpec();

	  this.bs.sr = to!int(tokens[1]);
	  this.bs.cr = to!int(tokens[2]);
	  this.bs.s = to!float(tokens[3]);
	  this.bs.fr = to!ubyte(tokens[4]);
	  this.bs.fg = to!ubyte(tokens[5]);
	  this.bs.fb = to!ubyte(tokens[6]);
	  this.bs.or = to!ubyte(tokens[7]);
	  this.bs.og = to!ubyte(tokens[8]);
	  this.bs.ob = to!ubyte(tokens[9]);
	  this.bs.ot = to!int(tokens[10]);
	  this.bs.v = to!int(tokens[11]);
	  this.bs.l = to!int(tokens[12]);
	}
      }
    }
  }

  void spawn_player() {
    if(this.ps !is null) {
      auto entity = this.entities.addEntity("player");

      // this.ps 에서의설정값으로Entity설정 
      CShape shape = new CShape(
				this.ps.sr * 2.0,
				this.ps.sr * 2.0,
				this.ps.fr,
				this.ps.fg,
				this.ps.fb,
				this.ps.or,
				this.ps.og,
				this.ps.ob,
				this.ps.ot
				);

      CTransform transform = new CTransform(
					    new Vec2(this.game.wc.width / 2,
						     this.game.wc.height / 2),
					    new Vec2(0, 0)
					    );
      CCollision collision = new CCollision(this.ps.cr);

      entity.shape = shape;
      entity.transform = transform;
      entity.collision = collision;
    }
  }

  void spawn_enemy() {
    import std.math;

    if(this.es !is null) {
      auto entity = this.entities.addEntity("enemy");
      
      
      // this.es 에서의 설정을 가져옴
      float speed = get_random(cast(int)this.es.smin, cast(int)this.es.smax);
      float theta = get_random(0, 360) * 2.0 * PI / 180.0;

      float x_span = this.game.wc.width - (this.es.sr * 2.0);
      float y_span = this.game.wc.height = (this.es.sr * 2.0);

      float x_pos = get_random(0, cast(int)x_span);
      float y_pos = get_random(0, cast(int)y_span);

      CShape shape = new CShape(
				this.es.sr * 2.0,
				this.es.sr * 2.0,
				0,
				0,
				0,
				this.es.or,
				this.es.og,
				this.es.ob,
				this.es.ot
				);

      
      CTransform transform = new CTransform(
					    
					    new Vec2(x_pos, y_pos), 
					    new Vec2(speed * cos(theta),
						     speed * sin(theta))
					    );
      CCollision collision = new CCollision(this.es.cr);
      
      entity.shape = shape;
      entity.transform = transform;
      entity.collision = collision;
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
	int margin_left = (cast(int)rect.width - font_width) / 2;
	int margin_top = (cast(int)rect.height - font_height) / 2;

	SDL_Color* font_color = new SDL_Color(0,0,0, 255);
	SDL_Color* bg_color = new SDL_Color(rect.r, rect.g, rect.b, 255);

	Rect bound = rect.get_local_bound();
	SDL_Rect* dest_rect = new SDL_Rect(bound.x + margin_left, bound.y + margin_top, font_width, font_height);

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


	// 사각형 먼저 그리기
	SDL_SetRenderDrawColor(this.game.renderer, rect.r, rect.g, rect.b, 0xff);
	SDL_RenderFillRect(this.game.renderer, new SDL_Rect(bound.x, bound.y, bound.w, bound.h));
	SDL_RenderCopy(this.game.renderer, text_texture, null, dest_rect);
      } else if(typeid(shape) == typeid(Circle)) {
	Circle circ = cast(Circle)shape;

	int font_width = 0;
	int font_height = 0;
	
	TTF_SizeText(this.game.fc.font, circ.name.toStringz, &font_width, &font_height);

	// shape 의 가운데에 TTF 노출
	int margin_left = (cast(int)circ.radius * 2 - font_width) / 2;
	int margin_top = (cast(int)circ.radius * 2 - font_height) / 2;


	SDL_Color* font_color = new SDL_Color(0,0,0, 255);
	SDL_Color* bg_color = new SDL_Color(circ.r, circ.g, circ.b, 255);

	Rect bound = circ.get_local_bound();
	SDL_Rect* dest_rect = new SDL_Rect(bound.x + margin_left, bound.y + margin_top, font_width, font_height);

	SDL_Surface* font_surface = 
	  TTF_RenderText_Shaded(
				this.game.fc.font, 
				circ.name.toStringz, 
				*font_color, 
				*bg_color);
	SDL_Texture* text_texture = 
	  SDL_CreateTextureFromSurface(this.game.renderer, font_surface);
	SDL_FreeSurface(font_surface);
	
	// 원 그리기 
	render_circle(this.game.renderer, circ);
	SDL_RenderCopy(this.game.renderer, text_texture, null, dest_rect);
	
      }
    }
  }

  // systems
  void sMovement() {}

  void sUserInput() {}

  void sRender() {}

  void sEnemySpawner() {}

  void sCollision() {}

} // End of Class Scene
