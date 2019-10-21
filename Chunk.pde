
class Chunk {

  // Variables
  float x, y, z; // position in world
  int[][][] blocks = new int[16][16][128]; // 3D array of blocks
  Chunk[] neighbors = new Chunk[4]; // 0=X-1 neighbor, 1=X+1 neighbor, 2=Z-1 neighbor, 3=Z+1 neighbor

  // ArrayList for faces to render
  ArrayList<Face> faces = new ArrayList<Face>();

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
        
          /** Create current block **/
          //blocks[i][j][h] = (h < 20)?int(round(random(1))):0;
          //blocks[i][j][h] = 1;
          if (h > noise((1000+i+x*16)*0.006, (1000+j+z*16)*0.006)*128) {
          //if (j >= i && h > i && h < 20) {
            blocks[i][j][h] = 1;
          }
          
        }
      }
    }
  }
  
  // Create the chunks mesh to render later
  void buildMesh() {
    // 3D loop for each cube
    for (int i = 0; i < blocks.length; i++) { // i refers to x
      for (int j = 0; j < blocks[0].length; j++) { // j refers to z
        for (int h = 0; h < blocks[0][1].length; h++) { // h refers to y

          // Initial variables
          float w = 0.5; // Half of cube width
          float texScale = 16;
          float texX = 2, texY = 0; // This texture index should change depending on block ID

          if (blocks[i][j][h] == 1) { // only proceed if current block is not air
            float xOff = i*w*2+(x*w*32), yOff = h*w*2, zOff = j*w*2+(z*w*32);
            try {
              // Y- face
              if (h == 0 || blocks[i][j][h-1] == 0) {
                Face f = new Face();
                faces.add(f);
                f.addVertex(0, (-w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale, texY*texScale); //1
                f.addVertex(1,  (w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //2
                f.addVertex(2,  (w)+xOff, (-w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //3
                f.addVertex(3, (-w)+xOff, (-w)+yOff, (w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //4
                //print("Y-");
              }
              
              /***** Z- face *****/
              if (!(j == 0)) { // If not at chunk edge
                // DRAW FACE
                if (j == 0 || blocks[i][j-1][h] == 0) { // face cull
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale, texY*texScale); //2
                  f.addVertex(1, (-w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //1
                  f.addVertex(2, (-w)+xOff, (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //5
                  f.addVertex(3, (w)+xOff, (w)+yOff, (-w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //6
                }
              } else if (neighbors[2] != null) { // If at chunk edge and neighbor exists
                // if neighbor has no block at same coordinates (but z = 15), draw face
                if (neighbors[2].blocks[i][15][h] == 0) {
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale, texY*texScale); //2
                  f.addVertex(1, (-w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //1
                  f.addVertex(2, (-w)+xOff, (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //5
                  f.addVertex(3, (w)+xOff, (w)+yOff, (-w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //6
                }
              }
              
              /***** Z+ face *****/
              if (!(j == 15)) { // If not at chunk edge
                // DRAW FACE
                if (j == 15 || blocks[i][j+1][h] == 0) { // face cull
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (-w)+xOff, (-w)+yOff, (w)+zOff, texX*texScale, texY*texScale); //4
                  f.addVertex(1, (w)+xOff, (-w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //3
                  f.addVertex(2, (w)+xOff, (w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //7
                  f.addVertex(3, (-w)+xOff, (w)+yOff, (w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //8
                }
              } else if (neighbors[3] != null) { // If at chunk edge and neighbor exists
                // draw face if neighbor's opposing block doesn's exist (==0)
                if (neighbors[3].blocks[i][0][h] == 0) {
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (-w)+xOff, (-w)+yOff, (w)+zOff, texX*texScale, texY*texScale); //4
                  f.addVertex(1, (w)+xOff, (-w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //3
                  f.addVertex(2, (w)+xOff, (w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //7
                  f.addVertex(3, (-w)+xOff, (w)+yOff, (w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //8
                }
              }
              
              /***** X- face *****/
              if (!(i == 0)) { // If not at chunk edge
                // DRAW FACE
                if (blocks[i-1][j][h] == 0) { // Face cull
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (-w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale, texY*texScale); //1
                  f.addVertex(1, (-w)+xOff, (-w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //4
                  f.addVertex(2, (-w)+xOff, (w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //8
                  f.addVertex(3, (-w)+xOff, (w)+yOff, (-w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //5
                }
              } else if (neighbors[0] != null) {
                // If neighbor has block at same coordinate but x = 15, don't draw face
                if (neighbors[0].blocks[15][j][h] == 0) {
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (-w)+xOff, (-w)+yOff, (-w)+zOff, texX*texScale, texY*texScale); //1
                  f.addVertex(1, (-w)+xOff, (-w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //4
                  f.addVertex(2, (-w)+xOff, (w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //8
                  f.addVertex(3, (-w)+xOff, (w)+yOff, (-w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //5
                }
              }
              
              /***** X+ face *****/
              if (!(i == 15)) {       // If not chunk at edge
                // DRAW FACE
                if (blocks[i+1][j][h] == 0) { // Face cull
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (w)+xOff, (-w)+yOff, (w)+zOff, texX*texScale, texY*texScale); //3
                  f.addVertex(1, (w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //2
                  f.addVertex(2, (w)+xOff, (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //6
                  f.addVertex(3, (w)+xOff, (w)+yOff, (w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //7
                }
              } else if (neighbors[1] != null) { // If at chunk edge and neighbor exists
                // If neighbor has block at same coordinates exept x = 0, don't draw face
                if (neighbors[1].blocks[0][j][h] == 0) {
                  Face f = new Face();
                  faces.add(f);
                  f.addVertex(0, (w)+xOff, (-w)+yOff, (w)+zOff, texX*texScale, texY*texScale); //3
                  f.addVertex(1, (w)+xOff, (-w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //2
                  f.addVertex(2, (w)+xOff, (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //6
                  f.addVertex(3, (w)+xOff, (w)+yOff, (w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //7
                }
              }
              
              // Y+ face (texture potentially upside-down depending how you want it, fix would be swap 6<->8 and 5<->7)
              if (h == 127 || blocks[i][j][h+1] == 0) {
                Face f = new Face();
                faces.add(f);
                f.addVertex(0, (-w)+xOff, (w)+yOff, (w)+zOff, texX*texScale, texY*texScale); //8
                f.addVertex(1, (w)+xOff, (w)+yOff, (w)+zOff, (texX*texScale)+(texScale-1), texY*texScale); //7
                f.addVertex(2, (w)+xOff, (w)+yOff, (-w)+zOff, (texX*texScale)+(texScale-1), (texY*texScale)+(texScale-1)); //6
                f.addVertex(3, (-w)+xOff, (w)+yOff, (-w)+zOff, texX*texScale, (texY*texScale)+(texScale-1)); //5
                //print("Y+");
              }
              //print("working ");
            } 
            catch (Exception e) {
              println("Error building block in chunk: X:"+i+"Y: "+h+"Z: "+j);
            }
          }
        }
      }
      //x+=0.001;
      //println(neighbors[!]);
    }
  }
  

  // Build entire mesh for chunk
  void render() {

    // Begin mesh rendering
    pushMatrix();
    beginShape(QUADS);
    texture(textures);

    // DRAW ALL FACES //
    for (Face f : faces) {
      for (int i = 0; i < 4; i++) {
        vertex(f.x[i], f.y[i], f.z[i], f.u[i], f.v[i]);
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

// Face class for adding faces I guess
class Face {
  float[] x = new float[4];
  float[] y = new float[4];
  float[] z = new float[4];
  float[] u = new float[4];
  float[] v = new float[4];
  
  // Add 1 vertex to face
  void addVertex(int i, float xx, float yy, float zz, float uu, float vv) {
    x[i] = xx;
    y[i] = yy;
    z[i] = zz;
    u[i] = uu;
    v[i] = vv;
  }
}
