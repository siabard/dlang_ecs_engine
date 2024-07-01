module camera;

import types;
import entity;
import shape;
import animation;
import component;
import physics;

class Camera {
  float x = 0.0;
  float y = 0.0;

  float width = 0.0;
  float height = 0.0;

  Entity followed = null;

  this() {
    this.x = 0.0;
    this.y = 0.0;
    this.width = 0.0;
    this.height = 0.0;
  }

  this(float x, float y, float width, float height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
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
}
