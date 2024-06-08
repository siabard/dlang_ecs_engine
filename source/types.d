class Rect {
  int x, y, w, h;

  this() {
    this.x = 0;
    this.y = 0;
    this.w = 0;
    this.h = 0;
  }

  this(int x, int y, int w, int h) {

    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  bool contains(const Rect rhs) const {
    return this.x <= rhs.x 
      && this.y <= rhs.y 
      && (this.x + this.w) >= (rhs.x + rhs.w) 
      && (this.y + this.h) >= (rhs.y + rhs.h);
  }

  bool is_inside_of(const Rect rhs) const {
    return rhs.x <= this.x 
      && rhs.y <= this.y 
      && (rhs.x + rhs.w) >= (this.x + this.w) 
      && (rhs.y + rhs.h) >= (this.y + this.h);
  }
}

unittest {
  import std.stdio;
  writeln("RECT");

  Rect outer = new Rect(0, 0, 100, 100);
  Rect inner = new Rect(-10, 0, 90, 90);

  assert(!outer.contains(inner) == true);
  
  writeln("outerrrr :", outer.x, outer.y, outer.w, outer.h);
  writeln("RECT END");
}

/*
  hash function from https://stackoverflow.com/questions/664014/what-integer-hash-function-are-good-that-accepts-an-integer-hash-key/12996028#12996028
*/
uint hash(uint x) {
  x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = (x >> 16) ^ x;
    return x;
}

class Vec2 {
  import std.math;

  float x, y;

  this() {
    this.x = 0.0;
    this.y = 0.0;
  }

  this(float x, float y) {
    this.x = x;
    this.y = y;
  }

  bool opEquals()(auto ref const Vec2 rhs) const {
    return this.x == rhs.x && this.y == rhs.y;

  }

  alias toHash = Object.toHash;
  uint toHash() const {
    uint seed = 2; // x, y 두 항목이니 기본 크기를 2로 한다.

    uint x_ = cast(int)this.x;
    uint y_ = cast(int)this.y;

    x_ = hash(x_);
    seed ^= x_ + 0x9e3779b9 + (seed << 6) + (seed >> 2);

    y_ = hash(y_);
    y_ = (y_ >> 16) ^ y_;

    seed ^= y_ + 0x9e3779b9 + (seed << 6) + (seed >> 2);

    return seed;
  }

  Vec2 opBinary(string op : "+")(Vec2 rhs) const {
    return new Vec2(this.x + rhs.x, this.y + rhs.y);
  }

  Vec2 opBinary(string op : "-")(Vec2 rhs) const {
    return new Vec2(this.x - rhs.x, this.y - rhs.y);
  }

  Vec2 opBinary(string op : "*")(float s) const {
    return new Vec2(this.x * s, this.y * s);
  }


  void opOpAssign(string op: "+")(Vec2 rhs) {
    this.x += rhs.x;
    this.y += rhs.y;
  }



  void scale(float s) {
    this.x *= s;
    this.y *= s;
  }

  float dist(Vec2 v) const {
    float dx = v.x - this.x;
    float dy = v.y - this.y;

    return sqrt((dx * dx) + (dy * dy));
  }

  float length() const {
    return sqrt((this.x * this.x) + (this.y * this.y));
  }


  Vec2 normalize() {
    auto l = this.length;
    return new Vec2(this.x / l, this.y / l); 
  }
  
  float angle_to(const Vec2 target) const {
    float theta = 0;

    Vec2 delta = new Vec2(target.x - this.x, target.y - this.y);
    theta = atan2(delta.y, delta.x);

    return theta;
    
  }

  unittest {

    import std.stdio;

    Vec2 v1 = new Vec2(2, 2);
    Vec2 v2 = new Vec2(3, 3);
    Vec2 v3 = new Vec2(2, 2);

    Vec2 v4 = new Vec2(4, 4);
    assert(v1 != v2);
    assert(v1 == v3);
    assert(v4 == (v1 + v3));
    assert( v1 * 2 == v4);

    v1 += v2;
    assert(v1.x == 5 && v1.y == 5);

    Vec2 v5 = new Vec2(3, 4);
    assert(v5.dist(new Vec2(0, 0)) == v5.length);
    assert(v5.length() == 5);
  }

  unittest {
    import std.stdio;

    writeln("Calcuate theta");

    Vec2 player = new Vec2(3, 3);
    Vec2 mouse = new Vec2(5, 1);
    
    float theta = player.angle_to(mouse);

    writeln("theta =>", theta);
    writeln("cos theta => ", cos(theta));
    writeln("sin theta => ", sin(theta));
  }
}


bool circle_collide(Vec2 p1, Vec2 p2, float r1, float r2) {
  float dist_sqaure = (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);
  
  return dist_sqaure < ((r1 + r2) * (r1 + r2));
}

unittest {
  import std.stdio;

  writeln("circle collisions");
  
  Vec2 p1 = new Vec2(2, 2);
  Vec2 p2 = new Vec2(4, 2);

  assert(circle_collide(p1, p2, 1.0, 1.0) == false);
  assert(circle_collide(p1, p2, 1.1, 1.0) == true);

  writeln("all circle test passed");

  
}
