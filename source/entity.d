module entity;

import component;
import std.algorithm.iteration;
import std.array;
import std.algorithm.mutation;

import types;

alias EntityVec = Entity[];
alias EntityMap = EntityVec[string];

class EntityManager {
  EntityVec entities;
  EntityVec to_add;
  EntityMap entity_map;

  uint total_entities = 0;

  this() {
    this.total_entities = 0;
    this.entities = [];
  }

  Entity addEntity(string tag) {
    // create a new Entity object
    Entity entity = new Entity(tag, this.total_entities);
    this.total_entities++;

    this.to_add ~= entity;
    // return the shared pointer pointing to that entity
    // In D, class instances are all reference, so it is ok return class instance

    return entity;
  }

  EntityVec getEntities() {
    return this.entities;
  }

  EntityVec getEntities(string tag) {
    EntityVec result = this.entities.filter!(e => e.tag == tag).array();

    return result;
  }

  void update() {
    foreach(entity; this.to_add) {
      
      // store it in the vector of all entities
      this.entities ~= entity;

      // store it in the map of tag->entityvector
      this.entity_map[entity.tag] ~= entity;

    }

    this.to_add = [];

    // if entity is dead, remove it from entities
    this.entities = this.entities.filter!(e => e.is_alive == true).array();
    // if entity is dead, remove it from entity_map[tag]
    foreach(tag; this.entity_map.keys) {
      this.entity_map[tag] = this.entity_map[tag].filter!(e => e.is_alive == true).array();
    }

  }

  unittest {
    import std.stdio;

    EntityManager em = new EntityManager();
    Entity e1 = em.addEntity("player");
    Entity e2 = em.addEntity("mob");

    assert(e1.entity_id == 0);
    assert(e2.entity_id == 1);

    assert(em.getEntities().length == 0);
    em.update();
    
    assert(em.getEntities().length == 2);
    assert(em.getEntities("player").length == 1);
    assert(em.entities[0].entity_id == 0);
    assert(em.entities[1].entity_id == 1);

    // transform 설정
    e1.transform = new CTransform();
    e1.transform.pos = new Vec2(120, 10);
    e1.transform.velocity = new Vec2(2, 2);
    e1.transform.pos += e1.transform.velocity;
    
    assert(em.entities[0].transform.pos.x == 122);

    // 삭제 테스트
    em.entities[1].destroy();
    assert(em.getEntities().length == 2);
    assert(em.getEntities("mob").length == 1);
    assert(em.getEntities("player").length == 1);

    em.update();

    assert(em.getEntities().length == 1);
    assert(em.getEntities("mob").length == 0);
    assert(em.getEntities("player").length == 1);
    assert(em.entities[0].transform.pos.x == 122);
  }
}

class Entity {
  string tag;
  uint entity_id;
  bool is_alive;

  CTransform transform;
  CName name;
  CShape shape;
  CBBox box;

  this(string tag, uint entity_id) {
    this.entity_id = entity_id;
    this.tag = tag;
    this.is_alive = true;
    this.transform = null;
    this.name = null;
    this.shape = null;
    this.box = null;

  }

  void destroy() {
    this.is_alive = false;
  }

}