/* @pjs preload="facebook,youtube,info.svg"; */
boolean started;
PFont font;
color[] colors;
color[] outlineColors;
Hashmap genres;
HashMap longText; //used for long text
Current current; //used to display current song info and controls
SidePane sidePane; //displays the sidepane
LibControl libControl; // used to control the library

final int NOSORT = 0;
final int HOTSORT = 1;
final int LHOTSORT = 2;

final int GENRE = 0;
final int STYLE = 1;
final int MOOD = 2;

int sortSongs = NOSORT;
boolean genreArray = false;
int genreDisplay = MOOD;
int filterPopRock = 0;

Song song;

//positions of different sections of the screen
int LIBMINX, LIBMINY, LIBMAXY, LIBMAXX;
final int ZOOM = 0;
final int SCROLL = 1;
int WIDTH,HEIGHT;

void setup(){
  WIDTH = 950;
  HEIGHT = 635;
  size(WIDTH+8, HEIGHT);
  frameRate(30);
  smooth();
  rectMode(CORNERS);
  ellipseMode(CENTER_RADIUS);
  started = false;
  font = createFont("Arial", 13);
  textFont(font);
  setUpColors();
  setUpStyles();
  songs = new ArrayList();
  longText = new HashMap();
  libControl = new LibControl();
  sidePane = new SidePane(LIBMAXX+10,LIBMINY);
  current = new Current();
}

void setUpColors(){
  colorMode(RGB);
  colors = new color[10];
  outlineColors = new color[10];
  colors[0] = color(255,0,0);
  colors[1] = color(255,103,0);
  colors[2] = color(255,182,0);
  colors[3] = color(231,255,0);
  colors[4] = color(0,255,18);
  colors[5] = color(0,255,212);
  colors[6] = color(0,104,155);
  colors[7] = color(149,0,255);
  colors[8] = color(248,0,255);
  colors[9] = color(255,3,141);
  outlineColors[0] = color(0,153,153);
  outlineColors[1] = color(100,168,209);
  outlineColors[2] = color(133,133,232);
  outlineColors[3] = color(230,113,255);
  outlineColors[4] = color(255,128,157);
  outlineColors[5] = color(255,176,128);
  outlineColors[6] = color(255,195,100);
  outlineColors[7] = color(249,243,140);
  outlineColors[8] = color(222,244,130);
  outlineColors[9] = color(204,255,123);
}

void draw(){
  background(0);
  drawLibrary();
  current.draw(); //draws the current song controller
  sidePane.draw();
  libControl.draw(); //draws libcontrol
  if(hoverSong > -1)
    drawHoverInfo();
}

void drawHoverInfo(){
    String title = songs.get(hoverSong).title;
    String artist = songs.get(hoverSong).artist;
    textSize(15);
    int xlength = max(textWidth(title), textWidth(artist));
    int numba;
    if(genreMode)
      numba = genres.get(songs.get(hoverSong).styles[0]);
    else
      numba = genres.get(songs.get(hoverSong).genre);
    fill(colors[numba]);
    stroke(outlineColors[numba]);
    rect(mouseX, mouseY-48,mouseX+xlength+12, mouseY-7,10);
    //fill(0);
    if(numba > 1 && numba < 6)
      fill(0);
    else
      fill(255);
     // fill(outlineColors[genres.get(songs.get(hoverSong).genre)]);
    textAlign(LEFT,TOP);
    text(title, mouseX+6, mouseY-45);
    text(artist, mouseX+6, mouseY-28);
}

boolean facebookClick = false;
boolean youtubeClick = false;

void mouseClicked(){
  if(hoverSong >= 0){
    if(started)
    song.stopSong();
    songs.get(hoverSong).startSong();
    curSong = hoverSong;
    song = songs.get(curSong);
    return;
  }
  if(facebookClick){
    link(song.facebookURL, "_new");
    return;
  }
  if(youtubeClick){
    link("http://www.youtube.com/results?search_query=" + song.title.replace(/ /g, '+') + "+" +
          song.artist.replace(/ /g, '+'), "_new");
    return;
  }
  //libControl.mouseClicked();
}

void mousePressed(){
  if(mouseY < 145-70){//145 = LIBMINY original
    current.mousePressed();
  }
  else if(mouseX > LIBMAXX){
    sidePane.mousePressed();
  }
  else
    libControl.mousePressed();
}

void mouseMoved(){
  hoverSong = -1;
  if(mouseX > LIBMINX-10 && mouseX < LIBMAXX + 10 && mouseY < LIBMAXY + 10 && mouseY > LIBMINY - 10)
    checkForHover();
}

void mouseDragged(){
  current.mouseDragged();
  libControl.mouseDragged();
}

void mouseReleased(){
  current.mouseReleased();
  libControl.mouseReleased();
}

void mouseScrolled(){
  libControl.mouseScrolled();
}

int hoverSong = -1;
//float[][] temp = new float[36][2]; //used to show the entirely returned json

int songGlow = 1;
int songGlowWait = 0;
boolean songGlowUp = true;

void checkForHover(){
  int totalSongs = songs.size();
  float x,y;
  for(int i = 0; i < totalSongs; i++){
    x = songs.get(i).x;
    y = songs.get(i).y;
    if(songs.get(i).inView && mouseX >= (x-10) && mouseX <= (x+10) && mouseY >= (y-10) && mouseY <= (y+10)){
        hoverSong = i;
        return;
    }
  }
}

void drawLibrary(){
  int totalSongs = songs.size();
  boolean outlines = false; //whether or not to draw outlines
  String curGenre, genre;
  int cur; //index for colors
  float x, y;
  if(hoverSong > -1){
    outlines = true;
    if(genreMode)
      curGenre = songs.get(hoverSong).styles[0];
    else
      curGenre = songs.get(hoverSong).genre;
  }
  
  for(int i = 0; i < totalSongs; i++){
    x = songs.get(i).x;
    y = songs.get(i).y;
    if(songs.get(i).inView){ //if in view
      if(genreMode){
        genre = songs.get(i).styles[0];
      }
      else{
        genre = songs.get(i).genre; 
      }
      cur = genres.get(genre);
      fill(colors[cur]);

      if(outlines && genre == curGenre){
        strokeWeight(4);
        stroke(outlineColors[cur]);
      }
      else if(curSong == i && started){
        if(songGlowWait == 3){
          songGlowWait = 0;
          if(songGlowUp){
            if(songGlow < 5)
              songGlow++;
            else{
              songGlow--;
              songGlowUp = false;
            }
          }
          else{
            if(songGlow > 1)
              songGlow--;
            else{
              songGlow++;
              songGlowUp = true;
            }
          }
        }
        else
          songGlowWait++;
        stroke(outlineColors[cur]);
        strokeWeight(songGlow);
      }
      else{
        stroke(colors[cur]);
        strokeWeight(1);
      }
      ellipse(x, y, 10, 10);
      strokeWeight(1);
    }
  }
  noStroke();
  /*if(totalSongs > 0){
  fill(255);
  for(int i = 0; i< 36; i++){    
    ellipse(map(temp[i][0], minX, maxX, LIBMINX+13, LIBMAXX-13),
      map(temp[i][1], maxY, minY, LIBMINY+13, LIBMAXY-13),3,3);
      }}*/  
              // USED TO SHOW THE ENTIRELY RETURNED JSON
  fill(0);
  rect(LIBMINX-22, LIBMINY-22, LIBMAXX+22, LIBMINY-1);
  rect(LIBMINX-22, LIBMAXY+22, LIBMAXX+22, LIBMAXY+1);
  rect(LIBMINX-22, LIBMINY-1, LIBMINX-1, LIBMAXY+1);
  rect(LIBMAXX+1, LIBMINY-1, LIBMAXX+22, LIBMAXY+1);
}

  
void resetSongs(){
  for(int i = songs.size()-1; i > -1; i--){
    if(i==curSong&&started)
      songs.get(i).stopSong();
    songs.remove(i);
  }
  curSong = -1;
  song = null;
  libControl.fixUpSongs(ZOOM);
}
  
class Axis{
  float min;
  float max;
  String mins; // string for lower bound
  String maxs; // string for upper bound
  int id;
  String type;
  float typeWidth;
  float xpos; //left pos of rect
  float ypos;
  
  Axis(float min, float max, String type, int id, String mins, String maxs){
    this.min = min;
    this.max = max;
    this.type = type;
    this.id = id;
    this.mins = mins;
    this.maxs = maxs;
    textSize(15);
    typeWidth = textWidth(type);
  }
}
void keyPressed(){
  //~ if(key == ' '){
    //~ setLibSize(LIBMINXMID,LIBMAXXMID,LIBMINYMID,LIBMAXYMID);
  //~ }
  //~ else if(key == 'L' || key == 'l'){
    //~ setLibSize(LIBMINX+10, LIBMAXX, LIBMINY, LIBMAXY);
  //~ }
  //~ else if(key == 'U' || key == 'u'){
    //~ setLibSize(LIBMINX, LIBMAXX, LIBMINY+10, LIBMAXY);
  //~ }
}

void setLibSize(minx,maxx,miny,maxy){
  if(LIBMINX != minx || LIBMAXX != maxx){
    LIBMAXX = maxx;
    LIBMINX = minx;
    pxLowerBound = xLowerBound = map(xLowerBound, BOUNDMINX, BOUNDMAXX, LIBMINX+LIBBOUNDDIFF, LIBMAXX-LIBBOUNDDIFF);
    pxUpperBound = xUpperBound = map(xUpperBound, BOUNDMINX, BOUNDMAXX, LIBMINX+LIBBOUNDDIFF, LIBMAXX-LIBBOUNDDIFF);
    BOUNDMINX = LIBMINX+LIBBOUNDDIFF;
    BOUNDMAXX = LIBMAXX-LIBBOUNDDIFF;
    setNewXs();
  }
  if(LIBMINY != miny || LIBMAXY != maxy){
    LIBMINY = miny;
    LIBMAXY = maxy;
    pyUpperBound = yUpperBound = map(yUpperBound, BOUNDMINY, BOUNDMAXY, LIBMINY+LIBBOUNDDIFF, LIBMAXY-LIBBOUNDDIFF);  
    pyLowerBound = yLowerBound = map(yLowerBound, BOUNDMINY, BOUNDMAXY, LIBMINY+LIBBOUNDDIFF, LIBMAXY-LIBBOUNDDIFF);
    BOUNDMINY = LIBMINY+LIBBOUNDDIFF;
    BOUNDMAXY = LIBMAXY-LIBBOUNDDIFF;
    setNewYs();
  }
}

int LIBBOUNDDIFF = 15;
int xaxis, yaxis;
float minX,maxY,maxX,minY, MINX, MAXY, MAXX, MINY;
int BOUNDMINX, BOUNDMAXX, BOUNDMINY, BOUNDMAXY;
float xLowerBound, xUpperBound, yUpperBound, yLowerBound;
float pxLowerBound, pxUpperBound, pyUpperBound, pyLowerBound; //previous values
int STARTX, STARTY;
    
class LibControl{
  ArrayList axes;  
  int totalAxes;
  int yBoundLength, xBoundLength, xAxisTop, xAxisBottom, yAxisLeft, yAxisRight;
  
  LibControl(){
    STARTX = 10;
    LIBMINX = STARTX + 55;
    LIBMINY = 95;
    LIBMAXX = 651;
    LIBMAXY = 570;

    xAxisTop = LIBMAXY + 15;
    xAxisBottom = LIBMAXY + 25;
    yAxisLeft = LIBMINX - 25;
    yAxisRight = LIBMINX - 15;
    
    minX = minY = MINX = MINY = 0.0;
    maxX = maxY = MAXX = MAXY = 1.0;
    pxLowerBound = xLowerBound = BOUNDMINX = LIBMINX+LIBBOUNDDIFF;
    pxUpperBound = xUpperBound = BOUNDMAXX = LIBMAXX-LIBBOUNDDIFF;
    pyUpperBound = yUpperBound = BOUNDMINY = LIBMINY+LIBBOUNDDIFF;
    pyLowerBound = yLowerBound = BOUNDMAXY = LIBMAXY-LIBBOUNDDIFF;
    xBoundLength = map(0.04, 0, 1, 0, BOUNDMAXX - BOUNDMINX);
    yBoundLength = map(0.04,0,1,0,BOUNDMAXY-BOUNDMINY);
    
    axes = new ArrayList();
    axes.add(new Axis(0.0, 500.0, "Tempo", 0, "min_tempo", "max_tempo"));
    axes.add(new Axis(0.0, 3600.0, "Duration", 1, "min_duration", "max_duration"));
    axes.add(new Axis(-100.0, 100.0, "Loudness", 2, "min_loudness", "max_loudness"));
    axes.add(new Axis(0.0, 1.0, "Artist Familiarity", 3, "artist_min_familiarity", "artist_max_familiarity"));
    axes.add(new Axis(0.0, 1.0, "Song Hotttnesss", 4, "song_min_hotttnesss", "song_max_hotttnesss"));
    axes.add(new Axis(0.0, 1.0, "Artist Hotttnesss", 5, "artist_min_hotttnesss", "artist_max_hotttnesss"));
    axes.add(new Axis(0.0, 1.0, "Energy", 6, "min_energy", "max_energy"));
    axes.add(new Axis(0.0, 1.0, "Danceability", 7, "min_danceability", "max_danceability"));
    axes.add(new Axis(-180.0, 180.0, "Artist Longitude", 9, "min_longitude", "max_longitude"));
    axes.add(new Axis(-90.0, 90.0, "Artist Latitude", 8, "min_latitude", "max_latitude"));
    totalAxes = axes.size();
    xaxis = 7;
    yaxis = 6; 
    setAxesXYpos();
    returnDragged = totalDragged;
    setUpSongs();
    xTotal = LIBMAXX-LIBMINX;
    yTotal = LIBMAXY-LIBMINY;

    //look into having a filter for artist start/end years
  }
  
    
  void draw(){
    textSize(15);
    noStroke();
    textAlign(LEFT,CENTER);
    //drawAxisControl();
    drawAxisLabels();
    /*if(curDragged)
      drawDragged();
    if(returnDragged < totalDragged)
    drawReturn();*/
    if(mousescroll)
      checkMouseScroll();
  }
  
  int mousescroll = 0;
  float msminX, msmaxX, msminY, msmaxY;
  int xTotal, yTotal;
  
  void mouseScrolled(){
    if(mouseX > LIBMINX && mouseX < LIBMAXX && mouseY > LIBMINY && mouseY < LIBMAXY){
      pxLowerBound = xLowerBound;
      pyLowerBound = yLowerBound;
      pxUpperBound = xUpperBound;
      pyUpperBound = yUpperBound;
      if(mouseScroll > 0){
        xLowerBound += mouseScroll*((mouseX - LIBMINX)/50);
        xUpperBound -= mouseScroll*((LIBMAXX - mouseX)/50);
        yLowerBound -= mouseScroll*((LIBMAXY - mouseY)/50);
        yUpperBound += mouseScroll*((mouseY - LIBMINY)/50);
        if(xUpperBound - xLowerBound < xBoundLength*2+3){
          xLowerBound = pxLowerBound;
          xUpperBound = pxUpperBound;
        }
        if(yLowerBound - yUpperBound < yBoundLength*2+3){
          yLowerBound = pyLowerBound;
          yUpperBound = pyUpperBound;
        } 
      }
      else{
        xLowerBound += mouseScroll*(xTotal/50);
        xUpperBound -= mouseScroll*(xTotal/50);
        yLowerBound -= mouseScroll*(yTotal/50);
        yUpperBound += mouseScroll*(yTotal/50);
        if(xLowerBound<BOUNDMINX)
          xLowerBound = BOUNDMINX;
        if(xUpperBound>BOUNDMAXX)
          xUpperBound = BOUNDMAXX;
        if(yLowerBound>BOUNDMAXY)
          yLowerBound = BOUNDMAXY;
        if(yUpperBound<BOUNDMINY)
          yUpperBound = BOUNDMINY;
      }
      if(xLowerBound != pxLowerBound)
        minX = map(xLowerBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
      if(xUpperBound != pxUpperBound)
        maxX = map(xUpperBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
      if(yLowerBound != pyLowerBound)
        minY = map(yLowerBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
      if(yUpperBound != pyUpperBound)
        maxY = map(yUpperBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
      
      mousescroll = 5;
      if(xLowerBound != pxLowerBound || xUpperBound != pxUpperBound)
        setNewXs();
      if(yLowerBound != pyLowerBound || yUpperBound != pyUpperBound)
        setNewYs();
    }
  }
  
  void checkMouseScroll(){
    mousescroll--;
    if(mousescroll == 0)
      fixUpSongs(ZOOM);
  }
      
   void drawAxisLabels(){
    fill(255);
    textAlign(CENTER,TOP);
    text(axes.get(xaxis).type, LIBMINX + (LIBMAXX-LIBMINX)/2, xAxisBottom + 8);
    textAlign(CENTER);
    pushMatrix();
    translate(yAxisLeft-12, LIBMINY + (LIBMAXY-LIBMINY)/2);
    rotate(-HALF_PI);
    text(axes.get(yaxis).type, 0, 0);
    popMatrix();
    textAlign(LEFT);
    stroke(colors[xaxis]);
    strokeWeight(2);
    line(LIBMINX-1, LIBMAXY+1, LIBMAXX, LIBMAXY+1);
    line(STARTX, LIBMINY, LIBMAXX, LIBMINY);
    line(STARTX, HEIGHT-10, LIBMAXX, HEIGHT-10);
    stroke(colors[yaxis]);
    line(LIBMINX-1, LIBMINY+2, LIBMINX-1, LIBMAXY-2);
    line(LIBMAXX+1, LIBMINY, LIBMAXX+1, HEIGHT-11);
    line(STARTX,LIBMINY+2, STARTX, HEIGHT-13);
    
    if(!boundPressed){
      if(mouseY >= xAxisTop - 5 && mouseY <= xAxisBottom + 5 && mouseX >= xLowerBound - 5 && mouseX <= xLowerBound + xBoundLength-3){
        whichBound = 1; onBound = true;
      }
      else if(mouseY >= xAxisTop - 5 && mouseY <= xAxisBottom + 5 && mouseX >= xUpperBound - xBoundLength +3 && mouseX <= xUpperBound + 5){
        whichBound = 2; onBound = true;
      }
      else if(mouseX <= yAxisRight + 5 && mouseX >= yAxisLeft - 5 && mouseY >= yUpperBound - 5 && mouseY <= yUpperBound+yBoundLength-3){
        whichBound = 3; onBound = true;
      }
      else if(mouseX <= yAxisRight + 5 && mouseX >= yAxisLeft - 5 && mouseY >= yLowerBound -yBoundLength+3 && mouseY <= yLowerBound+5){
        whichBound = 4; onBound = true;
      }
      else
        onBound = false;
    }
    if(!onBound){
      if(mouseY >= xAxisTop - 3 && mouseY <= xAxisBottom + 3 && mouseX > xLowerBound-xBoundLength && mouseX < xUpperBound+xBoundLength){
        onAxis = 1;
      }
      else if(mouseX <= yAxisRight + 3 && mouseX >= yAxisLeft-3 && mouseY < yLowerBound + yBoundLength && mouseY > yUpperBound- yBoundLength){
        onAxis = 2;
      }
      else if(!axisPressed)
        onAxis = 0;
    }
    else if(!axisPressed)
      onAxis = 0;
    
    noStroke();
    fill(102);
    rect(BOUNDMINX, xAxisTop+4, BOUNDMAXX, xAxisBottom - 4);
    rect(yAxisLeft+4, BOUNDMINY, yAxisRight-4, BOUNDMAXY);
    
    fill(colors[xaxis]);
    if(onAxis==1){
      stroke(outlineColors[xaxis]);
      strokeWeight(4);
      if(axisPressed == 1){
        fill(outlineColors[xaxis]);
        rect(xLowerBound, xAxisTop-2, xUpperBound, xAxisBottom+2, 10);
      }
      else
        rect(xLowerBound, xAxisTop-2, xUpperBound, xAxisBottom+2, 10);
    }
    else{
      noStroke();
      rect(xLowerBound, xAxisTop, xUpperBound, xAxisBottom, 10);
      noFill(); strokeWeight(2);
      for(int i = 0; i < 5; i++){
        stroke(lerpColor(outlineColors[xaxis],color(0),i/5));
        rect(xLowerBound-i, xAxisTop-i, xUpperBound+i, xAxisBottom+i, 10);
      }
    }
        
    fill(colors[yaxis]);
    if(onAxis == 2){
      stroke(outlineColors[yaxis]);
      strokeWeight(4);
      if(axisPressed == 2){
        fill(outlineColors[yaxis]);
        rect(yAxisLeft-2, yUpperBound, yAxisRight+2, yLowerBound,10);
      }
      else
        rect(yAxisLeft-2, yUpperBound, yAxisRight+2, yLowerBound,10);
    }  
    else{
      noStroke();
      rect(yAxisLeft, yUpperBound, yAxisRight, yLowerBound,10);
      strokeWeight(2);
      noFill();
      for(int i = 0; i < 5; i++){
        stroke(lerpColor(outlineColors[yaxis],color(0),i/5));      
        rect(yAxisLeft-i, yUpperBound-i, yAxisRight+i, yLowerBound+i,10);
      }
    }
    //bound delineators
    strokeWeight(3);
    strokeCap(SQUARE);
    stroke(outlineColors[xaxis]);
    line(xLowerBound+xBoundLength, xAxisTop, xLowerBound+xBoundLength, xAxisBottom);
    line(xUpperBound-xBoundLength,  xAxisTop, xUpperBound-xBoundLength, xAxisBottom);
    stroke(outlineColors[yaxis]);
    line(yAxisLeft,yUpperBound+yBoundLength,yAxisRight,yUpperBound+yBoundLength);
    line(yAxisLeft,yLowerBound-yBoundLength,yAxisRight,yLowerBound-yBoundLength);
    strokeCap(PROJECT);
    if(onBound){
      strokeWeight(4);
      if(boundPressed && whichBound <3)
        fill(outlineColors[xaxis]);
      else if(boundPressed)
        fill(outlineColors[yaxis]);
      if(whichBound < 3)
        stroke(outlineColors[xaxis]);
      else
        stroke(outlineColors[yaxis]);
      drawBound(whichBound);
    }
  }  
  
  void drawBound(int which){
    if(which == 1)
      rect(xLowerBound-2, xAxisTop-2, xLowerBound+xBoundLength,xAxisBottom+2,10,0,0,10);
    else if(which == 2)
      rect(xUpperBound-xBoundLength, xAxisTop-2, xUpperBound+2,xAxisBottom+2,0,10,10,0);
    else if(which == 3)
      rect(yAxisLeft-2,yUpperBound-2,yAxisRight+2,yUpperBound+yBoundLength,10,10,0,0);
    else if(which == 4)
      rect(yAxisLeft-2,yLowerBound-yBoundLength,yAxisRight+2,yLowerBound+2,0,0,10,10);
  }
  
  boolean onBound = false; //is mouse on a bound?
   
  //sets button axis locations
  void setAxesXYpos(){
    for(int i = 0; i < totalAxes; i++){
      axes.get(i).ypos = map(i%5, 0, 5, BOUNDMAXY+15, HEIGHT+10);
      if(i < 5)
        axes.get(i).xpos = BOUNDMINX+3;
      else
        axes.get(i).xpos = 320 - axes.get(i).typeWidth;
    }
  }

  void drawAxisControl(){
    Axis axis;
    for(int i = 0; i < totalAxes; i++){
      axis = axes.get(i);
      fill(colors[i+1]);
      rect(axis.xpos-3, axis.ypos+10, axis.xpos+axis.typeWidth+3, axis.ypos-10);
      fill(0);
      text(axis.type, axis.xpos, axis.ypos);
    }
  } 
  
  int curPressedAxis;
  boolean curPressed = false;
  boolean curDragged = false;
  float curPressedXoff; //distance from base
  float curPressedYoff;
  float curPressedWidth;
  float dragX, dragY; //final drag location
  float returnDragged; // dragged object returning count
  float totalDragged = 5.0; //dragged object returning total
    
  void drawDragged(){
    fill(colors[curPressedAxis+1]);
    rect(mouseX-curPressedXoff-3, mouseY-curPressedYoff-10, mouseX-curPressedXoff+curPressedWidth+3, mouseY-curPressedYoff+10);
    fill(0);
    textAlign(LEFT,CENTER);
    text(axes.get(curPressedAxis).type, mouseX-curPressedXoff, mouseY-curPressedYoff);
    textAlign(LEFT);
  }
  
  void drawReturn(){
    float curx = lerp(dragX, axes.get(curPressedAxis).xpos, returnDragged/totalDragged);
    float cury = lerp(dragY, axes.get(curPressedAxis).ypos, returnDragged/totalDragged);
    fill(colors[curPressedAxis+1]);
    rect(curx - 3, cury-10, curx + curPressedWidth + 3, cury + 10);
    fill(0);
    textAlign(LEFT,CENTER);
    text(axes.get(curPressedAxis).type, curx, cury);
    returnDragged++;
    textAlign(LEFT);
  }
  
  boolean boundPressed = false; // mouse pressed on bound?
  int whichBound = 0;
  int axisPressed = 0;
  int axisDistance = 0;
  int libClickY = 0;
  int libClickX = 0;
  int oxLowerBound, oyLowerBound, oxUpperBound, oyUpperbound; // originals
  int onAxis = 0;
  boolean libPressed = false;
  
  void mousePressed(){
    if(onBound){
      if(whichBound == 1)
        libClickX = mouseX-xLowerBound;
      else if(whichBound == 2)
        libClickX = xUpperBound - mouseX;
      else if(whichBound == 3)
        libClickY = mouseY - yUpperBound;
      else
        libClickY = yLowerBound - mouseY;
      boundPressed = true;
      return;
    }
    if(onAxis == 1){
      axisPressed = 1;
      axisDistance = mouseX - xLowerBound;
      pxLowerBound = xLowerBound;
      return;
    }
    if(onAxis == 2){
      axisPressed = 2;
      axisDistance = mouseY - yUpperBound;
      pyLowerBound = yLowerBound;
      return;
    }
    if(mouseX>LIBMINX && mouseX<LIBMAXX && mouseY>LIBMINY && mouseY<LIBMAXY){
      libPressed = true;
      libClickY = map(mouseY,LIBMINY,LIBMAXY,0,yLowerBound-yUpperBound);
      libClickX = map(mouseX,LIBMINX,LIBMAXX,0,xUpperBound-xLowerBound);
      oxLowerBound = pxLowerBound = xLowerBound;
      oyLowerBound = pyLowerBound = yLowerBound;
      oyUpperbound = yUpperBound;
      oxUpperbound = xUpperBound;
      return;
    }
    
    
    
    
    //FIGURE THIS SHIT OUT TOO!
    
    
    
    
    for(int i = 0; i < totalAxes; i++){
      if(mouseY >= axes.get(i).ypos-10 && mouseY <= axes.get(i).ypos+10 && mouseX >= axes.get(i).xpos-3 && mouseX <= axes.get(i).xpos+axes.get(i).typeWidth+3){
        curPressed = true;
        curPressedAxis = i;
        curPressedXoff = mouseX - axes.get(i).xpos;
        curPressedYoff = mouseY - axes.get(i).ypos;
        curPressedWidth = axes.get(i).typeWidth;
        return;
      }
    }
  }
  
  void mouseDragged(){
    if(curPressed){
      returnDragged = totalDragged;
      curDragged = true;
      curPressed = false;
    }
    else if(boundPressed){
      switch(whichBound){
        case 1:
          if(mouseX-libClickX < BOUNDMINX)
            xLowerBound = BOUNDMINX;
          else if(xUpperBound - mouseX-libClickX <= xBoundLength*2+3)
            xLowerBound = xUpperBound - xBoundLength*2-3;
          else
            xLowerBound = mouseX-libClickX;
          if(pxLowerBound != xLowerBound){
            minX = map(xLowerBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
            setNewXs();
            pxLowerBound = xLowerBound;
          }
          break;
        case 2:
          if(mouseX+libClickX > BOUNDMAXX)
            xUpperBound = BOUNDMAXX;
          else if(mouseX +libClickX- xLowerBound <= xBoundLength*2+3)
            xUpperBound = xLowerBound + xBoundLength*2+3;
          else
            xUpperBound = mouseX+libClickX;
          if(pxUpperBound != xUpperBound){
            maxX = map(xUpperBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
            setNewXs(); //set new x posishes for the songs
            pxUpperBound = xUpperBound;
          }
          break;
        case 3:
          if(mouseY - libClickY< BOUNDMINY)
            yUpperBound = BOUNDMINY;
          else if(yLowerBound - mouseY - libClickY <= yBoundLength*2+3)
            yUpperBound = yLowerBound - yBoundLength*2-3;
          else
            yUpperBound = mouseY - libClickY;
          if(pyUpperBound != yUpperBound){
            maxY = map(yUpperBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
            setNewYs();
            pyUpperBound = yUpperBound;
          }
          break;
        case 4:
          if(mouseY + libClickY > BOUNDMAXY)
            yLowerBound = BOUNDMAXY;
          else if(mouseY+libClickY - yUpperBound <= yBoundLength*2+3)
            yLowerBound = yUpperBound + yBoundLength*2+3;
          else
            yLowerBound = mouseY + libClickY;
          if(pyLowerBound != yLowerBound){
            minY = map(yLowerBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
            setNewYs();
            pyLowerBound = yLowerBound;
          }
          break;
      }
    }
    else if(axisPressed){
      switch(axisPressed){
        case 1: //x
          boundDiff = xUpperBound - xLowerBound;
          if(mouseX - axisDistance >= BOUNDMINX && mouseX - axisDistance + boundDiff <= BOUNDMAXX){
            xLowerBound = mouseX - axisDistance;
            xUpperBound = xLowerBound + boundDiff;
          }
          else if(mouseX - axisDistance < BOUNDMINX){
            xLowerBound = BOUNDMINX;
            xUpperBound = xLowerBound + boundDiff;
          }
          else if(mouseX -axisDistance + boundDiff > BOUNDMAXX){
            xUpperBound = BOUNDMAXX;
            xLowerBound = xUpperBound - boundDiff;
          }
          if(xLowerBound != pxLowerBound){
            minX = map(xLowerBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
            maxX = map(xUpperBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
            setNewXs(); //set new x posishes for the songs
            pxLowerBound = xLowerBound;
          }
          break;
        case 2: //y
          boundDiff = yLowerBound - yUpperBound;
          if(mouseY - axisDistance >= BOUNDMINY && mouseY - axisDistance + boundDiff <= BOUNDMAXY){
            yUpperBound = mouseY - axisDistance;
            yLowerBound = yUpperBound + boundDiff;
          }
          else if(mouseY - axisDistance < BOUNDMINY){
            yUpperBound = BOUNDMINY;
            yLowerBound = yUpperBound + boundDiff;
          }
          else if(mouseY - axisDistance + boundDiff > BOUNDMAXY){
            yLowerBound = BOUNDMAXY;
            yUpperBound = yLowerBound - boundDiff;
          }
          if(pyLowerBound != yLowerBound){
            minY = map(yLowerBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
            maxY = map(yUpperBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
            setNewYs();
            pyLowerBound = yLowerBound;
          }
          break;
      }
    }
    else if(libPressed && mouseX>LIBMINX && mouseX<LIBMAXX && mouseY>LIBMINY && mouseY<LIBMAXY){
      int boundDiffX = xUpperBound - xLowerBound;
      int boundDiffY = yLowerBound - yUpperBound;
      
      if(mouseX != pmouseX){
        int curMoveX = libClickX - map(mouseX,LIBMINX,LIBMAXX,0,boundDiffX);
        if(curMoveX != 0){
          xUpperBound = oxUpperbound + curMoveX;
          xLowerBound = oxLowerBound + curMoveX;
          if(xUpperBound > BOUNDMAXX){
            xUpperBound = BOUNDMAXX;
            xLowerBound = BOUNDMAXX - boundDiffX;
          }
          else if(xLowerBound < BOUNDMINX){
            xLowerBound = BOUNDMINX;
            xUpperBound = BOUNDMINX + boundDiffX;
          }
          if(xLowerBound != pxLowerBound){
            minX = map(xLowerBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
            maxX = map(xUpperBound, BOUNDMINX, BOUNDMAXX, MINX, MAXX);
            setNewXs();
          }
          pxLowerBound = xLowerBound;
        }
      }
      if(mouseY != pmouseY){
        int curMoveY = libClickY - map(mouseY,LIBMINY,LIBMAXY,0,boundDiffY);
        if(curMoveY != 0){
          yUpperBound = oyUpperbound + curMoveY;
          yLowerBound = oyLowerBound + curMoveY;
          if(yUpperBound < BOUNDMINY){
            yUpperBound = BOUNDMINY;
            yLowerBound = BOUNDMINY+boundDiffY;
          }
          else if(yLowerBound>BOUNDMAXY){
            yLowerBound = BOUNDMAXY;
            yUpperBound = BOUNDMAXY-boundDiffY;
          }
          if(yLowerBound != pyLowerBound){
            minY = map(yLowerBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
            maxY = map(yUpperBound, BOUNDMINY, BOUNDMAXY, MAXY, MINY);
            setNewYs();
          }
          pyLowerBound = yLowerBound;
        }
      }
    }
  }
  
  void mouseReleased(){
    if(curDragged){
      dragX = mouseX - curPressedXoff;
      dragY = mouseY - curPressedYoff;
      curDragged = false;
      if(mouseX < BOUNDMINX && mouseY < BOUNDMAXY && mouseY > BOUNDMINY){
        if(yaxis == curPressedAxis || xaxis == curPressedAxis){ //MAKE IT SO THE OPPOSITE AXIS FLASHES OR SOMETHING
          returnDragged = 0;
        }
        else{
          yaxis = curPressedAxis;
          maxY = MAXY = axes.get(yaxis).max;
          minY = MINY = axes.get(yaxis).min;
          yLowerBound = BOUNDMAXY;
          yUpperBound = BOUNDMINY;
          if(started){
            song.stopSong();
          }
          setUpSongs();
        }
      }
      else if(mouseY < BOUNDMINY && mouseX > BOUNDMINX && mouseX < BOUNDMAXX){ 
        if(xaxis == curPressedAxis || yaxis == curPressedAxis) //MAKE IT SO THE OPPOSITE AXIS FLASHES OR SOMETHING
          returnDragged = 0;
        else{
          xaxis = curPressedAxis;
          minX = MINX = axes.get(xaxis).min;
          maxX = MAXX = axes.get(xaxis).max;
          if(started){
            song.stopSong();
          }
          xUpperBound = BOUNDMAXX;
          xLowerBound = BOUNDMINX;
          setUpSongs();
        }
      }
      else
        returnDragged = 0;
    }
    else if(boundPressed){
      boundPressed = false;
      fixUpSongs(ZOOM);
    }
    else if(curPressed)
      curPressed = false;
    else if(axisPressed){
      axisPressed = 0;
      fixUpSongs(SCROLL);
    }
    else if(libPressed){
      libPressed = false;
      fixUpSongs(SCROLL);
    }
  }
  
  void fixUpSongs(int type){ 
    String id = ""; //if song is still in view
    int keepCurSong = -1;
    if(started){
      if(!song.inView)
        keepCurSong = curSong;//songs.get(curSong).stopSong();
      //else
        id = song.songID;
    }
    int prevLen = songs.size();
    String hid;
    if(hoverSong > -1)
      hid = songs.get(hoverSong).songID;
    for(int i = songs.size() - 1; i >= 0; i--){
      if(!songs.get(i).inView && keepCurSong != i){
        songs.remove(i);
      }
    }
    int len = songs.size();
    if(len < prevLen){
      boolean alreadyExists = false;
      int curRequestNum = ++requestNum;
      if(locs == null || locs.length != DENSITY)
        locs = new int[DENSITY][DENSITY];
      float curXmin, curXmax, curYmin, curYmax; // lower and upper bounds for the emerging grid system
      for(int i = 0; i < DENSITY; i++){
        curXmin = lerp(minX, maxX, i/DENSITY);
        curXmax = lerp(minX, maxX, (i+1)/DENSITY);
        for(int j = 0; j < DENSITY; j++){
          curYmin = lerp(minY, maxY, j/DENSITY);
          curYmax = lerp(minY, maxY, (j+1)/DENSITY);
          alreadyExists = false;
          for(int k = 0; k < len; k++){
            if(songs.get(k).originalX <= curXmax && songs.get(k).originalX >= curXmin && songs.get(k).originalY <= curYmax && songs.get(k).originalY >= curYmin){
              if(!alreadyExists){
                locs[i][j] = 1;
                alreadyExists = true;
              }
              break;
            }
          }
          if(!alreadyExists)
            locs[i][j] = 0;
        }
      }
      String jsonstring = "http://localhost:8888/getSongs?maxX="+maxX+"&minX="+minX+
              "&minY="+minY+"&maxY="+maxY;
      if(sortSongs){jsonstring+="&sort="+sortSongs;}
      if(genreMode){jsonstring+="&genre="+curGenre;}
      else if(filterPopRock){jsonstring+="&filter=1";}
      $.getJSON(jsonstring, function(results){     
        if(results != null){
          addSomeSongs(results, curRequestNum);
        }
      });
    }
    else if(type == ZOOM){
      boolean alreadyExists;
      int curRequestNum = ++requestNum;
      if(locs == null || locs.length != DENSITY)
        locs = new int[DENSITY][DENSITY];
      float curXmin, curXmax, curYmin, curYmax; // lower and upper bounds for the emerging grid system
      for(int i = 0; i < DENSITY; i++){
        curXmin = lerp(minX, maxX, i/DENSITY);
        curXmax = lerp(minX, maxX, (i+1)/DENSITY);
        for(int j = 0; j < DENSITY; j++){
          curYmin = lerp(minY, maxY, j/DENSITY);
          curYmax = lerp(minY, maxY, (j+1)/DENSITY);
          alreadyExists = false;
          for(int k = songs.size()-1; k >= 0; k--){
            if(songs.get(k).originalX <= curXmax && songs.get(k).originalX >= curXmin && songs.get(k).originalY <= curYmax && songs.get(k).originalY >= curYmin){
              if(alreadyExists){
                if(id != songs.get(k).songID)
                  songs.remove(k);
              }
              else{
                locs[i][j]=1;
                alreadyExists = true;
              }
            }
          }
          if(!alreadyExists){
            locs[i][j] = 0;
          }
        }
      }
      String jsonstring = "http://localhost:8888/getSongs?maxX="+maxX+"&minX="+minX+
              "&minY="+minY+"&maxY="+maxY;
      if(sortSongs){jsonstring+="&sort="+sortSongs;}
      if(genreMode){jsonstring+="&genre="+curGenre;}
      else if(filterPopRock){jsonstring+="&filter=1";}
      $.getJSON(jsonstring, function(results){     
        if(results != null){
          addSomeSongs(results, curRequestNum);
        }
      });
    }
    if(id != ""){
      for(len = songs.size() -1; len >= 0; len--){
        if(id == songs.get(len).songID){
          curSong = len;
          break;
        }
      }
    }
    len = songs.size();
    if(len < prevLen && hoverSong > -1){
      if(hoverSong < len && songs.get(hoverSong).songID == hid)
        return;
      for(int i = 0; i < len; i++){
        if(songs.get(i).songID == hid){
          hoverSong = i;
          return;
        }
      }
      hoverSong = -1;
    }
  }
  void addSomeSongs(Object results, int curRequestNum){
    if(curRequestNum != requestNum)
      return;
    int length=results.length;
    if(length == 0)
      return; 
    float curXmin, curXmax, curYmin, curYmax; // lower and upper bounds for the emerging grid system
    float[][] poses = new float[length][2]; //positions of each song
    for(int i = 0; i < length; i++){
      //poses[i][0] = temp[i][0] = getPos(xaxis, results[i].song);
      //poses[i][1] = temp[i][1] = getPos(yaxis, results[i].song);
      poses[i][0] = getPos(xaxis, results[i].song);
      poses[i][1] = getPos(yaxis, results[i].song);
    }
    for(int i = 0; i < DENSITY; i++){
      curXmin = lerp(minX, maxX, i/DENSITY);
      curXmax = lerp(minX, maxX, (i+1)/DENSITY);
      for(int j = 0; j < DENSITY; j++){
        if(!locs[i][j]){
          curYmin = lerp(minY, maxY, j/DENSITY);
          curYmax = lerp(minY, maxY, (j+1)/DENSITY);
          length = results.length;
          for(int k = 0; k < length; k++){
            if(poses[k][0] < curXmax && poses[k][0] > curXmin && poses[k][1] > curYmin && poses[k][1] < curYmax){
              songs.add(new Song(results.splice(k,1)[0].song));
              poses.splice(k,1);
              break;
            }
          }
        }
      }
    }
  }
  
  int DENSITY = 6;
  int requestNum = 0;
  int[][] locs; //locations needing song data
  void setUpSongs(){
    songs.clear();
    String jsonstring = "http://localhost:8888/getSongs?maxX="+maxX+"&minX="+minX+
              "&minY="+minY+"&maxY="+maxY;
    if(sortSongs){jsonstring+="&sort="+sortSongs;}
    if(genreMode){jsonstring+="&genre="+curGenre;}
    else if(filterPopRock){jsonstring+="&filter=1";}
    $.getJSON(jsonstring, function(results){      
      if(results != null){
        var length = results.length;
        for(int i = 0; i < length; i++)
          songs.add(new Song(results[i].song));
      }
    });
  }
}

abstract class Button{
  int x, y, hw, hh;//x and y coordinates, followed by half the WIDTH and HEIGHT
  boolean invert;
  boolean pressedHere; // boolean to check whether button was pressed originally vs a different one
  Button(int x, int y, int hw, int hh)
  {
    this.x = x;
    this.y = y;
    this.hw = hw;
    this.hh = hh;
  }
  
  boolean pressed()
  {
    return mouseX > x - hw && mouseX < x + hw && mouseY > y - hh && mouseY < y + hh;
  }
  
  abstract void mousePressed();
  abstract void mouseReleased();
  abstract void draw();
}

class Play extends Button{
  boolean play;
    
  Play(int x, int y, int hw, int hh) 
  { 
    super(x, y, hw, hh); 
    play = true;
  }
  
  boolean paused()
  {
    return play;
  }
  
  // code to handle playing and pausing the file
  void mousePressed()
  {
    if (super.pressed()){
      invert = true;
      pressedHere = true;
    }
  }
  
  void mouseDragged(){
    if (super.pressed() && pressedHere)
      invert = true;
    else
      invert = false;
  }
  
  void mouseReleased()
  {
    if(invert && pressedHere){
      if(started)
        song.song.togglePause();
      invert = false;
    }
    pressedHere = false;
  }
  
  // play is a boolean value used to determine what to draw on the button
  void update()
  {
    if(started){
      if (song.song != null && song.song.playState==1){
        if(song.song.paused){
          if(!changingPosition)
            play = true;
        }
        else
          play = false;
      }
      else 
        play = true;
    }
  }
  
  void draw()
  {
    if ( invert ){
      fill(255);
      noStroke();
    }
    else{
      noFill();
      if(super.pressed())
        stroke(255);
      else
        noStroke();
    }
    rect(x - hw, y - hh, x+hw, y+hh);
    if ( invert )
    {
      fill(0);
      stroke(255);
    }
    else
    {
      fill(255);
      noStroke();
    }
    if ( play )
    {
      triangle(x - hw/3, y - hh/2, x - hw/3, y + hh/2, x + hw/2, y);
    }
    else
    {
      rect(x - hw/3, y - hh/2, x-1, y + hh/2);
      rect(x + hw/3, y - hh/2, x +1, y + hh/2);
    }
  }
}

class Forward extends Button{
  boolean invert;
  boolean pressed;
  
  Forward(int x, int y, int hw, int hh)
  {
    super(x, y, hw, hh);
    invert = false;
  }
  
  void mousePressed()
  {
    if (super.pressed()){ 
      invert = true;
      pressedHere = true;
    }
  }
  
  void mouseDragged(){
    if (super.pressed() && pressedHere)
      invert = true;
    else
      invert = false;
  }
  
  void mouseReleased()
  {
    if(invert && pressedHere){
      //code to skip to next song
      if(started){
        createNext();
      }
      invert = false;
    }
    pressedHere = false;
  }

  void draw()
  {
    if ( invert ){
      fill(255);
      noStroke();
    }
    else{
      noFill();
      if(super.pressed())
        stroke(255);
      else
        noStroke();
    }
    rect(x - hw, y - hh, x + hw, y+hh);
    if ( invert )
    {
      fill(0);
      stroke(255);
    }
    else
    {
      fill(255);
      noStroke();
    }
    rect(x-3, y-hh/2, x-8, y + hh/2); 
    triangle(x, y - hh/2, x, y + hh/2, x + hw/2, y);    
  }  
}

//create the next song
void createNext(){
  song.stopSong();
  int rand;
  do{
    rand = (int) random(songs.size());
  }while(rand == curSong && songs.size()>1);
  curSong = rand;
  song = songs.get(curSong);
  song.startSong();
}

void setUpStyles(){
  genres = new HashMap();
	// moods
	genres.put("Trippy",4);
	genres.put("Relaxed",5);
	genres.put("Sad",6);
	genres.put("Dark",7);
	genres.put("Angry",0);
	genres.put("Epic",1);
	genres.put("Sweet",8);
	genres.put("Sexy",9);
	genres.put("Happy",3);
	genres.put("Funky",2);
  //electro
  genres.put("Techno",2);
  genres.put("Trance",3);
  genres.put("Dubstep",5);
  genres.put("Jungle",4);
  genres.put("Drum and Bass",4);
  genres.put("House",1);
  genres.put("Ambient",9);
  genres.put("Trip-Hop",7);
  genres.put("Downtempo",8);
  genres.put("IDM",6);
  //pop
  genres.put("Dance Pop",1);
  genres.put("Pop Rock", 2);
  genres.put("Rock Pop", 2);
  genres.put("Electropop",3);
  genres.put("Indie Pop", 4);
  genres.put("Teen Pop", 5);
  genres.put("Europop", 6);
  genres.put("Power Pop", 7);
  genres.put("Country Pop",8);
  genres.put("Pop Rap", 0);
  //rock
  genres.put("Indie Rock", 1);
  genres.put("Punk Rock", 2);
  genres.put("Alternative Rock", 4);
  genres.put("Progressive Rock", 7);
  genres.put("Psychedelic Rock", 6);
  genres.put("Heavy Metal", 8);
  genres.put("Classic Rock", 5);
  genres.put("Hard Rock", 3);
  genres.put("Rap Rock", 0);
  //hip hop
  genres.put("Gangsta Rap", 1);
  genres.put("G-Funk", 2);
  genres.put("East Coast Hip Hop", 7);
  genres.put("West Coast Hip Hop", 3);
  genres.put("Alternative Hip Hop", 4);
  genres.put("Southern Rap", 6);
  genres.put("Turntablism", 5);
  //jazz
  genres.put("Free Jazz", 0);
  genres.put("Acid Jazz", 2);
  genres.put("Cool Jazz", 3);
  genres.put("Smooth Jazz", 4);
  genres.put("Soul Jazz", 5);
  genres.put("Avant-Garde Jazz", 1);
  genres.put("Big Band", 7);
  genres.put("Bebop", 6);
  genres.put("Swing", 8);
  //r&b
  genres.put("Contemporary R&B", 1);
  genres.put("New Jack Swing", 2);
  genres.put("Doo-wop", 7);
  genres.put("Funk",4);
  genres.put("Disco",5);
  genres.put("Soul",6);
  genres.put("P-Funk",3);
  //country/folk
  genres.put("Bluegrass", 5);
  genres.put("Rockabilly",0);
  genres.put("Americana",1);
  genres.put("Western",2);
  genres.put("Country Rock",3);
  genres.put("Neofolk",6);
  genres.put("Indie Folk", 7);
  genres.put("Progressive Folk", 8);
  genres.put("Folk Rock", 9);
  //Ska
  genres.put("Lovers Rock", 9);
  genres.put("2 Tone", 7);
  genres.put("Dub", 5);
  genres.put("Dancehall", 3);
  genres.put("Reggae Fusion", 2);
  genres.put("Reggae", 1);
  genres.put("Rocksteady", 4);
  //blues
  genres.put("Boogie-Woogie",1);
  genres.put("Country Blues", 3);
  genres.put("Delta Blues",5);
  genres.put("Electric Blues", 7);
  genres.put("Jump Blues", 9);
  genres.put("Piano Blues", 4);
  //Latin
  genres.put("Bossa Nova", 0);
  genres.put("Salsa", 1);
  genres.put("Samba", 2);
  genres.put("Reggaeton", 3);
  genres.put("Mambo", 4);
  genres.put("Merengue", 5);
  genres.put("Tejano", 6);
  genres.put("Nueva Canción", 7);
  genres.put("Tango", 8);
}

function textPair(length,index){
  this.length = length;
  this.index = index;
}

void checkText(String string, int x, int y,int max,color col, int ybelow){
  if(textWidth(string)>max){
    var cur = longText.get(string + textWidth(string));
    if(cur == null){
      cur = new textPair(0,0);
      longText.put(string+textWidth(string),cur);
    }
    int i = cur.index;
    int slength = string.length();
    if(cur.length >= textWidth(string.charAt(i))){
      if(i < slength-1){
        cur.index++;
        i++;
        cur.length = 0;
      }
      else{
        cur.index = i = 0;
        cur.length = -40;
      }
    }
    int totalLength = textWidth(string.charAt(i))-cur.length;
    i++;
    while(totalLength < max && i < slength){
      totalLength += textWidth(string.charAt(i));
      i++;
    }
    text(string.substring(cur.index,i),x-cur.length,y);
    if(i == slength){
      totalLength += 40;
      int j = 0;
      while(totalLength < max){
        totalLength += textWidth(string.charAt(j));
        j++;
      }
      text(string.substring(0,j),x+textWidth(string.substring(cur.index,i))-cur.length + 40, y);
    }
    noStroke();
    fill(0);
    rect(x-textWidth('W'),y+ybelow,x,y);
    rect(x+max,y,x+max+textWidth('W'),y+ybelow);
    fill(col);
    cur.length++;
    longText.put(string+textWidth(string),cur);
  }
  else
    text(string,x,y);
}

class Item{
	ArrayList items;
	boolean subVisible, hasButton, on, isSwitch, hover, newlySwitched, isTop,isBar,isGenre,isTitle,isInfo;
	String title, dynamic;
  int color = -1;
	int switchNum; // number to be attributed to whatever is associated with this switchnum
	var action, offAction;
	Item(String title){
		this.title = title;
		items = null;
	}
	Item(String title, int mode, var value){
		this.title = title;
    if(mode < 10){
      this.hasButton = true;
      this.on = false;
      this.isSwitch = true;
      this.switchNum = value;
      if(mode == 0)//styles
        this.action = switchOnStyle;
      else if(mode == 1)//mode
        this.action = switchOnMode;
      else if(mode == 2)//sort
        this.action = switchOnSort;
      this.offAction = switchOff;
    }
    else{
      this.isInfo = true;
      this.hasButton = false;
      this.dynamic = value;
      if(mode == 10){ // bar
        this.isBar = true;
      }
      else if(mode == 12){ //array of words
        this.isGenre = true;
      }
      else if(mode == 13){ // artist/title
        this.isTitle = true;
      }
    }
  }

  Item(String title, boolean hascolor){
    this.title = title;
    if(hascolor)
      this.color = genres.get(title);
    this.hasButton = false;
  }
	
	function switchOnSort(){
		this.on = true;
		this.newlySwitched = true;
		sortSongs = this.switchNum;
      if(started){
        song.stopSong();
        started = false;
      }
      resetSongs();
	}
  function switchOnMode(){
		this.on = true;
		this.subVisible = true;
		this.newlySwitched = true;
    genreMode = !genreMode;
		genreDisplay = this.switchNum;
      if(started){
        song.stopSong();
        started = false;
      }
      resetSongs();
    makeSubVisible(this);
	}
	function switchOnStyle(){
		this.on = true;
		this.subVisible = true;
		this.newlySwitched = true;
		curGenre = this.switchNum;
		if(started){
			song.stopSong();
			started = false;
		}
		resetSongs();
    makeSubVisible(this);
	}
  
  function makeSubVisible(item){
    if(item.prevSubVisible){
      item.prevSubVisible = false;
      item.subVisible = true;
    }
    if(item.items){
      for(int i = 0; i < item.items.size(); i++)
        makeSubVisible(item.items.get(i));
    }
  }
  function makeSubInvisible(item){
    if(item.subVisible){
      item.prevSubVisible = true;
      item.subVisible = false;
    }
    if(item.items){
      for(int i = 0; i < item.items.size(); i++)
        makeSubInvisible(item.items.get(i));
    }
  }
	function switchOff(){
		this.subVisible = false;
		this.on = false;
    makeSubInvisible(this);
	}
  
	function toggleBelowVisible(){
		if(this.on){this.on = false; this.subVisible = false;}
		else{this.on = true; this.subVisible = true; this.subVisibleNum = 1;}
	}
}

function colorIconCreator(){
  this.start = Math.floor(Math.random()*10);
  this.places = new int[20];
  for(int i = 0; i < 3; i++){
    for(int j = 0; j < 3; j++){
      this.places[i*6+j*2] = Math.floor(Math.random()*15)+i*14 + 8;
      this.places[i*6+j*2+1] = Math.floor(Math.random()*15)+j*14 + 8;
    }
  }
  this.places[18] = Math.floor(Math.random()*45)+6;
  this.places[19] = Math.floor(Math.random()*45)+6;
}

function sortIconCreator(){
  this.places = new int[10];
  this.places[0] = 5;
  for(int i = 1; i < 10; i++){
    this.places[i] = this.places[i-1] + i;
  }
  this.start = Math.floor(Math.random()*10);
}

final int BASICINFO = 0;
final int SETTINGS = 1;

boolean genreMode = false;
int curGenre = 0;
int PANEMINY, PANEMINX;
class SidePane{  
  int panel = BASICINFO;
  int margin = 10;
  int slant = 2;
  int num, length;
  int mouseMainPaneControl = -1;
  int mouseSort = -1;
  int mouseFilter = 0;
  int genreFilter = 0;
  boolean mouseOnTitle = 0;
  int mouseGenre = -1;
  int INFOMINY;
  PShapeSVG info;
  var colorIcon, sortIcon;
  
  String[] names = {" Current Info"," Color Mode","Sorting"};
  color currentColor;
  ArrayList items;

  SidePane(minx, miny){
    info = loadShape("info.svg");
    shapeMode(CORNERS);
    items = new ArrayList();
    PANEMINX = minx;
    PANEMINY = miny;
    length = 57;
    INFOMINY = PANEMINY+length;
    num = names.length;
    colorIcon = new colorIconCreator();
    sortIcon = new sortIconCreator();
    prepareItems();
    textSize(16);
  }
  
  void draw(){
    if(started){
      if(genreDisplay == STYLE)
        currentColor = colors[genres.get(song.styles[0])];
      else
        currentColor = colors[genres.get(song.genre)];
    }
		switch(panel){
		  case BASICINFO: if(!started){printNoSong(); break;}
		  default: 
			fill(255);
			stroke(255);
			strokeWeight(2);
			textAlign(LEFT,TOP);		
			displayItem(items.get(panel), PANEMINX+10, INFOMINY+10, 20);
			break;
		}
    drawControl();		
	}

  void prepareItems(){
    Item info = new Item("Current Song/Artist Info");
    info.items = new ArrayList();
    Item title = new Item("Title",13,"title");
    Item artist = new Item("Artist",13,"artist");
    title.items = new ArrayList();
    artist.items = new ArrayList();
    title.items.add(new Item("Danceability",10,"danceability"));
    title.items.add(new Item("Energy",10,"energy"));
    title.items.add(new Item("Loudness",10,"loudness"));
    title.items.add(new Item("Hotness",10,"songHotness"));
    title.items.add(new Item("Tempo",11,"tempo"));
    title.items.add(new Item("Duration",11,"time"));
    artist.items.add(new Item("Familiarity",10,"artistFamiliarity"));
    artist.items.add(new Item("Hotness",10,"artistHotness"));
    artist.items.add(new Item("Location",11,"location"));
    artist.items.add(new Item("Type",12,"mood"));
    artist.subVisible = true;
    title.subVisible = true;
    info.items.add(title);
    info.items.add(artist);
    info.isTop = true;
    info.subVisible = true;
		Item mode = new Item("Color Mode");
		Item mood = new Item("Mood",1,MOOD);
		mood.items = new ArrayList();
		mood.on = true;
		mood.subVisible = true;
		mood.items.add(new Item("Angry", true));
		mood.items.add(new Item("Dark", true));
		mood.items.add(new Item("Epic", true));
		mood.items.add(new Item("Funky", true));
		mood.items.add(new Item("Happy", true));
		mood.items.add(new Item("Relaxed", true));
		mood.items.add(new Item("Sad", true));
		mood.items.add(new Item("Sexy", true));
		mood.items.add(new Item("Sweet", true));
		mood.items.add(new Item("Trippy", true));
		Item genre = new Item("Genre",1,STYLE);
		genre.subVisible = false;
		genre.items = new ArrayList();
		Item electro = new Item("Electronic", 0, 2);
    electro.items = new ArrayList();
    electro.items.add(new Item("Ambient",true));
    electro.items.add(new Item("Downtempo",true));
    electro.items.add(new Item("Drum and Bass",true));
    electro.items.add(new Item("Dubstep",true));
    electro.items.add(new Item("House",true));
    electro.items.add(new Item("IDM",true));
    electro.items.add(new Item("Techno",true));
    electro.items.add(new Item("Trance",true));
    electro.items.add(new Item("Trip-Hop",true));
    Item hiphop = new Item("Hip Hop", 0, 3);
    hiphop.items = new ArrayList();
    hiphop.items.add(new Item("Alternative Hip Hop", true));
    hiphop.items.add(new Item("East Coast Hip Hop",true));
    hiphop.items.add(new Item("G-Funk",true));
    hiphop.items.add(new Item("Gangsta Rap",true));
    hiphop.items.add(new Item("Southern Rap",true));
    hiphop.items.add(new Item("Turntablism", true));
    hiphop.items.add(new Item("West Coast Hip Hop",true));
		Item pop = new Item("Pop", 0, 6);
    pop.items = new ArrayList();
    pop.items.add(new Item("Country Pop",true));
    pop.items.add(new Item("Dance Pop",true));
    pop.items.add(new Item("Electropop",true));
    pop.items.add(new Item("Europop",true));
    pop.items.add(new Item("Indie Pop",true));
    pop.items.add(new Item("Pop Rap",true));
    pop.items.add(new Item("Pop Rock",true));
    pop.items.add(new Item("Power Pop",true));
    pop.items.add(new Item("Teen Pop",true));
    Item rock = new Item("Rock", 0, 8);
    rock.items = new ArrayList();
    rock.items.add(new Item("Alternative Rock", true));
    rock.items.add(new Item("Classic Rock",true));
    rock.items.add(new Item("Hard Rock",true));
    rock.items.add(new Item("Heavy Metal",true));
    rock.items.add(new Item("Indie Rock",true));
    rock.items.add(new Item("Progressive Rock",true));
    rock.items.add(new Item("Psychedelic Rock",true));
    rock.items.add(new Item("Punk Rock",true));
    rock.items.add(new Item("Rap Rock",true));
		Item jazz = new Item("Jazz", 0, 4);
    jazz.items = new ArrayList();
    jazz.items.add(new Item("Acid Jazz",true));
    jazz.items.add(new Item("Avant-Garde Jazz",true));
    jazz.items.add(new Item("Bebop",true));
    jazz.items.add(new Item("Big Band",true));
    jazz.items.add(new Item("Cool Jazz",true));
    jazz.items.add(new Item("Free Jazz",true));
    jazz.items.add(new Item("Smooth Jazz",true));
    jazz.items.add(new Item("Soul Jazz",true));
    jazz.items.add(new Item("Swing",true));
    Item rb = new Item("R&B", 0, 7);
    rb.items = new ArrayList();
    rb.items.add(new Item("Contemporary R&B",true));
    rb.items.add(new Item("Disco",true));
    rb.items.add(new Item("Doo-wop",true));
    rb.items.add(new Item("Funk",true));
    rb.items.add(new Item("New Jack Swing", true));
    rb.items.add(new Item("P-Funk",true));
    rb.items.add(new Item("Soul",true));
    Item blues = new Item("Blues", 0, 0);
		blues.on = true;
    blues.prevSubVisible=true;
    blues.items = new ArrayList();
    blues.items.add(new Item("Boogie-Woogie",true));
    blues.items.add(new Item("Country Blues",true));
    blues.items.add(new Item("Delta Blues",true));
    blues.items.add(new Item("Electric Blues", true));
    blues.items.add(new Item("Jump Blues",true));
    blues.items.add(new Item("Piano Blues",true));
		genre.items.add(blues);
		Item folk = new Item("Country/Folk", 0, 1);
    folk.items = new ArrayList();
    folk.items.add(new Item("Americana",true));
    folk.items.add(new Item("Bluegrass",true));
    folk.items.add(new Item("Country Rock",true));
    folk.items.add(new Item("Folk Rock",true));
    folk.items.add(new Item("Indie Folk",true));
    folk.items.add(new Item("Neofolk",true));
    folk.items.add(new Item("Progressive Folk",true));
    folk.items.add(new Item("Rockabilly",true));
    folk.items.add(new Item("Western",true));
    Item ska = 	new Item("Ska", 0, 9);
    ska.items = new ArrayList();
    ska.items.add(new Item("2 Tone",true));
    ska.items.add(new Item("Dancehall",true));
    ska.items.add(new Item("Dub",true));
    ska.items.add(new Item("Lovers Rock",true));
    ska.items.add(new Item("Reggae",true));
    ska.items.add(new Item("Reggae Fusion",true));
    ska.items.add(new Item("Rocksteady",true));
    Item latin = new Item("Latin", 0, 5);
    latin.items = new ArrayList();
    latin.items.add(new Item("Bossa Nova",true));
    latin.items.add(new Item("Mambo",true));
    latin.items.add(new Item("Merengue",true));
    latin.items.add(new Item("Nueva Canción",true));
    latin.items.add(new Item("Reggaeton",true));
    latin.items.add(new Item("Salsa",true));
    latin.items.add(new Item("Samba",true));
    latin.items.add(new Item("Tango",true));
    latin.items.add(new Item("Tejano",true));
    genre.items.add(folk);
    genre.items.add(electro);
    genre.items.add(hiphop);
    genre.items.add(jazz);
    genre.items.add(latin);
    genre.items.add(pop);
    genre.items.add(rb);
    genre.items.add(rock);
    genre.items.add(ska);
		mode.items = new ArrayList();
		mode.items.add(mood);
		mode.items.add(genre);
		mode.subVisible = true;
    mode.isTop = true;
    Item sort = new Item("Sorting");
    sort.isTop = true;
    sort.subVisible = true;
    sort.hasButton = false;
    sort.items = new ArrayList();
    sort.items.add(new Item("None",2,NOSORT));
    sort.items.get(0).on = true;
    sort.items.add(new Item("Hottest Songs First",2,HOTSORT));
    sort.items.add(new Item("Least Hot Songs First",2,LHOTSORT));
    items.add(info);
		items.add(mode);
    items.add(sort);
    for(int i = 0; i < items.size(); i++)
      setSubVisibleNums(items.get(i));
	}
  
  void setSubVisibleNums(item){
    if(item.subVisible)
      item.subVisibleNum = item.items.size();
    else
      item.subVisibleNum = 0;
    if(item.items){
      for(int i = 0; i < item.items.size(); i++)
        setSubVisibleNums(item.items.get(i));
    }
  }
			
	int displayItem(cur, curX, curY, curSize){
		textSize(curSize);
		int xoffset = 0;
    int yoffset = 0;
    if(cur.isTop) yoffset = 5;
		if(cur.hasButton){
			xoffset = curSize + 5;
      stroke(255);
			if(cur.on)	fill(255);
			else noFill();
			if(!(cur.isSwitch && cur.on) && mouseX > curX && mouseX < curX+curSize && mouseY>curY && mouseY < curY + curSize){
				strokeWeight(3);
				cur.hover = true;
			}
			else{strokeWeight(2); cur.hover = false;}
			ellipse(curX+curSize/2, curY+curSize/2+2, curSize/3, curSize/3);
			text(cur.title,curX + curSize + 5, curY);
		}
    else if(cur.color > -1){
      fill(colors[cur.color]);
      stroke(colors[cur.color]);
      ellipse(curX+curSize/2,curY+curSize/2+2,curSize/3,curSize/3);
      fill(255);
      text(cur.title,curX+curSize+5,curY);
    }
		else if(cur.isTitle){
      fill(currentColor);
      curSize++;
      textSize(curSize);
      if(cur.dynamic == "artist") 
        curY += 35;
      checkText(song[cur.dynamic],curX,curY,WIDTH-curX-16,currentColor,22);
      yoffset = 6;
    }
    else if(cur.isGenre){
      fill(255);
      if(genreDisplay == STYLE){
        text("Style",curX,curY);
        fill(currentColor);
        for(int i = 0; i < song.styles.length; i++){
          checkText(song.styles[i],curX+120, curY + i*24,100,currentColor,20);
      }}
      else{
        text("Mood",curX,curY);
        fill(currentColor);
        text(song.genre,curX+120,curY);
      }
    }
    else if(cur.isInfo){
      fill(255); 
      text(cur.title, curX, curY);
      fill(currentColor);
      if(cur.isBar){
        noStroke();
        if(cur.dynamic == "loudness")
          rect(curX+120,curY+2,curX+120+(song[cur.dynamic]+100)/2,curY+curSize);
        else
          rect(curX+120,curY+2,curX+120+song[cur.dynamic]*100,curY+curSize);
        noFill();
        stroke(currentColor);
        rect(curX+121, curY+1, curX+220, curY+curSize);
      }
      else if(cur.dynamic == "location")
        checkText(song.location,curX+120,curY,100,currentColor,20);
      else if(cur.dynamic == "tempo")
        text(song[cur.dynamic] + " bpm",curX+120,curY);
      else
        text(song[cur.dynamic],curX+120,curY);
    }    
    else  
      text(cur.title, curX, curY);
		int offset = 1;
		if(cur.items && cur.subVisibleNum){
      for(int i = 0; i < cur.subVisibleNum; i++){
        offset += displayItem(cur.items.get(i), curX + xoffset+ 10, curY + yoffset*(i+1) + offset*20, curSize-2);
      }
      if(cur.subVisible && cur.subVisibleNum < cur.items.size())
        cur.subVisibleNum++;
      else if(!cur.subVisible && cur.subVisibleNum > 0)
        cur.subVisibleNum--;
    }
    if(cur.subVisible && cur.subVisibleNum == 0)
      cur.subVisibleNum = 1;
    return offset;
	}
	
	int checkPressed(cur){
		if(cur.hover){
			cur.action();
			if(cur.isSwitch) return 2;
			return 1;
		}
		else if(cur.items && cur.subVisible){
			int value;
			for(int i = 0; i < cur.items.size(); i++){
				value = checkPressed(cur.items.get(i));
				if(value == 1)
					return 1;
				else if(value == 2)
					break;
			}
			if(value == 2){
				Item sub;
				for(int i = 0; i < cur.items.size(); i++){
					sub = cur.items.get(i);
					if(sub.on && !sub.newlySwitched)
						sub.offAction();
					else if(sub.on)
						sub.newlySwitched = false;
				}
				return 1;
			}
		}
		return 0;
	}
			
  void mousePressed(){
    if(mouseMainPaneControl >= 0)
      panel = mouseMainPaneControl;
    else if(mouseSort >= 0){
      sortSongs = mouseSort;
      resetSongs();
    }
    else if(mouseFilter){
      filterPopRock = ++filterPopRock%2;
      if(!genreMode)
        resetSongs();
    }
    else if(genreFilter){
      genreMode = !genreMode;
      if(genreMode)
        genreDisplay = STYLE;
      else
        genreDisplay = MOOD;
      if(started){
        song.stopSong();
        started = false;
      }
      curSong = -1;
      resetSongs();
    }
    else if(mouseGenre >= 0){
      curGenre = mouseGenre;
      if(genreMode){
        resetSongs();
      }
    }
    else if(panel > 0){
		checkPressed(items.get(panel));
	}
  }
  
  void mouseReleased(){}
  
  void drawControl(){
    strokeWeight(2);
    stroke(255);
    textSize(15);
    line(PANEMINX,PANEMINY,WIDTH-5,PANEMINY);
    line(PANEMINX, INFOMINY, WIDTH-5, INFOMINY);
    line(PANEMINX,HEIGHT-10,WIDTH-5,HEIGHT-10);    
    line(PANEMINX,PANEMINY,PANEMINX, HEIGHT-11);
    line(WIDTH-4,PANEMINY,WIDTH-4,HEIGHT-11);
    for(int i = 0; i < 5; i++)
      line(PANEMINX + length*(i+1), PANEMINY, PANEMINX + length*(i+1),INFOMINY-1);
    shape(info, PANEMINX, PANEMINY,PANEMINX+length,PANEMINY+length);
    rectMode(CORNERS);
    ellipseMode(CENTER_RADIUS);
    noStroke();
    for(int i = 0; i < 10; i++){
      fill(colors[(colorIcon.start + i)%10]);
      ellipse(PANEMINX+length+colorIcon.places[i*2],PANEMINY+colorIcon.places[i*2+1],4,4);
    }
    for(int i = 0; i < 10; i++){
      stroke(colors[(sortIcon.start + i)%10]);
      line(PANEMINX+length*2+7,PANEMINY+sortIcon.places[i], PANEMINX+length*3-8,PANEMINY+sortIcon.places[i]);
    }
    //checking da mouse
    mouseMainPaneControl = -1;
    stroke(255);
    noFill();
    rect(PANEMINX+length*panel+2,PANEMINY+1,PANEMINX+length*(panel+1)-2,INFOMINY-2);
    if(mouseX > PANEMINX && mouseY > PANEMINY && mouseY < INFOMINY){
      for(int i = 0; i < items.size(); i++){
        if(mouseX < PANEMINX + length*(i+1)){
          rect(PANEMINX+length*i+2,PANEMINY+1,PANEMINX+length*(i+1)-2,INFOMINY-2);
          textAlign(LEFT,BASELINE);
          textSize(16);
          fill(255);
          text(items.get(i).title,PANEMINX,PANEMINY-7);
          mouseMainPaneControl = i;
          break;
        }
      }
    }
  }
  
  //Basic Song Information
  void printNoSong(){
		textAlign(LEFT);
    textSize(16);
    text("Welcome to Undanceable Energy! Here you can find new music in a fun and intuitive way.\n\nEach circle to the left "
    +"represents a piece of music, and the color of each circle represents its mood (Happy, Sad, Angry, etc.). The music is organized by two "
    +"axes: Danceability and Energy. You can zoom in and out of the plane by controlling one of the handles directly, or by using "
    +"the scroll wheel on your mouse.\n\nTo listen to a sample of a piece, just click on it.\n\nDon't forget to explore the other tabs above to find other"
    +" features!", PANEMINX+20, INFOMINY+35, WIDTH - PANEMINX - 35,HEIGHT-INFOMINY);
  }
}
  	
class ToolBox{
  int x, y;
  PImage toolbox;
  PImage facebook, youtube, money;
  int down, fbook, ytube;
  int fluid = 0; //how far down images are
  ToolBox(int x, int y){
    this.x = x;
    this.y = y;
    down = 30;
    fbook = -20;
    ytube = 20;
    //toolbox = loadImage("toolbox-small.png");
    facebook = loadImage("facebook");
    youtube = loadImage("youtube");
    //money = loadImage("web_money.jpg");
    imageMode(CENTER);
  }
  void draw(){
    fill(222);
    textAlign(CENTER,CENTER);
    text("The Tool Box",x,y-2);
    //image(toolbox,x,y+30,100,59);//,x+571, y+330);
    rectMode(CENTER);
    noFill(); stroke(160);
    rect(x,y+down,80,40);
    image(youtube, x+ytube, y+down);//,28,28);
    image(facebook, x+fbook, y+down, 29, 29);
    rectMode(CORNERS);
    if(mouseX > x+ytube-15 && mouseX < x+ytube+15 && mouseY > y+down-15 && mouseY < y+down+15){
      textAlign(LEFT, BASELINE); textSize(16);
      text("Search for artist/song on YouTube!",PANEMINX,PANEMINY-7);
      youtubeClick = true;
      facebookClick = false;
    }
    else if(mouseX > x+fbook-15 && mouseX < x+fbook+15 && mouseY > y+down-15 && mouseY < y+down+15){
      textAlign(LEFT, BASELINE); textSize(16);
      youtubeClick = false;
      if(song.facebookURL){
        facebookClick = true;
        text("Open artist's Facebook page!", PANEMINX,PANEMINY-7);
      }
      else{
        text("This artist doesn't have a Facebook page",PANEMINX-5,PANEMINY-7);
        facebookClick = false;
      }
    }
    else{facebookClick = false; youtubeClick=false}
  }
}

boolean changingPosition = false; // used to alter where the drawing happens
int volume = 50;
boolean muted = false;
  
//class used to control the current song. also displays current song info
class Current{
  Play play; //play button
        //Rewind rewind; //rewind button
  Forward ffwd; //ffwd button
  ToolBox toolBox;
  int timeDisplacement;
  Current(){
    play = new Play(300, 50, 20, 10);
             //rewind = new Rewind(250, 50, 20, 10);
    ffwd = new Forward(350, 50, 20, 10);
    toolBox = new ToolBox(PANEMINX + (WIDTH - PANEMINX)/2,18);
    textSize(15);
    timeDisplacement = textWidth("0:00/0:00");
  }
  
  void draw(){
    if(started){
      // draw the controls
      play.update();
      play.draw();
              //rewind.draw();
      ffwd.draw();  
      
      // draw the seekbar
      drawSeekBar();
      drawSongInfo();
      
      drawVolume();
      if(onVolGen)
        drawVolumeSetter();
      toolBox.draw();
      rectMode(CORNERS);
      ellipseMode(CENTER_RADIUS);
    }
    else{
      textSize(46);
      fill(255);
      textAlign(LEFT, BASELINE);
      text("UndanceableEnergy",LIBMINX,60);
      int titlesize = textWidth("UndanceableEnergy");
      textSize(26);
      text(" Alpha",LIBMINX+titlesize,60);
      titlesize += textWidth(" Alpha");
      textSize(14);
      text("v2",LIBMINX+titlesize,60);
    }
  }
  
  void drawSongInfo(){
    textAlign(LEFT,TOP);
    textSize(20);
    color currentColor;
    if(genreDisplay == STYLE)
      currentColor = colors[genres.get(song.styles[0])];
    else
      currentColor = colors[genres.get(song.genre)];
    fill(currentColor);
    int maxt,maxa;
    if(textWidth(song.title+" by "+song.artist) <= LIBMAXX-30){
      maxt = maxa = WIDTH;
    }
    else if(textWidth(song.title) > (LIBMAXX-30)/2-16 && textWidth(song.artist) > (LIBMAXX-30)/2-16){
      maxt = maxa = (LIBMAXX-30)/2-16;
    }
    else if(textWidth(song.title) > textWidth(song.artist)){
      maxa = WIDTH;
      maxt = LIBMAXX-30 - textWidth(song.artist+" by ");
    }
    else{
      maxt = WIDTH;
      maxa = LIBMAXX -30- textWidth(song.title+" by ");
    }
    checkText(song.title, 30, 10,maxt,currentColor,24);
    checkText(song.artist, 30+textWidth(" by ") + min(maxt,textWidth(song.title)),10,maxa,currentColor,24);
    fill(255);
    text(" by ", 30+min(maxt,textWidth(song.title)),10);
    fill(currentColor);
    textSize(18);
    text(song.genre, 30, 37);
  }
  
  boolean pressedInSeekBar = false;
  /* FUUUUUUCK WASTE OF MY TIME! 
  void mouseClicked(){
    //play.mouseClicked();
    //ffwd.mouseClicked();
    seekBarClicked();
    volClicked();
  }
  */
  void mousePressed(){
    play.mousePressed();
            //rewind.mousePressed();
    ffwd.mousePressed();
    checkSeekBar();
    checkVol();
  }
  
  void mouseDragged(){
    play.mouseDragged();
              //rewind.mouseDragged();
    ffwd.mouseDragged();
    dragSeekBar();
    dragVol();
  }

  void mouseReleased()
  {
    play.mouseReleased();
              //rewind.mouseReleased();
    ffwd.mouseReleased();
    releaseSeekBar();
    releaseVol();
  }
  
  boolean onVolume(){
    if(mouseX > 247 && mouseX < 259 && mouseY > 44 && mouseY < 56)
      return true;
    return false;
  }
  boolean onVolumeSetter(){
    if(mouseX > 225 && mouseX < 280 && mouseY > 15 && mouseY < 85)
      return true;
    return false;
  }
  
  boolean onVol = false;
  boolean onVolGen = false;
  boolean volDragged = false;
  
  void drawVolume(){
    if(onVolume()){
      onVol = true;
      stroke(255);
    }
    else{
      noStroke();
      onVol = false;
    }
    fill(255);
    triangle(249, 50, 259, 43, 259, 57);
    rect(247,53,255, 47);
    stroke(255);
    strokeWeight(2);
    noFill();
    if(!muted){
      if(volume > 80)
        arc(263, 50, 12, 12, -(PI/3), PI/3);
      if(volume > 60)
        arc(262, 50, 9, 9, -(PI/3), PI/3);
      if(volume > 40)
        arc(261, 50, 6, 6, -(PI/3), PI/3);
      if(volume > 20)
        arc(260, 50, 3, 3, -(PI/3), PI/3);
    }
    else{
      stroke(new color(255,0,0));
      line(248,42,261,57);
    }
    if(onVolumeSetter())
      onVolGen = true;
    else if(!volDragged)
      onVolGen = false;
  }  
  
  void checkVol(){
    if(onVol)
      toggleMute();
    else if(onVolGen && mouseX > 232 && mouseX < 242 && mouseY > 20 && mouseY < 80){
      volDragged = true;
      volume = (80 - mouseY)/0.6;
      song.song.setVolume(volume);
    }
  }
  /* FUUUUUUCK WASTE OF TIIIIIIIIIIIIIIIIIIME
  void volClicked(){
    if(onVol)
      toggleMute();
    else if(onVolGen && mouseX > 232 && mouseX < 242 && mouseY > 20 && mouseY < 80){
      volume = (80 - mouseY)/0.6;
      songs.get(curSong).song.setVolume(volume);
    }
  }
  */
  void dragVol(){
    if(volDragged){
      if(mouseY > 80)
        volume = 0;
      else if(mouseY < 20)
        volume = 100;
      else
        volume = (80 - mouseY)/0.6;
      song.song.setVolume(volume);
    }
  }
  
  void releaseVol(){
    if(volDragged){
      volDragged = false; 
    }    
  }
  
  void drawVolumeSetter(){
    stroke(255);
    strokeWeight(2);
    fill(0);
    rect(232, 20, 242, 80);
    if(volume > 0){
      fill(colors[genres.get(song.genre)]);
      noStroke();
      rect(233, 79, 241, 81 - volume*0.6);
    }
  }
  //toggle both real mute and our variable
  void toggleMute(){
    song.song.toggleMute();
    muted = !muted;
  }
  
  boolean songPausedToBeginWith = false;
  
  //checks to see if user clicked somewhere in the seek bar
  void checkSeekBar(){
    //if song is loaded
    if(started){
      //if it is within the seekbar range
      if(mouseX>385 && mouseX<LIBMAXX-10-timeDisplacement && mouseY>40 && mouseY<60){
        changingPosition = true;
        stillWithinSeekBar = true;
        if(song.song.paused) //save whatever state it was in
          songPausedToBeginWith = true;
        else
          songPausedToBeginWith = false;
        song.song.pause();
      }
    }
  }
  /* fuuuuuuuuuuuuuuuuuuuck waaaaste of tiiiime!
  void seekBarClicked(){
    if(started){
      //if it is within the seekbar range
      if(mouseX>385 && mouseX<385+512 && mouseY>40 && mouseY<60){
        if(songs.get(curSong).song.readyState == 1)
          total = songs.get(curSong).song.durationEstimate;
        //if song is fully loaded
        else if(songs.get(curSong).song.readyState == 3)
          total = songs.get(curSong).song.duration;
        int seekPosition = (int)map(mouseX-385, 0, WIDTH/2, 0, total);
        /*if(!songPausedToBeginWith)
        songs.get(curSong).song.resume();  till here
        songs.get(curSong).song.setPosition(seekPosition);
      }
    }
  }
  */
  //checks to see if user let go of the mouse will in seekbar land
  void releaseSeekBar(){
    //if song is loaded
    if(started){
      //if click was initiated in seekbar
      if(changingPosition){
        //if within range still
        if(mouseX>385 && mouseX<LIBMAXX-10-timeDisplacement && mouseY>40 && mouseY<60){
          int total;
          if(song.song != null && song.song.readyState == 1)
            total = song.song.durationEstimate;
          //if song is fully loaded
          else if(song.song != null && song.song.readyState == 3)
            total = song.song.duration;
          int seekPosition = (int)map(mouseX,385,LIBMAXX-10-timeDisplacement, 0, total);
          if(!songPausedToBeginWith)
            song.song.resume();
          song.song.setPosition(seekPosition);
        }
        changingPosition = false;
        stillWithinSeekBar = false;
        //make it play again if it's been paused in the transition process
        if(!songPausedToBeginWith)
          song.song.resume();
      }
    }
  }
  
  boolean stillWithinSeekBar;
  //makes the line follow where the mouse is while dragging around
  void dragSeekBar(){
    //if song is loaded
    if(started){
      //if click was initiated in seekbar
      if(changingPosition){
        //if within range still
        if(mouseX>385 && mouseX<LIBMAXX-10-timeDisplacement && mouseY>40 && mouseY<60)
          stillWithinSeekBar = true;
        else
          stillWithinSeekBar = false;
      }
    }
  }
  
  String totTime;
  int total;
  
  //draws the seekbar, along with the position of the song if it's playing, as well as the time
  void drawSeekBar(){
    stroke(255);
    strokeWeight(3);
    if(song.song != null && song.song.readyState == 1){
      //draw song duration
      strokeWeight(1);
      line(385, 50, LIBMAXX-10-timeDisplacement, 50);
      //draw amount loaded
      strokeWeight(3);
      float x = map(song.song.bytesLoaded, 0, song.song.bytesTotal, 385, LIBMAXX-10-timeDisplacement);
      if(x>=0)
        line(385, 50, x, 50);
    }
    else
      line(385, 50, LIBMAXX-10-timeDisplacement, 50);
    //if song is loaded/loading, draw position
    if(song.song != null && song.song.readyState == 1 || song.song.readyState == 3){
      //take seek changes into account
      String curTime;

      if(!changingPosition || !stillWithinSeekBar){
        //if song is currently loading
        if(song.song.readyState == 1){
          total = song.song.durationEstimate;
          totTime = makeTime(total/1000);
        }
        //if song is fully loaded
        else if(song.song.readyState == 3){
          total = song.song.duration;
          totTime = makeTime(total/1000);
        }
        curTime = makeTime(song.song.position/1000);
        float x = map(song.song.position, 0, total, 385, LIBMAXX-10-timeDisplacement);
        if(x>=0)
          line(x, 40, x, 60);
      }
      else{
        line(mouseX, 40, mouseX, 60);
        curTime = makeTime(map(mouseX,385,LIBMAXX-10-timeDisplacement,0,total)/1000);
      }
      fill(255);
      textSize(15);
      textAlign(LEFT,CENTER);
      //if(total != 0)
        //curTime += "/" + totTime;
      text(curTime+"/"+totTime,LIBMAXX-timeDisplacement,50);
    }
    strokeWeight(1);
  }
}


ArrayList songs;
int maxSongs = 25;
int curSong;

void setNewXs(){
  for(int len = songs.size() - 1; len >= 0; len--)
    songs.get(len).setNewPos(0);
}
void setNewYs(){
  for(int len = songs.size() - 1; len >= 0; len--)
    songs.get(len).setNewPos(1);
}

float getPos(int curAxis, Object json){
  switch(curAxis){
    case 0: return json.audio_summary.tempo;
    case 1: return json.audio_summary.duration;
    case 2: return json.audio_summary.loudness;
    case 3: return json.artist_familiarity;
    case 4: return json.song_hotttnesss;
    case 5: return json.artist_hotttnesss;
    case 6: return json.audio_summary.energy;
    case 7: return json.audio_summary.danceability;
    case 8: return json.artist_location.longitude;
    case 9: return json.artist_location.latitude;
  }
}


/*song class. stores the audio object, as well as all the information related to it (title, genre, length, beat info, etc.)
*/
class Song{
  var song; // SMSound object
  String title;
  String artist;
  String genre;
  String mood;
  String filename;
  String location;
  int length;
  String time;
  float x, y, originalX,originalY;
  float[] beats;
  int curBeat; //index of current beat
  int nextBeatTime;
  boolean inView; 
  float artistFamiliarity, artistHotness, latitude, longitude, songHotness, danceability, energy, loudness, tempo;
  String artistID, songID, analysisURL;
  int timeSignature, key, mode;
  String[] styles;
  String facebookURL;
  
  Song(Object json){
    artistID = json.artist_id;
    filename = json.tracks[0].preview_url;
    title = json.title;
    artist = json.artist_name;
    length = json.audio_summary.duration*1000;
    time = makeTime(json.audio_summary.duration);
    originalX = getPos(xaxis, json);
    originalY = getPos(yaxis, json);
    x = map(originalX, minX, maxX, LIBMINX+13, LIBMAXX-13);
    y = map(originalY, maxY, minY, LIBMINY+13, LIBMAXY-13);
    location = json.artist_location.location;
    setView();
    artistFamiliarity = json.artist_familiarity;
    artistHotness = json.artist_hotttnesss;
    songID = json.id;
    analysisURL = json.audio_summary.analysis_url;
    latitude = json.artist_location.latitude;
    longitude = json.artist_location.longitude;
    songHotness = json.song_hotttnesss;
    danceability = json.audio_summary.danceability;
    energy = json.audio_summary.energy;
    loudness = json.audio_summary.loudness;
    tempo = json.audio_summary.tempo;
    timeSignature = json.audio_summary.time_signature;
    key = json.audio_summary.key;
    mode = json.audio_summary.mode;
    if(!genreArray)
      genre = json.genre;
    else
      genre = json.genre[0];
    if(genre == null) genre = json.mood;
    facebookURL = json.facebook;
    styles = json.style;
  }
  
  void figureOutTerms(Object terms){
    int len = terms.length;
    
    len = min(len, 3);
    if(len > 1){
      styles = new String[len];
      do{
        styles[len-1] = terms[len-1].name;
        len--;
      }while(len>0);
    }
  }
  
  void setNewPos(int i){
    switch(i){
      case 0: //x
        x = map(originalX, minX, maxX, LIBMINX+13, LIBMAXX-13);
        break;
      case 1: //y
        y = map(originalY, maxY, minY, LIBMINY+13, LIBMAXY-13); 
        break;
      case 2: //both
        y = map(originalY, maxY, minY, LIBMINY+13, LIBMAXY-13);
        x = map(originalX, minX, maxX, LIBMINX+13, LIBMAXX-13);
        break;
    }
    setView();
  }
  
  void setView(){
    if(x < LIBMAXX + 10 && x > LIBMINX - 10 && y < LIBMAXY + 10 && y > LIBMINY -10)
      inView = true;
    else
      inView = false; 
  }

  String getTitle(){
    return title;
  }
  String getArtist(){
    return artist;
  }
  String getGenre(){
    return genre;
  }
  int getLength(){
    return length;
  }
  float getX(){
    return x;
  }
  float getY(){
    return y;
  }
  void startSong(){
    song = soundManager.createSound({
      id: filename,
      url: filename,
      autoLoad: true,
      autoPlay: true,
      volume: volume,
      onfinish: function(){ createNext(); }
    });
    started = true;
    if(muted)
      song.mute();
  }
  void stopSong(){
    started = false;
    song.stop();
    song.unload();
    song.destruct();
  }
  var getSong(){
    return song;
  }
}

String makeTime(float time){ 
  int secs = (int) (time % 60);
  String minutes = (int) ((time % 3600) / 60);
  String seconds;
  //take care of sub-10 second cases
  if(secs == 0) 
    seconds = "00";
  else if(secs < 10)
    seconds = "0" + secs;
  else
    seconds = secs;
  return (minutes + ":" + seconds);
}  

/* class used to read in  CSV files*/
class CSV {
  String[][] data;
  int rowCount;
  
  CSV(String filename) {
    String[] rows = loadStrings(filename);
    data = new String[rows.length][];
    
    for (int i = 0; i < rows.length; i++) {
      /* OLD CODE FOR SKIPPING EMPTY ROWS
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }*/
      
      // split the row on the commas and copy to the array
      data[rowCount++] = split(rows[i], ',');
    }
    // resize the 'data' array as necessary
    data = (String[][]) subset(data, 0, rowCount);
  }


  int getRowCount() {
    return rowCount;
  }
  
  String getRowName(int row) {
    return getString(row, 0);
  }


  String getString(int rowIndex, int column) {
    return data[rowIndex][column].substring(1,data[rowIndex][column].length -1); //the substring is for files that have been saved
    // from open office
  }
  
  String getStringNormal(int rowIndex, int column){
    return data[rowIndex][column];
  }
  
  int getInt(int rowIndex, int column) {
    return parseInt(getStringNormal(rowIndex, column));
  }

  float getFloat(int rowIndex, int column) {
    return parseFloat(getStringNormal(rowIndex, column));
  }
}


