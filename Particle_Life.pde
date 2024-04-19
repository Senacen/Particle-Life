import java.util.HashSet;
int numParticles = 1000;
int numTypes = 10;
int colorStep = 360/numTypes;
int particleSize = 30;
int iteration = 0;
int howManyFramesPrintFrameRate = 30;

ArrayList<Particle> particles;
float forceMultiplier = 0.5f;
float friction = 0.2f;
float radius = 150;

// How much of the radius the min distance is at
float minRadiusProportion = 0.3f;
float transparency = 0.1f;
float[][] forces;

// Cells for space partitioning
ArrayList<ArrayList<HashSet<Particle>>> cells;
int cols, rows;
int changedCells;
int comparisons;

public void setup() {
  size(2100, 1200);
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
  particles = new ArrayList<Particle>();
  initialiseCells();
  
  for (int i = 0; i < numParticles; i++) {
    Particle p = new Particle();
    particles.add(p);
    // Add the particle to the appropriate cell
    cells.get(int(p.currentCell.y)).get(int(p.currentCell.x)).add(p);
  }
  forces = new float[numTypes][numTypes];
  setParametersRandom();
}

public void initialiseCells() {
  cells = new ArrayList<ArrayList<HashSet<Particle>>>();
  cols = floor(width / radius);
  rows = floor(height / radius);
  //[floor(height / radius)][floor(width / radius)];
  for (int i = 0; i < rows; i++) {
    ArrayList<HashSet<Particle>> row = new ArrayList<HashSet<Particle>>();
    for (int j = 0; j < cols; j++) {
      row.add(new HashSet<Particle>());
    }
    cells.add(row);
  }
}

public void draw() {
  changedCells = 0;
  comparisons = 0;
  background(0);
  for (Particle p : particles) {
    p.updateForces();
  }
  for (Particle p : particles) {
    p.updatePosition();
  }
  for (Particle p : particles) {
    p.display();
  }
  /*
  stroke(0,0,100);
  for (int i = 0; i < width; i += radius) {
    line(i, 0, i, height);
  }
  for (int i = 0; i < height; i += radius) {
    line(0, i, width, i);
  }
  noStroke();
  */
  iteration++;
  if (iteration > howManyFramesPrintFrameRate) {
    iteration = 0;
    println(frameRate, changedCells, comparisons, cells.get(0).get(0).size());
  }
  
}

public void keyPressed() {
  if (key == ' ') {
    setParametersRandom();
  }
  if (key == 's') {
    setParametersSnake();
  }
}
public void setParametersRandom() {
  for (int i = 0; i < numTypes; i++) {
    for (int j = 0; j < numTypes; j++) {
      forces[i][j] = random(0.3f, 1.0f);
      if (random(1) < 0.5f) {
        forces[i][j] *= -1;
      }
    }
  }
      
}

public void setParametersSnake() {
  // Clear forces
  for (int i = 0; i < numTypes; i++) {
    for (int j = 0; j < numTypes; j++) {
      forces[i][j] = 0;
    }
  }
  // Set up snake behaviour
  for (int i = 0; i < numTypes; i++) {
    forces[i][i] = 1;
    forces[i][(i+1) % numTypes] = 0.2f;
  }
}
