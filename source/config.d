module config;

/* 
   WindowConfig 는 아래의 객체이다.
   Number Number
   WindowConfig window_config = new Window(w, h)
   가로 w, 세로 h를 가지는 윈도우 객체를 표현한다.
*/
class WindowConfig {
  int width;
  int height;


  this() {
    this.width = 0;
    this.height = 0;
  }

  this(int width, int height) {
    this.width = width;
    this.height = height;
  }

  unittest {
    WindowConfig wc = new WindowConfig();
    assert(wc.width == 0);
    assert(wc.height == 0);

    WindowConfig wc2 = new WindowConfig(1280, 720);
    assert(wc2.width == 1280);
    assert(wc2.height == 720);
  }
}


/*
  FontConfig 는 아래의 객체이다.
  String Number RNumber GNumber BNumber
  FontConfig font_config = new FontConfig("fonts/tech.ttf", 18, 255, 255, 255);
  해당 경로의 파일, 크기, 색상코드값을 갖는 객체를 표현한다.
*/

class FontConfig {
  string path;
  int size;
  int r;
  int g;
  int b;

  this() {
    this.path = "";
    this.size = 0;
    this.r = 0;
    this.g = 0;
    this.b = 0;
  }

  this(string path, int size, int r, int g, int b) {
    this.path = path;
    this.size = size;
    this.r = r;
    this.b = b;
    this.g = g;
  }

  unittest {
    FontConfig fc = new FontConfig("fonts/tech.ttf", 18, 255, 127, 0);
    assert(fc.path == "fonts/tech.ttf");
    assert(fc.size == 18);
    assert(fc.r == 255);
    assert(fc.g == 127);
    assert(fc.b == 0);
  }
}
