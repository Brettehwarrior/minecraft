/* minecraft by Trent Baker (c) 2019
*
* This is an attempt to recreate Mojang's Minecraft (2009) in Processing
* All code written by Trent baker unless shamefully copied from forums (comments with links throughout)
* Shoutouts to Processing's incredible documentation and the Coding Train's fantastic tutorials
*/

import com.jogamp.newt.opengl.GLWindow;
import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2ES2;

PJOGL pgl; //https://forum.processing.org/two/discussion/25272/how-to-enable-backface-culling-in-p3d
GL2ES2 gl;

GLWindow win;
PVector mousePos = new PVector();

PImage textures;
Cam cam;
float w = 1280, h = 720;
float fov = PI/3, ar = w/h; // FOV and Aspect ratio values

// Create ArrayList for loaded chunks
ArrayList<Chunk> chunks = new ArrayList<Chunk>();
ArrayList<Chunk> chunksToRemove = new ArrayList<Chunk>();

/************************************************/
/***************** SETUP METHOD *****************/
/************************************************/

void setup() {
  // Create canvas (window)
  size(1280, 720, P3D);
  
  // Disable antialiasing
  ((PGraphicsOpenGL)g).textureSampling(3); // https://forum.processing.org/one/topic/p3d-disable-texture-smoothing-antialiasing-when-upscaling.html
  
  // Load texture map to pass to chunk objects
  textures = loadImage("textures.png");
  
  // Camera
  cam = new Cam(0,0,0, 0,0,0); //z was formerly (height/2)/tan(PI/6)
  
  /**** Chunks init ****/
  // Create first chunks (for now it makes 16 chunks around camera spawn)
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      chunks.add(new Chunk(i, j));
    }
  }
  
  // Generate terrain for chunks
  for (Chunk c : chunks) {
    // Generate terrain data
    c.generateTerrain();
    c.textures = textures;
    
    chunkAddNeighbors(c);
  }
  
  // Generate mesh data for chunk drawing
  // Seperate loop to ensure all chunks have data
  for (Chunk c : chunks) {
    c.buildMesh();
  }
  
  //Funky doodah reset mouse position (https://discourse.processing.org/t/extending-the-mouse-range-past-the-screen-size/4431/4)
  win = (GLWindow)surface.getNative();
  win.setPointerVisible(false);
  mousePos.set(width/2, height/2).mult(3);
  
}


/*********************************************/
/**************** DRAW METHOD ****************/
/*********************************************/

void draw() {
  background(103, 152, 201);
  // Back-face culling
  pgl = (PJOGL) beginPGL();  
  gl = pgl.gl.getGL2ES2();
  gl.glEnable(GL.GL_CULL_FACE);
  gl.glCullFace(GL.GL_BACK);
  
  // Camera stuff
  float lookSpeed = 0.15;
  cam.ah -= ((width/2)-mouseX) *lookSpeed;
  cam.av -= ((height/2)-mouseY)*lookSpeed;
  cam.move();
  perspective(fov, ar, 0.01, 10000); // This one extends the render distance near and far
  cam.update();
  cam.display();
  
  // lights after camera so it is dependant on camera transformations
  ambientLight(140, 140, 140);
  directionalLight(200, 200, 200, 0.8, 0.9, -0.5);
  
  // Add new chunks where they are needed
  for (int i = -3; i < 4; i++) {
    for (int j = -3; j < 4; j++) {
      // If chunk with coords doesn't exist
      boolean exists = false;
      for (Chunk c : chunks) {
        if (c.x == cam.chunkX+i && c.z == cam.chunkZ+j) {
          exists = true;
        }
      }
      // Create chunk at coords
      if (!exists) {
        Chunk newChunk = new Chunk(cam.chunkX+i, cam.chunkZ+j);
        chunks.add(newChunk);
        newChunk.generateTerrain();
        newChunk.textures = textures;
        chunkAddNeighbors(newChunk);
        newChunk.buildMesh();
        // Update neighbors' meshes
        //for (int n = 0; n < 4; n ++) {
        //  try {
        //    newChunk.neighbors[n].buildMesh();
        //  } catch (Exception e) {
        //    println("Could not find chunk neighbor");
        //  }
        //}
      }
    }
  }
  
  // Render chunks
  for (Chunk c : chunks) {
    if (screenX(c.x*16, cam.y, c.z*16) >= -300 && screenX(c.x*16, cam.y, c.z*16) <= width+300) { // Attempt at view frustum culling
     c.render();
    }
    
    // Add distant chunks to remove list
    if (dist(cam.chunkX, cam.chunkZ, c.x, c.z) > 4) {
      chunksToRemove.add(c);
    }
  }
  
  // Remove chunks in remove list
  for (Chunk c : chunksToRemove) {
    try {
      chunks.remove(c);
    } catch (Exception e) {
      println("Error while removing chunk "+c+" from chunks ArrayList");
    }
  }
  
  // Clear remove list
  for (int i = 0; i < chunksToRemove.size(); i++) {
    chunksToRemove.remove(i);
  }
  
  /*** Draw GUI ***/
  hint(DISABLE_DEPTH_TEST);
  noLights();
  camera();
  text("FPS: "+frameRate, width-100, 20);
  text("X: "+cam.x, 10, 20);
  text("Y: "+cam.y, 10, 40);
  text("Z: "+cam.z, 10, 60);
  
  text("Chunk X: "+cam.chunkX, 10, 100);
  text("Chunk Z: "+cam.chunkZ, 10, 120);
  
  text("H angle: "+cam.ah, 10, 160);
  text("V angle: "+cam.av, 10, 180);
  hint(ENABLE_DEPTH_TEST);
  
  // Reset mouse position if window has focus
  if (focused) { resetMousePos(); }
}

void chunkAddNeighbors(Chunk c) {
  // Add neighbors
  for (Chunk n : chunks) {
    // Z offset = 0 (X neighbors)
    if (n.z == c.z) {
      if (n.x == c.x-1) {
        c.neighbors[0] = n;
      } else if (n.x == c.x+1) {
        c.neighbors[1] = n;
      }
    }
    // X offset = 0 (Z neighbors)
    if (n.x == c.x) {
      if (n.z == c.z-1) {
        c.neighbors[2] = n;
      } else if (n.z == c.z+1) {
        c.neighbors[3] = n;
      }
    }
    }
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

// Adjust camera speed with scrolling
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  
  cam.speed -= e/10;
  
  //fov += e/10;
  //println("FOV: "+fov);
  
  //ar += e/100;
  //println("Aspect Ratio: "+ar);
}
