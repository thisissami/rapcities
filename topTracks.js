var api = require('7digital-api'),
	artistes = new api.Artists();
	var mongodb = require('mongodb');
	var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);

var done = false;
var rateLimit = 500;

	dbConnector.open(function(err, db) {
	  if(err) {
	    console.log(err.message);
	  } else {
	    db.collection('artists', function(err, collection) {
	      if(err) {
	        console.log(err.message);
	      } else {
	        cursor = collection.find({});
	        //global var
	        cursor.count(function(err, tot) {
	          if(err) {
	            console.log(err.message);
	          } else {
		
		db.collection('artistLocations2', function(err,col){
			if (err){
				console.log(err);
			}
			else{
				locs = col;
			
	            total = tot;
	            //global var
	            console.log('Number of artists: ' + total);
	            intervalID = setInterval(doNext, rateLimit, collection);
	            //global var
	          }});}
	        });
	      }
	    });
	  }
	});

	var totCount = 0;
	var count = 0;
	function doNext(artists) {
	  cursor.nextObject(function(err, artist) {
	    if(err) {
	      console.log(err.message);
	    } else if(artist != null) {
	      count++;
			
			var id7 = artist['7id'].split(':')[2];
			
			artistes.getTopTracks({artistId:id7}, function(err,data){
				if(err){
					console.log("7digital top tracks error:");
					console.log(err);
				}
				else{
					var i;
					var top = new Array();
					for(i = 0; i < data.tracks.track.length; i++){
						var cur = {
							'title': data.tracks.track[i].title,
							'id': data.tracks.track[i].id,
							'duration': data.tracks.track[i].duration,
							'explicit': data.tracks.track[i].explicitContent
						}
						top.push(cur);
					}
					locs.findAndModify({
		              'echoID' : artist._id
		            }, [['_id', 'asc']], {
		              $set : {
		                'topTracks' : top
		              }
		            }, function(err) {
		              if(err) {
		                console.log(err.message);
		              }
		              count--;
		              totCount++;
		              console.log('total count: ' + totCount);
		              console.log('done: ' + done);
		              if(count <= 0 && done == true) {
		                console.log('Finished. Total elements updated: ' + totCount);
		                if(done) {
		                  process.exit();
		                }
		            
				}
			});
		}
	});
}	else {
      done = true;
      clearInterval(intervalID);
      if(count <= 0) {
        console.log('total count: ' + totCount);
        process.exit();
      }
    }
});
}


		
	
	
	
	/*34988" }
	{ "_id" : "ARVTAI41187B9B8B67", "7id" : "7digital-US:artist:3249" }
	{ "_id" : "ARZ3U2M1187B989ACB", "7id" : "7digital-US:artist:11066*/