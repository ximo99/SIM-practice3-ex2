class HashTable
{
  // Variables of class Hash table
  ArrayList<ArrayList<Particle>> _table;
  
  int _numCells;
  float _cellSize;
  color[] _colors;
  
  HashTable(int numCells, float cellSize) 
  {
    _table = new ArrayList<ArrayList<Particle>>();
    
    _numCells = numCells; 
    _cellSize = cellSize;

    _colors = new color[_numCells];
    
    for (int i = 0; i < _numCells; i++)
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      _table.add(cell);
      _colors[i] = color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)), 150);
    }
  }
  
  // Get the corresponding cell given a position with the hash function
  int getCell(PVector pos) 
  {
    int c = hash(pos);
    
    return c;
  }
  
  // Get the corresponding cell given a position using the hash function
  int hash (PVector pos)
  {
    int xd = (int)floor(pos.x/_cellSize);
    int yd = (int)floor(pos.y/_cellSize);
    
    int h = int((73856093 * xd + 19349663 * yd) % (_numCells));
     
    if (h < 0)
      h += _numCells;
     
    return h;
  }
  
  // Insert particles in the table
  void insert(Particle p, int cell)
  {
    _table.get(cell).add(p);
  }
  
  // Hash restart
  void restart()
  {
    for(int i = 0; i < _table.size(); i++)
      _table.get(i).clear();
  }
 //<>//
}
