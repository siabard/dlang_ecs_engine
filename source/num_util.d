module num_util;

import std.random;

int get_random(int from, int to) {
  auto rnd = Random(unpredictableSeed);
  return uniform(from, to, rnd);
}
