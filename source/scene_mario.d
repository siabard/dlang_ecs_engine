// Module for platformer like mario

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
import animation;

class SceneMario: Scene {

  Entity player;

  MarioSpec ps;
  EnemySpec es;
  BulletSpec bs;

  bool collision_mode = false;

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
	string[] tokens = line.split;
	if(tokens[0][0] == '#') {
	  // comment
	  // do nothing
	} else if(tokens[0].toLower() == "player") {
	  // GX GY width height speed_x speed_y speed_max gravity BulletAnimation
	  this.ps = new MarioSpec();
	  ps.x = to!float(tokens[1]);
	  ps.y = to!float(tokens[2]);
	  ps.cw = to!float(tokens[3]);
	  ps.ch = to!float(tokens[4]);
	  ps.sx = to!float(tokens[5]);
	  ps.sy = to!float(tokens[6]);
	  ps.sm = to!float(tokens[7]);
	  ps.gy = to!float(tokens[8]);
	  ps.bullet = tokens[9];

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
	} else if(tokens[0].toLower() == "tile") {
	  // Collision 이 있는 Entity
	  // Tile Ground 0 0
	  // Tile [Tile name] [Grid x] [Grid y]

	  // Grid Y는 바닥(Game Height)에서 위로 올라간다.
	  // 즉 GY = 0 은 GAME_HEIGHT - GY * TILE_SIZE 인 것
	  // Grid X는 왼쪽에서 오른쪽으로 간다.

	  string animation_name = tokens[1];
	  float grid_x = to!float(tokens[2]);
	  float grid_y = to!float(tokens[3]);
	  spawn_tile(animation_name, grid_x, grid_y);
	} else if(tokens[0].toLower() == "dec") {
	  // Collision 이 없는 Entity
	  // 나머지는 tile 과 동일하다.
	  string animation_name = tokens[1];
	  float grid_x = to!float(tokens[2]);
	  float grid_y = to!float(tokens[3]);
	  spawn_bg(animation_name, grid_x, grid_y);
	}

      }
    }

    register_action(SDLK_a, "LEFT");
    register_action(SDLK_d, "RIGHT");
    register_action(SDLK_w, "JUMP");
    register_action(SDLK_c, "COLLISION");

    spawn_player();
  }

  void spawn_tile(string animation_name, float grid_x, float grid_y) {
    auto entity = this.entities.addEntity("tile");

    // 외양 설정
    entity.animation = new CAnimation();
    entity.animation.current_animation = animation_name;
    entity.animation.animations[animation_name] = this.game.am.get_animation(animation_name);

    auto current_animation = entity.animation.animations[entity.animation.current_animation];

    // 좌표 설정 및 이동속도 (멈춰있음) 설정
    float y_pos = this.game.wc.height - grid_y * 64;
    float x_pos = grid_x * 64;
    Vec2 pos = new Vec2(x_pos + current_animation.size.x / 2, y_pos - current_animation.size.y / 2); // pos 는 해당 셀의 중점을 가르킴


    CTransform transform = new CTransform(pos, new Vec2(0, 0));
    entity.transform = transform;

    // Collision 설정
    CBoundingBox box = new CBoundingBox(current_animation.size.x, current_animation.size.y);
    entity.box = box;

  }

  void spawn_bg(string animation_name, float grid_x, float grid_y) {
    auto entity = this.entities.addEntity("tile");

    // 외양 설정
    entity.animation = new CAnimation();
    entity.animation.current_animation = animation_name;
    entity.animation.animations[animation_name] = this.game.am.get_animation(animation_name);

    auto current_animation = entity.animation.animations[entity.animation.current_animation];

    // 좌표 설정 및 이동속도 (멈춰있음) 설정
    float y_pos = this.game.wc.height - grid_y * 64;
    float x_pos = grid_x * 64;
    Vec2 pos = new Vec2(x_pos + current_animation.size.x / 2, y_pos - current_animation.size.y / 2); // pos 는 해당 셀의 중점을 가르킴

    CTransform transform = new CTransform(pos, new Vec2(0, 0));
    entity.transform = transform;

  }

  void spawn_player() {
    if(this.ps !is null) {
      auto entity = this.entities.addEntity("player");
      // Animation

      CAnimation animation = new CAnimation();
      animation.current_animation = "Stand";
      animation.animations["Stand"] = this.game.am.animations["Stand"];
      animation.animations["Run"] = this.game.am.animations["Run"];
      animation.animations["Air"] = this.game.am.animations["Air"];
      auto current_animation = animation.animations[animation.current_animation];

      // this.ps 에서의설정값으로Entity설정
      CTransform transform = new CTransform(
					    new Vec2(this.ps.x * 64 + current_animation.size.x / 2.0,
						     this.game.wc.height - this.ps.y * 64 - current_animation.size.y /  2.0),
					    new Vec2(0, 0)
					    );
      CBoundingBox box = new CBoundingBox(this.ps.cw, this.ps.ch);
      CInput input = new CInput();

      // Gravity
      CGravity gravity = new CGravity();
      gravity.gravity = this.ps.gy;

      entity.transform = transform;
      entity.box = box;
      entity.input = input;
      entity.animation = animation;
      entity.gravity = gravity;

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

  override void update(float dt) {
    sKeyMouseEvent();
    sUserInput();
    sLifespan(dt);
    sGravity(dt);
    sMovement(dt);
    sCollision();
    sAnimation(dt);
    sEnemySpawner(dt);
    this.entities.update();
  }


  override void render() {
    // clear screen
    SDL_SetRenderDrawColor(this.game.renderer, 0xaf, 0xff, 0xaf, 0xff);
    SDL_RenderClear(this.game.renderer);
    sRender();
  }

  // systems
  void sMovement(float dt) {
    Rect world_rect = new Rect(0, 0, cast(int)this.game.wc.width, cast(int)this.game.wc.height);

    foreach(entity; this.entities.getEntities()) {
      if(entity.transform !is null && entity.animation !is null) {
	entity.transform.prev_pos.x = entity.transform.pos.x;
	entity.transform.prev_pos.y = entity.transform.pos.y;
	entity.transform.pos.x = entity.transform.pos.x + entity.transform.velocity.x * dt;
	entity.transform.pos.y = entity.transform.pos.y + entity.transform.velocity.y * dt;
      }
    }

    auto entity = this.player;
    // 플레이어는 더 이상 움직이지 않아야함.
    Animation current_animation = entity.animation.animations[entity.animation.current_animation];
    Rect entity_rect = get_bound_rect(entity.transform.pos, current_animation.size.x, current_animation.size.y);
    if(!world_rect.contains(entity_rect)) {
      entity.transform.pos.x =
	min(cast(float)this.game.wc.width - current_animation.size.x / 2.0 + 1.0,
	    max(current_animation.size.x / 2.0 - 1.0, entity.transform.pos.x));

      entity.transform.pos.y =
	min(cast(float)this.game.wc.height - current_animation.size.y / 2.0 + 1.0,
	    max(current_animation.size.y / 2.0 - 1.0, entity.transform.pos.y));
    }

    // 플레이어의 속도는 시간이 지날수록 조금씩 줄어들어야한다. (틱당 25% 정도)
    entity.transform.velocity.x -= entity.transform.velocity.x * 0.35;
    if(entity.transform.velocity.x.isClose(0, 0.1, 0.1)) {
      entity.transform.velocity.x = 0;
    }
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

  void sAnimation(float dt) {
    foreach(entity; this.entities.getEntities()) {
      if(entity.animation !is null) {
	Animation current_animation = entity.animation.animations[entity.animation.current_animation];
	current_animation.update(dt);
      }
    }

    // 플레이어의 속도가 0이 된다면 멈춘다.
    // 단 점프가 아닐때
    if(this.player.transform.velocity.x.isClose(0, 0.1, 0.1) && this.player.animation.current_animation == "Run") {
      this.player.animation.current_animation = "Stand";
    }
  }

  void sUserInput() {
    // Player 이동 데이터 생성
    if(this.player !is null && this.player.input !is null && this.player.transform !is null && this.player.input.left) {
      this.player.transform.velocity.x -= this.ps.sx;
    }

    if(this.player !is null && this.player.input !is null && this.player.transform !is null && this.player.input.right) {
      this.player.transform.velocity.x += this.ps.sx;
    }

    if(this.player.transform.velocity.x < -this.ps.sm) {
      this.player.transform.velocity.x = -this.ps.sm;
    } else if(this.player.transform.velocity.x > this.ps.sm) {
      this.player.transform.velocity.x = this.ps.sm;
    }

    if(!abs(this.player.transform.velocity.y).isClose(0.0, 0.1, 0.1)) {
      this.player.animation.current_animation = "Air";
    } else if(abs(this.player.transform.velocity.x).isClose(0.0, 0.1, 0.1)) {
      this.player.animation.current_animation = "Stand";
    } else {
      this.player.animation.current_animation = "Run";
    }

    Animation current_animation = this.player.animation.animations[this.player.animation.current_animation];

    if(this.player.transform.velocity.x < 0 && current_animation.flip_h == SDL_FLIP_NONE) {
      // 왼쪽 바라보게 하기
      current_animation.flip_h = SDL_FLIP_HORIZONTAL;
    } else if(this.player.transform.velocity.x > 0 && current_animation.flip_h != SDL_FLIP_NONE) {
      // 오른쪽 바라보게 하기
      current_animation.flip_h = SDL_FLIP_NONE;
    }
  }

  void sGravity(float dt) {
    foreach(entity; this.entities.getEntities()) {
      if(entity.transform !is null && entity.gravity !is null) {
	float y_acc = entity.transform.velocity.y;

	y_acc += entity.gravity.gravity * 2;
	entity.transform.velocity.y = min(this.ps.sm, y_acc);
      }
    }
  }

  void sRender() {
    // Shape 이 있는 항목에 대한 그림 그리기 (사각형)
    foreach(entity; this.entities.getEntities()) {

      if(entity.transform !is null && entity.animation !is null) {
	ubyte alpha = 0xff;
	if(entity.lifespan !is null) {
	  alpha = cast(ubyte)((cast(float)alpha) * (entity.lifespan.total - entity.lifespan.duration) / entity.lifespan.total);
	}


	// 위치 정하기
	Vec2 pos = entity.transform.pos;

	if(this.collision_mode) {
	  if(entity.box !is null) {
	    Rect local_bound = get_bound_rect(pos, entity.box.width, entity.box.height);
	    SDL_SetRenderDrawColor(this.game.renderer, 255, 255, 255, 255);
	    SDL_RenderDrawRect(this.game.renderer,
			       new SDL_Rect(
					    cast(int)local_bound.x,
					    cast(int)local_bound.y,
					    cast(int)local_bound.w,
					    cast(int)local_bound.h));
	  }
	} else {
	  // 노출할 애니메이션
	  auto current_animation = entity.animation.animations[entity.animation.current_animation];

	  // 애니메이션의 폭
	  Vec2 size = current_animation.size;

	  Rect local_bound = get_bound_rect(pos, size.x, size.y);
	  SDL_Rect* tgt_rect = new SDL_Rect(
					    cast(int)local_bound.x,
					    cast(int)local_bound.y,
					    cast(int)local_bound.w,
					    cast(int)local_bound.h);

	  entity.animation.animations[entity.animation.current_animation].render(this.game.renderer, tgt_rect);
	}
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
    foreach(entity; this.entities.getEntities("tile")) {
      auto ovlp_dir = overlap_direction(this.player, entity);

      if(ovlp_dir != OVERLAP_DIRECTION.NONE) {
	auto ovlp = entity_overlap_amount(this.player, entity);

	if(ovlp_dir == OVERLAP_DIRECTION.DOWN && this.player.transform.velocity.y > 0) {
	  // 아래에 부딪히면..
	  // 부딪힌 y좌표만큼 위로 올린다.
	  // 속도는 올라갈 수는 있으니 0보다는 작을 수 있다.
	  this.player.transform.velocity.y = 
	    min(this.player.transform.velocity.y, 0);
	  this.player.transform.pos.y -= ovlp.y;
	} else  if (ovlp_dir == OVERLAP_DIRECTION.UP && this.player.transform.velocity.y < 0) {
	  // 위에 부딪히면..
	  // 부딪힌 y거리만큼 아래로 내린다.
	  // 속도는 떨어질 수는 있으니 0보다 클 수 있다.
	   this.player.transform.velocity.y = 
	     max(this.player.transform.velocity.y, 0);
	   this.player.transform.pos.y += ovlp.y;
	} else if(ovlp_dir == OVERLAP_DIRECTION.LEFT && this.player.transform.velocity.x < 0) {
	  // 왼쪽으로 부딪히면..
	  // 부딪힌 x거리만큼 오른쪽으로 이동한다.
	  this.player.transform.velocity.x = 0;
	  this.player.transform.pos.x += ovlp.x;
	} else if (ovlp_dir == OVERLAP_DIRECTION.RIGHT && this.player.transform.velocity.x > 0) {
	  // 오른쪽으로 부딪히면..
	  // 부딪힌 x거리만큼 왼쪽으로 이동한다.
	  this.player.transform.velocity.x = 0;
	  this.player.transform.pos.x -= ovlp.x;
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
      } else if(action.m_name == "JUMP") {
	if(this.player.transform.velocity.y.isClose(0, 0.1, 0.1)) {
	  this.player.transform.velocity.y = -this.ps.sy;
	}
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
      } else if(action.m_name == "COLLISION") {
	this.collision_mode = !this.collision_mode;
      }
    }
  } // end of sAction

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
} // End of Class Scene
