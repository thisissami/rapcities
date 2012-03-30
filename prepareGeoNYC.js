/**
 * Iterate through the artists in the database and
 * add information such as biographies and news to them.
 */
var mongodb = require('mongodb');
//var mongoserver = new mongodb.Server('localhost', 26374);
var mongoserver = new mongodb.Server('10.112.0.110', 26374);
var dbConnector = new mongodb.Db('uenergy', mongoserver);

var count = 0;

dbConnector.open(function(err, db) {
  if(err) {
    console.log(err.message);
  } else {
	db.collection('artistLocations2',function(err,collection){
		if(err){
			console.log(err.message);
		} else {
		collection.ensureIndex({loc:'2d'},{min:200,max:1400, safe:true},function(err){
			if(err)
				console.log(err.message);
			else{
			/*collection.insert({pos:[600, 600]}, {safe:true}, function(err, result) {
			if (err) console.log(err);
			else console.log('worked');
			});*/
			
        cursor = collection.find({});
        //global var
		cursor.count(function(err, total) {
          if(err) {
            console.log(err.message);
          } else {

        cursor.each(function(err, artist) {
          if(err) {
            console.log(err.message);
          } else if(artist != null) {
			collection.findAndModify({'_id':artist._id}, [['_id','asc']],
			{$set : {loc: Array(parseFloat(artist.x), parseFloat(artist.y))}},function(err){
				if(err) console.log(err);
				else{
					count++;
					if(count == total)
						process.exit();
				}
			});			
			}
        });
		}});
   }});   }
});}
    });