	var mongodb = require('mongodb');
	var mongoserver = new mongodb.Server('10.112.0.110', 26374);
	//var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);

// USAGE node replaceYouTubeURL STRING artist INT postionInTopTracks STRING youtubeID

	dbConnector.open(function(err, db) {
	  if(err) {
	    console.log(err.message);
	  } else {
		db.collection('artistLocations2', function(err,col){
			if (err){
				console.log(err);
			}
			else{
				console.log(process.argv[2]);
				col.findOne({'name':process.argv[2]},function(err,artist){
					if(err) console.log(err)
					else{
						var top = artist.topTracks;
						top[process.argv[3]].video_id = process.argv[4];
						col.findAndModify({'echoID' : artist.echoID}, [['_id', 'asc']], {
			              $set : {
			                'topTracks' : top
			              }},{safe:true}, function(err) {
			              if(err) {
			                console.log(err.message);
			              }
							else{ console.log('success'); process.exit();}
						});
					}
				});
			}
		});
	}
});

