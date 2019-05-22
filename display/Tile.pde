class Tile {
  int x, y;
  int w, h;
  int v;
  boolean falling;
  boolean stubborn;
  
  Tile(int x_, int y_, int w_, int h_){
    falling = false;
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    v = -5;
    if (random(1) < .2)
      stubborn = true;
  }
  
  void display() {
    
    if (falling) {
      fill(color(255));
      y += v++;
    } else {
      fill(color(0, 0, 0));
    }
    rect(x, y, w, h);
  }
  
  boolean over()  {
    if (stubborn)
      return false;
    if (mouseX >= x && mouseX <= x+w && 
        mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }
}