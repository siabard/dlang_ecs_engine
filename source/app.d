import game;

void main()
{

  Game game = new Game();

  game.game_init("./assets/config.txt");

  if(game.sdl_available) {
    game.game_run();
  }

  game.game_quit();
}
