/*
* This one is actually minecraft by Trent Baker (c) 2019
*/

import com.jogamp.newt.opengl.GLWindow;

PImage textures;
Cam cam;

GLWindow win;
PVector mousePos = new PVector();

void setup() {
  size(1280, 720, P3D);
  
  ((PGraphicsOpenGL)g).textureSampling(3); // This just disables antialiasing because it looks all blurry (https://forum.processing.org/one/topic/p3d-disable-texture-smoothing-antialiasing-when-upscaling.html)
  
  // Load texture map
  textures = loadImage("textures.png");
  
  // Camera
  cam = new Cam(0,0, (height/2)/tan(PI/6), 0,0,0);
  cam.ah = 270;
  cam.av = 90;
  
  //Funky doodah reset mouse position (https://discourse.processing.org/t/extending-the-mouse-range-past-the-screen-size/4431/4)
  win = (GLWindow)surface.getNative();
  win.setPointerVisible(false);
  mousePos.set(width/2, height/2).mult(3);
}

void draw() {
  background(103, 152, 201);
  ambientLight(200, 200, 200);
  directionalLight(255, 255, 255, 0.5, 1, 0);
  noStroke();
  //noFill();
  
  // Camera stuff
  float lookSpeed = 0.15;
  cam.ah -= ((width/2)-mouseX) *lookSpeed;
  cam.av -= ((height/2)-mouseY)*lookSpeed;
  //robot.mouseMove(width-width/4, height-height/4); //center cursor
  cam.move();
  cam.update();
  cam.display();
  
  // Draw textured cube---------------------
  float w = 100; // cube width
  float texScale = 16;
  float texX = 8, texY = 0;
  
  pushMatrix();
  //translate(x,y,z);
  //rotateX(PI/8);
  //rotateY(PI/mouseX);
  beginShape(QUADS);
  texture(textures);
  
  // Y- face
  vertex(-w/2, -w/2, -w/2, texX*texScale,  texY*texScale); //1
  vertex( w/2, -w/2, -w/2, (texX*texScale)+(texScale-1), texY*texScale); //2
  vertex( w/2, -w/2,  w/2, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //3
  vertex(-w/2, -w/2,  w/2, texX*texScale,  (texY*texScale)+(texScale-1)); //4
  // Z- face
  vertex( w/2, -w/2, -w/2, texX*texScale,  texY*texScale); //2
  vertex(-w/2, -w/2, -w/2, (texX*texScale)+(texScale-1), texY*texScale); //1
  vertex(-w/2,  w/2, -w/2, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //5
  vertex( w/2,  w/2, -w/2, texX*texScale,  (texY*texScale)+(texScale-1)); //6
  // Z+ face
  vertex(-w/2, -w/2, w/2, texX*texScale,  texY*texScale); //4
  vertex( w/2, -w/2, w/2, (texX*texScale)+(texScale-1), texY*texScale); //3
  vertex( w/2,  w/2, w/2, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //7
  vertex(-w/2,  w/2, w/2, texX*texScale,  (texY*texScale)+(texScale-1)); //8
  // X- face
  vertex(-w/2, -w/2, -w/2, texX*texScale,  texY*texScale); //1
  vertex(-w/2, -w/2,  w/2, (texX*texScale)+(texScale-1), texY*texScale); //4
  vertex(-w/2,  w/2,  w/2, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //8
  vertex(-w/2,  w/2, -w/2, texX*texScale,  (texY*texScale)+(texScale-1)); //5
  // X+ face
  vertex(w/2, -w/2,  w/2, texX*texScale,  texY*texScale); //3
  vertex(w/2, -w/2, -w/2, (texX*texScale)+(texScale-1), texY*texScale); //2
  vertex(w/2,  w/2, -w/2, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //6
  vertex(w/2,  w/2,  w/2, texX*texScale,  (texY*texScale)+(texScale-1)); //7
  // Y+ face
  vertex(-w/2, w/2, -w/2, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //5
  vertex( w/2, w/2, -w/2, texX*texScale,  (texY*texScale)+(texScale-1)); //6
  vertex( w/2, w/2,  w/2, texX*texScale,  texY*texScale); //7
  vertex(-w/2, w/2,  w/2, (texX*texScale)+(texScale-1), texY*texScale); //8
  endShape();
  popMatrix();
  //z++;
  
  // Only reset mouse position if window has focus
  if (focused) { resetMousePos(); }
}

void keyPressed() {
  cam.setMove(keyCode, true);
}

void keyReleased() {
  cam.setMove(keyCode, false);
}

void resetMousePos() {
  // Reset mouse position
  win.warpPointer(width/2, height/2);
  mousePos.add(mouseX - width/2, mouseY - height/2);
}
