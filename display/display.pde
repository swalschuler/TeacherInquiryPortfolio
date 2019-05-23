import processing.serial.*;
import shiffman.box2d.*;
import processing.serial.*;
import processing.video.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

Serial myPort;  
String serialVal;
char buttonPressed = '0';

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
  String portName = Serial.list()[0];
  println(Serial.list()[0]);
  if (Serial.list().length == 0)
    println("No ports found.");
  myPort = new Serial(this, portName, 9600);
  
  earth = loadImage("earth.jpg");
  
  fullScreen();
  
  box2d = new Box2DProcessing(this);  
  box2d.createWorld();
  
  balls = new ArrayList<Ball>();
  boundaries = new ArrayList<Boundary>();
  rboundaries = new ArrayList<RectBoundary>();
  setupBoundaries();
  students = new ArrayList<Student>();
  cleanPosition();
  tiles = new ArrayList<Tile>();
  setupTiles();
  
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
  
}

void draw() {
  
  while (myPort.available() > 0) {
    char inByte = myPort.readChar();
    buttonPressed = inByte;
    myPort.clear();
  }
  
  switch(state) {
    case DEFAULT:
      background(255);
      break;
    case DISPLAYING_POLITICS:
      politicsFunction();
      if (buttonPressed == '1')
        cleanPolitics();
      break;
    case DISPLAYING_SYSTEMS:
      systemFunction();
      if (buttonPressed == '2')
        cleanSystems();
      break;
    case DISPLAYING_POSITION:
      positionFunction();
      if (buttonPressed == '3')
        cleanPosition();
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
    default:
      break;
  }
  
  switch(buttonPressed) { 
    case '1':
      cleanPolitics();
      state = State.DISPLAYING_POLITICS;
      buttonPressed = '0';
      break;
    case '2':
      cleanSystems();
      state = State.DISPLAYING_SYSTEMS;
      buttonPressed = '0';
      break;
    case '3':
      cleanPosition();
      state = State.DISPLAYING_POSITION;
      buttonPressed = '0';
      break;
    case '4':
      state = State.SETTING_UP_CAMERA;
      buttonPressed = '0';
    default:
      break;
    
  }
  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);
}

void cameraFunction() {
  background(255);
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
  image(cam, (width/2) - ((cam.width*1.5)/2), (height/2) - ((cam.height*1.5)/2) + 40, cam.width*1.5, cam.height*1.5 - 40);
  textSize(16);
  fill(0);
  textAlign(CENTER);
  text("Reflection is important, but you might not always like what you find.", width/2, 40);
}

int count = 0;

void systemFunction() {
  background(255);
  box2d.step();
  
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
  textAlign(LEFT);
  
  if (mode == Mode.FAIR)
    text("All balls are given a completely random spin.\nClick to try a different mode.", 40, 40);
  else
    text("Red balls are given counterclockwise spin\nwhile white balls are given clockwise spin.\nClick to try a different mode.", 40, 40);
}

void cleanSystems() { 
  balls.clear();
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
  fill(0, 0, 0);
  textAlign(LEFT);
  text("Simply position every student in the green square. \nHint: Press the mouse button to stop the students from moving.", 40, 40);
  
  fill(color(0, 255, 0));
  rect(width/2, height/2, 100, 100);
  for (Student s : students)
    s.display();
}

void cleanPosition() {
  students.clear();
  for (int i = 0; i < 30; i++)
    students.add(new Student());
}

void politicsFunction() {
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
  textSize(16);
  fill(255);
  textAlign(LEFT);
  text("Click and drag to reveal the world.", 40, 40);
}

void cleanPolitics() {
  tiles.clear();
  setupTiles();
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