/* @pjs preload="facebook,youtube,info,heart,twitter,NYC.gif,rapper.svg,bot.svg,miniNYC.png,eventicon.png,logo";*/
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
var grid,gridLoad;

//positions of different sections of the screen
final int ZOOM = 0;
final int SCROLL = 1;
int WIDTH,HEIGHT,YBASE,XBASE;
int xgrid,ygrid;
int bannerX, bannerY, bannerXFull, bannerYFull;
int MINIMAXY; 

void setup(){
  WIDTH = max(700,$(window).width());//screen.width;//950;
  HEIGHT = max(870,$(window).height());//screen.height;// 635;
  logo = loadImage("logo");
$("#parent").css("width",WIDTH).css("height",HEIGHT);
  if(WIDTH == 700 || HEIGHT == 870){
	$("body").css("overflow","visible");
	//$("#dialogWindow").css("position","fixed");
  }
//else $("#dialogWindow").css("position","absolute");
  bannerXFull = 1920;
  bannerYFull = 1000;
  bannerX = 20;//WIDTH/bannerXFull*300;
  bannerY = 30;//HEIGHT/bannerYFull*300;
  YBASE = 30;
  XBASE = 0;
  ygrid = 7757;
  xgrid = 8189;
togglePlayer();
recentlyPlayed = new ArrayList();
		
	
  size(WIDTH, HEIGHT);
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
  sidePane = new SidePane(WIDTH-bannerX-284,bannerY);
  current = new Current();
  nyc = new Map();
	grid = new Array(8);
	gridLoad = new Array(8);
	for(int i = 0; i < 8; i++){
		grid[i] = new Array(8);
		gridLoad[i] = new Array(8);
		for(int j = 0; j < 8; j++)
			gridLoad[i][j] = false;
	}
  artinfo = new ArtistInfo();
  facebook = loadImage("facebook");
  youtube = loadImage("youtube");
  info = loadImage("info");
  heart = loadImage("heart");
  twitter = loadImage("twitter");
  //money = loadImage("web_money.jpg")
}


void setUpSize(width,height){
	if(width != WIDTH || height != HEIGHT){
		WIDTH = width;
		HEIGHT = height;
		$("#parent").css("width",width).css("height",height);
		 YBASE = 30;
		 XBASE = 0;
		//MINIMAXY = HEIGHT-30;
		size(WIDTH,HEIGHT);
		xlength = WIDTH;
		ylength = HEIGHT;
		PANEMINX = WIDTH-bannerX-284;
	    //INFOMINY = PANEMINY+controlLength;
	    //PANEMINY = bannerY;
		PANEMAXX = WIDTH-bannerX;
		//PANEMAXY = HEIGHT-300;
		miniRedX = map(xlength,0,xgrid,0,284);
		miniRedY = map(ylength,0,ygrid,0,270);
		nyc.setMins();
		seekLeft = PANEMINX+110;
		volX = PANEMINX+40;
		seekRight = PANEMAXX - 10 - timeDisplacement;
		
		//yloc = PANEMAXY - 15;
	    current.play.newPos(PANEMINX+72, yloc);
	    current.ffwd.newPos(PANEMINX+95, yloc);
		curLeft = PANEMINX; curRight = PANEMAXX; //curTop = PANEMAXY - 230; curBottom = PANEMAXY;
	  //$('#dialogWindow').css('right',bannerX + "px").css('top',PANEMAXY-200+"px");
	}
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
  imageMode(CORNER);
  image(logo,0,0);//,logo.width,logo.height);
  //draws the current song controller
  sidePane.draw();
current.draw();
  if(curhover > -1)
		drawHoverInfo(curhover);
  if(curehover > -1)
		drawEventInfo(curehover);
}

var artists = new ArrayList();
var events = new ArrayList();
var artist = null;

void setUpArtists(){
    artists.clear();
    String jsonstring = "http://localhost:8888/getArtists";/*?maxX="+maxX+"&minX="+minX+
              "&minY="+minY+"&maxY="+maxY;*/
    if(sortSongs){jsonstring+="&sort="+sortSongs;}
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

void setUpEvents(){
	events.clear();
	var pathArray = window.location.pathname.split( '/' );
	var sponsor;
	if(pathArray.length > 0){
		if(pathArray.length < 3)
			sponsor = pathArray[1];
		else
			sponsor = pathArray[3];
			
		$.getJSON("http://localhost:8888/getEvents?sponsor="+sponsor, function(results){
			if(results != null){
				var length = results.length;
				for(int i = 0; i < length; i++){
					results[i].X = map(results[i].x,725.056,935.131,1,2000);
					results[i].Y = map(results[i].y,701.865,850.945,1,1422);
		            events.add(results[i]);
				}
			}
		});
	}
}

int minX, minY, maxX, maxY;
int xlength, ylength, miniRedX,miniRedY;

int curhover = -1;
void loadMapPiece(int i, int j){
	var title;
	if((i == 0) || (i == 1 && j < 1)){
		title = "0";
		title += String(i*8+j+1)+'.grid';
	}
	else
		title = String(i*8+j+1)+'.grid';
	gridLoad[i][j] = true;
	grid[i][j] = loadImage(title);
}

class Map{
	PShape rapper, rapcircle;
	PImage NYC, miniNYC, eventIcon;
	int NYCx = 1000;
	int NYCy = 711;
	int ox, oy, ocx, ocy;
	int allX, allY;//grid
	var widths, heights;//lengths
	int ominx, ominy, miniMidX,miniMidY,midX,midY;
	int minix, miniy, maxix, maxiy;
	boolean opressed = false;
	boolean miniPressed = false;
	Map(){
		NYC = loadImage("NYC.gif");
		miniNYC = loadImage("miniNYC.png");
		eventIcon = loadImage("eventicon.png");
		ox = oy = -1;
		/*ominx = minX = NYCx - xdif;//map(NYCx - xdif,0,2000,725.056,935.131);
		maxX = NYCx + xdif;//map(NYCx + xdif,0,2000,725.056,935.131);
		ominy = minY = NYCy - ydif;//map(NYCy - ydif,0,1422,701.865,950.945);
		maxY = NYCy + ydif;//map(NYCy + ydif,0,1422,701.865,950.945);*/
		//531.749 231.083 853 810
		setUpArtists();
		setUpEvents();
		rapper = loadShape("rapper.svg");
		rapcircle = loadShape("bot.svg");
		prep();
	}
//	2000 x 1422
	/*
	"bottom right", "x" : "935.1310068607902", "y" : "850.9446986836866", "_id" : ObjectId("4f650989a0651c0372000003") }
	{ "name" : "top left", "x" : "725.0560652572382", "y" : "701.8649879537509", "_id" : ObjectId("4f6509e2a0651c0372000004") }
	
	*/
	
	
	void draw(){
		drawMap();
		drawArtists();
		drawEvents();
		fill(0);
		noStroke();
		rectMode(CORNERS);
		drawMini();
	}
	
	void drawMap(){
		imageMode(CENTER);
		var totX = 0;//widths[0];
		var totY = 0;//heights[0];
		int i;
		for(i = 0; i < 8; i++){
			totX+=widths[i];
			if(totX > midX)
					break;
//				print(grid[0][i].width + " ");
		}
		int j;
		for(j = 0; j < 8; j++){
			totY += heights[j];
			if(totY > midY)
					break;
//				print(grid[j][0].height + " ");
		}
		grimage(j,i,0+xlength/2-(widths[i]/2-(totX-midX)),0+ylength/2-(heights[j]/2-(totY-midY)));
		if(j > 0)
			grimage(j-1,i,0+xlength/2-(widths[i]/2-(totX-midX)),0+ylength/2-heights[j] - (heights[j-1]/2-(totY-midY))+1);
		if(i > 0)
			grimage(j,i-1,0+xlength/2-widths[i]-(widths[i-1]/2-(totX-midX))+1,0+ylength/2-(heights[j]/2-(totY-midY)));
		if(j < 7)
			grimage(j+1,i,0+xlength/2-(widths[i]/2-(totX-midX)),0+ylength/2+heights[j+1]/2+(totY-midY)-1);
		if(i < 7)
			grimage(j,i+1,0+xlength/2+widths[i+1]/2+(totX-midX)-1,0+ylength/2-(heights[j]/2-(totY-midY)));
		if(j>0 && i>0)
			grimage(j-1,i-1,0+xlength/2-widths[i]-(widths[i-1]/2-(totX-midX))+1,0+ylength/2-heights[j] - (heights[j-1]/2-(totY-midY))+1);
		if(j>0 && i<7)
			grimage(j-1,i+1,0+xlength/2+widths[i+1]/2+(totX-midX)-1,0+ylength/2-heights[j] - (heights[j-1]/2-(totY-midY))+1);
		if(j<7 && i<7)
			grimage(j+1,i+1,0+xlength/2+widths[i+1]/2+(totX-midX)-1,0+ylength/2+heights[j+1]/2+(totY-midY)-1);
		if(j<7 && i>0)
			grimage(j+1,i-1,0+xlength/2-widths[i]-(widths[i-1]/2-(totX-midX))+1,0+ylength/2+heights[j+1]/2+(totY-midY)-1);
		//println("x: "+midX+"  y: "+midY);
		//println("i: " + i + "j: " + j);*/
	}
	
	void grimage(int j, int i, int one, int two){
		if(grid[j][i])
			image(grid[j][i],one,two);
		else if(!gridLoad[j][i]){
			loadMapPiece(j,i);
			rectMode(CENTER);
			fill(150); noStroke();
			rect(one, two, 1000,1000);
		}
	}
	
	void drawMini(){
		imageMode(CORNERS);
		image(miniNYC,PANEMINX,PANEMAXY,PANEMAXX,MINIMAXY);
		/*minix = map(minX, 0, 2000, 0, 284);
		maxix = map(maxX, 0, 2000, 0, 284);
		miniy = map(minY, 0, 1422, 0, 270);
		maxiy = map(maxY, 0, 1422, 0, 270);*/
		rectMode(CENTER);
		noFill();
		strokeWeight(1);
		stroke(colors[0]);
		rect(PANEMINX+miniMidX,PANEMAXY+miniMidY,miniRedX,miniRedY);
		ellipseMode(CENTER);
		fill(colors[2]); stroke(colors[2]); 
		for(int i = 0; i < artists.size(); i++){
			var cur = artists.get(i);
			if(cur == artist)
				ellipse(map(cur.x, 531.749,531.749+853,PANEMINX,PANEMAXX),map(cur.y,231.083,231.083+810,PANEMAXY,MINIMAXY),5,5);
			else
				ellipse(map(cur.x, 531.749,531.749+853,PANEMINX,PANEMAXX),map(cur.y,231.083,231.083+810,PANEMAXY,MINIMAXY),3,3);
		}
	//	fill(255); rect(PANEMAXX,PANEMAXY+270,10,10);
		//rect(PANEMINX+minix,PANEMAXY+miniy,PANEMINX+maxix,PANEMAXY+maxiy);
	}
	/*
	widths:
	1018 1027 1017 1028 1017 1028 1017 1037 
	heights
	950 970 970 969 979 970 970 979 
	totx:9207toty: 8707
	*/
	void prep(){
		xlength = WIDTH;
		ylength = HEIGHT;
		miniRedX = map(xlength,0,xgrid,0,284);
		miniRedY = map(ylength,0,ygrid,0,270);
		midX = xgrid/2;
		midY = ygrid/2;
		miniMidX = map(midX,0,xgrid,0,284);
		miniMidY = map(midY,0,ygrid,0,270);
		widths = new Array(1018,1027, 1017, 1028, 1017, 1028, 1017,1037);
		heights = new Array(950 ,970 ,970 ,969 ,979 ,970 ,970 ,979);
		allX = 9207; allY = 8707;
		setMins();
	}
	void miniMousePressed(){
		if(mouseX>PANEMINX && mouseY>PANEMAXY && mouseX<PANEMAXX && mouseY<MINIMAXY){
			miniPressed = true;
			miniMidX = min(max(miniRedX/2,mouseX - PANEMINX),284-miniRedX/2);
			miniMidY = min(max(miniRedY/2,mouseY - PANEMAXY),270-miniRedY/2);
			midX = map(miniMidX,0,284,0,xgrid);
			midY = map(miniMidY,0,270,0,ygrid);
			setMins();
			//alert(miniRedX);
		}
	}
	
	void miniMouseDragged(){
		if(miniPressed){
			miniMidX = min(max(miniRedX/2,mouseX - PANEMINX),284-miniRedX/2);
			miniMidY = min(max(miniRedY/2,mouseY - PANEMAXY),270-miniRedY/2);
			midX = map(miniMidX,0,284,0,xgrid);
			midY = map(miniMidY,0,270,0,ygrid);
			setMins();
		}
	}
	
	void miniMouseReleased(){
		miniPressed = false;
	}
	boolean once = false;
	
	void drawArtists(){
		shapeMode(CENTER);
		curhover = -1;
		for(int i = 0; i < artists.size(); i++){
			var cur = artists.get(i);
			if(cur.x < maxX+10 && cur.x > minX-10 && cur.y < maxY+15 && cur.y > minY-15){
				var x = map(cur.x,minX,maxX,0,WIDTH);
				var y = map(cur.y,minY,maxY,0,HEIGHT);
				if(mouseX < x+15 && mouseX > x-15 && mouseY < y+15 && mouseY > y-15){
					shape(rapcircle,x,y,30,30);
					curhover = i;
				}
				else if(cur==artist)
					shape(rapcircle,x,y,30,30);
				else
					shape(rapper,x,y,20,30);
			}
		}
	}
	
	void drawEvents(){
		imageMode(CENTER);
		curehover = -1;
		for(int i = 0; i < events.size(); i++){
			var cur = events.get(i);
			if(cur.x < maxX+15 && cur.x > minX-15 && cur.y < maxY+24 && cur.y > minY-24){
				var x = map(cur.x,minX,maxX,0,WIDTH);
				var y = map(cur.y,minY,maxY,0,HEIGHT);
				if(mouseX < x+15 && mouseX > x-15 && mouseY < y+24 && mouseY > y-24){
					curehover = i;
				}
				image(eventIcon,x,y);
			}
		}
	}
	
	void mousePressed(){
		ox = mouseX;
		oy = mouseY;
		ocx = midX; //original cur
		ocy = midY;
		ominx = minX;
		ominy = minY;
		opressed = true;
	}
	
	void mouseDragged(){
		if(opressed){
			midX = ocx - (mouseX-ox);
			midY = ocy - (mouseY-oy);
			if(midX > xgrid-xlength/2)
				midX = xgrid-xlength/2;
			if(midX < xlength/2)
				midX = xlength/2;
			if(midY < ylength/2)
				midY = ylength/2;
			if(midY > ygrid - ylength/2)
				midY = ygrid - ylength/2;
			miniMidX = map(midX,0,xgrid,0,284);
			miniMidY = map(midY,0,ygrid,0,270);
			
			setMins();
			/*
			minX = ominx + ocx - midX;
			maxX = minX + xdif*2;
			minY = ominy + ocy - curNYCy;
			maxY = minY + ydif*2;*/
		}
	}
	
	void setMins(){
		minX = map(midX-xlength/2,0,xgrid,531.749,531.749+853);
		maxX = map(midX+xlength/2,0,xgrid,531.749,531.749+853);
		minY = map(midY-ylength/2,0,ygrid,231.083,231.083+810);
		maxY = map(midY+ylength/2,0,ygrid,231.083,231.083+810);
	}
	
	void mouseReleased(){
		opressed = false;
		//setUpArtists();
	}
	void mouseOut(){
		opressed = false;
	}
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

void drawEventInfo(int i){
    String name = events.get(i).title;
    textSize(18);
    int xlength = textWidth(name);
    stroke(colors[6]);
    fill(0);
	rectMode(CORNERS);
    rect(mouseX, mouseY-33,mouseX+xlength+12, mouseY-7,10);

      fill(colors[6]);
    textAlign(LEFT,TOP);
    text(name, mouseX+6, mouseY-30);
}

void mouseClicked(){
  if(curhover >= 0){
    artist = artists.get(curhover);
	//getSong(artist.topTracks[0].id);
	playingSong = 0;
	loadVideo();
  }
  else if(curehover >= 0){
	//togglePlayer();
	loadEventVideo();
	//song.pause();
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
			/*togglePlayer();
			loadVideo();
			song.pause();*/
			//link("http://www.youtube.com/results?search_query=" + song.title.replace(/ /g, '+') + "+" +
		      //    song.artist.replace(/ /g, '+'), "_new");
		    return;
	}
	}
	else if(curSong >= 0){
		playingSong = curSong;
		loadVideo();
		//getSong(artist.topTracks[curSong].id);
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
  if(mouseY < curBottom && mouseY > curTop && mouseX < curRight && mouseX > curLeft){
    current.mousePressed();
  }
  else if(mouseX > PANEMINX && mouseX < PANEMAXX && mouseY > PANEMINY && mouseY < MINIMAXY){
	if(mouseY < PANEMAXY)
    	sidePane.mousePressed();
 	else
		nyc.miniMousePressed();
  }
  else
	nyc.mousePressed();
}


void mouseDragged(){
  current.mouseDragged();
  nyc.mouseDragged();
  nyc.miniMouseDragged();
}
void mouseOut(){
	nyc.mouseOut();
	current.mouseReleased();
}

void mouseReleased(){
  current.mouseReleased();
  nyc.mouseReleased();
  nyc.miniMouseReleased();
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
  
  void newPos(int x, int y){
	this.x = x;
	this.y = y;
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
      if(started && playMode == AUDIO)
        song.togglePause();
	  else if(playMode == VIDEO){
		if(player.getPlayerState()==2)
			player.playVideo();
		else
			player.pauseVideo();
	  }
      invert = false;
    }
    pressedHere = false;
  }
  
  // play is a boolean value used to determine what to draw on the button
  void update()
  {
    if(playMode == AUDIO && started){
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
	else if(playMode == VIDEO){
      if (player.getPlayerState()==2||player.getPlayerState()==-1){
          if(!changingPosition)
            play = true;
        }
        else
          play = false;
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
      noStroke();
    }
    else
    {
      fill(255);
      noStroke();
    }
    if ( play )
    {
      triangle(x - hw/2, y - hh/2, x - hw/2, y + hh/2, x + hw/2, y);
    }
    else
    {
      rect(x - hw/2, y - hh/2, x-1, y + hh/2);
      rect(x + hw/2, y - hh/2, x +1, y + hh/2);
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
      nextArtist();
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
      noStroke();
    }
    else
    {
      fill(255);
      noStroke();
    }
    rect(x-3, y-hh/2, x-6, y + hh/2); 
    triangle(x, y - hh/2, x, y + hh/2, x + hw/2 +1, y);    
  }  
}

//create the next song
void createNext(){
  stopSong();
  if(playingSong < artist.topTracks.length-1){
  	playingSong++;
	loadVideo();
	//getSong(artist.topTracks[playingSong].id);
  }
  else
	nextArtist();
}

ArrayList recentlyPlayed;

void nextArtist(){
	boolean alreadyPlayed = false;
	for(int i = 0; i < recentlyPlayed.size(); i++){
		if(recentlyPlayed.get(i) == artist.name){
			alreadyPlayed = true;
			break;
		}
	}
	if(!alreadyPlayed){
		recentlyPlayed.add(artist.name);
	}
	for(int i = 0; i < artists.size(); i++){
		var cur = artists.get(i);
		if(cur.x > minX && cur.x < maxX && cur.y > minY && cur.y < maxY){
			if(!recentlyPlayed.contains(cur.name)){
				artist = cur;
				//getSong(artist.topTracks[0].id);
				playingSong = 0;
				loadVideo();
			}
			
		}
	}
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

int curGenre = 0;
int PANEMINY, PANEMINX, PANEMAXY, PANEMAXX, controlLength, INFOMINY;
class SidePane{  
  int panel = BASICINFO;
  int margin = 10;
  int slant = 2;
  int num;
  int mouseMainPaneControl = -1;
  int mouseSort = -1;
  int mouseFilter = 0;
  int genreFilter = 0;
  boolean mouseOnTitle = 0;
  int mouseGenre = -1;
  var colorIcon, sortIcon;
  
  String[] names = {" Current Info"," Color Mode","Sorting"};
  color currentColor;

  SidePane(minx, miny){
    PANEMINX = minx;
    PANEMINY = miny;
    controlLength = 57;
    INFOMINY = PANEMINY+controlLength;
	PANEMAXX = WIDTH-bannerX;
	PANEMAXY = PANEMINY + 555;
	MINIMAXY = PANEMAXY + 270;
    num = names.length;
    textSize(16);
  }
  
  void draw(){
    drawControl();
	if(!artist){printNoSong();}else{printTopSongs();}		
  }

 
	
			
  void mousePressed(){

  }
  
  void mouseReleased(){}
  
  void drawControl(){
	fill(0);
	noStroke();
	rectMode(CORNERS);
	rect(PANEMINX,PANEMINY,PANEMAXX,PANEMAXY);
    strokeWeight(2);
    stroke(255);
    textSize(15);
    line(PANEMINX,PANEMINY,PANEMAXX,PANEMINY);
    line(PANEMINX, INFOMINY, PANEMAXX, INFOMINY);
    line(PANEMINX,PANEMINY,PANEMINX, PANEMAXY-1);
    line(PANEMAXX+1,PANEMINY,PANEMAXX+1,PANEMAXY-1);
	rectMode(CORNERS);
	noFill();
	rect(PANEMINX, MINIMAXY, PANEMAXX+1, PANEMAXY);
    for(int i = 0; i < 5; i++)
      line(PANEMINX + controlLength*(i+1), PANEMINY, PANEMINX + controlLength*(i+1),INFOMINY-1);
	imageMode(CORNERS);
	image(info, PANEMINX, PANEMINY,PANEMINX+controlLength,INFOMINY);
	image(facebook,PANEMINX+controlLength*2,PANEMINY,PANEMINX+controlLength*3,INFOMINY);
	image(heart,PANEMINX+controlLength,PANEMINY,PANEMINX+controlLength*2,INFOMINY);
	image(youtube,PANEMINX+controlLength*3,PANEMINY,PANEMINX+controlLength*4,INFOMINY);
	image(twitter,PANEMINX+controlLength*4,PANEMINY,PANEMINX+controlLength*5,INFOMINY);
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
    if(mouseX > PANEMINX && mouseY > PANEMINY && mouseY < INFOMINY && mouseX < PANEMINX+controlLength*5){
      for(int i = 0; i < 5; i++){
        if(mouseX < PANEMINX + controlLength*(i+1)){
          rect(PANEMINX+controlLength*i+2,PANEMINY+1,PANEMINX+controlLength*(i+1)-2,INFOMINY-2);
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
	fill(255);
    textSize(16);
    text("Welcome to RapCities! Here you can explore how the sound of Hip-Hop and Rap changes from neighborhood to neighborhood in New York City!\n\n"
    +"If you find an artist you want to check out, just click on their icon, and you'll get to sample some of their most popular tunes.\n\n"
    , PANEMINX+20, INFOMINY+35, PANEMAXX - PANEMINX - 40,HEIGHT-INFOMINY);
  }
}

int curSong = -1;
int playingSong = -1;

boolean changingPosition = false; // used to alter where the drawing happens
int volume = 50;
boolean muted = false;
int timeDisplacement, seekLeft, volX;
int curRight, curLeft, curTop, curBottom, yloc;
  
//class used to control the current song. also displays current song info
class Current{
  Play play; //play button
        //Rewind rewind; //rewind button
  Forward ffwd; //ffwd button

  Current(){
	curLeft = PANEMINX; curRight = PANEMAXX; curTop = PANEMAXY - 230; curBottom = PANEMAXY;
    timeDisplacement = textWidth("0:00/0:00");
	seekLeft = PANEMINX+110;
	yloc = PANEMAXY-18;
    play = new Play(PANEMINX+72, yloc, 10, 10);
             //rewind = new Rewind(250, 50, 20, 10);
    ffwd = new Forward(PANEMINX + 95, yloc, 10, 10);
	volX = PANEMINX+40;
	volY = 15; volD = 0.3; //divider (make it twice volY divided by 100)
	volS = 20; // separatedeness of volume setter
	seekRight = PANEMAXX - 10 - timeDisplacement;
    textSize(15);
  }
  
  void draw(){
    if(playMode == VIDEO || (playMode == AUDIO && started)){
	
	rectMode(CORNERS);
      // draw the controls
      play.update();
      play.draw();
              //rewind.draw();
      ffwd.draw();  
      
     // draw the seekbar
      drawSeekBar();
    //  drawSongInfo();
      
     drawVolume();
      if(onVolGen)
        drawVolumeSetter();
      rectMode(CENTER);
      ellipseMode(CENTER_RADIUS);
    }
  }
  
  void drawSongInfo(){
    textAlign(LEFT,TOP);
    textSize(20);
    color currentColor = colors[2];
    fill(currentColor);
    int maxt,maxa;
    if(textWidth(artist.topTracks[playingSong].title+" by "+artist.name) <= (volX- 50 - curLeft+20)){
      maxt = maxa = WIDTH;
    }
    else if(textWidth(artist.topTracks[playingSong].title) > (volX- 50 - curLeft+20)/2-16 && textWidth(artist.name) > (volX - 50- curLeft+20)/2-16){
      maxt = maxa = (volX - 50 - curLeft+20)/2-16;
    }
    else if(textWidth(artist.topTracks[playingSong].title) > textWidth(artist.name)){
      maxa = WIDTH;
      maxt = volX - 50 - curLeft+20 - textWidth(song.artist+" by ");
    }
    else{
      maxt = WIDTH;
      maxa = volX- 50 - curLeft+20- textWidth(artist.topTracks[playingSong].title+" by ");
    }
    checkText(artist.topTracks[playingSong].title, curLeft+20, YBASE+37,maxt,currentColor,24);
    checkText(artist.name, curLeft+20+textWidth(" by ") + min(maxt,textWidth(artist.topTracks[playingSong].title)),YBASE+37,maxa,currentColor,24);
    fill(255);
    text(" by ", curLeft+20+min(maxt,textWidth(artist.topTracks[playingSong].title)),YBASE+37);
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
    if(mouseX > volX-10 && mouseX < volX+2 && mouseY > yloc-6 && mouseY < yloc+6)
      return true;
    return false;
  }
  boolean onVolumeSetter(){
    if(mouseX > volX-volS-10 && mouseX < volX+20 && mouseY > yloc-volY && mouseY < yloc+volY)
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
    triangle(volX-10, yloc, volX, yloc-7, volX, yloc+7);
    rect(volX-10,yloc+3,volX-3, yloc-3);
    stroke(255);
    strokeWeight(2);
    noFill();
    if(!muted){
      if(volume > 80)
        arc(volX+6, yloc, 12, 12, -(PI/3), PI/3);
      if(volume > 60)
        arc(volX+5, yloc, 9, 9, -(PI/3), PI/3);
      if(volume > 40)
        arc(volX+4, yloc, 6, 6, -(PI/3), PI/3);
      if(volume > 20)
        arc(volX+3, yloc, 3, 3, -(PI/3), PI/3);
    }
    else{
      stroke(colors[0]);
      line(volX-9,yloc-8,volX+2,yloc+7);
    }
    if(onVolumeSetter())
      onVolGen = true;
    else if(!volDragged)
      onVolGen = false;
  }  
  
  void checkVol(){
    if(onVol)
      toggleMute();
    else if(onVolGen && mouseX > volX-volS-5 && mouseX < volX-volS+5 && mouseY > yloc -volY && mouseY < yloc+volY){
		volDragged = true;
      volume = (yloc+volY - mouseY)/volD;
		if(playMode == AUDIO)
      		song.setVolume(volume);
		else if(playMode == VIDEO)
  			player.setVolume(volume);			
    }
  }

  void dragVol(){
    if(volDragged){
      if(mouseY > yloc+volY)
        volume = 0;
      else if(mouseY < yloc-volY)
        volume = 100;
      else
        volume = (yloc+volY - mouseY)/volD;
	  	if(playMode == AUDIO)
      		song.setVolume(volume);
		else if(playMode == VIDEO)
  			player.setVolume(volume);			
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
    rect(volX-volS-5, yloc-volY, volX-volS+5, yloc+volY);
    if(volume > 0){
      fill(colors[2]);
      noStroke();
      rect(volX-volS-4, yloc+volY-1, volX-volS+4, yloc+volY+1 - volume*volD);
    }
  }
  //toggle both real mute and our variable
  void toggleMute(){
	if(playMode == AUDIO && started)
    	song.toggleMute();
	else if(playMode == VIDEO){
		if(player.isMuted())
			player.unMute();
		else
			player.mute();
	}	
    muted = !muted;
  }
  
  boolean songPausedToBeginWith = false;
  
  //checks to see if user clicked somewhere in the seek bar
  void checkSeekBar(){
    //if song is loaded
    if((playMode == AUDIO && started)||playMode == VIDEO){
      //if it is within the seekbar range
      if(mouseX>seekLeft && mouseX<seekRight && mouseY>yloc-10 && mouseY<yloc+10){
        changingPosition = true;
        stillWithinSeekBar = true;
        if((playMode == AUDIO && song.paused) || (playMode == VIDEO && player.getPlayerState() == 2)) //save whatever state it was in
          songPausedToBeginWith = true;
        else
          songPausedToBeginWith = false;
		if(playMode == AUDIO)
        	song.pause();
		else
			player.pauseVideo();
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
    if(playMode == VIDEO || (playMode == AUDIO && started)){
      //if click was initiated in seekbar
      if(changingPosition){
        //if within range still
        if(mouseX>seekLeft && mouseX<seekRight && mouseY>yloc-10 && mouseY<yloc+10){
          int total;
		  if(playMode == AUDIO){
          	if(song != null && song.readyState == 1)
	            total = song.durationEstimate;
	          //if song is fully loaded
	          else if(song != null && song.readyState == 3)
	            total = song.duration;
			 int seekPosition = (int)map(mouseX,seekLeft,seekRight, 0, total);
	          if(!songPausedToBeginWith)
	            song.resume();
	          song.setPosition(seekPosition);
		  }
		  else{
			int seekPosition = (int)map(mouseX,seekLeft,seekRight, 0, player.getDuration());
	          player.seekTo(seekPosition, true);
			  if(!songPausedToBeginWith)
	            player.playVideo();
			} 
          
        }
        changingPosition = false;
        stillWithinSeekBar = false;
        //make it play again if it's been paused in the transition process
        if(!songPausedToBeginWith){
			if(playMode == AUDIO)
          		song.resume();
			else
				player.playVideo();
		}
      }
    }
  }
  
  boolean stillWithinSeekBar;
  //makes the line follow where the mouse is while dragging around
  void dragSeekBar(){
    //if song is loaded
    if(playMode == VIDEO || (playMode == AUDIO && started)){
      //if click was initiated in seekbar
      if(changingPosition){
        //if within range still
        if(mouseX>seekLeft && mouseX<seekRight && mouseY>yloc-10 && mouseY<yloc+10)
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
    if((playMode == AUDIO && song != null && song.readyState == 1) || playMode == VIDEO && player.getPlayerState() == 3){
      //draw song duration
      strokeWeight(1);
      line(seekLeft, yloc, seekRight, yloc);
      //draw amount loaded
      strokeWeight(3);
	float x;
		if(playMode == AUDIO)
      		 x = map(song.bytesLoaded, 0, song.bytesTotal, seekLeft, seekRight);
		else
			 x = map(player.getVideoBytesLoaded(), 0, player.getVideoBytesTotal(),seekLeft,seekRight);
      if(x>=0)
        line(seekLeft, yloc, x, yloc);
    }
    else
      line(seekLeft, yloc, seekRight, yloc);
    //if song is loaded/loading, draw position
    if((playMode == AUDIO && song != null && (song.readyState == 1 || song.readyState == 3)) || 
		(playMode == VIDEO && player.getPlayerState() > 0)){
      //take seek changes into account
      String curTime;

      if(!changingPosition || !stillWithinSeekBar){
		float x;
		if(playMode == AUDIO){
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
	        x = map(song.position, 0, total, seekLeft, seekRight);
		}
		else if(playMode == VIDEO){
			total = player.getDuration();
			totTime = makeTime(total);
			curTime = makeTime(player.getCurrentTime());
	        x = map(player.getCurrentTime(), 0, total, seekLeft, seekRight);
	        
		}
        if(x>=0)
          line(x, yloc-10, x, yloc+10);
      }
      else{
        line(mouseX, yloc-10, mouseX, yloc+10);
		float time = map(mouseX,seekLeft,seekRight,0,total);
		if(playMode == AUDIO)
			time /= 1000;
        curTime = makeTime(time);
      }
      fill(255);
      textSize(15);
      textAlign(LEFT,CENTER);
      //if(total != 0)
        //curTime += "/" + totTime;
      text(curTime+"/"+totTime,curRight-timeDisplacement,yloc);
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

void videoEnded(){
	if(playingSong < artist.topTracks.length-1){
	  	playingSong++;
		loadVideo();
  }
  else
	nextArtist();
}

void togglePlayer(){
	$("#ytplayer").html('<script type="text/javascript">var params = { allowScriptAccess: "always" };var atts = { id: "YouTubeP" };swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&version=3", "ytplayer", "283", "200", "8", null, null, params, atts);</script>');
}

var player; 
boolean playMode;
int AUDIO = 1;
int VIDEO = 2;

void prepPlayer(){
	player = document.getElementById('YouTubeP');
	playMode = VIDEO;
	player.setVolume(volume);
}
void loadEventVideo(){
	$("#ytplayer").html('<script type="text/javascript">var params={allowScriptAccess:"always"};var atts={id:"ytplayer"};var url="http://www.youtube.com/v/'+events.get(curehover).link+'?enablejsapi=1&playerapiid=ytplayer&version=3&autoplay=1&controls=1";swfobject.embedSWF(url,"ytplayer","350","300","8",null,null,params,atts);</script>');
}

void loadVideo(){
	$.ajax({
    type: "GET",
	dataType:'jsonp',
	url: "http://gdata.youtube.com/feeds/api/videos?q="+artist.topTracks[playingSong].title.replace(/ /g,'+')+"+"+artist.name.replace(/ /g, '+')+"&v=2&alt=jsonc&max-results=1&format=5",
    success: function (response) {
      if(response.data.items.length>0){
        var video_id = response.data.items[0].id;
        player.loadVideoById(video_id);
      }
	  else{
	    $("#ytplayer").html("<p>Couldn't find this song on YouTube</p>");
	  }
	}
  });
}
void oldloadVideo(){
  $.ajax({
    type: "GET",
	dataType:'jsonp',
	url: "http://gdata.youtube.com/feeds/api/videos?q="+artist.topTracks[playingSong].title.replace(/ /g,'+')+"+"+artist.name.replace(/ /g, '+')+"&v=2&alt=jsonc&max-results=1&format=5",
    success: function (response) {
      if(response.data.items.length>0){
        var video_id = response.data.items[0].id;
        $("#ytplayer").html('<script type="text/javascript">var params={allowScriptAccess:"always"};var atts={id:"YouTubeP"};var url="http://www.youtube.com/v/'+video_id+'?enablejsapi=1&playerapiid=YouTubeP&version=3&autoplay=1&controls=1";swfobject.embedSWF(url,"ytplayer","350","300","8",null,null,params,atts);</script>');

      }
	  else{
	    $("#ytplayer").html("<p>Couldn't find this song on YouTube</p>");
	  }
	}
  });
}
