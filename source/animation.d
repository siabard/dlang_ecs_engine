module animation;

import bindbc.sdl;

import types;
import sprite;
import std.stdio;

class Animation {
  Sprite sprite;
  uint frame_count = 0; // 프레임 총수
  uint current_frame = 0; // 현재 프레임 번호
  int animation_speed = 0; // 초당 몇 프레임?
  float elapsed_time = 0.0; // 현재 프레임 경과 시간..
  Vec2 size = new Vec2(0, 0); // 한 프레임의 크기 
  bool repeatable = true;
  bool animation_ended = false;

  this() {}

  this(SDL_Texture* texture, uint frame_count, int animation_speed, bool repeatable = true) {
    int width , height;
    SDL_QueryTexture(texture, null, null, &width, &height);
    
    int texture_width = width / frame_count;
    int texture_height = height;
    
    this.sprite = new Sprite(texture);
    this.size = new Vec2(texture_width, texture_height);
    this.frame_count = frame_count;
    this.animation_speed = animation_speed;
    this.repeatable = repeatable;
  }

  void update(float dt) {
    if(this.frame_count == 0) {
      return;
    }

    this.elapsed_time += dt;
    float fixed_time = 1.0 / cast(float)this.animation_speed;
    
    if(this.elapsed_time >= fixed_time) {
	this.current_frame = this.current_frame + 1;
	this.elapsed_time = 0.0;
	
	if(this.current_frame >= this.frame_count) {
	  if(this.repeatable) {
	    this.current_frame = 0;
	  } else {
	    this.current_frame = this.frame_count - 1;
	    this.animation_ended = true;
	  }
	}

    }
  }

  void render(SDL_Renderer* renderer, SDL_Rect* tgt_rect, SDL_RendererFlip flip_h) {
    SDL_Rect *src_rect = 
      new SDL_Rect(this.current_frame * cast(int)this.size.x, 0, 
		   cast(int)this.size.x, cast(int)this.size.y);
    
    this.sprite.render(renderer, src_rect, tgt_rect, flip_h);
  }
}
