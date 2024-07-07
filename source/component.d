module component;

import types;
import animation;
import std.stdio;

class CTransform {
  Vec2 pos;
  Vec2 prev_pos;
  Vec2 velocity;

  this() {
    this.pos = new Vec2(0, 0);
    this.prev_pos = new Vec2(0, 0);
    this.velocity = new Vec2(0, 0);
  }


  this(const Vec2 p, const Vec2 v) {
    this.pos = new Vec2(p.x, p.y);
    this.prev_pos = new Vec2(0, 0);
    this.velocity = new Vec2(v.x, v.y);
  }

  void info_write() {
    writeln(" ppos pointer ", &prev_pos);
    writeln(" prev_pos ", prev_pos.x, " , " , prev_pos.y);
    writeln(" pos ", pos.x, " , " , pos.y);
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
  float duration;
  float total;

  this(float total) {
    this.duration = 0;
    this.total = total;
  }
}

class CInput {
  bool up = false;
  bool down = false;
  bool right = false;
  bool left = false;
  bool jump = false;
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

class CVertices {
  int vertices = 0;

  this(int vertices) {
    this.vertices = vertices;
  }
}


// Animation
class CAnimation {
  string current_animation;
  Animation[string] animations;
  bool h_flip = false;
}

// Bounding Box
class CBoundingBox {
  float width = 0.0;
  float height = 0.0;

  this(float w, float h) {
    this.width = w;
    this.height = h;
  }
}


class CGravity {
  float gravity = 0.0;
}

class CDestructable {
  string animation_name;

  this(string animation_name) {
    this.animation_name = animation_name;
  }
}
