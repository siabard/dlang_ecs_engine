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

class CShape {}

class CBBox {}
