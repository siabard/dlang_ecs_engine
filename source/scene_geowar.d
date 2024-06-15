import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

import config;
import shape;
import types;

import constants;
import entity;
import game;

import bindbc.sdl;

import component;

import num_util;
import key_util;
import physics;

import std.math;
import scene;
import action;

class SceneGeoWar: Scene {
  EntityManager entities;
  Entity player;
  string level_path;

  PlayerSpec ps;
  EnemySpec es;
  BulletSpec bs;

  this(Game game, string level_path) {
    super(game);
    this.entities = new EntityManager();
    this.level_path = level_path;

  }
  
  override void scene_init() {
    File file = File(this.level_path, "r");
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
	if(tokens[0].toLower() == "player") {
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

    register_action(SDLK_w, "UP");
    register_action(SDLK_s, "DOWN");
    register_action(SDLK_a, "LEFT");
    register_action(SDLK_d, "RIGHT");

    spawn_player();
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
      CInput input = new CInput();

      entity.shape = shape;
      entity.transform = transform;
      entity.collision = collision;
      entity.input = input;

      this.player = entity;
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
      float y_span = this.game.wc.height - (this.es.sr * 2.0);

      float x_pos = get_random(this.es.sr, cast(int)x_span);
      float y_pos = get_random(this.es.sr, cast(int)y_span);

      int vert = get_random(this.es.vmin, this.es.vmax + 1);

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
      CVertices vertices = new CVertices(vert);
      // TEST
      // CLifespan lifespan = new CLifespan(120);

      // entity.lifespan = lifespan;
      entity.shape = shape;
      entity.transform = transform;
      entity.collision = collision;
      entity.vertices = vertices;
    }
  }

  void show_configs() {

  }


  override void update(float dt) {
    sKeyMouseEvent();
    sUserInput();
    sLifespan(dt);
    sMovement(dt);
    sCollision();
    sEnemySpawner(dt);
    this.entities.update();   
  }

  void sLifespan(float dt) {
    foreach(entity; this.entities.getEntities()) {
      if(entity.lifespan !is null) {
	entity.lifespan.duration += dt;

	if(entity.lifespan.duration >= entity.lifespan.total) {
	  entity.destroy();
	}
      }
    }
  }

  override void render() {
    sRender();
  }

  // systems
  void sMovement(float dt) {
    Rect world_rect = new Rect(0, 0, cast(int)this.game.wc.width, cast(int)this.game.wc.height);
    
    foreach(entity; this.entities.getEntities()) {
      if(entity.transform !is null && entity.shape !is null) {
	entity.transform.prev_pos.x = entity.transform.pos.x;
	entity.transform.prev_pos.y = entity.transform.pos.y;
	entity.transform.pos.x = entity.transform.pos.x + entity.transform.velocity.x * dt;
	entity.transform.pos.y = entity.transform.pos.y + entity.transform.velocity.y * dt;

	// 화면 경계에서 플레이어와 다른 객체는 행동이 달라진다.
	// 플레이어는 더 이상 움직이지 않기만 하면 되지만, 다른 객체는 반사되어야함.
	Rect entity_rect = get_bound_rect(entity.transform.pos, entity.shape.width, entity.shape.height);
	if(!world_rect.contains(entity_rect)) {
	  if(entity.tag != "player") {
	    if((this.game.wc.width - entity.shape.width / 2.0) <= entity.transform.pos.x ||
	       (entity.shape.width / 2.0) >= entity.transform.pos.x) {
	      entity.transform.velocity.x *= -1;
	    }

	    if((this.game.wc.height - entity.shape.height / 2.0) <= entity.transform.pos.y ||
	       (entity.shape.height / 2.0 >= entity.transform.pos.y)) {
	      entity.transform.velocity.y *= -1;
		      
	    }
	  }
	  
	  entity.transform.pos.x = 
	    min(cast(float)this.game.wc.width - entity.shape.width / 2.0 + 1.0, 
		max(entity.shape.width / 2.0 - 1.0, entity.transform.pos.x));
	  
	  entity.transform.pos.y = 
	    min(cast(float)this.game.wc.height - entity.shape.height / 2.0 + 1.0, 
		max(entity.shape.height / 2.0 - 1.0, entity.transform.pos.y));
	}
      }
    }
  }

  unittest {
    import std.stdio;

    writeln("movement system");
    
    Rect entity_rect = get_bound_rect(new Vec2(80, 80), 200, 25);
    Rect world_rect = new Rect(0, 0, 1280, 720);
    
    assert(!world_rect.contains(entity_rect));
    assert("enemy" != "player");
    writeln(min(1280 - 100, max(100, 80)));
    writeln("movement system end");
  }

  void sKeyMouseEvent() {
    // W, S D, F (위, 아래, 왼쪽, 오른쪽)
    // 플레이어 이동함

    /*
    this.player.input.up = key_is_activated(this.game.key_hold, SDLK_w);
    this.player.input.down = key_is_activated(this.game.key_hold, SDLK_s);
    this.player.input.left = key_is_activated(this.game.key_hold, SDLK_a);
    this.player.input.right = key_is_activated(this.game.key_hold, SDLK_d);
    */

    // 마우스 클릭 처리
    if(this.game.mouse.lbutton_down == true) {
      Vec2 mouse_pos = new Vec2(this.game.mouse.x, this.game.mouse.y);
      // 현재 플레이어 위치에서 mouse_pos 까지의 각도 계산
      Vec2 difference = mouse_pos - this.player.transform.pos;
      Vec2 speed = difference.normalize();

      spawn_bullet(this.player.transform.pos, speed);
    }

    if(this.game.mouse.rbutton_down == true) {
      spawn_special_bullets(this.player.transform.pos);
    }
  }

  
  void spawn_special_bullets(Vec2 pos) {
    if(this.es !is null && this.bs !is null) {
      float speed = this.bs.s;
      
      float unit_theta = 2.0 * PI / 10;

      // 한 10개 정도를 뿌려라..
      for(auto i = 0; i < 10; i++) {
	auto entity = this.entities.addEntity("bullet");
      
      
      // this.es 에서의 설정을 가져옴
      CShape shape = new CShape(
				this.bs.sr * 2.0 / 4.0,
				this.bs.sr * 2.0 / 4.0,
				this.bs.fr,
				this.bs.fg,
				this.bs.fb,
				this.bs.or,
				this.bs.og,
				this.bs.ob,
				this.bs.ot
				);

      
      CTransform transform = new CTransform(
					    new Vec2(pos.x, pos.y), 
					    (new Vec2(cos(unit_theta * i) * speed,
						      sin(unit_theta * i) * speed)) 
					    );
      CCollision collision = new CCollision(this.bs.cr / 4.0);
      
      CLifespan lifespan = new CLifespan(this.bs.l / 5.0);
      entity.lifespan = lifespan;
      entity.shape = shape;
      entity.transform = transform;
      entity.collision = collision;
      }
      
    }
  }

  void spawn_bullet(Vec2 pos, Vec2 speed) {
    if(this.es !is null) {
      auto entity = this.entities.addEntity("bullet");
      
      
      // this.es 에서의 설정을 가져옴
      CShape shape = new CShape(
				this.bs.sr * 2.0,
				this.bs.sr * 2.0,
				this.bs.fr,
				this.bs.fg,
				this.bs.fb,
				this.bs.or,
				this.bs.og,
				this.bs.ob,
				this.bs.ot
				);

      
      CTransform transform = new CTransform(
					    
					    new Vec2(pos.x, pos.y), 
					    (new Vec2(speed.x,
						     speed.y)) * this.bs.s
					    );
      CCollision collision = new CCollision(this.bs.cr);
      
      CLifespan lifespan = new CLifespan(this.bs.l);
      entity.lifespan = lifespan;
      entity.shape = shape;
      entity.transform = transform;
      entity.collision = collision;
    }
  }

  void spawn_small_enemies(Entity entity) {
    if(entity.vertices !is null && entity.transform !is null && entity.is_alive) {
      int vert = entity.vertices.vertices;

      float unit_theta = 2.0 * PI / vert;
      float vel = entity.transform.velocity.length();

      for(auto i = 0; i < vert; i++) {
	CLifespan lifespan = new CLifespan(30);
	Vec2 vec = new Vec2(
			    cos(unit_theta * i) * vel,
			    sin(unit_theta * i) * vel);
	
	auto part = this.entities.addEntity("enemy");
	CShape shape = new CShape(
				this.es.sr / 2.0,
				this.es.sr  / 2.0,
				0,
				0,
				0,
				this.es.or,
				this.es.og,
				this.es.ob,
				this.es.ot
				);
	CCollision collision = new CCollision(this.es.cr / 2.0);
	part.transform = new CTransform(entity.transform.pos, vec);
	part.lifespan = lifespan;
	part.shape = shape;
	part.collision = collision;
	
      }
    }
  }

  void sUserInput() {
    // 플레이어 이동 데이터 생성
    Vec2 vel = new Vec2();
    if(this.player !is null && this.player.input !is null && this.player.transform !is null && this.player.input.up) {
      vel.y -= this.ps.speed;
    }

    if(this.player !is null && this.player.input !is null && this.player.transform !is null && this.player.input.down) {
      vel.y += this.ps.speed;
    }

    if(this.player !is null && this.player.input !is null && this.player.transform !is null && this.player.input.left) {
      vel.x -= this.ps.speed;
    }

    if(this.player !is null && this.player.input !is null && this.player.transform !is null && this.player.input.right) {
      vel.x += this.ps.speed;
    }

    this.player.transform.velocity = vel.normalize() * this.ps.speed;
  }

  void sRender() {
    // Shape 이 있는 항목에 대한 그림 그리기 (사각형)
    foreach(entity; this.entities.getEntities()) {
      if(entity.transform !is null && entity.shape !is null) {
	
	ubyte alpha = 0xff;
	if(entity.lifespan !is null) {
	  alpha = cast(ubyte)((cast(float)alpha) * (entity.lifespan.total - entity.lifespan.duration) / entity.lifespan.total);
	}
	
	CShape shape = entity.shape;
	
	Rect bound =  get_bound_rect(entity.transform.pos, entity.shape.width, entity.shape.height);
	

	SDL_SetRenderDrawColor(this.game.renderer, shape.r, shape.g, shape.b, alpha);
	SDL_RenderFillRect(this.game.renderer, new SDL_Rect(bound.x, bound.y, bound.w, bound.h));
	
	// 테두리 그리기
	SDL_SetRenderDrawColor(this.game.renderer, shape.br, shape.bg, shape.bb, alpha);
	SDL_RenderDrawPoint(this.game.renderer, cast(int)(entity.transform.pos.x), cast(int)(entity.transform.pos.y));
	SDL_RenderDrawRect(this.game.renderer, new SDL_Rect(bound.x, bound.y, bound.w, bound.h));
      }
    }
  }

  void sEnemySpawner(float dt) {
    if(this.es !is null) {
      if(this.last_spwan_time >= this.es.sp) {
	this.spawn_enemy();
	this.last_spwan_time = 0.0;
      } else {
	this.last_spwan_time += dt;
      }
    }
  }

  void sCollision() {
    auto enemies = this.entities.getEntities("enemy").filter!(e => e.is_alive == true).array();
    auto bullets = this.entities.getEntities("bullet").filter!(e => e.is_alive == true).array();

    foreach(enemy; enemies) {
      if((enemy.is_alive == true &&
	  player.is_alive == true) && 
	 circle_collide(
			player.transform.pos, 
			cast(float)this.ps.cr, 
			enemy.transform.pos, 
			cast(float)this.es.cr)) {
	enemy.destroy();
	player.destroy();
	spawn_player();
      }

      foreach(bullet; bullets) {
	if(enemy.is_alive == true &&
	   bullet.is_alive == true &&
	   circle_collide(
			  enemy.transform.pos, 
			  cast(float)this.es.cr, 
			  bullet.transform.pos, 
			  cast(float)this.bs.cr)) {
	  spawn_small_enemies(enemy);
	  enemy.destroy();
	  bullet.destroy();
	}
      }
    }
  }

  override void sAction(Action action) {
    if(action.m_type == "START") {
      if(action.m_name == "UP") {
	this.player.input.up = true;
      } else if(action.m_name == "DOWN") {
	this.player.input.down = true;
      } else if(action.m_name == "LEFT") {
	this.player.input.left = true;
      } else if(action.m_name == "RIGHT") {
	this.player.input.right = true;
      }
    } else if (action.m_type == "END") {
      if(action.m_name == "UP") {
	this.player.input.up = false;
      } else if(action.m_name == "DOWN") {
	this.player.input.down = false;
      } else if(action.m_name == "LEFT") {
	this.player.input.left = false;
      } else if(action.m_name == "RIGHT") {
	this.player.input.right = false;
      }
      
    } 
  } // end of sAction


} // End of Class Scene
