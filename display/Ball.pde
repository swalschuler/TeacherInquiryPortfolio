// A rectangular box
class Ball {
  //  Instead of any of the usual variables, we will store a reference to a Box2D Body
  Body body;      

  float r; // radius
  color c;

  Ball(float x, float y, Mode mode) {
    r = 7;

    // Build Body
    BodyDef bd = new BodyDef();      
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    body = box2d.createBody(bd);


   // Define a polygon (this is what we use for a rectangle)
    CircleShape circle = new CircleShape();
    circle.m_radius = box2d.scalarPixelsToWorld(r);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = circle;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.7;
    fd.restitution = 0.5;

    // Attach Fixture to Body               
    body.createFixture(fd);
    if (mode == Mode.FAIR) {
      body.setAngularVelocity(random(-9, 9));
      if (random(1) > .5) {
        c = color(255, 0, 0);
      } else {
        c = color(255, 255, 255);
      }
    }
    if (mode == Mode.UNFAIR) {
      if (random(1) > .5) {
        c = color(255, 0, 0);
        body.setAngularVelocity(random(9, 0));
      } else {
        c = color(255, 255, 255);
        body.setAngularVelocity(random(-9, 0));
      }
        
    }
      
  }

  void display() {
    // We need the Body’s location and angle
    Vec2 pos = box2d.getBodyPixelCoord(body);    
    float a = body.getAngle();

    pushMatrix();
    translate(pos.x,pos.y);    // Using the Vec2 position and float angle to
    rotate(-a);              // translate and rotate the rectangle
    fill(c);
    stroke(0);
    ellipseMode(CENTER);
    ellipse(0,0,r*2,r*2);
    line(0, 0, r, 0);
    popMatrix();
  }

}