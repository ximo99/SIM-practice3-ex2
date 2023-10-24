class ParticleSystem
{
  // Variables of class ParticleSystem
  ArrayList<Particle> _particles;

  float _mass = 10;   // Particle mass
  float _radius = 5;  // Particle radius
  int _n = 1500;      // Number of initial particles
  int _id = 0;        // Particle identifier
  
  ParticleSystem()  
  {
    
    _particles = new ArrayList<Particle>();
    
    int cols, rows;  // Number of columns and rows
    
    // Alert! The number of columns must be a multiple of the number of initial particles
    cols= 75;
    rows = _n / cols;
    
    //Distribución de las partículas dentro del recipiente
    for (int i = 0; i < rows; i++)
    {      
      for(int j = 0; j < cols; j++)
      {
        PVector initVel, initPos;  // Initial speed and initial position
        
        initVel = new PVector(0, 0);
        initPos = new PVector((_radius + 10) * j + 140, (_radius + 10) * i + 75);
        
        addParticle(_id, initPos, initVel, _mass, _radius);
        _id++;
      }
    }
  }

  // If the user clicks the mouse, more particles are added
  void addMoreParticles(PVector pos)
  {
    int newParts;    // Number of new particles
    int cols, rows;  // Number of columns and rows for the new particles
    
    newParts = 100;
    cols = 10;
    rows = newParts / cols;
    
    for (int i = 0; i < cols; i++)
    {      
      for(int j = 0; j < rows; j++)
      {   
        PVector initVel, initPos;  // Initial velocity and initial position for the new particles
        
        initVel = new PVector(0, 0);
        initPos = new PVector((_radius + 10) * j + pos.x, (_radius + 10) * i + pos.y);
        
        addParticle(_id, initPos, initVel, _mass, _radius);
        _id++;
      }
    }
    
    _n += newParts;
  } 
  
  void addParticle(int id, PVector initPos, PVector initVel, float _mass, float radius) 
  { 
    _particles.add(new Particle(this, id, initPos, initVel, _mass, radius));
  }
  
  int getNumParticles()
  {
    return _n;
  }

  ArrayList<Particle> getParticleArray()
  {
    return _particles;
  }

  void run() 
  {
    for (int i = 0; i < _n; i++) 
    {
      Particle p = _particles.get(i);
      p.update();
    }
  }
  
  void computeCollisions(ArrayList<PlaneSection> planes, boolean computeParticleCollision) 
  { 
    for (int i = 0; i < _n; i++)
    {
      Particle p = _particles.get(i);
      p.planeCollision(planes);

      if (computeParticleCollision)
        p.particleCollisionSpringModel();
    }
  }
  
  void updateStructure()
  {
    grid.restart();
    hash.restart();
    
    for(int i = 0; i < _n; i++)
    {
      Particle p = _particles.get(i);
      p.updateCell();
    }
  }

  void display() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);   
      color c = color(0, 118, 255);
      int celda;
      
      switch(actualStructure)
      {
        case NONE:
          c = color(0, 118, 255);
        break;
        
        case GRID:
          celda = grid.getCell(p._s);
          c = grid._colors[celda];
        break;
        
        case HASH:
          celda = hash.hash(p._s);
          c = hash._colors[celda];
        break;
      }
      
      p.display(c);
    }
  }
}
