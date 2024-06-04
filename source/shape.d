import types: Rect;
import constants;

import std.algorithm;
import bindbc.sdl;

class Shape {
  
  Rect get_local_bound() {
    return new Rect();
  }

  void update(float dt) {}

}


/*
  Circle 은 아래의 객체이다.
  Circle c = new Circle("CGreen", 100, 100, -3, 2, 0, 255, 0, 50);
  이름 "CGreen"과 위치 (X, Y), 이동속도 (SX, SY), 색상(R, G, B), 반지름 R을 가지는
  객체를 표현한다. 위치는 원의 중점이다. 즉 중점으로부터 거리 R을 가진다.
*/

class Circle: Shape {
  string name;
  float x, y;
  float sx, sy;
  ubyte r, g, b;
  float radius;


  this() {}

  this(string name, float x, float y, float sx, float sy, ubyte r, ubyte g, ubyte b, float radius) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.sx = sx;
    this.sy = sy;
    this.r = r;
    this.g = g;
    this.b = b;
    this.radius = radius;
  }

  override Rect get_local_bound() {
    int px = cast(int)(this.x - this.radius);
    int py = cast(int)(this.y - this.radius);

    return new Rect(px, py, cast(int)(radius * 2), cast(int)(radius * 2));
  }


  override void update(float dt) {
    this.x += (this.sx * dt);
    this.y += (this.sy * dt);

    Rect bound_rect = this.get_local_bound();      

    if(bound_rect.x <= 0.0 || (bound_rect.x + bound_rect.w) > GAME_WIDTH) {
      this.x = min(GAME_WIDTH, max(0.0, this.x));
      this.sx *= -1;
    }

    if(bound_rect.y <= 0.0 || (bound_rect.y + bound_rect.h) > GAME_HEIGHT) {
      this.y = min(GAME_HEIGHT, max(0.0, this.y));
      this.sy *= -1;
    }
  } 

  unittest {
    Circle c1 = new Circle("CGreen", 100, 100, -3, 2, 0, 255, 0, 50);
    assert(c1.name == "CGreen");
    assert(c1.sx == -3);
    assert(c1.sy == 2);
  }
}


/*
  Rectangle 은 다음과 같은 객체이다.
  Rectangle r = new Rectangle("RRed",200, 200, 4, 4, 255, 0, 0, 50, 25);
  이름 "RRed", 중심점(200, 200), 속도(4, 4), 색상(255, 0, 0) 이며 
  가로 50, 세로 25의 사각형이다.
*/

class Rectangle: Shape {
  string name;
  float x, y;
  float sx, sy;
  ubyte r, g, b;
  float width, height;

  private int tl_x, tl_y, br_x, br_y;

  this() {}

  this(string name, float x, float y, float sx, float sy, ubyte r, ubyte g, ubyte b, float width, float height) {
    import std.stdio;

    this.name = name;
    this.x = x;
    this.y = y;
    this.sx = sx;
    this.sy = sy;
    this.r = r;
    this.g = g;
    this.b = b;
    this.width = width;
    this.height = height;

    // 홀수인 경우 오른쪽과 하단에 1 픽셀씩을 더하기 위한 나머지 값
    // 짝수일 때 1- (4 / 2 - ( 4 - 1 ) / 2) => 1 - (2 - 3 / 2) -> 
    //           1 - ( 2 - 1) => 1 - 1 = 0
    // 홀수일 때 1 - (5 / 2 - ( 5 - 1 ) / 2) => 1 - (2 - 4 / 2 ) ->
    //           1 - (2 - 2) = 1
    int iwidth = cast(int)width;
    int iheight = cast(int)height;
    int odd_remainder_x = 1 - (iwidth / 2 - ((iwidth - 1) / 2));
    int odd_remainder_y = 1 - (iheight / 2 - ((iheight - 1) / 2));
    
    this.tl_x = cast(int)x - (iwidth / 2);
    this.br_x = cast(int)x + (iwidth / 2) + odd_remainder_x;

    this.tl_y = cast(int)y - (iheight / 2);
    this.br_y = cast(int)y + (iheight / 2) + odd_remainder_y;
  }

  override Rect get_local_bound() {

    int iwidth = cast(int)this.width;
    int iheight = cast(int)this.height;
    int odd_remainder_x = 1 - (iwidth / 2 - ((iwidth - 1) / 2));
    int odd_remainder_y = 1 - (iheight / 2 - ((iheight - 1) / 2));
    
    this.tl_x = cast(int)this.x - (iwidth / 2);
    this.br_x = cast(int)this.x + (iwidth / 2) + odd_remainder_x;

    this.tl_y = cast(int)this.y - (iheight / 2);
    this.br_y = cast(int)this.y + (iheight / 2) + odd_remainder_y;

    return new Rect(this.tl_x, this.tl_y, cast(int)this.width, cast(int)this.height);
  }


  override void update(float dt) {  
    import std.stdio;

    this.x += this.sx * dt;
    this.y += this.sy * dt;

    Rect bound_rect = this.get_local_bound();
      
    if(bound_rect.x < 0 || (bound_rect.x + bound_rect.w) > GAME_WIDTH) {
      this.x = min(GAME_WIDTH, max(0, this.x));
      this.sx *= -1;
    }

    if(bound_rect.y < 0 || (bound_rect.y + bound_rect.h) > GAME_HEIGHT) {
      this.y = min(GAME_HEIGHT, max(0, this.y));
      this.sy *= -1;
    }
   
  } 


  unittest {
    Rectangle r1 = new Rectangle("RRed", 200, 200, 4, 4, 255, 0, 0, 50, 25);
    assert(r1.tl_x == (200 - 25));
    assert(r1.tl_y == (200 - 12));
    assert(r1.br_x == (200 + 25));
    assert(r1.br_y == (200 + 13));

    assert(r1.br_x - r1.tl_x == r1.width);
    assert(r1.br_y - r1.tl_y == r1.height);
  }
}


unittest {
  import std.stdio;

  Shape[] shapes;

  Rectangle r1 = new Rectangle("RRed1", 200, 200, 4, 4, 255, 0, 0, 50, 20);
  Rectangle r2 = new Rectangle("RRed2", 200, 200, 4, 4, 255, 0, 0, 50, 25);
  Rectangle r3 = new Rectangle("RRed3", 200, 200, 4, 4, 255, 0, 0, 50, 30);

  shapes ~= r1;
  shapes ~= r2;
  shapes ~= r3;

  Circle c1 = new Circle("CGreen", 100, 100, -3, 2, 0, 255, 0, 50);
  Circle c2 = new Circle("CGreen", 100, 100, -3, 2, 0, 255, 0, 55);
  Circle c3 = new Circle("CGreen", 100, 100, -3, 2, 0, 255, 0, 56);

  shapes ~= c1;
  shapes ~= c2;
  shapes ~= c3;

  assert(typeid(shapes[0]) == typeid(Rectangle));
  assert(typeid(shapes[3]) == typeid(Circle));
  
  Rect bound_rect = shapes[0].get_local_bound();
  Rect bound_rect_c = shapes[3].get_local_bound();

  assert(bound_rect.x != 0);
  assert(bound_rect_c.w == 100);
}
