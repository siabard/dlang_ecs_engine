import bindbc.sdl;

bool key_is_activated(bool[SDL_Scancode] keystatus, SDL_Scancode whichkey) {
  return (whichkey in keystatus) !is null &&
    keystatus[whichkey];
}
