module physics;

import types;
import std.math.operations;

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
