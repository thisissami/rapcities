	var mongodb = require('mongodb');
	//var mongoserver = new mongodb.Server('10.112.0.110', 26374);
	var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);
	var http = require('http');

var done = false;
var rateLimit = 500;

	dbConnector.open(function(err, db) {
	  if(err) {
	    console.log(err.message);
	  } else {
		db.collection('artistLocations2', function(err,col){
			if (err){
				console.log(err);
			}
			else{
				locs = col;
				cursor = col.find({});
				cursor.count(function(err, tot) {
		          if(err) {
		            console.log(err.message);
		          } else {
				total = tot;
	            console.log('Number of artists: ' + total);
	            intervalID = setInterval(doNext, rateLimit);
	          }});}
	        });
	      }
	    });

	var totCount = 0;
	var count = 0;
	function doNext() {
	  cursor.nextObject(function(err, artist) {
	    if(err) {
	      console.log(err.message);
	    } else if(artist != null) {
	      count++;
	console.log(artist.name);
			var top = artist.topTracks;
			var i = 0;
			var trackCount = 0; var trackTotal = top.length;
			for(i = 0; i < trackTotal; i++){
				(function(cur){
					var request = {
						'host': 'gdata.youtube.com',
						'port': 80,
						'path': "/feeds/api/videos?q="+top[cur].title.replace(/ /g,'+')+"+"+artist.name.replace(/ /g, '+')+"&v=2&alt=jsonc&max-results=1&format=5"
					}
					http.get(request, function(response){
						var body = '';
					    response.on('data', function(data){
					      body += data;
					    });
					    response.on('end', function(){
							//console.log(body);
					      	var results = JSON.parse(body);
							//console.log(results);					
							trackCount++;
							if(results.data.items){
						        var video_id = results.data.items[0].id;
								top[cur].video_id = video_id;
						    }
							if(trackCount == trackTotal){
								locs.findAndModify({'echoID' : artist.echoID}, [['_id', 'asc']], {
					              $set : {
					                'topTracks' : top
					              }},{safe:true}, function(err) {
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
										removeDuplicates();
					                }
								}
							});
							}
						});
					});
				})(i);
			}		
		}
		else {
		     done = true;
	      clearInterval(intervalID);
	      if(count <= 0) {
	        console.log('total count: ' + totCount);
	        removeDuplicates();
	      }
	    }
	});
}	

function removeDuplicates(){
	cursor.rewind();
	var newCount = 0;
	cursor.each(function(err,artist){
		if(err) console.log(err);
		else if(artist){
			var i;
			var flag = false; 
			for(i = 0; i < artist.topTracks.length; i++){
				var id = artist.topTracks[i].video_id;
				var j; 
				for(j = i+1; j < artist.topTracks.length; j++){
					if(artist.topTracks[j].video_id == id){
						artist.topTracks[j].flag = true;
						flag = true;
					}	
				}
			}
			if(flag){
				var top = new Array();
				for(i = 0; i < artist.topTracks.length; i++){
					if(!artist.topTracks[i].flag)
						top.push(artist.topTracks[i]);
				}
				locs.findAndModify({'echoID' : artist.echoID}, [['_id', 'asc']], {
	              $set : {
	                'topTracks' : top
	              }}, {safe:true},function(err) {
	              if(err) {
	                console.log(err.message);
	              }else{
						console.log('updated '+ artist.name);
						newCount++;
						if(newCount == total) process.exit();
					}
				});
			}
			else newCount++;
		}
		else if(newCount == total) process.exit();
	});
}
