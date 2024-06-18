import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

import config;
import shape;
import types;

import constants;
import entity;
import game;

import bindbc.sdl;

import component;

import num_util;
import key_util;
import physics;
import action;

import std.math;

class Scene {
  EntityManager entities;
  Game game;
  string level_path;

  /*
    Action Map 은 SDL2의 키코드에 대하여 어떤 Action을 취할지 설정한 설정 내역이다.
    key에 Action을 등록하려면 registerAction(int, string) 으로 주어진 action_map에
    항목을 등록하도록 한다.
   */
  string[int] action_map;
  float last_spwan_time = 0.0;
    
  this(Game game) {
    this.game = game;
  }


  void scene_init() {}

  void update(float dt) {

  }

  void render() {

  }

  void do_action(Action action) {
    if(action.m_name == "NONE") { 
      return ; 
    }

    this.sAction(action);
  }

  void sAction(Action action) {}

  void register_action(int action_key, string action_name) {
    this.action_map[action_key] = action_name;
  }
  // systems


} // End of Class Scene
