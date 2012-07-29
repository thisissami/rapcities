	var mongodb = require('mongodb');
	var mongoserver = new mongodb.Server('10.112.0.110', 26374);
	//var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);
	var shortID = require('shortid').seed(18).worker(8);

// USAGE node port STRING artist/culture STRING example_id

	dbConnector.open(function(err, db) {
	  if(err) {
	    console.log(err.message);
	  } else {
		var type = process.argv[2];
		var coltoget;
		if(type == 'artist') coltoget = 'artistLocations2';
		else if(type == 'culture') coltoget = 'sponsorEvents';
		else{console.log('you did not specify artist or culture'); process.exit()}
		
		db.collection(coltoget, function(err,col){
			if (err){
				console.log(err);
			}
			else{
				db.collection('locs',function(err,joodoob){
					if(err)console.log(err);
					else if(process.argv[3]){
						locs = joodoob;
						locs.findOne({'_id':process.argv[3]}, function(err,example){
							if(err)console.log(err);
							else{
				//var newlocs = new Array();
				var cursor = col.find({});
				cursor.count(function(err,numba){
					if(err)console.log(err);
					else{
					total = numba;

				count = 0;
				cursor.each(function(err,doc){
					if(err) console.log(err)
					else if(doc){
						var cur = example;
						cur['x'] = doc.x;
						cur['y'] = doc.y;
						if(type == 'artist'){
							cur.title = doc.name;
							cur.facebook = doc.facebook;
							var list = new Array(); var i;
							for(i = 0; i < doc.topTracks.length; i++){
								list.push({
									'title':doc.topTracks[i].title,
									'ytid':doc.topTracks[i].video_id,
									'RID':i,
									'viewcount':0
								});
							}
							cur.list = list;
							cur.listnum = list.length;
							cur._id = shortID.generate();
							console.log('success - artist:  ' + cur.title);
							console.log(cur._id);
							locs.insert(cur,{safe:true},insertion);
						}
						else if(doc.sponsor == 'culture'){
							cur.title = doc.title;
							cur.info = 'This needs to be filled.';
							cur.ytid = doc.link;
							cur.viewcount = 0;
							cur._id = shortID.generate();
							console.log('success - culture:  ' + cur.title);
							locs.insert(cur,{safe:true},insertion);
						}
						else count++;
					}
					else{
						console.log('seem to have gotten through everything...');
					}
				});
								}}); 
					}
				});
					}
				});				
			}
		});
	}
});

function insertion(err,docs){
	if(err) console.log(err);
	else{
		console.log(++count+' tot: '+total); if(count == total){
			console.log('all inserted!');
			locs.remove({'_id':process.argv[3]},function(err,jib){
				if(err)console.log(err);
				else{console.log('finished!'); process.exit();}
			})
		}
	}
}

