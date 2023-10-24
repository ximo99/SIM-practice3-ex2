class Particle //<>//
{
  // Variables of class Particle
  ParticleSystem _ps;
  int _id;
  int particleCell;
  
  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;

  float _m;
  float _radius;
  color _color;
  
  ArrayList neighbours;
  
  Particle(ParticleSystem ps, int id, PVector initPos, PVector initVel, float mass, float radius) 
  {
    neighbours = new ArrayList<Particle>();
    _ps = ps;
    _id = id;

    _s = initPos.copy();
    _v = initVel.copy();
    _a = new PVector(0.0, 0.0);
    _f = new PVector(0.0, 0.0);

    _m = mass;
    _radius = radius;
    _color = color(0, 136, 255, 155);
  }
  
  void setVel(PVector v)
  {
    _v = v.copy();
  }

  // Update values using Symplectic Euler
  void update() 
  {  
    updateForce();
    PVector Ft = _f.copy();
    _a = PVector.div(Ft, _m);
    _v.add(PVector.mult(_a, SIM_STEP));
    _s.add(PVector.mult(_v, SIM_STEP));    
  }

  // Calculate all the forces
  void updateForce()
  {  
      PVector Froz = PVector.mult(_v, Kd);
      PVector Fg = PVector.mult(G, _m);
      PVector Ft = PVector.add(Froz, Fg);
      
      _f = Ft.copy();
  }
  
  // Particle-plane collision model
  void planeCollision(ArrayList<PlaneSection> planes)
  {
    float dC; // Collision distance
    PVector n1 = new PVector(); // Normal 1
    PVector n2 = new PVector(); // Normal 2
    
    PVector vS = new PVector(); // Output speed
    PVector vN = new PVector(); // Normal speed
    PVector vT = new PVector(); // Tangential speed
    
    PVector Prep = new PVector();
    float nv;
    
    for(int i = 0; i < planes.size();i++)
    {
      PlaneSection p = planes.get(i); 

      if(p.inside(_s))
      {
        // Repositioning
        n1 = planes.get(i).getNormal();
        n2 = PVector.mult(n1, -1);
        
        PVector pp = PVector.sub (p.getPoint1(), _s);
        dC = pp.dot(n1);
        
        if (abs(dC) < _radius)
        {
          float dRest = _radius - abs(dC);
          Prep = _s.add(PVector.mult(n1, dRest));
          _s = Prep.copy();
          
          // Speed change
          // Get normal speed
          nv = _v.dot(n2);
          
          // Speed decomposition (normal and tangential)
          vN = n2.copy().mult(nv);
          vT = _v.sub(vN);
          vS = vT.sub(vN);
          _v = vS.copy();
        }
      }
    }
  }
  
 void particleCollisionSpringModel()
 { 
    ArrayList<Particle> system = new ArrayList<Particle>();
    int totalParticle = 0;
    
    float ang;
    float dMin;
    PVector vc;
    PVector target;
    PVector fSpring;
    float distance;

    switch(actualStructure)
    {
      case NONE:
        totalParticle = _ps.getNumParticles();
        system = _ps.getParticleArray();
      break;
      
      case GRID:
        updateNeighbours();
        totalParticle = neighbours.size();
        system = neighbours;
      break;
        
      case HASH:
        updateNeighbours();
        totalParticle = neighbours.size();
        system = neighbours;
      break;
    }
    
    for (int i = 0 ; i < totalParticle; i++)
    {
      if(_id != i)
      {
        Particle p = system.get(i);
        
        vc = PVector.sub(p._s, _s);
        distance = vc.mag();
        
        dMin = p._radius + _radius;
        dMin *= 0.7;
        
        if(distance < dMin)
        {
          ang = atan2(vc.y, vc.x);
          
          // Spring force = distance * Ke (elastic constant of the spring)
          target = new PVector(_s.x + cos(ang) * dMin, _s.y + sin(ang) * dMin);
          fSpring = new PVector((target.x - p._s.x) * Ke, (target.y - p._s.y) * Ke);
          
          // New exit velocities for the particles
          _v = new PVector(_v.x -= fSpring.x, _v.y -= fSpring.y);
          p._v = new PVector(p._v.x += fSpring.x, p._v.y += fSpring.y);
        }
      }
    }
  }
  
  void updateCell()
  {
    int cell;
    
    if (actualStructure == actualStructure.GRID)
    {
      cell = grid.getCell(_s);
      
      if(cell >= 0)
        if (cell < grid._cells.size())
          particleCell = cell;
      
      grid.insert(this, particleCell);
    }
    else if (actualStructure == actualStructure.HASH)
    {
      cell = hash.hash(_s);
      
      if(cell >= 0)
        if (cell < hash._table.size())
          particleCell = cell;
      
      hash.insert(this, particleCell);
    }
  }
  
  void updateNeighbours()
  {
    PVector a, b, c, d, e, f, g, h;
    int cellA, cellB, cellC, cellD, cellE, cellF, cellG, cellH;
    neighbours.clear();
    
    a = new PVector(_s.x - _radius, _s.y - _radius);
    b = new PVector(_s.x + _radius, _s.y - _radius);
    c = new PVector(_s.x + _radius, _s.y + _radius);
    d = new PVector(_s.x - _radius, _s.y + _radius);
    e = new PVector(_s.x, _s.y + _radius);
    f = new PVector(_s.x, _s.y - _radius);
    g = new PVector(_s.x + _radius, _s.y);
    h = new PVector(_s.x - _radius, _s.y);
    
    // Update neighbours for Grid
    if (actualStructure == actualStructure.GRID)
    {
      cellA = grid.getCell(a);
      cellB = grid.getCell(b);
      cellC = grid.getCell(c);
      cellD = grid.getCell(d);
      cellE = grid.getCell(e);
      cellF = grid.getCell(f);
      cellG = grid.getCell(g);
      cellH = grid.getCell(h);
      
      
      for(int i = 0; i < grid._cells.get(cellA).size(); i++)
      {
        Particle p = grid._cells.get(cellA).get(i);
        neighbours.add(p);
      }
      
      if(cellB != cellA)
      {
        for(int i = 0; i < grid._cells.get(cellB).size(); i++)
        {
          Particle p = grid._cells.get(cellB).get(i);
          neighbours.add(p);
        }
      }
      if(cellC != cellA && cellC != cellB)
      {
        for(int i = 0; i < grid._cells.get(cellC).size(); i++)
        {
          Particle p = grid._cells.get(cellC).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellD != cellA && cellD != cellB && cellD != cellC)
      {
        for(int i = 0; i < grid._cells.get(cellD).size(); i++)
        {
          Particle p = grid._cells.get(cellD).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellE != cellA && cellE != cellB && cellE != cellC && cellE != cellD)
      {
        for(int i = 0; i < grid._cells.get(cellE).size(); i++)
        {
          Particle p = grid._cells.get(cellE).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellF != cellA && cellF != cellB && cellF != cellC && cellF != cellD && cellF != cellE )
      {
        for(int i = 0; i < grid._cells.get(cellF).size(); i++)
        {
          Particle p = grid._cells.get(cellF).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellG != cellA && cellG != cellB && cellG != cellC && cellG != cellD && cellG != cellE && cellG != cellF)
      {
        for(int i = 0; i < grid._cells.get(cellG).size(); i++)
        {
          Particle p = grid._cells.get(cellG).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellH != cellA && cellH != cellB && cellH != cellC && cellH != cellD && cellH != cellE && cellH != cellF && cellH != cellG)
      {
        for(int i = 0; i < grid._cells.get(cellH).size(); i++)
        {
          Particle p = grid._cells.get(cellH).get(i);
          neighbours.add(p);
        }
      }
    }
    // Update neighbours for Hash
    else if (actualStructure == actualStructure.HASH)
    {
      cellA = hash.getCell(a);
      cellB = hash.getCell(b);
      cellC = hash.getCell(c);
      cellD = hash.getCell(d);
      cellE = hash.getCell(e);
      cellF = hash.getCell(f);
      cellG = hash.getCell(g);
      cellH = hash.getCell(h);
      
      for(int i = 0; i < hash._table.get(cellA).size(); i++)
      {
        Particle p = hash._table.get(cellA).get(i);
        neighbours.add(p);
      }
      
      if(cellB != cellA)
      {
        for(int i = 0; i < hash._table.get(cellB).size(); i++)
        {
          Particle p = hash._table.get(cellB).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellC != cellA && cellC != cellB)
      {
        for(int i = 0; i < hash._table.get(cellC).size(); i++)
        {
          Particle p = hash._table.get(cellC).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellD != cellA && cellD != cellB && cellD != cellC)
      {
        for(int i = 0; i < hash._table.get(cellD).size(); i++)
        {
          Particle p = hash._table.get(cellD).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellE != cellA && cellE != cellB && cellE != cellC && cellE != cellD)
      {
        for(int i = 0; i < hash._table.get(cellE).size(); i++)
        {
          Particle p = hash._table.get(cellE).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellF != cellA && cellF != cellB && cellF != cellC && cellF != cellD && cellF != cellE )
      {
        for(int i = 0; i < hash._table.get(cellF).size(); i++)
        {
          Particle p = hash._table.get(cellF).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellG != cellA && cellG != cellB && cellG != cellC && cellG != cellD && cellG != cellE && cellG != cellF)
      {
        for(int i = 0; i < hash._table.get(cellG).size(); i++)
        {
          Particle p = hash._table.get(cellG).get(i);
          neighbours.add(p);
        }
      }
      
      if(cellH != cellA && cellH != cellB && cellH != cellC && cellH != cellD && cellH != cellE && cellH != cellF && cellH != cellG)
      {
        for(int i = 0; i < hash._table.get(cellH).size(); i++)
        {
          Particle p = hash._table.get(cellH).get(i);
          neighbours.add(p);
        }
      }
    }
  }
  
  void display(color c) 
  {
    fill(c);
    noStroke();
    circle(_s.x, _s.y, 2.0 * _radius);
  }
}
