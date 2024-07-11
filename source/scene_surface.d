import scene;
import game;
import bindbc.sdl;
import core.stdc.stdlib;

import num_util;

extern(C) {
  void* memset(void* s, int c, size_t n);
}


class SceneSurface: Scene {
  SDL_Texture * scene_texture;
  void* buffer;

  this(Game game, string level_path) {
    super(game);
    
    this.scene_texture = SDL_CreateTexture(this.game.renderer, 
					   SDL_PIXELFORMAT_RGBA8888,
					   SDL_TEXTUREACCESS_TARGET,
					   cast(int)this.game.wc.width,
					   cast(int)this.game.wc.height);
    SDL_SetTextureBlendMode(this.scene_texture, SDL_BLENDMODE_BLEND);
    this.buffer = malloc(200 * 200 * 4); // 가로 세로 200픽셀. RGBA 1바이트씩 4바이트
  }


  override void update(float dt) {
    // 버퍼를 지운다.
    memset(this.buffer, 0, 200*200*4);

    // pointer 를 이용해서 랜덤하게 점을 찍자.
    for(uint y = 0; y < 200; y++) {
      for(uint x = 0; x < 200; x++) {
	auto r = x;
	auto g = y;
	auto b = (x + y) / 200;
	auto a = cast(uint)get_random(0, 255);
	auto pixel = (r << 24) + (g << 16) + (b << 16) + a;
       *cast(ulong*)(this.buffer + (y * 200 + x) * 4)  = pixel;
      }
    }

    //texture를 pixel로 업데이트한다.
    auto rect = SDL_Rect(0, 0, 200, 200);
    SDL_UpdateTexture(this.scene_texture,
		      &rect, 
		      this.buffer,
		      200 * 4);
  }

  override void render() {
    auto src_rect = SDL_Rect(0, 0, cast(int)this.game.wc.width, cast(int)this.game.wc.height);
    SDL_RenderCopyEx(this.game.renderer, 
		     this.scene_texture,
		     &src_rect,
		     &src_rect,
		     0.0,
		     null,
		     SDL_FLIP_NONE);
  }

  override void scene_quit() {
    if(this.buffer !is null) {
      free(this.buffer);
    }

    if(scene_texture !is null) {
      SDL_DestroyTexture(scene_texture);
    }
   
  }
}
