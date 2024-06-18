module sprite;
// Texture를 특정 Rect 에 맞춘 Sprite

import bindbc.sdl;

class Sprite {
  SDL_Texture* texture;

  this(SDL_Texture* texture) {
    this.texture = texture;
  }

  void render(SDL_Renderer* renderer, SDL_Rect *src_rect, SDL_Rect* tgt_rect, SDL_RendererFlip flip = SDL_FLIP_NONE) {
    if(this.texture !is null) {
      SDL_RenderCopyEx(renderer, this.texture, src_rect, tgt_rect, 0.0, null, flip);
    }
  }
}
