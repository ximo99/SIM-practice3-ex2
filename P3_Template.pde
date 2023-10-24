// Authors:
// Julian Rodriguez
// Ximo Casanova

// Description of the problem:
// Simulation of a fluid (collision model based on springs, adding Grid and Hash type data structures)

// Display values:
final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;    // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1400;   // Display width (pixels)
int DISPLAY_SIZE_Y = 950;    // Display height (pixels)

// Structure of the models
enum StructureType 
{
  NONE,
  GRID,
  HASH
}

StructureType actualStructure = StructureType.HASH;
Grid grid;
HashTable hash;

// Draw values:
final int [] BACKGROUND_COLOR = {160};
final int [] REFERENCE_COLOR = {0, 255, 0};
final int [] OBJECTS_COLOR = {255, 0, 0};
final float OBJECTS_SIZE = 1.0;   // Size of the objects (m)
final float PIXELS_PER_METER = 20.0;   // Display length that corresponds with 1 meter (pixels)
final PVector DISPLAY_CENTER = new PVector(0.0, 0.0);   // World position that corresponds with the center of the display (m)

// Time control:
final float SIM_STEP = 0.05;  // Simulation time-step (s)

int _lastTimeDraw = 0;       // Last measure of time in draw() function (ms)
float _simTime = 0.0;        // Simulated time (s)
float _deltaTimeDraw = 0.0;  // Time between draw() calls (s)
float _elapsedTime = 0.0;    // Elapsed (real) time (s)
float _drawTime = 0.0;       // Draw time counter (for one iteration)
float _computTime = 0.0;     // Computation time counter (for one iteration)
float _totalTime = 0.0;           // Total time (for one iteration)

// Classes:
ParticleSystem _system;   // Particle system
ArrayList<PlaneSection> _planes;    // Planes representing the limits

// Problem variables:
boolean _computePlaneCollisions = true; // Collision counting
boolean _drawCells = false;  // Drawing of cells
boolean _openDoor = false;  // Open lower door

// Parameters of the problem: 
final float Gc    = 9.801;  // Gravity constant (m/(s*s))
final PVector G   = new PVector(0.0, Gc);  // Acceleration due to gravity (m/(s*s))

final float Kd = -4.0;   // Friction constant
final float Ke = 0.8;    // Spring constant

int rows = 10;  // Rows
int cols = 10;  // Columns

// Impress values:
//PrintWriter output1;
//String file1 = "frame500.txt";
//String file1 = "frame1000.txt";
//String file1 = "frame2000.txt";
//String file1 = "frame3000.txt";
//String file1 = "frame4000.txt";
//String file1 = "frame5000.txt";
//String file1 = "frame6000.txt";

//PrintWriter output2;
//String file2 = "total500.txt";
//String file2 = "total1000.txt";
//String file2 = "total2000.txt";
//String file2 = "total3000.txt";
//String file2 = "total4000.txt";
//String file2 = "total5000.txt";
//String file2 = "total6000.txt";

//PrintWriter output3;
//String file3 = "comput500.txt";
//String file3 = "comput1000.txt";
//String file3 = "comput2000.txt";
//String file3 = "comput3000.txt";
//String file3 = "comput4000.txt";
//String file3 = "comput5000.txt";
//String file3 = "comput6000.txt";

void settings()
{
  size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y);
}

void setup()
{
  initSimulation();
  _lastTimeDraw = millis();
  _drawTime = millis();
  
  // To print values
  /*
  output1 = createWriter(file1);
  output2 = createWriter(file2);
  output3 = createWriter(file3);
  */
}

void initSimulation()
{
  _system = new ParticleSystem();
  _planes = new ArrayList<PlaneSection>();
  
  // 6 point definition
  PVector topLeft   = new PVector(100, 50);
  PVector topRight  = new PVector(1300, 50);
  PVector medLeft   = new PVector(150, 400);
  PVector medRight  = new PVector(1250, 400);
  PVector botLeft   = new PVector(600, 700);
  PVector botRight  = new PVector(800, 700);
  
  // Definition of 6 planes from the 6 previous points
  PlaneSection top      = new PlaneSection(topLeft.x, topLeft.y, topRight.x, topRight.y, false);
  PlaneSection bottom   = new PlaneSection(botLeft.x, botLeft.y, botRight.x, botRight.y, false);
  PlaneSection leftSup  = new PlaneSection(topLeft.x, topLeft.y, medLeft.x, medLeft.y, false);
  PlaneSection leftLow  = new PlaneSection(medLeft.x, medLeft.y, botLeft.x, botLeft.y, false);
  PlaneSection rightSup = new PlaneSection(medRight.x, medRight.y, topRight.x, topRight.y, false);
  PlaneSection rightLow = new PlaneSection(botRight.x, botRight.y, medRight.x, medRight.y, false);
  
  // Add planes
  _planes.add(top);
  _planes.add(bottom);
  _planes.add(leftSup);
  _planes.add(leftLow);
  _planes.add(rightSup);
  _planes.add(rightLow);
  
  grid = new Grid(rows, cols);
  hash = new HashTable(_system.getNumParticles()*2, width/rows);
}

void drawStaticEnvironment()
{
  background(165, 165, 165);
  
  fill(0);
  textSize(20);
  
  // Information displayed on the screen
  // Variables of time, model used and number of total particles
  text("Number of particles: "+ _system.getNumParticles(), 100, 775);
  text("Actual structure: "+ actualStructure, 100, 800);
  text("Frame rate: " + 1.0/_deltaTimeDraw + " fps", 100, 825);
  text("Elapsed time: " + _elapsedTime + " s", 100, 850);
  text("Simulated time: " + _simTime + " s", 100, 875);
  text("Computation time: " + _computTime + "s", 100, 900);
  text("Draw time: " + _drawTime + "s", 100, 925);
  
  // Keys to press to modify the simulation
  text("Press N to not use any data structure. ", 800, 775);
  text("Press G to use GRID", 800, 800);
  text("Press H to use HASH. ", 800, 825);
  text("Press F to display the cells.", 800, 850);
  text("Press P to open or close the lower door. ", 800, 875);
  text("Press R to reboot the system. ", 800, 900);
  text("Press the mouse insert to insert particles. ", 800, 925);
  
  // To print values
  /*
  output1.println(1.0/_deltaTimeDraw);
  output2.println(_totalTime);
  output3.println(_computTime);
  */
  
  fill(255, 255, 255);
  beginShape();
  vertex(100, 50);
  vertex(1300, 50);
  vertex(1250, 400);
  vertex(800, 700);
  vertex(600, 700);
  vertex(150, 400);
  endShape(CLOSE);
  
  // Drawing from the plans
  for(int i = 0; i < _planes.size(); i++)
  {
      PlaneSection p = _planes.get(i);
      p.draw();
  } //<>//
  
  // Draw cells
  if (_drawCells)
  {
    grid.showCells();  
  }
}

void draw() 
{
  int timeNow1, timeNow2, timeNow3;
  
  timeNow1 = millis();
  _deltaTimeDraw = (timeNow1 - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = timeNow1;   
  
  _system.run();
  _system.updateStructure();
  _system.computeCollisions(_planes, _computePlaneCollisions);
  
  timeNow2 = millis();
  drawStaticEnvironment();
  _system.display();
  timeNow3 = millis();
   
  _drawTime = (timeNow3 - timeNow2)/1000.0;   
  _computTime = (timeNow2 - timeNow1)/1000.0;
  _totalTime = _drawTime + _computTime;
  
  _simTime += SIM_STEP;
  
  // To print values
  /*
  // Close the program after 30 seconds
  if (_elapsedTime > 30)
  {
    stop();
    exit();
  }
  */
}

// Add particles with a mouse click
void mouseClicked() 
{
  PVector pos = new PVector(mouseX, mouseY);
   _system.addMoreParticles(pos);
}

// Modify the simulation by pressing the indicated keys
void keyPressed()
{
  switch(key)
  {
    case 'n':
    case 'N':
      actualStructure = StructureType.NONE;
    break;
    
    case 'g':
    case 'G':
      actualStructure = StructureType.GRID;
    break;
    
    case 'h':
    case 'H':
      actualStructure = StructureType.HASH;
    break;
    
    case 'r':
    case 'R':
      reset();
    break;
   
    case 'p':
    case 'P':
      _openDoor = !_openDoor;
      openLowerDoor();
    break;
    
    case 'f':
    case 'F':
      _drawCells = !_drawCells;
    break;
      
    default:
      break;
  }
}

// If the user presses the letter P, the bottom plane is deleted
void openLowerDoor()
{
  if (_openDoor)
  {
    PVector pos = new PVector(0, 0);
    _planes.get(1).setPoint1(pos);
    _planes.get(1).setPoint2(pos);
  }
  else
  {
    PVector pos1 = new PVector(600, 700);
    PVector pos2 = new PVector(800, 700);
    
    _planes.get(1).setPoint1(pos1);
    _planes.get(1).setPoint2(pos2);
  }
}

// System reset
void reset()
{
  _system._particles.clear();
  _system = new ParticleSystem();
  actualStructure = StructureType.NONE;
  
  _simTime = 0.0; 
    
  _computePlaneCollisions = true;
  _drawCells = false;
}

// Stop system
void stop()
{
    // To print values
    /*
    output1.flush();
    output1.close();
    output2.flush();
    output2.close();
    output3.flush();
    output3.close();
    */
    exit();
}
