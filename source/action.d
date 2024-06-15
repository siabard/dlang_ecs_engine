module action;

class Action {
  string m_name = "NONE";
  string m_type = "NONE";
  
  this(string name, string type) {
    this.m_name = name;
    this.m_type = type;
  }
}
