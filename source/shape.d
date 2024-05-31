class Shape {}


/*
  Circle 은 아래의 객체이다.
  Circle c = new Circle("CGreen", 100, 100, -3, 2, 0, 255, 0, 50);
  이름 "CGreen"과 위치 (X, Y), 이동속도 (SX, SY), 색상(R, G, B), 반지름 R을 가지는
  객체를 표현한다. 위치는 원의 중점이다. 즉 중점으로부터 거리 R을 가진다.
*/

class Circle: Shape {
  string name;
  int x, y;
  int sx, sy;
  int r, g, b;
  int radius;


  this() {}

  this(string name, int x, int y, int sx, int sy, int r, int g, int b, int radius) {
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
  int x, y;
  int sx, sy;
  int r, g, b;
  int width, height;

  private int tl_x, tl_y, br_x, br_y;

  this() {}

  this(string name, int x, int y, int sx, int sy, int r, int g, int b, int width, int height) {
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
    int odd_remainder_x = 1 - (width / 2 - ((width - 1) / 2));
    int odd_remainder_y = 1 - (height / 2 - ((height - 1) / 2));
    
    this.tl_x = x - (width / 2);
    this.br_x = x + (width / 2) + odd_remainder_x;

    this.tl_y = y - (height / 2);
    this.br_y = y + (height / 2) + odd_remainder_y;
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
  
}
