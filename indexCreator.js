	var mongodb = require('mongodb');
	//var mongoserver = new mongodb.Server('10.112.0.110', 26374);
	var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);
	var artists;

	dbConnector.open(function(err, db) {
	  if(err) {
	    console.log(err.message);
	  } else {
		db.collection('artistLocations2', function(err,col){
			if (err){
				console.log(err);
			}
			else{
			  col.ensureIndex('RID',function(err,index){
			    if(err) console.log('error: ' + err);
			    else{ artists = col; console.log('artists for songurls ready');}
			  });
			}
		});
	  }
      });
			      
    function returnSongIndex(splitURL, res){
      artists.findOne({'RID':splitURL[2]},function(err,artist){
	if(err) console.log('error finding artist: ' + err);
	else{
	  for(var i = 0; i < artist.topTracks.length; i++){
	    if(artist.topTracks[i].RID == splitURL[3]){
	      returnSongPage(splitURL, res, artist.name, artist.topTracks[i].title);
	      return;
	    }
	  }
	}
      });
    }
    
    function returnSongPage(splitURL, res, artistName, songName){
      //fs.readFile(__dirname + '/pde/indexoldhalf.html', function(error, content){
	  fs.readFile(__dirname + '/files/indexhalf.html', function(error, content){
          if(error){
            res.writeHead(500);
            res.end();
          }
          else{
      
      var top = '<html> <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# rapcities: http://ogp.me/ns/fb/rapcities#">'
  +'<meta property="fb:app_id" content="134659439991720" />'
  +'<meta property="og:type"   content="rapcities:song" />'
  +'<meta property="og:url"    content="http://rapcities.com/song/'+splitURL[2]+'/'+splitURL[3]+'" />' 
  +'<meta property="og:title"  content="'+songName+' by '+artistName+ '" />' 
  +'<meta property="og:description" content="Broadcasting Hip-Hop 24/7 from a virtual city of music and culture." />'
  +'<meta property="og:image"  content="http://rapcities.com/frlogo.png" />'
   +' <title>RapCities - '+artistName+' -- '+songName+'</title>';
      
      
      res.writeHead(200, {'Content-Type':'text/html; charset=utf-8'});
      res.end(top + content);
	  }
      });
    }
        
    exports.returnSongIndex = returnSongIndex;
