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

import std.math;

class Scene {
  Game game;

  float last_spwan_time = 0.0;
    
  this(Game game) {
    this.game = game;
  }


  void scene_init() {}

  void update(float dt) {

  }

  void render() {

  }

  // systems


} // End of Class Scene
