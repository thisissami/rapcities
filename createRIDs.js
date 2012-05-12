	var mongodb = require('mongodb');
	var mongoserver = new mongodb.Server('10.112.0.110', 26374);
	//var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);

// USAGE node removeYouTubeURL STRING artist INT postionInTopTracks INT newPositionInTopTracks

	dbConnector.open(function(err, db) {
	  if(err) {
	    console.log(err.message);
	  } else {
		db.collection('artistLocations2', function(err,col){
			if (err){
				console.log(err);
			}
			else{
				var cursor = col.find({});
				cursor.count(function(err,count){
					if(err) console.log('count error');
				console.log(count + ' artists');
				cursor.each(function(err,artist){
					if(err) console.log(err)
					else if(artist != null){
						var top = artist.topTracks;
						var i;
						for(i = 0; i < top.length; i++){
							if(top[i].RID == null){
								top[i]['RID'] = top[i].video_id;
							}
						}
						col.findAndModify({'echoID' : artist.echoID}, [['_id', 'asc']], {
			              $set : {
			                'topTracks' : top, 'RID':artist.echoID
			              }},{safe:true}, function(err) {
			              if(err) {
			                console.log(err.message);
			              }
							else{ console.log(artist.name + ' = success'); count--; if(count == 0) process.exit();}
						});
					}
				});});
			}
		});
	}
});

