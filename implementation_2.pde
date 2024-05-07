/**
 * Game of Life
 * by Joan Soler-Adillon.
 *
 * Press SPACE BAR to pause and change the cell's values 
 * with the mouse. On pause, click to activate/deactivate 
 * cells. Press 'R' to randomly reset the cells' grid. 
 * Press 'C' to clear the cells' grid. The original Game 
 * of Life was created by John Conway in 1970.
 */

// Size of cells
int cellSize = 20;  //20

color[] cellData = new color[cellSize*cellSize];

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 32;

int newCells = 3; //6

// Variables for timer
int interval = 100;
int lastRecordedTime = 0;

// Colors for active/inactive cells
color alive = color(0, 200, 0);
color dead = color(0);

// Array of cells
int[][] cells; 
// Buffer to record the state of the cells and use this 
// while changing the others in the interations
int[][] cellsBuffer; 

// Pause
boolean pause = false;

import processing.video.*;
Movie movie;

void setup() {
  //size (1920, 1080);
  //size(512, 288);
  size(270, 270);
  
  //size(400, 400);
  noStroke();
  fill(0);
  background(255);
  //frameRate(2);
  
  movie = new Movie(this, "/Users/madsoleclasen/Desktop/frameoflife/20230122_100656--blind.mov");
  //movie.frameRate(1);
  //movie.speed(0.5);
  movie.play();  

  // Instantiate arrays 
  cells = new int[width/cellSize][height/cellSize];
  cellsBuffer = new int[width/cellSize][height/cellSize];

  // Initialization of cells
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      float state = random (100);
      if (state > probabilityOfAliveAtStart) { 
        state = 0;
      }
      else {
        state = 1;
      }
      cells[x][y] = int(state); // Save state of each cell
    }
  }
  drawGrid();
}

PImage move;
void draw() {
  if (movie.available()) {
    movie.read();
  }   
  move = movie.get();
  //move.resize(1920, 1080);
  //move.resize(512, 288);
  move.resize(270, 270);
  
  //move.resize(640, 480);
  
  
  
  image(move, 0,0);
  loadPixels();
  //Draw grid
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      if (cells[x][y]==1) {
        
        //if (y <= cellSize) {  
          for(int i = 0; i < 50; i++){
          //moveCell(x,y,(int)random(width/cellSize),(int)random(width/cellSize));
          moveCell(x,y,x+5,y);
          }
        //}
      }
      
      else {
        moveCell(x, y, x, y);
        
      }
      //rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
  updatePixels();
  saveFrame("frames/####.png");
  
   for (int x=0; x<newCells; x++) {
    for (int y=0; y<newCells; y++) {
      cells[(int)random(width/cellSize)][(int)random(height/cellSize)] = 1;
    }
   }
  
  // Iterate if timer ticks
  if (millis()-lastRecordedTime>interval) {
    if (!pause) {
      iteration();
      lastRecordedTime = millis();
    }
  }

  // Create  new cells manually on pause
  if (pause && mousePressed) {
    // Map and avoid out of bound errors
    int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
    xCellOver = constrain(xCellOver, 0, width/cellSize-1);
    int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
    yCellOver = constrain(yCellOver, 0, height/cellSize-1);

    // Check against cells in buffer
    if (cellsBuffer[xCellOver][yCellOver]==1) { // Cell is alive
      cells[xCellOver][yCellOver]=0; // Kill
      fill(dead); // Fill with kill color
    }
    else { // Cell is dead
      cells[xCellOver][yCellOver]=1; // Make alive
      fill(alive); // Fill alive color
    }
  } 
  else if (pause && !mousePressed) { // And then save to buffer once mouse goes up
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cellsBuffer[x][y] = cells[x][y];
      }
    }
  }
}

void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      cellsBuffer[x][y] = cells[x][y];
    }
  }

  // Visit each cell:
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      // And visit all the neighbours of each cell
      int neighbours = 0; // We'll count the neighbours
      for (int xx=x-1; xx<=x+1;xx++) {
        for (int yy=y-1; yy<=y+1;yy++) {  
          if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) { // Make sure you are not out of bounds
            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
              if (cellsBuffer[xx][yy]==1){
                neighbours ++; // Check alive neighbours and count them
              }
            } // End of if
          } // End of if
        } // End of yy loop
      } //End of xx loop
      // We've checked the neigbours: apply rules!
      if (cellsBuffer[x][y]==1) { // The cell is alive: kill it if necessary
        if (neighbours < 2 || neighbours > 3) {
          cells[x][y] = 0; // Die unless it has 2 or 3 neighbours
        }
      } 
      else { // The cell is dead: make it live if necessary      
        if (neighbours == 3 ) {
          cells[x][y] = 1; // Only if it has 3 neighbours
        }
      } // End of if
    } // End of y loop
  } // End of x loop
} // End of function

void keyPressed() {
  if (key=='r' || key == 'R') {
    // Restart: reinitialization of cells
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        float state = random (100);
        if (state > probabilityOfAliveAtStart) {
          state = 0;
        }
        else {
          state = 1;
        }
        cells[x][y] = int(state); // Save state of each cell
      }
    }
  }
  if (key==' ') { // On/off of pause
    pause = !pause;
  }
  if (key=='c' || key == 'C') { // Clear all
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cells[x][y] = 0; // Save all to zero
      }
    }
  }
}

void mousePressed(){
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      float state = random (100);
      if (state > probabilityOfAliveAtStart-10) { 
        state = 0;
      }
      else {
        state = 1;
      }
      cells[x][y] = int(state); // Save state of each cell
    }
  }  
  //for(int i = 0; i < 50; i++){
    //moveCell(7,1,(int)random(width/cellSize),(int)random(width/cellSize));
  //}
  
}

void moveCell(int inX, int inY, int outX, int outY){
  
  //loadPixels();
  
  for(int x = 0; x < cellSize; x++){
    for(int y = 0; y < cellSize; y++){
      int cx = (inX*cellSize)+x;
      int cy = (inY*cellSize)+y;
      int index = cx + (width*cy);
      
      int cellIndex = x+(cellSize*y);
      
      cellData[cellIndex] = pixels[index];
    }
  }
  

  
  for(int x = 0; x < cellSize; x++){
    for(int y = 0; y < cellSize; y++){
      int cx = (outX*cellSize)+x;
      int cy = (outY*cellSize)+y;
      int index = cx + (width*cy);
      
      int cellIndex = x+(cellSize*y);
      
      if (index < (width* height)) {
      pixels[index] = cellData[cellIndex];
      }
    }
  }
  //updatePixels();
}

void drawGrid() {

  for (int x = 0; x < width/cellSize; x++) {
    for (int y = 0; y < height/cellSize; y++) {
      stroke(0);
      noFill();

      rect(x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
}
