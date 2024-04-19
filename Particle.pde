class Particle {
  PVector position;
  PVector oldCell;
  PVector currentCell;
  PVector velocity;
  PVector totalForce;
  PVector acceleration;
  int type;
  
  Particle() {
    position = new PVector(random(width), random(height));
    currentCell = calculateCell(position);
    oldCell = currentCell.copy();
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    totalForce = new PVector(0, 0);
    type = int(random(numTypes));
  }
  
  public void updateForces() {
    
    PVector direction = new PVector(0,0);
    totalForce.mult(0);
    acceleration.mult(0);
    float distance;
    
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int cellX = (int(currentCell.x + i) + cols) % cols;
        int cellY = (int(currentCell.y + j) + rows) % rows;
        for (Particle p : cells.get(cellY).get(cellX)) {
          comparisons++;
          if (p == this) {
            continue;
          }
          
          // Calculate direction vector
          direction.mult(0);
          direction = p.position.copy();
          direction.sub(this.position);
          
          // Wrap the direction vector around the borders
          if (direction.x > 0.5f * width) {
            direction.x -= width;
          }
          if (direction.x < -0.5f * width) {
            direction.x += width;
          }
          if (direction.y > 0.5f * height) {
            direction.y -= height;
          }
          if (direction.y < -0.5f * height) {
            direction.y += height;
          }
          
          // Calculate distance and direction
          distance = direction.mag();
          direction.normalize();
          
          // Apply force function
          if (distance < radius){
            PVector force = direction.copy();
            force.mult(forceFunction(distance / radius, forces[type][p.type]));
            force.mult(forceMultiplier);
            totalForce.add(force);
          }
        }
      }
    }
    
    /*
    for (Particle p : particles) {
      comparisons++;
      if (p == this) {
        continue;
      }
      
      // Calculate direction vector
      direction.mult(0);
      direction = p.position.copy();
      direction.sub(this.position);
      
      // Wrap the direction vector around the borders
      if (direction.x > 0.5 * width) {
        direction.x -= width;
      }
      if (direction.x < -0.5 * width) {
        direction.x += width;
      }
      if (direction.y > 0.5 * height) {
        direction.y -= height;
      }
      if (direction.y < -0.5 * height) {
        direction.y += height;
      }
      
      // Calculate distance and direction
      distance = direction.mag();
      direction.normalize();
      
      // Apply force function
      if (distance < radius){
        PVector force = direction.copy();
        force.mult(forceFunction(distance / radius, forces[type][p.type]));
        force.mult(forceMultiplier);
        totalForce.add(force);
      }
    }
    */
    
    
  }
  
  public void updatePosition() {
    // Euler integration
    acceleration.add(totalForce);
    velocity.add(acceleration);
    position.add(velocity);
    
    // Wrapping position
    
    position.x = (position.x + width) % width;
    position.y = (position.y + height) % height;
    
    // Update cell if necessary
    currentCell = calculateCell(position);
    if (currentCell.x != oldCell.x || currentCell.y != oldCell.y) {
      cells.get(int(oldCell.y)).get(int(oldCell.x)).remove(this);
      cells.get(int(currentCell.y)).get(int(currentCell.x)).add(this);
      oldCell = currentCell.copy();
      changedCells++;
    }
 
    velocity.mult(1-friction);
  }
  
  public float forceFunction(float radiusProportion, float forceParameter) {
    // Repel if too close
    if (radiusProportion < minRadiusProportion) {
      return (radiusProportion / minRadiusProportion) - 1;
    }
    return forceParameter * (1 - abs(2 * radiusProportion - 1 - minRadiusProportion)) / (1 - minRadiusProportion);
  }
  
  public PVector calculateCell(PVector pos) {
    return new PVector(floor(pos.x / radius), floor(pos.y / radius)); 
  }
  
  public void display() {
    //fill((currentCell.x * currentCell.y * colorStep) % 360, 100, 100, transparency);
    fill(type * colorStep, 100, 100, transparency);
    circle(position.x, position.y, particleSize);
  }
}
