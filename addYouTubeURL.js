	var mongodb = require('mongodb');
	var mongoserver = new mongodb.Server('10.112.0.110', 26374);
	//var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);
	var http = require('http');

	var base = '/api/v4/song/search?api_key=AOGW6OBBGGYABOKGX&limit=true&bucket=id:7digital-US&results=1&format=json&bucket=tracks';
	var request = {
	  'host' : 'developer.echonest.com',
	  'port' : 80
	}

// USAGE node addYouTubeURL STRING artist STRING title STRING video_id

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
						request['path'] = base + '&artist_id=' + (((artist.echoID).replace(/ /g, '%20')).replace(/&/g, '%26'))
						 + '&title=' + (((process.argv[3]).replace(/ /g, '%20')).replace(/&/g, '%26'));
					    console.log('Getting info from artist: ' + artist.name);

					      http.get(request, function(response) {
					        var body = '';
					        response.on('data', function(data) {
					          body += data;
					        });

					        response.on('end', function() {
					          var results = JSON.parse(body);
					          if(results.response.status.code == 0 && results.response.songs.length > 0) {							
								var top = artist.topTracks;
								var id7 = results.response.songs[0].tracks[0].foreign_id.split(':')[2];
								var song = { 'title':results.response.songs[0].title,'video_id':process.argv[4],'id':id7}
								top.push(song);
								col.findAndModify({'echoID' : artist.echoID}, [['_id', 'asc']], {
					              $set : {
					                'topTracks' : top
					              }},{safe:true}, function(err) {
					              if(err) {
					                console.log(err.message);
					              }
									else{ console.log('success'); process.exit();}
								});
							}else{
								var top = artist.topTracks;
								var song = { 'title':process.argv[3],'video_id':process.argv[4]}
								top.push(song);
								col.findAndModify({'echoID' : artist.echoID}, [['_id', 'asc']], {
					              $set : {
					                'topTracks' : top
					              }},{safe:true}, function(err) {
					              if(err) {
					                console.log(err.message);
					              }
									else{ console.log('shittier success'); process.exit();}
								});
							}
							});
						}).on('error',function(e){console.log(e)});
					}
				});
			}
		});
	}
});

