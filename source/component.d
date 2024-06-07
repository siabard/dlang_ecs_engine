module component;

import types;

class CTransform {
  Vec2 pos;
  Vec2 velocity;

  this() {
    this.pos = new Vec2(0, 0);
    this.velocity = new Vec2(0, 0);
  }

  this(const Vec2 p, const Vec2 v) {
    this.pos = new Vec2(p.x, p.y);
    this.velocity = new Vec2(v.x, v.y);
  }
}

class CName {
  string name;

  this() {
    this.name = "";
  }

  this(string name) {
    this.name = name;
  }
}


class CCollision {
  float radius;

  this(float radius) {
    this.radius = radius;
  }
}


class CScore {
  int score;

  this(int score) {
    this.score = score;
  }
}


class CLifespan {
  int duration;

  this(int duration) {
    this.duration = duration;
  }
}

class CInput {
  bool up = false;
  bool down = false;
  bool right = false;
  bool left = false;

  bool shoot = false;
}

class CShape {
  float width  = 0.0;
  float height = 0.0;

  // 도형 색상 
  ubyte r = 0;
  ubyte g = 0;
  ubyte b = 0;

  // 도형 테두리 색상
  ubyte br = 0;
  ubyte bg = 0;
  ubyte bb = 0;

  // 도형 테두리 두께
  int thickness = 0;

  this(float width, float height, ubyte r, ubyte g, ubyte b, int thickness) {
    this.width = width;
    this.height = height;
    this.r = r;
    this.g = g;
    this.b = b;
    this.thickness = thickness;
  }

  this(float width, float height, ubyte r, ubyte g, ubyte b, ubyte br, ubyte bg, ubyte bb, int thickness) {
    this.width = width;
    this.height = height;
    this.r = r;
    this.g = g;
    this.b = b;
    this.br = br;
    this.bg = bg;
    this.bb = bb;
    this.thickness = thickness;
  }
}
