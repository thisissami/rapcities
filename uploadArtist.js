var mongodb = require('mongodb'),
  mongoserver = new mongodb.Server('10.112.0.110', 26374),
  dbConnector = new mongodb.Db('uenergy', mongoserver);
dbConnector.open(function(err, DB){
    if(err){
      console.log('oh shit! connector.open error!');
      console.log(err.message);
    }
    else{
      db = DB;
      console.log('opened successfully');
      db.createCollection('artistLocations', function(err, artlocs){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
	console.log('artist locations created');
	locs = artlocs;
});
}
});

function uploadLoc(response, query){
	console.log(query);
	locs.insert(query, {safe:true}, function(err, doc){
		if(err){console.log('ruh-roh! scooby dooby scawedy booby! (AKA artist upload failed)')}
		else{
			response.writeHead(200, {'Content-Type': 'application/json'});
			var returned = {'name':query.name};
			response.end(JSON.stringify(returned));
		}
	});
}

function getLocs(response){
	locs.find({}).toArray(function(err, results){
		if(!err){
			//var data = {}
			//data['results'] = results;
			response.writeHead(200, {'Content-Type': 'application/json'});
			response.end(JSON.stringify(results));
		}
	});
}

exports.uploadLoc = uploadLoc;
exports.getLocs = getLocs;