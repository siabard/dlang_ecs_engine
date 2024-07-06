module text_util;

import bindbc.sdl;
import std.string;

// Render를 이용해서 해당 위치에 텍스트 출력하기
void put_utf_text(SDL_Renderer *renderer, TTF_Font *font,  string contents, int x, int y, SDL_Color color) {
  int w, h;

  // 크기를 결정한다.
  TTF_SizeText(font, contents.toStringz, &w, &h);
  SDL_Rect rect = SDL_Rect(x, y, w, h);

  SDL_Surface* font_surface = TTF_RenderUTF8_Blended(font, contents.toStringz, color);
  SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, font_surface);
  SDL_FreeSurface(font_surface);

  SDL_RenderCopy(renderer,
		 texture,
		 null,
		 &rect);

  SDL_DestroyTexture(texture);
}
