/* @pjs preload="NYC.svg,bot.svg,frame.svg";*/
/* this file supports P R O C E S S I N G . J S - 1.3.6 */
/* then go to http://localhost:8888/svg */

float fScale = 1.0;
float zoomFactor = 1;
float mouseXPrev=0.0f, mouseYPrev = 0.0f;

boolean rightDragging, leftDragging, leftClicked, rightClicked;

int BOTCOUNT = 0;

SceneGraph scene = new SceneGraph( this );

// viewport values for testing
int VPMINX, VPMINY, VPMAXY, VPMAXX;
// LIBControl values
float minX, maxY, maxX, minY, MINX, MAXY, MAXX, MINY;
String[] fontList;
var artlocs;
var rapper, rapcircle;

void setup() {
  size(853, 810);
  println( "setup!" );
  fontList = PFont.list();
  shapeMode(CENTER);

  VPMINX = 0;
  VPMINY = 0;
  VPMAXX = 853;
  VPMAXY = 810;
  rightDragging = leftDragging = leftClicked = rightClicked = false;
  minX = minY = MINX = MINY = 0.0;
  maxX = maxY = MAXX = MAXY = 1.0;

  frameRate(30);

  mainApp = this;
  //shapeMode(CORNER);
  rectMode(CORNERS);

  //if ( false == scene.addNode( null, "screen", 0, 0, width, height ) ) {
  if ( false == scene.addNode( null, "screen", VPMINX, VPMINY, VPMAXX-VPMINX, VPMAXY-VPMINY ) ) {
    println( "Setup failed" );
    return;
  }  	
  scene.gotoRoot();

  //if ( false == scene.addNode( "NYCMapOutlines2_simple.svg", "map", VPMINX, VPMINY, VPMAXX-VPMINX, VPMAXY-VPMINY )) {
  if ( false == scene.addNode( "NYC.svg", "map", 0, 0, 853, 810 )) {
    println( "Setup failed" );
    return;
  }  
  scene.gotoChild( "map" );
  // work at the "map" level
$.ajax({
	//url: "http://rapcities.com/getArtists", 
	url: "http://localhost:8888/getArtists", 
	success: function(data){if(data){artlocs = data}}
});
scene.setMapBounds();
rapper = loadShape("rapper.svg");
rapcircle = loadShape("bot.svg");
}
ellipseMode(CENTER);
var times = 0;

void draw() {
  //println( "Draw!");
  background(150);
  perFrame();

  scene.draw();

  pushStyle();
  fill(0);
  rect(0, 0, VPMINX, VPMAXY);
  rect(0, VPMAXY, VPMAXX, height);
  rect(VPMINX, 0, width, VPMINY);
  rect(VPMAXX, VPMINY, width, height);   
  popStyle();
if( !(rightDragging || leftDragging) )
  noLoop();
else
	scene.setMapBounds();
	
	if(artlocs)
		drawArtists();
	if(curclicked != -1){
		stroke(255);
		textSize(13);
		text(artlocs[curclicked].name, 50, 50);
	}
}
var curartist = -1;
var curclicked = -1;
void drawArtists(){
	fill(255);
	shapeMode(CENTER);
	//alert('wkaaksdfkjsf!');
	curartist = -1;
	for(int i = 0; i < artlocs.length; i++){
		if(artlocs[i].x < right && artlocs[i].x > left && artlocs[i].y > top && artlocs[i].y < bottom){
			float x = map(artlocs[i].x, left, right, 0, width);
			float y = map(artlocs[i].y, top, bottom, 0, height);
			if(mouseX < x+15 && mouseX > x-15 && mouseY > y-15 && mouseY < y+15){
				shape(rapcircle,x,y,30,30);
				curartist = i;
			}
			else
				shape(rapper,x, y, 20,30);
		}
	}	
}	
var left, right, top, bottom;
var artist;

void perFrame() {
  if (rightDragging) {
    //scene.pan(mouseX-mouseXPrev, mouseY-mouseYPrev);
    scene.panOnPoint(mouseX,mouseY,mouseXPrev,mouseYPrev, rightClicked);
  } 
  if (leftClicked) {
    println( "left clicked" );
	var curX = mouseX;
	var curY = mouseY;
	
    SceneNode clickedNode = scene.getNodeUsingScreenCoords( curX, curY );
    if( clickedNode == null ) {
      println( "clicked location not within bounds of root." );
    } else if ( clickedNode.getName() == "map" ) {
} 
    else if ( clickedNode.getName() != "screen" ) {
      println("clickedNode:"+clickedNode.getName());
    }
    leftClicked = false;
  }

  // Reset: events handled
  rightClicked = false;
  //mouseXPrev = mouseX;
  //mouseYPrev = mouseY;
}

void mousePressed() {
  if (!bMouseOut) {
    println("mousePressed");
    if (mouseButton == RIGHT) { 
      rightClicked = rightDragging = true;
      mouseXPrev = mouseX;
      mouseYPrev = mouseY;      
    }
    if (mouseButton == LEFT) { 
      leftClicked = leftDragging = true;
		if(curartist != -1){
			curclicked = curartist;
		}
		else
			curclicked = -1;
    }
    loop();
  }
}

void mouseReleased() {
  rightDragging = leftDragging = false;
}

void mouseScrolled() {
  int delta = 1;
  if (mouseScroll > 0) {
    // scroll up
    delta*=-1;
  } else if (mouseScroll < 0) {
    // scroll down
  }
  if (!bMouseOut) {
    zoomFactor = 1-0.1*delta;
    scene.zoomOnPoint(mouseX, mouseY, zoomFactor, zoomFactor);
    scene.setMapBounds();
	loop();
  }
}

void keyRelease() {
  println( "keyReleased");
  // Reset
  fScale = 1.0;
}

void mouseMoved() {
  if (!bMouseOut) loop();
}

boolean bMouseOut = false;
void mouseOver() {
  bMouseOut = false;
}

void mouseOut() {
  bMouseOut = true;
}

void keyPressed() {
  println( "keyPressed");

  if (keyCode == UP || keyCode == DOWN) {
    if (keyCode == UP) zoomFactor = 1.1;
    if (keyCode == DOWN) zoomFactor = 0.9;

    scene.zoomOnPoint(mouseX, mouseY, zoomFactor, zoomFactor);
  }
  if(key == 'f') {
    println( "fixUpMap" );
    //scene.setBounds(VPMINX,VPMINY,VPMAXX,VPMAXY,false);
    fixUpMap(0);
  }
  if (!bMouseOut) loop();
}

void fixUpMap(int type) {
  float x0, x1, y0, y1;    
  x0 = lerp( VPMINX, VPMAXX, minX/(MAXX-MINX) );
  x1 = lerp( VPMINX, VPMAXX, maxX/(MAXX-MINX) );
  y0 = lerp( VPMINY, VPMAXX, minY/(MAXY-MINY) );
  y1 = lerp( VPMINY, VPMAXY, maxY/(MAXY-MINY) );
  println("fixupMap");
  scene.setBounds(x0, y0, x1, y1);
//  scene.gotoRoot();
//  if( scene.gotoChild( "map" ) != false){
//    PVector mins = m_fromRoot.mult( new PVector(VPMINX, VPMINY), null );    
//    PVector maxs = m_fromRoot.mult( new PVector(VPMAXX, VPMAXY), null );
//    scene.setBounds(x0, y0, x1, y1, true);
//  }
}

// custom svg file tweaks

void processPrivateData(SceneNode newNode, String filename ) {
  // Any file specific processing  
  // DEBUG start
  println( "processPrivateData: SceneNode: " + newNode.getName());
  int childCount = newNode.getChildCount();
  println( "child count = " + childCount );
  if ( filename == "frame.svg") {
    for ( int i =0; i < childCount; ++i ) {
      String name = newNode.getChild(i).getName();
      println( i + ": " + name+" w:"+newNode.getChild(i).width+" h:"+newNode.getChild(i).height );
      newNode.getChild(i).setVisible(false);
      if ( name.equals( "Frame" )) {
        SceneNode frameNode = new SceneNode(newNode.getChild(i));
        if ( frameNode==null ) {
          println("frameNode is null");
        }
        PShape fromPath = frameNode.getChild(0);
        println( fromPath.getFamily() + "!" );
        if ( fromPath != null && fromPath.getFamily()==21 ) {  // path

          println( "fromPath.vertices.length" + fromPath.vertices.length );
          float[][] v = new float [fromPath.vertices.length][2];
          for ( int nv = 0 ; nv < fromPath.vertices.length; ++nv )
          {
            v[nv] = fromPath.vertices[nv];
            println( "v["+nv+"]="+v[nv][0]+" "+v[nv][1] );
          }
        } 
        else {
          println( "frame is null" );
        }
      }
    }
  }
  // for the map: BUGBUG: fix later
  if ( filename == "NYC.svg" ) {
    for ( int i =0; i < childCount; ++i ) {
      String name = newNode.getChild(i).getName();
      println( i + ": " + name+" w:"+newNode.getChild(i).width+" h:"+newNode.getChild(i).height );
      //if ( i > 3 && i <55 ) {
      //  newNode.getChild(i).setVisible( false );
      //}
    }
    // d="M182.274,153.498v1439.115h1585.788V153.498H182.274z"
    println("calling setBounds");
    //newNode.setBounds( 182.274,153.498,600.062,600.613,true);
newNode.setBounds( 531, 231, 1384, 1041,true);
    float[][] bounds = newNode.getBounds(true);
    bounds = newNode.getBounds(false);
  }
}
class SceneGraph {
  PApplet App;

  SceneNodeFactory m_nodeFactory;
  SceneNode root; 
  SceneNode current;
  // keep track of accumulated tx from current node to root
  // must update every time current is modified 
  PMatrix2D m_toRoot;
  PMatrix2D m_fromRoot;

  int m_nCount; 

  SceneGraph( PApplet app ) {
    App = app;
    m_nodeFactory = new SceneNodeFactory(app);
    m_nCount = 0;
    m_toRoot = new PMatrix2D();
    m_fromRoot = new PMatrix2D();
  }

  void gotoRoot() {
    current = root;
    m_toRoot = new PMatrix2D(root.getToParent(null));
    m_fromRoot = new PMatrix2D(root.getFromParent(m_fromRoot));
    //PMatrix2D p = root.getToParent(null);
    //p.print();
    //for( int i=0;i<6;++i)
    //  m_toRoot.elements[i] = p.elements[i];
    println("gotoRoot " + root.getName());
    m_toRoot.print();
  }

	void setMapBounds(){
	    PVector p = new PVector(0,0);
		tmp = root.getNode(0);
	    PVector p2 = root.fromParentCoords( p, null );      
	    PVector vectorC = tmp.fromParentCoords( p2, null );
		left = vectorC.x; top = vectorC.y;
		PVector p = new PVector(width,height);
		tmp = root.getNode(0);
	    PVector p2 = root.fromParentCoords( p, null );      
	    PVector vectorC = tmp.fromParentCoords( p2, null );
		right = vectorC.x; bottom = vectorC.y;
		println('\n\n\n\n\n\nOMG TOP = '+top+' and RIGHT = '+ right);
	}
	
  protected SceneNode addNode( String filename, String nodeName, PVector pos, PVector d ) {
    SceneNode newNode;
    //m_toParent.mult( pos, pos );
    println("calling addNode "+" "+pos.x+" "+pos.y);
    try {
      newNode = m_nodeFactory.CreateNode( filename, pos.x, pos.y, d.x, d.y );
      if ( newNode == null ) {
        println( "SceneGraph::addNode: could not create node using file " + filename );
        return null;
      }

      newNode.setName( nodeName );

      //BUGBUG: only adding to root
      if ( current != null ) {
        println( "adding node " + nodeName + " to " + current.getName()+" "+pos.x+" "+pos.y ) ;
        current.addNode( newNode );
      } 
      else {
        current = root = newNode;
      }  
      if ( pos != null ) { 
        newNode.translate( pos.x, pos.y, false );
      }
      if ( d != null ) {
        newNode.setDims( d.x, d.y );
      }
      m_nCount++;
      processPrivateData( newNode, filename );
      return newNode;
    } 
    catch ( Exception e ) {
      e.printStackTrace();
      println(e.getMessage());
    }    
    return null;
  }  

  SceneNode addNode( String filename, String nodeName, float posX, float posY, float dx, float dy ) {
    return addNode( filename, nodeName, new PVector( posX, posY), new PVector(dx, dy ));
  }

  boolean gotoChild( String childName ) {
    SceneNode tmp;
    for ( int j = 0; j<current.getNodeCount(); j++ ) { 
      tmp = current.getNode(j);
      if( tmp == null ){
        println("gotoChild:tmp is null");
        return false;
      }
      if ( tmp.getName() == childName ) {
        current = tmp;

        PMatrix2D test1 = new PMatrix2D( current.getToParent(null) );
        test1.invert();
        print( "gotoChild::test1:invert current.getToParent");test1.print();

        m_toRoot.apply( current.getToParent(null) );
        print( "m_toRoot" ); m_toRoot.print();
        m_fromRoot.preApply( current.getFromParent(m_fromRoot) );
        print( "m_fromRoot" ); m_fromRoot.print();
        println("gotoChild returning. current:"+current.getName());
        PMatrix2D test = new PMatrix2D( m_fromRoot );
        //test.apply( m_toRoot );
        test.invert();
        print( "test");test.print();
        return true;
      }
    }
    println("could not find child " + childName );
    return false;
  }

  void draw() {
    SceneNode tmp = root;
    recursiveDraw( tmp );
    tmp = root.getNode(0);
    if ( tmp.getName()=="map" ) {
      pushStyle();
      //text("\n Map:" +c.x + " " + c.y, mouseX, mouseY);
      popStyle();
    }  
  }  

  void recursiveDraw( SceneNode node ) {     
    //println("recursiveDraw");
    // apply m_toParent: so we can work in the current child's coordinate system
    pushMatrix();   
    PMatrix2D tx;
    //if (node != root ) {
      if ( (tx = node.getToParent(null)) == null ) {
        println( node.getName()+": null toParent!" );
      } 
      else {
        //println("applyingmatrix for" + node.getName());
        //tx.print();
      }
    //}
    node.pre();
    node.drawImpl();
    SceneNode nextNode = node.getNode(0);
    for ( int j = 0; nextNode != null ; nextNode = node.getNode(++j) ) {
      //println("node #" + j );
      recursiveDraw( nextNode );
      //nextNode.draw();
    }
    node.post();
    popMatrix();
  } 

  // get lowest z-order node using root node's coordinate system ( ie "screen" )  
  SceneNode getNodeUsingParentCoords ( float posX, float posY, SceneNode node, SceneNode topContaining  ) {
    println( "getNodeUsingParentCoords: node:"+ node.getName() + " topContaining: " + topContaining.getName() );
    PShape containingChild = null;
    if ( !node.checkBounds( posX, posY )) {
      return null;
    }
    // get coords into this node's f.o.r
    PVector pt = node.fromParentCoords( new PVector(posX, posY), null );   
    for ( int i = node.getNodeCount() - 1; i>=0; --i) {
      SceneNode tmp = node.getNode(i);
      // SceneNodes have lower z-order than PShape children
      topContaining = tmp;
      if ( null != (topContaining = getNodeUsingParentCoords( pt.x, pt.y, tmp, topContaining ) )) {
        return topContaining;
      }
    }/*
    // Now get to the PShape children
    if ( getContaining( pt.x, pt.y, (PShape)node ) == null ) {
      // has immediate PShape children. (x,y) not contained by any of them. 
      if ( node.getChildCount() > 0 ) {
        return null ;
      }        
      // no PShape children. Just go with w/h boundaries and return itself
    }*/
    // this node that contains (x,y)
    return node;
  }

  // below:: operating on entire scene
  // BUGBUG: these should really belong to screenOperations class
  // PtX and PtY are screen coords. Operations only affect 1st level nodes ( ie the screen's direct children's mtx's )
  void zoomOnPoint( float PtX, float PtY, float sX, float sY) {
    SceneNode tmp = root;
    int j = 0;

    PVector p = new PVector(PtX, PtY);
    PVector r = root.fromParentCoords( p, null );  // always from root

    while ( null != (tmp = root.getNode (j++))) {
      println( "j="+j+" : zoom on " + tmp.getName() );
      tmp.setScaleAboutPt( r.x, r.y, sX, sY );
      tmp.resetVisible();
    }
  }
  
  PVector panPoint;
  void panOnPoint( float curMx, float curMy, float prevMx, float prevMy, boolean bReset ) {
    if( bReset || panPoint == null ){
      panPoint = new PVector();
      // mouse just down. keep the coords in root's coords.
      //panPoint = root.fromParentCoords( new PVector( prevMx, prevMy ), null );
      panPoint = new PVector( prevMx, prevMy );
    }
    println("panPoint: "+panPoint.x+","+panPoint.y+" curMx,y:"+curMx+","+curMy);
    //PMatrix m = root.getFromParent(null);
    //m.print();
    //PVector c= new PVector( curMx, curMy );
    //PVector curM = m.mult( c, null ); 
    println("panOnPoint "+(curMx-panPoint.x)+","+(curMy-panPoint.y) );
    pan( curMx-panPoint.x, curMy-panPoint.y, true );
     
  }           

  void pan( float dx, float dy, boolean bLocal ) {
    float _dx = dx;
    float _dy = dy;

    gotoRoot();
    if ( !gotoChild( "map" ) ) {
      return;
    }
    PMatrix2D m = m_toRoot;
    if( m == null ) println("m is null ");
    _dx = m.elements[0]*dx+m.elements[1]*dy;
    _dy = m.elements[3]*dx+m.elements[4]*dy;

    println( "Attempting to translate "+_dx+","+_dy );
    float[] r_bounds = root.getBounds(true);
    println( "root bounds "+r_bounds[0]+","+r_bounds[1]+","+r_bounds[2]+","+r_bounds[3]);
    SceneNode tmp = root.getNode(0);
    for ( int j = 1; tmp != null ; tmp = root.getNode(j++) ) {
      float[] bounds = tmp.getBounds(false);
      println( tmp.getName()+" bounds: " +bounds[0]+","+bounds[1]+","+bounds[2]+","+bounds[3]);
      m= tmp.getFromParent(m);
      if( m == null ) println("m is null ");
      println( bounds[0]+","+bounds[1]+","+bounds[2]+","+bounds[3]);
      float[][] temp = new float[2][2];
      temp[0] = m.elements[0]*r_bounds[0]+m.elements[1]*r_bounds[1]+m.elements[2];
      temp[1] = m.elements[3]*r_bounds[0]+m.elements[4]*r_bounds[1]+m.elements[5];
      temp[2] = m.elements[0]*r_bounds[2]+m.elements[1]*r_bounds[3]+m.elements[2];
      temp[3] = m.elements[3]*r_bounds[2]+m.elements[4]*r_bounds[3]+m.elements[5];
      //println( "root bounds in child coords:"+temp[0]+","+temp[1]+","+temp[2]+","+temp[3]);     
      if( _dx > 0 ) _dx = min( r_bounds[0] - bounds[0] , _dx );
      if( _dx < 0 ) _dx = -min( bounds[2]-r_bounds[2], -_dx );
      if( _dy > 0 ) _dy = min( r_bounds[1] - bounds[1] , _dy );
      if( _dy < 0 ) _dy = -min( bounds[3] - r_bounds[3], -_dy );
     }

    if( abs(_dx) < 0.0000001 ) {
      if( abs(_dy) < 0.0000001 ) return; // don't do anything
      _dx += 0.0000001; 
    } 
    if( abs(_dy) < 0.0000001 ) {
      _dy += 0.0000001;
    }

    tmp = root.getNode(0);
    for ( int j = 0; tmp != null ; tmp = root.getNode(j++) ) {
      println( tmp.getName() + " translate "+_dx+","+_dy );
      //if( !tmp.checkBounds(tMinX+_dx, tMinY+_dy  ) ){}
      //PVector lt = tmp.fromParentCoords( new PVector(  tMinX+_dx, tMinY+_dy ), null );
      //PVector rb = tmp.fromParentCoords( new PVector(  tMaxX+_dx, tMaxY+_dy ), null );
      //PVector lt, rb;
      //tmp.getBounds( lt, rb );
      //if( lt.x 
      tmp.translate( _dx, _dy, true );
    }
  }
  
  void setBounds( float x0, float y0, float x1, float y1 ){
    SceneNode tmp = root.getNode(0);
    PMatrix2D m= root.getToParent(null);
    println( "root "+m.elements[0]+" "+m.elements[1]+" "+m.elements[2]);
    println( "     "+m.elements[3]+" "+m.elements[4]+" "+m.elements[5]);
    float _x0 = m.elements[0]*x0+m.elements[1]*y0;
    float _y0 = m.elements[3]*x0+m.elements[4]*y0;
    float _x1 = m.elements[0]*x1+m.elements[1]*y1;
    float _y1 = m.elements[3]*x1+m.elements[4]*y1;
    
    m_root.setBounds(_x0,_y0,_x1,_y1,true);
  }

  /*void setBounds( float x0, float y0, float x1, float y1 ) {
    if ( current != null ) current.setBounds( x0, x1, y0, y1, false );
  }

void setMapBoundsUsingScreenCoords( float x0, float y0, float x1, float y1 ){
  scene.gotoRoot();
  if( scene.gotoChild( "map" ) != false){
    PVector mins = m_fromRoot.mult( new PVector(x0, y0), null );    
    PVector maxs = m_fromRoot.mult( new PVector(x1, y1), null );
    scene.setBounds(mins.x, mins.y, maxs.x, maxs.y, true);
  }
}*/


  // Helper Functions
  // adds node using root node's coordinate system ( ie "screen" )
  // returns 
  SceneNode addNodeUsingScreenCoords ( String filename, String nodeName, float posX, float posY, float dx, float dy ) {
    gotoRoot();
    if ( !gotoChild( "map" ) ) {
      return false;
    }
    m_fromRoot.print();
    PVector p = new PVector(mouseX, mouseY);
    PVector r = m_fromRoot.mult( p, null );    
    PVector s = m_fromRoot.mult( new PVector(posX+dx, posY+dy), null );
    
    s.sub(r);
    
    println("addNodeUsingScreenCoords: current node is "+current.getName());
    // Now in current's frame of reference ( ie: new node's parent's f.o.r )
    // TODO: check if within current's bounds? ( current.getDims/Pos would be in current's parent coords
    //PShape child = null;
    //if ( !current.contains( r.x, r.y, child )) {
    //  println( "not within map's boundaries" );
    //  return false;
    //}
    // v[1,0] becomes v'[tmp.m00,tmp.m01] ( if there is no rotation then tmp.m01 = 0 )
    // dims ( last 2 params in addNode ) are scalers. Take abs.
    //float sX = (tmp.m00)*(tmp.m00)+(tmp.m01)*(tmp.m01);
    //sX = sqrt(sX);
    //float sY = (tmp.m10)*(tmp.m10)+(tmp.m11)*(tmp.m11);
    //sY = sqrt(sY);

    //return addNode( filename, nodeName, tmp.m02, tmp.m12, (tmp.m00+tmp.m01),(tmp.m10+tmp.m11) );
    //return addNode( filename, nodeName, tmp.m02, tmp.m12, sX, sY );
}

  // get lowest z-order node using root node's coordinate system ( ie "screen" )
  SceneNode getNodeUsingScreenCoords ( float posX, float posY ) {
    // nodes are added in reverse z-order
    SceneNode foundNode = root;
    if ( (foundNode = getNodeUsingParentCoords( posX, posY, root, foundNode )) != null )
    {
      println("found node: " + foundNode.getName());
    }
    return foundNode;
  }
    
} 

///////////////////////////////////////////////////////////////////////////////////////////////////
public class SceneNode {
  boolean m_bInitialized = false;
  PShapeSVG svgP;
  PShapeSVG svg;
  private PMatrix2D m_toParent;	// svgP's matrix must be reset whenever m_toParent changes
  private PMatrix2D m_fromParent;

  ArrayList childNodeList;
  SceneNode parent;

  // This node's dimensions ( if .svg , get from outermost <svg>'s viewBox definition
  float tMinX, tMaxX, tMinY, tMaxY;  
  float ptMinX, ptMaxX, ptMinY, ptMaxY; // prev

  SceneNode( String filename, SceneNode parent ) {
    if( filename != null ) {
      svgP = new PShapeSVG( null, filename );
      Initialize(parent);
    } else {
      Initialize(null);
    }
  }
  SceneNode( PShapeSVG g ) {
    svgP=g;
    if (g!=null) {
      if ( g instanceof PShape ) {
        println( "g is a PShape" );
        if ( g.parent != null && g.parent instanceof SceneNode ) {
          Initialize(g.parent);
        }
        else {
          Initialize(null);
        }
      }
    }
  }

  void Initialize(SceneNode parent) {
    println("Initializing");
    if ( svgP != null ) {
      if (svgP.getChildCount() != 0 ) {
        svg = svgP.getChild(0);		// SceneNode is pretending to be a wrapper for the top level element
      } 
      else { 
        svg=svgP;
      }
      tMaxX = svgP.width;
      tMaxY = svgP.height;
    }
    if ( svg == null ) {
      println( "svg is null");
      tMaxX = 1;
      tMaxY = 1;
    }
    childNodeList = new ArrayList();
    setParent(parent);
    tMinX = tMinY = 0.0f;
    println("Initialize: w:"+tMaxX+" h:"+tMaxY);
  } 

  void setParent(SceneNode parent) {
    this.parent = parent;
    if ( parent != null ) {
      println( "parent is " + parent.getName());
    }
    m_toParent = new PMatrix2D();
    m_fromParent = new PMatrix2D();
    svgP.resetMatrix();

    m_bInitialized = true;
  }

  void setName(string name) { 
    svgP.setName(name);
  }
  string getName() { 
    return svgP.getName();
  }

  PVector toParentCoords( PVector pT, PVector pP ) {
    pP = m_toParent.mult(  new PVector( pT.x, pT.y ), null );
    //pP = svgP.matrix.mult(  new PVector( pT.x, pT.y ), null );    
    return pP;
  }

  PVector fromParentCoords( PVector pP, PVector pT ) {
    //PMatrix2D m_fromParent = new PMatrix2D( m_toParent );
    //m_fromParent.invert();
    pT = m_fromParent.mult(  new PVector( pP.x, pP.y ), null );
    return pT;
  }  

  void pre() {
    svgP.pre();
  }
  void drawImpl() {
    if ( m_bInitialized ) {
      // DEBUG bounding box
      if(frameCount == 1 )
        println("Drawing debug rect for "+getName() );
      noFill();
      stroke(125,125,125);
      strokeWeight(3);
      rectMode( CORNER );
      rect( 0, 0, svgP.width, svgP.height );
      // END OF DEBUG
    }
    shapeMode( CORNERS );
    //println("Drawing svg " + svgP.getName());
    svgP.drawImpl();
  }
  void draw() {
    if ( m_bInitialized ) {
      // DEBUG bounding box
      //println("Drawing SceneNode");
//      fill(0);
//      stroke(100);
//      strokeWeight(1);
//      rectMode( CORNER );
//      rect( 0, 0, svgP.width, svgP.height );
      // END OF DEBUG
    }
    shapeMode( CORNERS );
    //println("Drawing svg " + svgP.getName());
     svgP.draw();
  }
  void post() {
    svgP.post();
  }

  void translate( float x, float y ){
    translate(x, y, true );
  }
  // in Parent coordinates, or local if bLocal = true
  void translate( float dx, float dy, boolean bLocal ) {
    print("translate sceneNode");
    if ( !m_bInitialized ) { 
      return;
    }
    float _dx = m_toParent.elements[0]*dx+m_toParent.elements[1]*dy;
    float _dy = m_toParent.elements[3]*dx+m_toParent.elements[4]*dy;

    if ( bLocal ) {
      print("translate fromParent "); m_fromParent.print();
      _dx = m_fromParent.elements[0]*dx+m_fromParent.elements[1]*dy;
      _dy = m_fromParent.elements[3]*dx+m_fromParent.elements[4]*dy;

      m_toParent.translate( _dx, _dy );
      svgP.translate( _dx, _dy );
      
    } 
    else { 
      m_toParent.translate( _dx,_dy );
      svgP.matrix.translate( _dx,_dy );
    }
    println( "translating "+getName()+" by "+_dx+","+_dy);
    m_fromParent = new PMatrix2D( m_toParent );
    m_fromParent.invert();
    print("m_fromParent");m_fromParent.print();
    print("svgP.matrix");
    svgP.matrix.print();
  }

  // ptX / Y in parent coords
  void setScaleAboutPt( float PtX, float PtY, float sX, float sY) {
    if ( !m_bInitialized ) { 
      return;
    }
    println("setScaleAboutPt "+PtX+","+PtY);
    PMatrix2D mat_new = new PMatrix2D();

    mat_new.translate(PtX, PtY);
    mat_new.scale(sX, sY);
    mat_new.translate(-PtX, -PtY);

    m_toParent.preApply( mat_new );
    PVector newBounds = m_toParent.mult( new PVector( tMinX, tMinY ), null );
    //tMinX = newBounds.x;
    //tMinY = newBounds.y;
    newBounds = m_toParent.mult( new PVector( tMaxX, tMaxY ), null );
    //tMaxX = newBounds.x;
    //tMaxY = newBounds.y;
    svgP.matrix.preApply( mat_new );
    
    mat_new.invert();
    m_fromParent.apply( mat_new );
    // DEBUG output
    print("m_toParent " ); m_toParent.print();
    print("m_fromParent " ); m_fromParent.print();
    print("getBounds " ); getBounds(true);getBounds(false);
  }

  void addNode( SceneNode node ) {
    if ( node == null ) {
      println( "attempted to add null node! " );
      return;
    } 
    node.setParent( this );
    childNodeList.add( node );
    println( getName() + " now has " + childNodeList.size() + " children" );
  }

  SceneNode getNode( int idx ) {
    //println("getNode");
    if( childNodeList == null ) println( "null childNodeList");
    if ( idx >= childNodeList.size() || idx < 0) {
      if ( idx < 0 ) println( "Bug! get node: idx =" + idx );
      return null;
    }
    return childNodeList.get(idx);
  }

  PShape getSVG() { 
    return svg;
  }

  PShape getChild(int idx) { 
    return svg.getChild(idx);
  }
  int getChildCount() { 
    return svg.getChildCount();
  }

  SceneNode getParent() { 
    return parent;
  }

  int getNodeCount() { 
    return childNodeList.size();
  }

  SceneNode getLastAdded() {
    return (SceneNode)childNodeList.get( childNodeList.size() - 1 );
  }

  PVector getScale() {
    float dx = sqrt( (m_toParent.m00)*(m_toParent.m00)+(m_toParent.m01)*(m_toParent.m01) );
    float dy = sqrt( (m_toParent.m10)*(m_toParent.m10)+(m_toParent.m11)*(m_toParent.m11) );
    //if ( matrix instanceof PMatrix2D) ((PMatrix2D)matrix).print();

    //dx *= svgP.width/(tMaxX-tMinX); // internal scaling
    //dy *= svgP.height/(tMaxY-tMinY); // internal scaling    
    return new PVector( dx, dy, 0.0 );
  }

  void scale(float x, float y ) {
    m_toParent.scale( x, y );
    m_fromParent.scale( 1/x, 1/y );
    svgP.scale(x,y);
  }

  // always wrt to parent: reset / init Dimension
  PVector getDims() {
    println("getDims.");
    m_toParent.print();
    PVector l = m_toParent.mult( new PVector( tMinX, tMinY ), null );
    PVector r = m_toParent.mult( new PVector( tMaxX, tMaxY ), null );
    r.sub(l);
    return r;
  }

  void setDims( float x, float y ) {    
    PVector dims = getDims();
    PVector l = m_toParent.mult( new PVector( tMinX, tMinY ), null );
    PVector r = m_toParent.mult( new PVector( tMaxX, tMaxY ), null );   
    r.sub(l);  
    
    PVector dims = new PVector( x/r.x, y/r.y );
    println("setDims "+dims.x+","+dims.y);
    m_toParent.scale( dims.x, dims.y );
    m_toParent.translate(-tMinX * (1 - dims.x ), -tMinY * (1 - dims.y ));
    
    m_fromParent = new PMatrix2D( m_toParent );
    m_fromParent.invert();
    
    svgP.scale(dims.x,dims.y);
    svgP.translate(-tMinX * (1 - dims.x ), -tMinY * (1 - dims.y ));
    println("translating "+l.x * (1 - dims.x )+","+l.y * ( 1- dims.y ));
    
    m_fromParent.print();
    svgP.matrix.print();
  }

  PVector getPos() {
    return m_toParent.mult( new PVector( tMinX, tMinY ), null );
  }

  // PShape's contains only implemented for PATH objects: checks within vertices
  // this method first checks if within display bounds, and then check in more detail
  boolean checkBounds( float x, float y ) {
    PVector dims = getDims();
    PVector pos = getPos();
    // x, y in parent coords
    if ( x < pos.x || x > (pos.x + dims.x) ) { 
      println( name+" "+x+" not within "+ pos.x+" & "+(pos.x + dims.x)); 
      return false;
    }
    if ( y < pos.y || y > (pos.y + dims.y) ) { 
      println( y+" not within "+ pos.y+" & "+(pos.y + dims.y)); 
      return false;
    }
    return true;
  }
  
  void setBounds( float xMin, float yMin, float xMax, float yMax, boolean bLocal ) {
    // where the tMin's used to be in parent coords
    PVector l = m_toParent.mult( new PVector( tMinX, tMinY ), null );    
    if( bLocal ) {
     ptMinX=tMinX; ptMaxX=tMaxX; ptMinY=tMinY; ptMaxY=tMaxY;     
     tMinX = xMin; tMinY = yMin; tMaxX = xMax; tMaxY = yMax;
     float dx = ptMinX-tMinX;
     float dy = ptMinY-tMinY; 
     float sx = (ptMaxX-ptMinX)/(tMaxX-tMinX);
     float sy = (ptMaxY-ptMinY)/(tMaxY-tMinY);
     println("dtMinX "+dx+",dtMinY "+dy);
     println("scaling "+sx+","+sy);
     this.scale( sx, sy );
     // new tMin's
     PVector l_ = m_toParent.mult( new PVector( tMinX, tMinY ), null );
     l.sub(l_);
     this.translate(l.x,l.y,true); 
   } else {
       this.translate( l.x-xMin, l.y-yMin, false );
       setDims( xMax-xMin, yMax-yMin );
     }
  }
  
  float[] getBounds(boolean bLocal) {
    println(getName()+" getBounds.");
    print( this.getName());
    float[] vertices = new float[4];
    if(bLocal){
      vertices[0]=tMinX;vertices[1]=tMinY;vertices[2]=tMaxX;vertices[3]=tMaxY;
      println( "local: "+vertices[0]+","+vertices[1]+","+vertices[2]+","+vertices[3]);
    }else {
      PVector lt = new PVector();
      PVector rb = new PVector();
      println( tMinX+","+tMinY+","+tMaxX+","+tMaxY);
      print("m_toParent " ); m_toParent.print();
      lt = m_toParent.mult( new PVector( tMinX, tMinY ), null );
      rb = m_toParent.mult( new PVector( tMaxX, tMaxY ), null );
      println( lt.x+","+lt.y+","+rb.x+","+rb.y);
      vertices[0]=lt.x;vertices[1]=lt.y;vertices[2]=rb.x;vertices[3]=rb.y;
    }
    return vertices;
  }
  
  boolean contains( float x, float y, PShape containingChild ) {
    // We need this node's coords:
    PVector Pos = fromParentCoords( new PVector(x, y), null );
    println( getName()+" contains: " + Pos.x + "," + Pos.y + "?" );
    containingChild = getContaining( Pos.x, Pos.y, this.svgP );
    return (containingChild != null);
  }

  boolean isInitialized() { 
    return m_bInitialized;
  }

  PMatrix2D getToParent(PMatrix2D target) {
    if ( m_toParent == null ) return null;

    target = new PMatrix2D( m_toParent ); 
    return target;
  }

  PMatrix2D getFromParent(PMatrix2D target) {
    if ( m_fromParent == null ) {
      println(getName()+" m_fromParent is null");
      return null;
    }
    target = new PMatrix2D( m_fromParent ); 
    return target;
  }  
  void resetVisible(){
    PVector s = getScale();
  }
  
}

class SceneNodeFactory {
  SceneNodeFactory(PApplet app) {
  }
  SceneNode CreateNode( String filename, float a, float b, float c, float d ) {
    SceneNode newNode;
    if ( filename == null ) {
      println( "Creating Null Node" );
      filename = "frame.svg";
    } 
    if ( filename.contains( ".svg" ) ) {
      try {
        println( "Loading file "+ filename );
        newNode = new SceneNode( filename, null );
      } 
      catch (Exception e) {
        println( "Unable to load file "+ filename);
        e.printStackTrace();
        return null;
      }
      if ( newNode == null ) println( "Unable to create node with file "+ filename);
      //processPrivateData( newNode, filename );
      return newNode;
    } 

    if ( filename != null || filename.length() > 1 ) {
      // to do: other file formats
      return null;
    } 

    // DEBUG end
    return null;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
// util functions
// .contains test
/*
boolean contains( float x, float y, PShape s ) {
 int family = s.getFamily();
 // Even if the path is not closed, we can just assume the first vertex = last to make it closed
 if( family == 21 ) { //PATH
 return s._contains(x, y, s.vertices);
 } else if( family == 1 ){ //PRIMITIVE
 return primitiveContains( x, y, s );
 } else if( family == 3 ) { // GEOMETRY
 return geometryContains( x, y, s );
 } else if ( family == 0 ) {
 //recurse
 return !(null == getContaining( x, y, s ));
 }
 println( "contains: unexpected family. PShape.name:"+s.getName() );
 return false;
 }  */

PShape getContaining( float x, float y, PShape ctnRoot ) {
  int family;
  if ( ctnRoot instanceof SceneNode ) {
    println("getGontaining( x, y, SceneNode )");
    family = 0;
  }
  else {
    family = ctnRoot.getFamily();
  }
  println( "family="+family );
  // Even if the path is not closed, we can just assume the first vertex = last to make it closed
  if ( family == 21 ) { //PATH
    if ( !_contains(x, y, ctnRoot.vertices)) return null;
  } 
  else if ( family == 1 ) { //PRIMITIVE
    if ( !primitiveContains( x, y, ctnRoot )) return null;
  } 
  else if ( family == 3 ) { // GEOMETRY
    if (! geometryContains( x, y, ctnRoot )) return null;
  } 
  else if ( family == 0 ) { //GROUP
    //recurse
    for ( int i= ctnRoot.getChildCount() -1; i >= 0 ; --i ) {
      PShape c = ctnRoot.getChild(i);
      c = getContaining( x, y, c );
      if ( c != null ) { 
        return c;
      }
    }
    return null;  // not in this group
  }
  else {
    println( "contains: unexpected family. PShape.name:"+ctnRoot.getName() );
    return null;
  }
  // This PShape is the containing shape
  return ctnRoot;
}


boolean geometryContains(float x, float y, PShape s ) {
  boolean c = false;
  int vertexCount = s.getVertexCount();
  for (int i = 0, j = vertexCount-1; i < vertexCount; j = i++) {
    float[][] vertices = { 
      {
        s.getVertexX(i), s.getVertexY(i), 0.0f
      }
      , 
      {
        s.getVertexX(j), s.getVertexY(j), 0.0f
      }
    };
    // vertices[i/j][x/y/z];
    if (((vertices[0][1] > y) != (vertices[1][1] > y)) &&
      (x < 
      (vertices[1][X]-vertices[0][X]) * 
      (y-vertices[0][Y]) / 
    (vertices[1][1]-vertices[0][Y]) + 
      vertices[0][X])) {
      c = !c;
    }
  } 
  return c;
}

boolean primitiveContains(float x, float y, PShape s ) {
  boolean c = false;
  int primitive = s.kind;  //PRIMITIVE type
  //float[] params = s.getParams();
  if (primitive == TRIANGLE) {
    println("TRIANGLE:");
    float[][] vertices = { 
      {
        s.params[0], s.params[1], 0
      }
      , 
      {
        s.params[2], s.params[3], 0
      }
      , 
      {
        s.params[4], s.params[5], 0
      }
    };
    return _contains( x, y, vertices);
  } 
  else if (primitive == QUAD) {
    println("QUAD:");
    float[][] vertices = { 
      {
        s.params[0], s.params[1], 0
      }
      , 
      {
        s.params[2], s.params[3], 0
      }
      , 
      {
        s.params[4], s.params[5], 0
      }
      , 
      {
        s.params[6], s.params[7], 0
      }
    };
    return _contains( x, y, vertices);
  } 
  else if (primitive == RECT) {
    println("RECT:");
    float[][] vertices = { 
      {
        s.params[0], s.params[1], 0
      }
      , 
      {
        s.params[0]+s.params[2], s.params[1], 0
      }
      , 
      {
        s.params[0]+s.params[2], s.params[1]+s.params[3], 0
      }
      , 
      {
        s.params[0], s.params[1]+s.params[3], 0
      }
    };
    return _contains( x, y, vertices);
  } 
  else if (primitive == ELLIPSE || primitive == ARC ) {
    println("ELLIPSE:cx"+s.params[0]+"cy"+s.params[1]+"w"+s.params[2]+"h"+s.params[3]+" ("+x+","+y+")");
    float a = (x-s.params[0]) / (s.params[2]/2.0f);
    a = a*a;
    float b = (y-s.params[1]) / (s.params[3]/2.0f);
    b = b*b;
    return( a + b < 1 );
  } 
  else if ( primitive == LINE || primitive == POINT ) {
    // LINE/POINT cannot contain anything
  } 
  else {
    println("primitiveContains: Unexpected primitive type.");
  }
  return false;
}

// tests if a point x,y is bounded by a list of vertices float [i][X/Y/Z]
// http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
boolean _contains( float x, float y, float[][] vertices ) {
  boolean c = false;
  for (int i = 0, j = vertices.length-1; i < vertices.length; j = i++) {
    if (((vertices[i][Y] > y) != (vertices[j][Y] > y)) &&
      (x < 
      (vertices[j][X]-vertices[i][X]) * 
      (y-vertices[i][Y]) / 
    (vertices[j][1]-vertices[i][Y]) + 
      vertices[i][X])) {
      c = !c;
    }
  }   
  return c;
}

//
// anonymous class: for easy SceneGraph traversal while performing some user defined function, passed in via wrapper object
class worker {
  PShape m_n;
  public Object[] params;

  worker ( PShape node ) { 
    println("worker()");
    setNode( node );
  }
  PShape getNode() { 
    return m_n;
  }
  void setNode( PShape n ) { 
    println("worker::setNode");
    if ( node instanceof SceneNode ) {
      m_n = node.getSVG();
    } 
    else {
      m_n = node;
    }
  }
  void action() {
  }
  void pre() {
  }
  void post() {
  }
}


////////////////////////////////////////////////////
//
// s_w can be defined to be anything at runtime and 
// executed in any of the following
static worker s_w;
//
///////////////////////////////////////////////////
void operateOnChildren(worker w)
{
  PShape n = w.getNode();
  w.pre();  
  for ( int i= 0; i< n.getChildCount(); ++i )
  {
    PShape child = n.getChild(i);
    w.setNode( child );
    w.action();
  }
  w.post();
}

/////////////////////////////////////////////////////
static worker s_rw;
void recurseAndOperation() {
  s_rw = new worker(s_w.getNode()) {
    public void action () {
      s_w.setNode( s_rw.getNode() );
      operateOnChildren(s_rw);
    } 
    public void pre() { 
      s_w.action();
    }
  }; 
  operateOnChildren(s_rw);
}

////////////////////////////////////////////////
void operateOnVisible()
{
  PShape n = s_w.getNode();
  s_w.action();
  s_w.pre();  
  for ( int i= 0; i< n.getChildCount(); ++i )
  {
    PShape child = n.getChild(i);
    if ( child.isVisible()) {
      s_w.setNode( child );
      operateOnVisible();
    }
  }
  s_w.post();
}




