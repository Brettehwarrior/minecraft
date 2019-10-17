class Cam {
  
  // Object variables
  float x, y, z; //pos of camera
  float xTo, yTo, zTo; //coordinates to look at
  float ah, av; //angles for calculating lookat coords
  float speed = 12.0; //speed factor
  
  boolean isF, isB, isL, isR, isU, isD; //input booleans
  
  // Camera initialization
  Cam(float _x, float _y, float _z, float _xTo, float _yTo, float _zTo) {
    x = _x;
    y = _y;
    z = _z;
    xTo = _xTo;
    yTo = _yTo;
    zTo = _zTo;
    
    ah = 270;
    av = 90;
  }
  
  void update() {
    // constrain ah to 0-360
    if (ah >= 360) { ah -= 360; }
    if (ah < 0) { ah += 360; }
    // unit circle look direction
    xTo = cos(radians(ah));
    zTo = sin(radians(ah));
    
    // lock av between values (exact 0 and 180 have rendering errors) 
    av = constrain(av, 0.1, 179.9);
    // unit circle look direction
    yTo = tan(radians(av-90));
  }
  
  void display() {
    // 3D camera with current settings
    camera(x,y,z, x+xTo,y+yTo,z+zTo, 0,1,0); // camera y- is up
  }
  
  void move() {
    // Forward/backward movement
    if (isF) {
      x += xTo*speed;
      z += zTo*speed;
    }
    if (isB) {
      x -= xTo*speed;
      z -= zTo*speed;
    }
    // Left/right movement
    float lrmoveX = cos(radians(ah+90)), lrmoveZ = sin(radians(ah+90));  //It's basically like moving forwards but 90 degrees away
    if (isR) {
      x += lrmoveX*speed;
      z += lrmoveZ*speed;
    }
    if (isL) {
      x -= lrmoveX*speed;
      z -= lrmoveZ*speed;
    }
    // Vertical movement
    if (isU) {
      y -= speed;
    }
    if (isD) {
      y += speed;
    }
  }
  
  // This guy makes it so multiple keys can be used together
  //not sure why this is supposed to be a boolean
  boolean setMove(int k, boolean bb) { // brought to you by http://studio.processingtogether.com/sp/pad/export/ro.91tcpPtI9LrXp
    switch (k) {
      case 'W':
        return isF = bb;
      case 'A':
        return isL = bb;
      case 'S':
        return isB = bb;
      case 'D':
        return isR = bb;
      case ' ':
        return isU = bb;
      case SHIFT:
        return isD = bb;
      default:
        return bb;
    }
  }
}
