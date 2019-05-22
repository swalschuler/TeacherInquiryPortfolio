import shiffman.box2d.*;
import processing.serial.*;
import processing.video.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

Box2DProcessing box2d;
ArrayList<Ball> balls;
ArrayList<Boundary> boundaries;
ArrayList<RectBoundary> rboundaries;
ArrayList<Student> students;
ArrayList<Tile> tiles;

PImage earth;

Capture cam;
enum State {
 DEFAULT,
 SETTING_UP_CAMERA,
 DISPLAYING_CAMERA,
 DISPLAYING_SYSTEMS,
 DISPLAYING_POSITION,
 DISPLAYING_POLITICS
}

enum Mode {
  FAIR,
  UNFAIR
}
State state = State.DISPLAYING_POLITICS;
Mode mode = Mode.UNFAIR;
int filterType = 0;

void setup() {
  earth = loadImage("earth.jpg");
  
  fullScreen();
  
  box2d = new Box2DProcessing(this);  
  box2d.createWorld();
  
  balls = new ArrayList<Ball>();
  boundaries = new ArrayList<Boundary>();
  rboundaries = new ArrayList<RectBoundary>();
  setupBoundaries();
  students = new ArrayList<Student>();
  for (int i = 0; i < 30; i++)
    students.add(new Student());
  tiles = new ArrayList<Tile>();
  setupTiles();
  /*
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    cam = new Capture(this, cameras[0]);
    cam.start();
  }    
  */
}

void draw() {
  switch(state) {
    case DEFAULT:
      break;
    case DISPLAYING_SYSTEMS:
      systemFunction();
      break;
    case SETTING_UP_CAMERA:
      if (random(1) > .5)
        filterType = int(random(5));
      else
        filterType = 10;
      state = State.DISPLAYING_CAMERA;
      break;
    case DISPLAYING_CAMERA:
      cameraFunction();
      break;
    case DISPLAYING_POSITION:
      positionFunction();
    case DISPLAYING_POLITICS:
      politicsFunction();
    default:
      break;
  }
  
  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);
}

void cameraFunction() {
  if (cam.available() == true) {
    cam.read();
    switch(filterType) {
      case 0:
        cam.filter(THRESHOLD, 0.7);
        break;
      case 1:
        cam.filter(GRAY);
        break;
      case 2:
        cam.filter(INVERT);
        break;
      case 3:
        cam.filter(POSTERIZE, 4);
        break;
      case 4:
        cam.filter(BLUR, 6);
        break;
      default:
        break;      
    }
  }
 
  image(cam, (width/2) - ((cam.width*1.5)/2), (height/2) - ((cam.height*1.5)/2), cam.width*1.5, cam.height*1.5);
}

int count = 0;

void systemFunction() {
  background(255);
  box2d.step();
  
  
  /*
  if (mousePressed) {
    Ball p = new Ball(mouseX,mouseY, Mode.FAIR);
    balls.add(p);
  }
  */
  if (count++ % 50 == 0)
    balls.add(new Ball(width/2, 20, mode));
  for (Boundary b: boundaries) {
    b.display();
  }
  for (RectBoundary b: rboundaries) {
    b.display();
  }
  
  // Display all the balls
  for (Ball b: balls) {
    b.display();
  }
  
  textSize(16);
  fill(0, 0, 0);
  
  if (mode == Mode.FAIR)
    text("All balls are given a completely random spin. Click to try a different mode.", 200, 270, width/4, 500);
  else
    text("Red balls are given counterclockwise spin while white balls are given clockwise spin. Click to try a different mode.", 200, 270, width/4, 500);
  
}

void setupBoundaries() {
  for (int x = 1; x < 17; x++) {
    for (int y = 1; y < 7; y+=2) {
      boundaries.add(new Boundary((80 * x) - 40, (80 * y) + 80, 10, 10, 0));
      boundaries.add(new Boundary(80 * x, (80 * y) + 80 + 80, 10, 10, 0));
    }
  }
  boundaries.add(new Boundary(width/2, 80, 10, 10, 0));
  
  rboundaries.add(new RectBoundary(0, height/2, 10, height, 0));
  rboundaries.add(new RectBoundary(width, height/2, 10, height, 0));
  rboundaries.add(new RectBoundary(width/2, height, width, 10, 0));
  rboundaries.add(new RectBoundary(width/2, height+70, 10, height/2, 0));
  
}

void mouseClicked() {
  if (state == State.DISPLAYING_SYSTEMS) {
    if (mode == Mode.FAIR)
      mode = Mode.UNFAIR;
    else
      mode = Mode.FAIR;
  }
  //state = State.SETTING_UP_CAMERA;
}

void positionFunction() {
  
  background(255);
  
  textSize(16);
  fill(39, 109, 221);
  text("Simply position every student in the green square. \nHint: Press the mouse button to stop the students from moving.", 40, 40, width/4, 500);
  
  fill(color(0, 255, 0));
  rect(width/2, height/2, 100, 100);
  for (Student s : students)
    s.display();
}

void politicsFunction() { //<>//
  background(color(132, 180, 226));
  image(earth, 0, 0);
  fill(color(255, 0, 0));
  
  for (Tile t : tiles) {
    if (!t.falling)
      t.display(); 
  }
  for (Tile t : tiles) {
    if (t.falling)
      t.display(); 
  }  
}

void mouseDragged() {
  if (state != State.DISPLAYING_POLITICS)
    return;
  
  for (Tile t: tiles) {
    if(t.over()) {
      t.falling = true;
    }
  }
}

void setupTiles() {
  int numTiles = 20;
  int w = (width/numTiles) + 10;
  int h = (height/numTiles) + 10;
  
  for (int i = 0; i < numTiles; i++) {
    for (int j = 0; j < numTiles; j++) {
       tiles.add(new Tile(i * w, j * h, w, h));
    }
  }
}