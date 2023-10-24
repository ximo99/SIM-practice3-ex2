class Grid
{
  // Variables of class Grid
  ArrayList<ArrayList<Particle>> _cells;
  
  int _nRows; 
  int _nCols; 
  int _numCells;
  
  float _cellSize;
  color[] _colors;
  
  Grid(int rows, int cols) 
  {
    _cells = new ArrayList<ArrayList<Particle>>();
    
    _nRows = rows;
    _nCols = cols;
    _numCells = _nRows * _nCols;
    _cellSize = width / _nRows;
    
    _colors = new color[_numCells];
    
    for (int i = 0; i < _numCells; i++) 
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      _cells.add(cell);
      _colors[i] = color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)), 150);
    }
  }
  
  // Get the corresponding cell given a position
  int getCell(PVector l)
  {
    int cell = 0;
    int fila = int (l.y / _cellSize);
    cell = fila + int(l.x / _cellSize) * _nCols;
    
    if(cell < 0 || cell >= grid._cells.size())
      return 0;
    else
      return cell;
  }
  
  // Draw cells
  void showCells()
  {
    strokeWeight(3);
    stroke(255, 0, 0);
    
    for(int i = 0; i <_nRows * _nCols; i++)
    {
      line(0, i * _cellSize, width, i * _cellSize);
      line(i * _cellSize, 0, i * _cellSize, height);
    }
  }
  
  // Insert particles in the grid
  void insert(Particle p, int cell)
  {
    _cells.get(cell).add(p);
  }
  
  // Grid restart
  void restart()
  {
    for(int i = 0; i < _nRows*_nCols; i++)
      _cells.get(i).clear();
  }
}
