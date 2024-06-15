module animation;

import bindbc.sdl;

import types;
import sprite;

class Animation {
  Sprite sprite;
  uint frame_count = 0;
  uint current_frame = 0;
  int animation_speed = 0; // 초당 몇 프레임?
  float elapsed_time = 0.0; // 현재 프레임 경과 시간..

  Vec2 size = new Vec2(0, 0);

  this(SDL_Texture* texture, uint frame_count, int animation_speed) {
    int width , height;
    SDL_QueryTexture(texture, null, null, &width, &height);
    
    int texture_width = width / frame_count;
    int texture_height = height;
    
    SDL_Rect animation_rect = SDL_Rect(0, 0, texture_width, texture_height);
    this.sprite = new Sprite(texture, &animation_rect);
    this.size = new Vec2(texture_width / frame_count, texture_height);
    this.frame_count = frame_count;
    this.animation_speed = animation_speed;
  }

  void update(float dt) {
    this.elapsed_time += dt;
    float fixed_time = 1000.0 / cast(float)this.animation_speed;
    
    if(this.elapsed_time >= fixed_time) {
      this.current_frame = (this.current_frame + 1) % this.frame_count;
      this.elapsed_time = 0.0;
    }
  }

  void render(SDL_Renderer* renderer, SDL_Rect* tgt_rect) {
    SDL_Rect *src_rect = 
      new SDL_Rect(this.current_frame * cast(int)this.size.x, 0, 
		   cast(int)this.size.x, cast(int)this.size.y);
    
    this.sprite.render(renderer, src_rect, tgt_rect);
  }
}
