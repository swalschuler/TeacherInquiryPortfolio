class Student {
 int xOffset, yOffset;
 float scaleFactor;
 int x, y;
 color c;
 
 Student() {
   x = int(random(width));
   y = int(random(height));
   scaleFactor = random(-1,1);
   c = color(int(random(255)), int(random(255)), int(random(255)));
 }
 
 void display() {
   fill(c);
   if(!mousePressed) {
     x = int(x + (mouseX - pmouseX) * scaleFactor);
     y = int(y + (mouseY - pmouseY) * scaleFactor);
   }
   rect(x, y, 10, 10);
 }
   
}