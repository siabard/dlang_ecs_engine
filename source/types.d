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
}
