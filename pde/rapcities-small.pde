/* @pjs preload="facebook,youtube,info,heart,twitter,NYC.gif,rapper.svg,bot.svg,miniNYC.png"; */
boolean started;
PFont font;
color[] colors;
color[] outlineColors;
Hashmap genres;
HashMap longText; //used for long text
Current current; //used to display current song info and controls
SidePane sidePane; //displays the sidepane
Map nyc;
ArtistInfo artinfo;

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
  LIBMINX = 10;
  LIBMINY = 95;
  LIBMAXX = 651;
  LIBMAXY = HEIGHT-10;

  size(WIDTH+8, HEIGHT);
  frameRate(30);
  smooth();
  rectMode(CORNERS);
  ellipseMode(CENTER_RADIUS);
  started = false;
  font = createFont("Arial", 13);
  textFont(font);
  setUpColors();
  songs = new ArrayList();
  longText = new HashMap();
  sidePane = new SidePane(LIBMAXX+10,LIBMINY);
  current = new Current();
  nyc = new Map();
  artinfo = new ArtistInfo();
  facebook = loadImage("facebook");
  youtube = loadImage("youtube");
  info = loadImage("info");
  heart = loadImage("heart");
  twitter = loadImage("twitter");
  //money = loadImage("web_money.jpg");
}
//PShapeSVG info;
PImage facebook, youtube, money,info,heart,facebook2,twitter;

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
  nyc.draw();
  current.draw(); //draws the current song controller
  sidePane.draw();
  if(curhover > -1)
		drawHoverInfo(curhover);
}

var artists = new ArrayList();
var artist = null;

void setUpArtists(){
    artists.clear();
    String jsonstring = "http://localhost:8888/getArtists";/*?maxX="+maxX+"&minX="+minX+
              "&minY="+minY+"&maxY="+maxY;*/
    if(sortSongs){jsonstring+="&sort="+sortSongs;}
    if(genreMode){jsonstring+="&genre="+curGenre;}
    $.getJSON(jsonstring, function(results){      
      if(results != null){
        var length = results.length;
        for(int i = 0; i < length; i++){
			results[i].X = map(results[i].x,725.056,935.131,1,2000);
			results[i].Y = map(results[i].y,701.865,850.945,1,1422);
            artists.add(results[i]);
		}
      }
    });
  }
int minX, minY, maxX, maxY;
int curhover = -1;

class Map{
	PShape rapper, rapcircle;
	PImage NYC, miniNYC;
	int NYCx = 1000;
	int NYCy = 711;
	int xdif = (LIBMAXX-LIBMINX)/2;
	int ydif = (LIBMAXY-LIBMINY)/2;
	int curNYCx = LIBMINX + xdif;
	int curNYCy = LIBMINY + ydif;
	int ox, oy, ocx, ocy;
	int ominx, ominy;
	int minix, miniy, maxix, maxiy;
	boolean opressed = false;
	Map(){
		NYC = loadImage("NYC.gif");
		miniNYC = loadImage("miniNYC.png");
		ox = oy = -1;
		ominx = minX = NYCx - xdif;//map(NYCx - xdif,0,2000,725.056,935.131);
		maxX = NYCx + xdif;//map(NYCx + xdif,0,2000,725.056,935.131);
		ominy = minY = NYCy - ydif;//map(NYCy - ydif,0,1422,701.865,950.945);
		maxY = NYCy + ydif;//map(NYCy + ydif,0,1422,701.865,950.945);
		setUpArtists();
		rapper = loadShape("rapper.svg");
		rapcircle = loadShape("bot.svg");
	}
//	2000 x 1422
	/*
	"bottom right", "x" : "935.1310068607902", "y" : "850.9446986836866", "_id" : ObjectId("4f650989a0651c0372000003") }
	{ "name" : "top left", "x" : "725.0560652572382", "y" : "701.8649879537509", "_id" : ObjectId("4f6509e2a0651c0372000004") }
	
	*/
	void draw(){
		imageMode(CENTER);
		image(NYC,curNYCx,curNYCy);
		drawArtists();
		fill(0);
		noStroke();
		rectMode(CORNERS);
		rect(0,0,LIBMINX,HEIGHT);
		rect(0,0,width,LIBMINY);
		rect(width,height,0,LIBMAXY);
		rect(width,height,LIBMAXX,0);
		noFill();
		stroke(255);
		rect(LIBMINX,LIBMINY,LIBMAXX,LIBMAXY);
		drawMini();
	}
	void drawMini(){
		imageMode(CORNERS);
		image(miniNYC,PANEMINX,PANEMAXY,PANEMAXX,HEIGHT-10);
		minix = map(minX, 0, 2000, 63, 135);// 0, 284);
		maxix = map(maxX, 0, 2000, 63, 135);//0, 284);
		miniy = map(minY, 0, 1422, 157, 207);//0, 270);
		maxiy = map(maxY, 0, 1422, 157, 207);//0, 270);
		rectMode(CORNERS);
		noFill();
		strokeWeight(1);
		stroke(colors[0]);
		rect(PANEMINX+minix,PANEMAXY+miniy,PANEMINX+maxix,PANEMAXY+maxiy);
	}
	boolean once = false;
	void drawArtists(){
		shapeMode(CENTER);
		curhover = -1;
		for(int i = 0; i < artists.size(); i++){
			var cur = artists.get(i);
			if(cur.X < maxX+10 && cur.X > minX-10 && cur.Y < maxY+15 && cur.Y > minY-15){
				var x = map(cur.X,minX,maxX,LIBMINX,LIBMAXX);
				var y = map(cur.Y,minY,maxY,LIBMINY,LIBMAXY);
				if(mouseX < x+15 && mouseX > x-15 && mouseY < y+15 && mouseY > y-15){
					shape(rapcircle,x,y,30,30);
					curhover = i;
				}
				else
					shape(rapper,x,y,20,30);
			}
		}
	}
	
	void mousePressed(){
		ox = mouseX;
		oy = mouseY;
		ocx = curNYCx; //original cur
		ocy = curNYCy;
		ominx = minX;
		ominy = minY;
		opressed = true;
	}
	
	void mouseDragged(){
		if(opressed){
			curNYCx = ocx + (mouseX-ox);
			curNYCy = ocy + (mouseY-oy);
			if(curNYCx > LIBMINX + NYCx)
				curNYCx = LIBMINX + NYCx;
			if(curNYCx < LIBMAXX - NYCx + 2)
				curNYCx = LIBMAXX - NYCx+2;
			if(curNYCy < LIBMAXY - NYCy + 1)
				curNYCy = LIBMAXY - NYCy + 1;
			if(curNYCy > LIBMINY + NYCy)
				curNYCy = LIBMINY + NYCy;
			minX = ominx + ocx - curNYCx;
			maxX = minX + xdif*2;
			minY = ominy + ocy - curNYCy;
			maxY = minY + ydif*2;
		}
	}
	
	void mouseReleased(){
		opressed = false;
		//setUpArtists();
	}
	void mouseOut(){
		opressed = false;
	}
}

void keyPressed(){
	//artinfo.showArtistInfo("ARZ3U2M1187B989ACB"); //get artist info
}


void drawHoverInfo(int i){
    String name = artists.get(i).name;
    textSize(18);
    int xlength = textWidth(name);
    stroke(colors[2]);
    fill(0);
	rectMode(CORNERS);
    rect(mouseX, mouseY-33,mouseX+xlength+12, mouseY-7,10);

      fill(colors[2]);
     // fill(outlineColors[genres.get(songs.get(hoverSong).genre)]);
    textAlign(LEFT,TOP);
    text(name, mouseX+6, mouseY-30);
}

void mouseClicked(){
  if(curhover >= 0){
    artist = artists.get(curhover);
  }
  else if(curMenu >= 0){
	switch(curMenu){
		case 0: //info
			artinfo.showArtistInfo(artist.echoID);
			return;
		case 1: //heart
		case 4: //twitter
		case 2://facebook
			link(artist.facebook, "_new");
		    return;
		case 3://youtube
			togglePlayer();
			loadVideo();
			//link("http://www.youtube.com/results?search_query=" + song.title.replace(/ /g, '+') + "+" +
		      //    song.artist.replace(/ /g, '+'), "_new");
		    return;
	}
	}
	else if(curSong >= 0){
		playingSong = curSong;
		getSong(artist.topTracks[curSong].id);
	}
}	
void getSong(int id){
	$.getJSON('http://localhost:8888/getTrack?id=' + id, function(data){
		if(started) stopSong();
		startSong(data.url);
	});
}
void startSong(String url){
	    song = soundManager.createSound({
	      id: url,
	      url: url,
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

void mousePressed(){
  if(mouseY < 145-70){//145 = LIBMINY original
    current.mousePressed();
  }
  else if(mouseX > LIBMAXX){
    sidePane.mousePressed();
  }
  else if(mouseX>LIBMINX && mouseY>LIBMINY && mouseY<LIBMAXY){
	nyc.mousePressed();
}
}


void mouseDragged(){
  current.mouseDragged();
  nyc.mouseDragged();
}
void mouseOut(){
	nyc.mouseOut();
}
void mouseReleased(){
  current.mouseReleased();
  nyc.mouseReleased();
}

int hoverSong = -1;
//float[][] temp = new float[36][2]; //used to show the entirely returned json

int songGlow = 1;
int songGlowWait = 0;
boolean songGlowUp = true;

  
void resetSongs(){
  for(int i = songs.size()-1; i > -1; i--){
    if(i==curSong&&started)
      songs.get(i).stopSong();
    songs.remove(i);
  }
  curSong = -1;
  song = null;
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
        song.togglePause();
      invert = false;
    }
    pressedHere = false;
  }
  
  // play is a boolean value used to determine what to draw on the button
  void update()
  {
    if(started){
      if (song != null && song.playState==1){
        if(song.paused){
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
  stopSong();
  int rand;
  do{
    rand = (int) random(artist.topTracks.length);
  }while(rand == curSong);
  playingSong = rand;
  getSong(artist.topTracks[playingSong].id);
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
	rectMode(CORNERS);
    rect(x-textWidth('W'),y+ybelow,x,y);
    rect(x+max,y,x+max+textWidth('W'),y+ybelow);
    fill(col);
    cur.length++;
    longText.put(string+textWidth(string),cur);
  }
  else
    text(string,x,y);
}

final int BASICINFO = 0;
final int SETTINGS = 1;

boolean genreMode = false;
int curGenre = 0;
int PANEMINY, PANEMINX, PANEMAXY, PANEMAXX;
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
  var colorIcon, sortIcon;
  
  String[] names = {" Current Info"," Color Mode","Sorting"};
  color currentColor;

  SidePane(minx, miny){
    PANEMINX = minx;
    INFOMINY = miny;
    length = 57;
    PANEMINY = INFOMINY-length;
	PANEMAXX = WIDTH-5;
	PANEMAXY = HEIGHT-280;
    num = names.length;
    textSize(16);
  }
  
  void draw(){
	if(!artist){printNoSong();}else{printTopSongs();}
    drawControl();		
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
      resetSongs();
    }
    else if(mouseGenre >= 0){
      curGenre = mouseGenre;
      if(genreMode){
        resetSongs();
      }
    }
  }
  
  void mouseReleased(){}
  
  void drawControl(){
    strokeWeight(2);
    stroke(255);
    textSize(15);
    line(PANEMINX,PANEMINY,PANEMAXX,PANEMINY);
    line(PANEMINX, INFOMINY, PANEMAXX, INFOMINY);
    line(PANEMINX,PANEMINY,PANEMINX, PANEMAXY-1);
    line(PANEMAXX+1,PANEMINY,PANEMAXX+1,PANEMAXY-1);
	rectMode(CORNERS);
	noFill();
	rect(PANEMINX, HEIGHT-10, PANEMAXX+1, PANEMAXY);
    for(int i = 0; i < 5; i++)
      line(PANEMINX + length*(i+1), PANEMINY, PANEMINX + length*(i+1),INFOMINY-1);
	imageMode(CORNERS);
	image(info, PANEMINX, PANEMINY,PANEMINX+length,INFOMINY);
	image(facebook,PANEMINX+length*2,PANEMINY,PANEMINX+length*3,INFOMINY);
	image(heart,PANEMINX+length,PANEMINY,PANEMINX+length*2,INFOMINY);
	image(youtube,PANEMINX+length*3,PANEMINY,PANEMINX+length*4,INFOMINY);
	image(twitter,PANEMINX+length*4,PANEMINY,PANEMINX+length*5,INFOMINY);
    ellipseMode(CENTER_RADIUS);
    noStroke();
    /*for(int i = 0; i < 10; i++){
      fill(colors[(colorIcon.start + i)%10]);
      ellipse(PANEMINX+length+colorIcon.places[i*2],PANEMINY+colorIcon.places[i*2+1],4,4);
    }
    for(int i = 0; i < 10; i++){
      stroke(colors[(sortIcon.start + i)%10]);
      line(PANEMINX+length*2+7,PANEMINY+sortIcon.places[i], PANEMINX+length*3-8,PANEMINY+sortIcon.places[i]);
    }*/
    //checking da mouse
    mouseMainPaneControl = -1;
    stroke(255);
    noFill();
    //rect(PANEMINX+length*panel+2,PANEMINY+1,PANEMINX+length*(panel+1)-2,INFOMINY-2);
    if(mouseX > PANEMINX && mouseY > PANEMINY && mouseY < INFOMINY && mouseX < PANEMINX+length*5){
      for(int i = 0; i < 5; i++){
        if(mouseX < PANEMINX + length*(i+1)){
          rect(PANEMINX+length*i+2,PANEMINY+1,PANEMINX+length*(i+1)-2,INFOMINY-2);
          textAlign(LEFT,BASELINE);
          textSize(16);
          fill(255);
		  curMenu = i;
          title(PANEMINX,PANEMINY-7);
          mouseMainPaneControl = i;
          break;
        }
      }
    }
	else curMenu = -1;
  }
  
	void title(int x, int y){
		switch(curMenu){
			case 0: text("Artist Info",x,y);break;
			case 1: text("Heart Artist",x,y);break;
			case 2: text("Artist's Facebook Page",x,y);break;
			case 3: text("View Current Song Video",x,y);break;
			case 4: text("Tweet About Song",x,y); break;
		}
	}
	void printTopSongs(){
		textAlign(LEFT,TOP);
		textSize(22);
		fill(colors[2]);
		checkText(artist.name,PANEMINX+10,INFOMINY+10, 200, 0,22);
		fill(255);
		textSize(16);
		int tot = artist.topTracks.length;
		curSong = -1;
		for(int i = 0; i < tot; i++){
			if(i == playingSong){
				fill(colors[2]);
				checkText(artist.topTracks[i].title, PANEMINX+20, INFOMINY + 35 + i*22,250,colors[2],30);
				fill(255);
			}
			else if(mouseX>PANEMINX+20 && mouseY < INFOMINY+35+(i+1)*22&& mouseY>INFOMINY+35+i*22){
				fill(colors[2]);
				checkText(artist.topTracks[i].title, PANEMINX+20, INFOMINY + 35 + i*22,250,colors[2],30);
				curSong = i;
				fill(255);
			}
			else
				checkText(artist.topTracks[i].title, PANEMINX+20, INFOMINY + 35 + i*22,250,color(255),30);
		}
	}
  //Basic Song Information
  void printNoSong(){
		textAlign(LEFT);
    textSize(16);
    text("Welcome to RapCities! Here you can explore how the sound of Hip-Hop and Rap changes from neighborhood to neighborhood in New York City!\n\n"
    +"If you find an artist you want to check out, just click on their icon, and you'll get to sample some of their most popular tunes.\n\n"
    , PANEMINX+20, INFOMINY+35, WIDTH - PANEMINX - 35,HEIGHT-INFOMINY);
  }
}

int curSong = -1;
int playingSong = -1;

boolean changingPosition = false; // used to alter where the drawing happens
int volume = 50;
boolean muted = false;
  
//class used to control the current song. also displays current song info
class Current{
  Play play; //play button
        //Rewind rewind; //rewind button
  Forward ffwd; //ffwd button
  int timeDisplacement;
  Current(){
    play = new Play(300, 50, 20, 10);
             //rewind = new Rewind(250, 50, 20, 10);
    ffwd = new Forward(350, 50, 20, 10);
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
      rectMode(CORNERS);
      ellipseMode(CENTER_RADIUS);
    }
    else{
      textSize(46);
      fill(255);
      textAlign(LEFT, BASELINE);
      text("RapCities",LIBMINX,60);
      int titlesize = textWidth("RapCities");
      textSize(26);
      text(" Alpha",LIBMINX+titlesize,60);
      titlesize += textWidth(" Alpha");
      textSize(14);
      text("v1",LIBMINX+titlesize,60);
    }
  }
  
  void drawSongInfo(){
    textAlign(LEFT,TOP);
    textSize(20);
    color currentColor = colors[2];
    fill(currentColor);
    int maxt,maxa;
    if(textWidth(artist.topTracks[playingSong].title+" by "+artist.name) <= LIBMAXX-30){
      maxt = maxa = WIDTH;
    }
    else if(textWidth(artist.topTracks[playingSong].title) > (LIBMAXX-30)/2-16 && textWidth(artist.name) > (LIBMAXX-30)/2-16){
      maxt = maxa = (LIBMAXX-30)/2-16;
    }
    else if(textWidth(artist.topTracks[playingSong].title) > textWidth(artist.name)){
      maxa = WIDTH;
      maxt = LIBMAXX-30 - textWidth(song.artist+" by ");
    }
    else{
      maxt = WIDTH;
      maxa = LIBMAXX -30- textWidth(artist.topTracks[playingSong].title+" by ");
    }
    checkText(artist.topTracks[playingSong].title, 30, 10,maxt,currentColor,24);
    checkText(artist.name, 30+textWidth(" by ") + min(maxt,textWidth(artist.topTracks[playingSong].title)),10,maxa,currentColor,24);
    fill(255);
    text(" by ", 30+min(maxt,textWidth(artist.topTracks[playingSong].title)),10);
    //fill(currentColor);
    //textSize(18);
    //text(song.genre, 30, 37);
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
      stroke(colors[0]);
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
      song.setVolume(volume);
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
      song.setVolume(volume);
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
      fill(colors[2]);
      noStroke();
      rect(233, 79, 241, 81 - volume*0.6);
    }
  }
  //toggle both real mute and our variable
  void toggleMute(){
    song.toggleMute();
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
        if(song.paused) //save whatever state it was in
          songPausedToBeginWith = true;
        else
          songPausedToBeginWith = false;
        song.pause();
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
          if(song != null && song.readyState == 1)
            total = song.durationEstimate;
          //if song is fully loaded
          else if(song != null && song.readyState == 3)
            total = song.duration;
          int seekPosition = (int)map(mouseX,385,LIBMAXX-10-timeDisplacement, 0, total);
          if(!songPausedToBeginWith)
            song.resume();
          song.setPosition(seekPosition);
        }
        changingPosition = false;
        stillWithinSeekBar = false;
        //make it play again if it's been paused in the transition process
        if(!songPausedToBeginWith)
          song.resume();
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
    if(song != null && song.readyState == 1){
      //draw song duration
      strokeWeight(1);
      line(385, 50, LIBMAXX-10-timeDisplacement, 50);
      //draw amount loaded
      strokeWeight(3);
      float x = map(song.bytesLoaded, 0, song.bytesTotal, 385, LIBMAXX-10-timeDisplacement);
      if(x>=0)
        line(385, 50, x, 50);
    }
    else
      line(385, 50, LIBMAXX-10-timeDisplacement, 50);
    //if song is loaded/loading, draw position
    if(song != null && song.readyState == 1 || song.readyState == 3){
      //take seek changes into account
      String curTime;

      if(!changingPosition || !stillWithinSeekBar){
        //if song is currently loading
        if(song.readyState == 1){
          total = song.durationEstimate;
          totTime = makeTime(total/1000);
        }
        //if song is fully loaded
        else if(song.readyState == 3){
          total = song.duration;
          totTime = makeTime(total/1000);
        }
        curTime = makeTime(song.position/1000);
        float x = map(song.position, 0, total, 385, LIBMAXX-10-timeDisplacement);
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



class ArtistInfo{
	var canvas = document.getElementById('canvas');
	var selectDiv = document.getElementById('artist-info');


	/**
	 * Set height and width and X and Y values here.
	 */
	var selectDivHeight = 635;
	var selectDivWidth = 1158;
	var selectDivX = 9;
	var selectDivY = 9;

	ArtistInfo(){}

	
	
	//invoked when the user presses the select button
	void showArtistInfo(artist_id) {
	  selectDiv.style.width = selectDivWidth;
	  selectDiv.style.height = selectDivHeight;
	  selectDiv.style.top = selectDivY+"px";
	  //selectDiv.style.left = selectDivX+"px";
	  //brings the selectDiv above the canvas
	  selectDiv.style.zIndex = 1;

	  /* set divs to correct width and height */
	  $('#center, #popup, #popup-nav, #popup-content').css('width', selectDivWidth+'px');
	  $('#popup-content').css('height', selectDivHeight+'px');

	  $.getJSON('http://localhost:8888/getArtistInfo?id=' + artist_id, function(data) {
	    loadBiographies(data.biographies);
	    loadBlogs(data.blogs);
	    loadImages(data.images);
	    loadNews(data.news);
	    loadVideos(data.videos);

	    //square hover and click
	    $('.square').hover(function() {
	      $(this).addClass('square-hover');
	    },
	    function() {
	      $(this).removeClass('square-hover');
	    }).click(function() {
	      popupLink($(this).data('url'));
	    });

	    $('#close').click(function() {
	      $('#artist-info').css('z-index', '-1');
	    });
	  });

	  $('.type').click(function() {
	    show_type( $(this).data('type') );
	    $('.type').removeClass('selected-type');
	    $(this).addClass('selected-type');
	    $('#popup').hide();
	    $('#center').show();
	  }).hover(
	    function() {
	      $(this).addClass('hover-type');
	    },
	    function() {
	      $(this).removeClass('hover-type');
	    }
	  );
	  $('#popup-close').click(function() {
	    $('#popup').hide();
	    $('#center').show();
	  });
	}

	/* Pop up an iframe to view link */
	function popupLink(url) {
	  $('#popup-content').attr('src', url);
	  $('#popup-url').attr('href', url);
	  $('#center').hide();
	  $('#popup').show();
	}

	function loadBiographies(data) {
	  var bioHtml = "<table><tr>";
	  $.each(data, function(index, value) {
	    bioHtml += "<td class='square-td'><div class='square' data-url='" + value.url + "'>" + "<h2>" + value.site + "</h2><p>"+condense(value.text) + "</p></div></td>";

	    if(index == 8) {
	      bioHtml += "</tr>";
	      return false;
	    } else if((index + 1) % 3 == 0) {
	      bioHtml += "</tr><tr>"
	    }
	  });
	  $('#biographies').html(bioHtml);
	}

	function condense(text) {
	  return text.substr(0, 250) + "...";
	}

	function loadBlogs(data) {
	  var bioHtml = "<table><tr>";
	  $.each(data, function(index, value) {
	    bioHtml += "<td class='square-td'><div class='square' data-url='" + value.url + "'><h2>" + value.name + "</h2><p>" + condense(value.summary) + "</p></div></td>";

	    if(index == 8) {
	      bioHtml += "</tr>";
	      return false;
	    } else if((index + 1) % 3 == 0) {
	      bioHtml += "</tr><tr>"
	    }
	  });
	  $('#blogs').html(bioHtml);
	}

	function loadImages(data) {
	  // var slideHtml = "<div id='slides'><div class='slides_container'>";
	  // $.each(data, function(index, value) {
	    // slideHtml += "<div class='slide'><a href='#'><img src='" + value.url + "'></a></div>";
	  // });
	  // slideHtml += "</div></div>";
	  // $('#images').html(slideHtml);
	  // $('#slides').slides({
	    // preload: true,
	    // play: 5000,
	    // pause: 2500,
	    // hoverPause: true,
	    // animationStart: function(current){
	      // $('.caption').animate({
	        // bottom:-35
	      // },100);
	    // },
	    // animationComplete: function(current){
	      // $('.caption').animate({
	        // bottom:0
	      // },200);
	    // },
	    // slidesLoaded: function() {
	      // $('.caption').animate({
	        // bottom:0
	      // },200);
	    // }
	  // });
	}

	function loadNews(data) {
	  var bioHtml = "<table><tr>";
	  $.each(data, function(index, value) {
	    bioHtml += "<td class='square-td'><div class='square' data-url='" + value.url + "'>" + "<h2>" + value.name + "</h2><p>"+condense(value.summary)+"</p></div></td>";

	    if(index == 8) {
	      bioHtml += "</tr>";
	      return false;
	    } else if((index + 1) % 3 == 0) {
	      bioHtml += "</tr><tr>"
	    }
	  });
	  $('#news').html(bioHtml);
	}

	function loadVideos(data) {
	  var vidHtml = "<table><tr>";
	  $.each(data, function(index, value) {
	    vidHtml += "<td class='square-td'><div class='square video' data-url='" + value.url + "'><h2>" + value.title + "</h2><img class='video-thumbnail' src='" + value.image_url + "'></div></td>";
	    if(index == 8) {
	      vidHtml += "</tr>";
	      return false;
	    } else if((index + 1) % 3 == 0) {
	      vidHtml += "</tr><tr>"
	    }
	  });
	  $('#videos').html(vidHtml);
	}

	function show_type(type) {
	  $('#center').children().css('display', 'none');
	  $("#" + type).css('display', 'block');
	}
}

void togglePlayer(){
  if( $("div#dialogWindow").dialog("isOpen") ) {
	$("div#dialogWindow").dialog("close");
  } else {
	$("div#dialogWindow").dialog("open");
  }
}

void loadVideo(){
  $.ajax({
    type: "GET",
	dataType:'jsonp',
	//url:"http://gdata.youtube.com/feeds/api/videos?q=felix+cartal+world+class+driver&v=2&alt=jsonc&max-results=1&format=5",
	url: "http://gdata.youtube.com/feeds/api/videos?q="+artist.topTracks[playingSong].title.replace(/ /g,'+')+"+"+artist.name.replace(/ /g, '+')+"&v=2&alt=jsonc&max-results=1&format=5",
    success: function (response) {
      if(response.data.items.length>0){
        var video_id = response.data.items[0].id;
        $("#ytplayer").html('<script type="text/javascript">var params={allowScriptAccess:"always"};var atts={id:"ytplayer"};var url="http://www.youtube.com/v/'+video_id+'?enablejsapi=1&playerapiid=ytplayer&version=3&autoplay=1&controls=1";swfobject.embedSWF(url,"ytplayer","350","300","8",null,null,params,atts);</script>');
      }
	  else{
	    $("#ytplayer").html("<p>Couldn't find this song on YouTube</p>");
	  }
	}
  });
}
