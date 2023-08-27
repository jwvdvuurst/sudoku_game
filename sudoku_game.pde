int sudoku[][]; //<>//
int puzzle[][];
int solution[][];

boolean cellSelected = false;
int selX = 0;
int selY = 0;

boolean puzzleSolved = false;

ArrayList<Integer> row( int y ) {
  ArrayList<Integer> rv = new ArrayList<>();

  for ( int x = 0; x < 9; x++ ) rv.add(sudoku[x][y]);

  return rv;
}

ArrayList<Integer> column( int x ) {
  ArrayList<Integer> rv = new ArrayList<>();

  for ( int y = 0; y < 9; y++ ) rv.add(sudoku[x][y]);

  return rv;
}

ArrayList<Integer> quadrant( int x, int y ) {
  ArrayList<Integer> rv = new ArrayList<>();

  int nx = floor(x/3) * 3;
  int ny = floor(y/3) * 3;

  for ( int cy = 0; cy < 3; cy++ ) for ( int cx = 0; cx < 3; cx++ ) rv.add(sudoku[nx+cx][ny+cy]);

  return rv;
}

int[][] copy_matrix() {
  int cp[][] = new int[9][9];

  for ( int x=0; x<9; x++ ) for ( int y=0; y<9; y++ ) cp[x][y] = sudoku[x][y];

  return cp;
}

int[][] copy_puzzle() {
  int cp[][] = new int[9][9];

  for ( int x=0; x<9; x++ ) for ( int y=0; y<9; y++ ) cp[x][y] = puzzle[x][y];

  return cp;
}

boolean solved() {
  boolean retval = true;

  for ( int x=0; (x<9) && retval; x++ ) for ( int y=0; (y<9) && retval; y++ ) retval = retval && (solution[x][y] == sudoku[x][y]);

  return retval;
}

int[] count_missing() {
  int retvals[] = new int[9];
  
  for( int n = 0; n < 9; n++ ) retvals[n] = 9;
  
  for( int x=0; x<9; x++ ) for( int y=0; y<9; y++ ) if (solution[x][y] != 0) retvals[solution[x][y]-1]--;
  
  return retvals;
}

void clean_row( int y ) {
  for ( int x=0; x<9; x++ ) sudoku[x][y]=0;
}

void clean_column( int x ) {
  for ( int y=0; y<9; y++ ) sudoku[x][y]=0;
}

void clean_all() {
  for ( int x=0; x<9; x++ ) clean_column(x);
}

int next(int n) {
  n = (n+1)%10;

  if (n==0) n=1;

  return n;
}

boolean generate() {
  boolean regenerate = true;
  int gen_count = 10;

  while ( regenerate && (gen_count > 0) ) {
    regenerate = false;
    gen_count--;

    int nr_scan = 10;
    boolean rescan = true;

    clean_all();

    while ( rescan && (nr_scan > 0) ) {
      nr_scan--;
      rescan = false;

      for ( int y=0; y<9; y++ ) {
        for ( int x=0; x<9; x++ ) {
          if (sudoku[x][y] == 0) {

            int n = (round(random(18))%9)+1;
            boolean ok = false;
            int count = 9;
            while ( !ok && (count > 0)) {
              ok = true;

              if (row(y).contains(n)) {
                println( n, " appears in row ", y);
                ok = false;
              }

              if (column(x).contains(n)) {
                println( n, " appears in column ", x);
                ok = false;
              }

              if (quadrant(x, y).contains(n)) {
                println( n, " appears in the quadrant containting (", x, ",", y, ")" );
                ok = false;
              }

              if (!ok) {
                n = next(n);
                count--;
              }
            }

            if (count == 0) {
              clean_row(y);
              clean_column(x);
              rescan=true;
            } else {
              sudoku[x][y]=n;
            }
          }
        }
      }
    }

    if (rescan) {
      regenerate=true;
    }
  }

  return !regenerate;
}

void generate_puzzle() {
  puzzle = copy_matrix();

  int blanks=round(random(41))+10;

  while ( blanks > 0 ) {
    int x = round(random(8));
    int y = round(random(8));

    if (puzzle[x][y] != 0) {
      puzzle[x][y] = 0;
      blanks--;
    }
  }

  solution = copy_puzzle();
}

void setup() {
  sudoku = new int[9][9];

  size(800, 900);
  background(255);

  while (! generate()) println("Generated failed, restart");

  generate_puzzle();
  //puzzle = copy_matrix();

  //int blanks=round(random(31))+10;

  //while( blanks > 0 ) {
  //  int x = round(random(8));
  //  int y = round(random(8));

  //  if (puzzle[x][y] != 0) {
  //    puzzle[x][y] = 0;
  //    blanks--;
  //  }
  //}
}

void draw() {
  background(255);

  stroke(0);

  for ( int x=0; x<9; x++ ) {
    for ( int y=0; y<9; y++ ) {
      int sx = 40+(80*x);
      int sy = 40+(80*y);

      if (!cellSelected || (x != selX) || (y != selY)) {
        fill(255);
      } else {
        fill(220);
      }
      rect(sx, sy, 80, 80);

      textSize(60);
      sx += 20;
      sy += 60;

      if (puzzle[x][y] != 0) {
        fill(0);
        text(str(sudoku[x][y]), sx, sy);
      } else {
        if (solution[x][y] != 0) {
          if (solution[x][y] == sudoku[x][y]) {
            fill(64, 255, 64);
          } else {
            fill(255, 64, 64);
          }
          text(str(solution[x][y]), sx, sy);
        }
      }
    }
  }

  strokeWeight(4);
  line(40, 40, 760, 40);
  line(760, 40, 760, 760);
  line(760, 760, 40, 760);
  line(40, 760, 40, 40);

  line(280, 40, 280, 760);
  line(520, 40, 520, 760);
  line(40, 280, 760, 280);
  line(40, 520, 760, 520);

  strokeWeight(1);

  int missing[] = count_missing();
  
  for( int n=0; n<9; n++ ) {
    fill(200);
    rect(40+(n*80), 800, 80, 80);
    
    fill(0);
    textSize(40);
    text(str(n+1), 80+(n*80), 850);
    
    textSize(20);
    text( str(missing[n]), 80+(n*80), 875);
  }
    
  //  saveFrame("sudoku-#####.png");

  if (solved()) {
    if (!puzzleSolved) {
      puzzleSolved = true;

      fill(0, 128, 255);
      textSize(120);
      text("Solved!", 200, 400);
    } else {
      delay(5000);
      while (! generate()) println("Generated failed, restart");

      generate_puzzle();
      puzzleSolved = false;
    }
  }
}

void mousePressed() {
  cellSelected = false;
  selX = 0;
  selY = 0;

  if ((mouseX < 40) || (mouseX > 760)) return;
  if ((mouseY < 40) || (mouseY > 760)) return;

  selX = round((mouseX-40) / 80);
  selY = round((mouseY-40) / 80);
  cellSelected = true;
}

void keyPressed() {
  if (cellSelected) {
    if ((key >= '1') && (key <= '9')) solution[selX][selY] = byte(key)-byte('1')+1;
    if ((key == '0') || (key == ' ')) solution[selX][selY] = 0;
  }
  
  if ((key == 'n') || (key == 'N') || (key == TAB)) {
    int nx=0;
    int ny=0;
    
    if (cellSelected) {
      if (selX < 9) {
        nx = selX+1;
        ny = selY;
      } else {
        nx = 0;
        if (selY < 9) {
          ny = selY+1;
        }
      }
    }
    
    while ((ny < 9) && (solution[nx][ny] != 0)) {
      while ((nx < 9) && (solution[nx][ny] != 0)) nx++;
      
      if ((nx == 9) || (solution[nx][ny] != 0)) {
        nx = 0;
        ny = (ny + 1)%9;
      }
    }
    
    selX = nx;
    selY = ny;
    cellSelected = true;
  }
  
  if (key == BACKSPACE) cellSelected = false;
  
  if (key == CODED) {
    if (keyCode == UP) if (selY > 0) selY--;
    if (keyCode == DOWN) if (selY < 8) selY++;
    if (keyCode == LEFT) if (selX > 0) selX--;
    if (keyCode == RIGHT) if (selX < 8) selX++;
    
    cellSelected = true;
  }
}
