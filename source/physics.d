module physics;

import types;
import std.math.operations;
import std.math;
import shape;

import entity;

enum OVERLAP_DIRECTION {
  UP, DOWN, LEFT, RIGHT, NONE
}

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
  // x가 0보다 크면 가로로 겹친다
  // y가 0보다 크면 세로로 겹친다
  Vec2 c1 = new Vec2(r1.x + r1.w / 2, r1.y + r1.h / 2);
  Vec2 c2 = new Vec2(r2.x + r2.w / 2, r2.y + r2.h / 2);

  Vec2 delta = new Vec2(
			abs(c1.x - c2.x),
			abs(c1.y - c2.y));

  float ox = r1.w / 2 + r2.w / 2 - delta.x;
  float oy = r1.h / 2 + r2.h / 2 - delta.y;

  return new Vec2(ox, oy);
}

Vec2 entity_overlap_amount(Entity src, Entity opponent) {
  Vec2 ovlp = new Vec2(0, 0);
  
  if(src.box is null || opponent.box is null) {
    return ovlp;
  }
  Vec2 pos = src.transform.pos;

  Vec2 opp_pos = opponent.transform.pos;

  Rect src_rect = get_bound_rect(pos, src.box.width, src.box.height);
  Rect opp_rect = get_bound_rect(opp_pos, opponent.box.width, opponent.box.height);

  ovlp = overlap_amount(src_rect, opp_rect);

  return ovlp;
}

Vec2 entity_prev_overlap_amount(Entity src, Entity opponent) {
  Vec2 ovlp = new Vec2(0, 0);
  
  if(src.box is null || opponent.box is null) {
    return ovlp;
  }
  Vec2 old_pos = src.transform.prev_pos;
  Vec2 src_size = new Vec2(src.box.width, src.box.height);

  Vec2 opp_pos = opponent.transform.pos;
  Vec2 opp_size = new Vec2(opponent.box.width, opponent.box.height);

  Rect src_prev_rect = get_bound_rect(old_pos, src_size.x, src_size.y);
  Rect opp_rect = get_bound_rect(opp_pos, opp_size.x, opp_size.y);

  ovlp = overlap_amount(src_prev_rect, opp_rect);

  return ovlp;
}

OVERLAP_DIRECTION overlap_direction(Entity src, Entity opponent) {
  Vec2 ovlp = entity_overlap_amount(src, opponent);
  Vec2 ovlp_prev = entity_prev_overlap_amount(src, opponent);
  
  Vec2 pos = src.transform.pos;

  Vec2 opp_pos = opponent.transform.pos;

  // x축 y축 모두 겹쳐야 판단함
  if(ovlp.x > 0 && ovlp.y > 0) {
    // 그럼 이전에 어떤 상황이었는지가 중요하다.
    if(ovlp_prev.x > 0 && ovlp_prev.y <= 0) {
      // 이전에 x만 겹쳤었다면
      // 이 상황은 y 축으로 충돌이 일어난 것이다.
      
      if(pos.y > opp_pos.y) { 
	// src가 더 아래였으니 이는 src기준 위
	return OVERLAP_DIRECTION.UP;
      } else {
	// src가 더 위였으니 이는 src기준 아래
	return OVERLAP_DIRECTION.DOWN;
      }

    } else if(ovlp_prev.x <= 0 && ovlp_prev.y > 0) {
      // 반대로 y만 겹쳤었다면
      // 이 상황은 x 축으로 충돌이 일어난 것이다.
      if (pos.x > opp_pos.x) {
	// src 가 더 오른쪽이었으니 이는 src기준 왼쪽
	return OVERLAP_DIRECTION.LEFT;
      } else {
	// src 가 더 왼쪽이었으니 이는 src기준 오른쪽 
	return OVERLAP_DIRECTION.RIGHT;
      }
    
    } 
  }
  return OVERLAP_DIRECTION.NONE;
    
}

unittest {
  import std.stdio;
  import shape;

  writeln("***** TEST OVERLAPPING *****");

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

  writeln("***** TEST OVERLAPPING END *****");
  
}

unittest {
  import std.stdio;
  import shape;
  import component;
  import animation;

  Vec2 player_pos = new Vec2(0, 20);
  Vec2 player_pos_right_moved = new Vec2(25, 20);
  Vec2 collider_pos = new Vec2(60, 20);
  float width = 40;
  float height = 30;

  writeln("**** TEST OVERLAPPING DIRECTION ***");
  
  Entity player = new Entity();
  Animation anim = new Animation();
  CAnimation canimation = new CAnimation();
  anim.size = new Vec2(40, 30);
  canimation.animations["DEFAULT"] = anim;
  canimation.current_animation = "DEFAULT";

  player.transform = new CTransform(player_pos_right_moved, new Vec2(0, 0));
  player.transform.prev_pos = player_pos;
  player.animation = canimation;

  Entity block = new Entity();
  Animation block_anim = new Animation();
  CAnimation cblock_anim= new CAnimation();
  block_anim.size = new Vec2(40, 30);
  cblock_anim.animations["DEFAULT"] = block_anim;
  cblock_anim.current_animation = "DEFAULT";
  block.animation = cblock_anim;
  block.transform = new CTransform(collider_pos, new Vec2(0, 0));

  Rect player_rect = get_bound_rect(player_pos, width, height);
  Rect player_right_moved_rect = get_bound_rect(player_pos_right_moved, width, height);
  Rect collider_rect = get_bound_rect(collider_pos, width, height);

  // colliding 검사
  Vec2 ovlp = overlap_amount(player_rect, collider_rect);
  Vec2 ovlp_moved = overlap_amount(player_right_moved_rect, collider_rect);

  writeln("olvp : x " , ovlp.x , " , ovlp. : y " , ovlp.y);
  writeln("olvp moved : x " , ovlp_moved.x , " , ovlp moved : y " , ovlp_moved.y);
  assert(ovlp.x <= 0 || ovlp.y <= 0); // 겹침 없음
  assert(ovlp_moved.x > 0 && ovlp_moved.y > 0); // 겹침 있음


  Vec2 ovlp_entity = entity_overlap_amount(player, block);
  Vec2 ovlp_prev_entity = entity_prev_overlap_amount(player, block);
  writeln("ovlp entity : x ", ovlp_entity.x , " , " , ovlp_entity.y);
  writeln("ovlp prev entity : x ", ovlp_prev_entity.x , " , " , ovlp_prev_entity.y);

  // 플레이어가 오른족으로 이동했을 때 검사
  // x가 0에서 25로 움직였음
  // 그러니 오른쪽으로 부딪혀야함.
  // 이 때 현재 ovlp_entity 가 겹친상태(x, y가 다 0 이 넘을 것)인데
  // 이전 상태에서는 x 가 음수값이어야 하며 (x 축으로 겹침발생)
  // 이전 포지션이 현재 포지션보다 작아야함.
  auto direction = overlap_direction(player, block);
  writeln(direction);

  
  
  writeln("**** TEST OVERLAPPING DIRECTION ENDED ***");
}

