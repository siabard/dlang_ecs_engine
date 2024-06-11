module physics;

import types;
import std.math.operations;
import std.math;

// circle collisions
// C1(x, y1, r1)과 C2(x2, y2, r2)가 collide 하는가?

bool circle_collide(Vec2 c1, float r1, Vec2 c2, float r2) {
  float distance = 
    (c1.x - c2.x) * (c1.x - c2.x) + 
    (c1.y - c2.y) * (c1.y - c2.y);
    
  float radius_diff = r1 + r2;
  
  return distance < radius_diff * radius_diff;
}

// aabb

// point
bool aabb_point_inside(Rect r, Vec2 p) {
  return r.x < p.x &&
    r.y < p.y &&
    r.x + r.w > p.x &&
    r.y + r.h > p.y;
}

// intersect
bool aabb_intersect(Rect r1, Rect r2) {
  return r1.y < r2.y + r2.h &&
    r2.y < r1.y + r1.h &&
    r1.x < r2.x + r2.w &&
    r2.x < r1.x + r1.w;
}


// overlapping
bool is_overlap(float w1, float w2, float d) {
  return (w1 / 2) + (w2 / 2) - d > 0;
}

Vec2 overlap_amount(Rect r1, Rect r2) {
  Vec2 c1 = new Vec2(r1.x + r1.w / 2, r1.y + r1.h / 2);
  Vec2 c2 = new Vec2(r2.x + r2.w / 2, r2.y + r2.h / 2);

  Vec2 delta = new Vec2(
			abs(c1.x - c2.x),
			abs(c1.y - c2.y));

  float ox = r1.w / 2 + r2.w / 2 - delta.x;
  float oy = r2.h / 2 + r2.h / 2 - delta.y;

  return new Vec2(ox, oy);
}

unittest {
  import std.stdio;
  import shape;

  writeln("TEST OVERLAPPING");

  Vec2 pos1 = new Vec2(20, 20);
  Vec2 pos2 = new Vec2(55, 25);
  Vec2 pos1_new = new Vec2(40, 20);
  Vec2 pos1_new2 = new Vec2(80, 20);
  float w1 = 20;
  float h1 = 20;
  float w2 = 20;
  float h2 = 20;

  Rect r1 = get_bound_rect(pos1, w1, h1);
  Rect r2 = get_bound_rect(pos2, w2, h2);
  Rect r1_new = get_bound_rect(pos1_new, w1, h1);
  Rect r1_new2 = get_bound_rect(pos1_new2, w1, h1);
  Vec2 ovlp = overlap_amount(r1, r2);
  Vec2 new_ovlp = overlap_amount(r1_new, r2);
  Vec2 new_ovlp2 = overlap_amount(r1_new2, r2);
  writeln("OVLP ", ovlp.x, " , ", ovlp.y);
  writeln("OVLP NEW ", new_ovlp.x, " , ", new_ovlp.y);
  writeln("OVLP NEW2 ", new_ovlp2.x, " , ", new_ovlp2.y);

  writeln("TEST OVERLAPPING END");
  
}
