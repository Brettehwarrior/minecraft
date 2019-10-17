
class Chunk {
  
  // Variables
  float x, y, z; // position in world
  int[][][] blocks = new int[16][16][128]; // 3D array of blocks
  
  
  //PImage in here temporarily
  // Load texture map
  PImage textures = loadImage("textures.png");
  
  
  // Chunk init; pass in chunk x and z 
  Chunk(float xx, float zz) {
    x = xx;
    y = 0;
    z = zz;
  }
  
  // Fill blocks array with data
  void generateTerrain() {
    for (int i = 0; i < blocks.length; i++) { // i refers to x
      for (int j = 0; j < blocks[0].length; j++) { // j refers to z
        for (int h = 0; h < blocks[0][1].length; h++) { // h refers to y
          blocks[i][j][h] = (h < 20)?int(round(random(1))):0;
        }
      }
    }
  }
  
  // Build entire mesh for chunk
  void buildMesh() {
    // Initial variables
    float w = 50; // Half of cube width
    float texScale = 16;
    float texX = 8, texY = 0; // This texture index should change depending on block ID
    
    // Begin mesh construciton
    pushMatrix();
    beginShape(QUADS);
    texture(textures);
    
    // 3D loop for each cube
    for (int i = 0; i < blocks.length; i++) { // i refers to x
      for (int j = 0; j < blocks[0].length; j++) { // j refers to z
        for (int h = 0; h < blocks[0][1].length; h++) { // h refers to y
        
          if (blocks[i][j][h] == 1) { // only proceed if current block is not air
            float xOff = i*w*2, yOff = h*w*2, zOff = j*w*2;
            try {
              // Y- face
              if (h == 0 || blocks[i][j][h-1] == 0) {
                vertex((-w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale,  texY*texScale); //1
                vertex( (w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //2
                vertex( (w)+xOff, (-w)+yOff,  (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //3
                vertex((-w)+xOff, (-w)+yOff,  (w)+zOff, texX*texScale,  (texY*texScale)+(texScale-1)); //4
                //print("Y-");
              }
              // Z- face
              if (j == 0 || blocks[i][j-1][h] == 0) {
                vertex( (w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale,  texY*texScale); //2
                vertex((-w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //1
                vertex((-w)+xOff,  (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //5
                vertex( (w)+xOff,  (w)+yOff, (-w)+zOff, texX*texScale,  (texY*texScale)+(texScale-1)); //6
                //print("Z-");
              }
              // Z+ face
              if (j == 15 || blocks[i][j+1][h] == 0) {
                vertex((-w)+xOff, (-w)+yOff, (w)+zOff, texX*texScale,  texY*texScale); //4
                vertex( (w)+xOff, (-w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //3
                vertex( (w)+xOff,  (w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //7
                vertex((-w)+xOff,  (w)+yOff, (w)+zOff, texX*texScale,  (texY*texScale)+(texScale-1)); //8
                //print("Z+");
              }
              // X- face
              if (i == 0 || blocks[i-1][j][h] == 0) {
                vertex((-w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale,  texY*texScale); //1
                vertex((-w)+xOff, (-w)+yOff,  (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //4
                vertex((-w)+xOff,  (w)+yOff,  (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //8
                vertex((-w)+xOff,  (w)+yOff, (-w)+zOff, texX*texScale,  (texY*texScale)+(texScale-1)); //5
                //print("X-");
              }
              if (i == 15 || blocks[i+1][j][h] == 0) {
              // X+ face
                vertex((w)+xOff, (-w)+yOff,  (w)+zOff, texX*texScale,  texY*texScale); //3
                vertex((w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //2
                vertex((w)+xOff,  (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //6
                vertex((w)+xOff,  (w)+yOff,  (w)+zOff, texX*texScale,  (texY*texScale)+(texScale-1)); //7
                //print("X+");
              }
              // Y+ face (texture potentially upside-down depending how you want it, fix would be swap 6<->8 and 5<->7)
              if (h == 127 || blocks[i][j][h+1] == 0) {
                vertex((-w)+xOff, (w)+yOff,  (w)+zOff, texX*texScale,  texY*texScale); //8
                vertex( (w)+xOff, (w)+yOff,  (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //7
                vertex( (w)+xOff, (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //6
                vertex((-w)+xOff, (w)+yOff, (-w)+zOff, texX*texScale,  (texY*texScale)+(texScale-1)); //5
                //print("Y+");
              }
              //print("working ");
            } catch (Exception e) {
              println("Error rendering block in chunk: "+i+h+j);
            }
          }
        }
      }
    }
    
    // End mesh construction
    endShape();
    popMatrix();
  }
  
  void addCube() {
    // was i supposed to put something here
  }
}
