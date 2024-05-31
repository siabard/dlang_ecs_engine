import std.stdio;
import std.string;
import std.conv;


import config: WindowConfig, FontConfig;
import shape: Rectangle, Circle, Shape;

void main()
{
  File file = File("./assets/config.txt", "r");
  scope(exit) {
    if(file.isOpen()) {
      file.close();
    }
  }

  Shape[] shapes = [];
  WindowConfig wc = new WindowConfig();
  FontConfig fc = new FontConfig();

  while(!file.eof()) {
    string line = strip(file.readln());
    // writeln("read line -> |", line, line.length);

    if(line.length > 0) {
      string[] tokens = line.split(" ");
      
      if(tokens[0].toLower() == "window") {
	int width = to!int(tokens[1]);
	int height = to!int(tokens[2]);

	wc.width = width;
	wc.height = height;
      } else if(tokens[0].toLower() == "font") {
	
	fc.path = tokens[1];
	fc.size = to!int(tokens[2]);
	fc.r = to!int(tokens[3]);
	fc.g = to!int(tokens[4]);
	fc.b = to!int(tokens[5]);
      } else if(tokens[0].toLower() == "circle") {
	
	Circle circ = new Circle();
	circ.name = tokens[1];
	circ.x = to!int(tokens[2]);
	circ.y = to!int(tokens[3]);
	circ.sx = to!int(tokens[4]);
	circ.sy = to!int(tokens[5]);
	circ.r = to!int(tokens[6]);
	circ.g = to!int(tokens[7]);
	circ.b = to!int(tokens[8]);
	circ.radius = to!int(tokens[9]);

	shapes ~= circ;

      } else if(tokens[0].toLower() == "rectangle") {
	Rectangle rect = new Rectangle();
	rect.name = tokens[1];
	rect.x = to!int(tokens[2]);
	rect.y = to!int(tokens[3]);
	rect.sx = to!int(tokens[4]);
	rect.sy = to!int(tokens[5]);
	rect.r = to!int(tokens[6]);
	rect.g = to!int(tokens[7]);
	rect.b = to!int(tokens[8]);
	rect.width = to!int(tokens[9]);
	rect.height = to!int(tokens[10]);

	shapes ~= rect;
      }

    }
  }

  writeln("Window Width -> |", wc.width);
  writeln("Window height -> |", wc.height);

  foreach(shape; shapes) {
    if(typeid(shape) == typeid(Rectangle)) {
      writeln("Rectangle name -> ", (cast(Rectangle)shape).name);
    } else if(typeid(shape) == typeid(Circle)) {
      writeln("Circle name -> ", (cast(Circle)shape).name);
    }
  }
}
