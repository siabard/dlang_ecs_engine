module config;

import bindbc.sdl;

/* 
   WindowConfig 는 아래의 객체이다.
   Number Number
   WindowConfig window_config = new Window(w, h)
   가로 w, 세로 h를 가지는 윈도우 객체를 표현한다.
*/
class WindowConfig {
  float width;
  float height;


  this() {
    this.width = 0.0;
    this.height = 0.0;
  }

  this(float width, float height) {
    this.width = width;
    this.height = height;
  }

  unittest {
    WindowConfig wc = new WindowConfig();
    assert(wc.width == 0.0);
    assert(wc.height == 0.0);

    WindowConfig wc2 = new WindowConfig(1280.0, 720.0);
    assert(wc2.width == 1280.0);
    assert(wc2.height == 720.0);
  }
}


/*
  FontConfig 는 아래의 객체이다.
  String Number RNumber GNumber BNumber
  FontConfig font_config = new FontConfig("fonts/tech.ttf", 18, 255, 255, 255);
  해당 경로의 파일, 크기, 색상코드값을 갖는 객체를 표현한다.
*/

class FontConfig {
  string path;
  int size;
  int r;
  int g;
  int b;
  TTF_Font* font;

  this() {
    this.path = "";
    this.size = 0;
    this.r = 0;
    this.g = 0;
    this.b = 0;
  }

  this(string path, int size, int r, int g, int b) {
    this.path = path;
    this.size = size;
    this.r = r;
    this.b = b;
    this.g = g;
  }

  unittest {
    FontConfig fc = new FontConfig("fonts/tech.ttf", 18, 255, 127, 0);
    assert(fc.path == "fonts/tech.ttf");
    assert(fc.size == 18);
    assert(fc.r == 255);
    assert(fc.g == 127);
    assert(fc.b == 0);
  }
}


/*
  Player Specification 은 아래의 객체이다.
  int int float int int int int int int int int
  new PlayerSpec(SR, CR, S, FR, FG, FB, OR, OG, OB, OT, V)
  SR Shape Radius
  CR Collision Radius
  S  Speed
  FR, FG, FB Fill Color
  OR, OG, OB outline color
  OT outline thickness
  
*/

class PlayerSpec {
  int sr;
  int cr;
  float speed;
  ubyte fr, fg, fb;
  ubyte or, og, ob;
  int ot;

  this() {}

  this(int sr, int cr, float speed, ubyte fr, ubyte fg, ubyte fb, ubyte or, ubyte og, ubyte ob, int ot) {
    this.sr = sr;
    this.cr = cr;
    this.speed = speed;
    this.fr = fr;
    this.fg = fg;
    this.fb = fb;
    this.or = or;
    this.og = og;
    this.ob = ob;
    this.ot = ot;
  }
}

/*
  Enemy Specification 은 아래의 객체이다.
  int int float float ubyteubyte ubyte int int int int int
  SHape Radius       SR         int
  Collision Radius   CR         int
  Min / Max Speed    SMIN, SMAX float, float
  Outline Color      OR, OG, OB ubyte, ubyte, ubyte
  Outlien THickness  OT         int
  Min / Max Vertices VMIN, VMAX int, int
  Small Lifespan     L          int
  Spawn Interval     SP         int
  
*/

class EnemySpec {
  int sr;
  int cr;
  float smin, smax;
  ubyte or, og, ob;
  int ot;
  int vmin, vmax;
  int l;
  int sp;

  this() {}

  this(int sr, int cr, float smin, float smax, ubyte or, ubyte og, ubyte ob, int ot, int vmin, int vmax, int l, int sp) {
    this.sr = sr;
    this.cr = cr;
    this.smin = smin;
    this.smax = smax;
    this.or = or;
    this.ob = ob;
    this.og = og;
    this.ot = ot;
    this.vmin = vmin;
    this.vmax = vmax;
    this.l = l;
    this.sp = sp;
  }
}


/*
  Bullet Specification 은 다음의 객체이다.
  Bullet SR CR S FR FG FB OR OG OB OT V L
  Shape Radius        SR         int
  Collision Radius    CR         int
  Speed               S          float
  Fill Color          FR, FG, FB ubyte, ubyte, ubyte
  Outline Color       OR, OG, OB ubyte, ubyte, ubyte
  Outline Thickness   OT         int
  Shape Vertices      V          int
  Lifespan            L          int
*/

class BulletSpec {
  int sr, cr;
  float s;
  ubyte fr, fg, fb;
  ubyte or, og, ob;
  int ot;
  int v;
  int l;


  this() {}

  this(int sr, int cr, float s, ubyte fr, ubyte fg, ubyte fb, ubyte or, ubyte og, ubyte ob, int ot, int v, int l) {
    this.sr = sr;
    this.cr = cr;
    this.s = s;
    this.fr = fr;
    this.fg = fg;
    this.fb = fb;
    this.or = or;
    this.og = og;
    this.ob = ob;
    this.ot = ot;
    this.v = v;
    this.l = l;
  }
}



/*
  MarioSpec 은 다음의 객체이다.
  Player X Y CW CH SX SY SM GY B
  X, Y Position       X, Y      float, float
  BoundingBox W/H     CW, CH    float, float
  Left/Right SPEED    SX        float, float
  Jump Speed          SY        float
  Gravity             GY        float
  Bullet Animation    B         string
*/
class MarioSpec {
  float x = 0.0;
  float y = 0.0;
  float cw = 0.0;
  float ch = 0.0;
  float sx = 0.0;
  float sy = 0.0;
  float sm = 0.0;
  float gy = 0.0;
  string bullet = "";
}
