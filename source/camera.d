module camera;

import types;
import entity;
import shape;
import animation;
import component;
import physics;

import std.math;

class Camera {
  float x = 0.0;
  float y = 0.0;
  float target_x = 0.0;
  float target_y = 0.0;

  float width = 0.0;
  float height = 0.0;

  float max_x = 0.0;
  float max_y = 0.0;
  Entity followed = null;

  this() {
    this.x = 0.0;
    this.y = 0.0;
    this.width = 0.0;
    this.height = 0.0;
  }

  this(float x, float y, float width, float height, float max_x, float max_y) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.max_x = max_x;
    this.max_y = max_y;
    this.target_x = x;
    this.target_y = y;
  }

  Vec2 get_pos() {
    return new Vec2(this.x, this.y);
  }

  Vec2 get_size() {
    return new Vec2(this.width, this.height);
  }

  bool contains(Entity entity) {
    if((entity.transform is null) || (entity.animation is null)) {
      return false;
    }

    Rect camera_rect = new Rect(this.x, this.y, this.width, this.height);
    Animation current_animation = entity.animation.animations[entity.animation.current_animation];

    Rect entity_rect = get_bound_rect(entity.transform.pos, current_animation.size.x, current_animation.size.y);

    return aabb_intersect(camera_rect, entity_rect);
  }

  void follow_pos(Vec2 pos, bool v_dir, bool h_dir) {
    import std.algorithm;

    // 대상의 position 을 쫓는다.
    // v_dir == true : 상단을 보고 있음 (상단 영역이 60% 차지해야함)
    // v_dir == false : 하단을 보고 있음 (하단 영역이 60^ 차지해야함)
    // h_dir == true: 왼쪽을 보고 있음(왼쪽 영역이 60% 차지해야함)
    // h_dir == false: 오른쪽을 보고 있음(오른족 영역이 60% 차지해야함)
    float orig_x = pos.x;
    float orig_y = pos.y;
    if(v_dir == true) {
      orig_y = min(this.max_y - this.height, max(0, pos.y - this.height * 0.6)); 
      // 0보다 작아질 수는 없음 
      // max_y 보다 밑이 보여서는 안됨
      
    } else if(v_dir == false) {
      // max_y  보다 밑이 보여서는 안됨
      // 0보다 작아질 수는 없음
      orig_y = max(0, min(this.max_y - this.height, (pos.y - this.height * 0.4)));
    }

    if(h_dir == true) {
      // 0보다 작아질 수는 없음
      // max_x 보다 오른쪽이 보여질 수 없음
      orig_x = min(this.max_x - this.width, max(0, (pos.x - this.width * 0.6)));
    } else if(h_dir == false) {
      // max_x 보다 오른쪽이 보여질 수 없음
      // 0보다 작아질 수 없음
      orig_x = max(0, min(this.max_x - this.width, (pos.x - this.width * 0.4)));
    }
    
    this.target_x = orig_x;
    this.target_y = orig_y;
  }

  void update(float dt) {
    if(this.target_x == this.x && this.target_y == this.y) {
      return;
    }

    auto delta_x = this.x - this.target_x;
    auto delta_y = this.y - this.target_y;

    // 매 틱마다 지정한 위치로 이동한다.
    this.x = this.x - delta_x * dt;
    this.y = this.y - delta_y * dt;

    if(this.x.isClose(this.target_x, 0.5, 0.5)) {
      //this.x = this.target_x;
    }

    if(this.y.isClose(this.target_y, 0.5, 0.5)) {
      //this.y = this.target_y;
    }
  }
}

unittest {
  import std.stdio;

  writeln("*** CAMERA TEST ***");
  float maxx = 1792;
  float maxy = 720;

  Camera camera = new Camera();
  camera.width = 1280;
  camera.height = 720;
  camera.max_x = maxx;
  camera.max_y = maxy;

  camera.follow_pos(new Vec2(120, 630), true, false);

  writeln("camera x " , camera.x);
  writeln("camera y " , camera.y); 
  writeln("*** CAMERA TEST END ***");
}
