	var mongodb = require('mongodb');
	var mongoserver = new mongodb.Server('10.112.0.110', 26374);
	//var mongoserver = new mongodb.Server('localhost', 26374);
	var dbConnector = new mongodb.Db('uenergy', mongoserver);

// USAGE node removeEvent STRING link 

	dbConnector.open(function(err, db) {
	  if(err) {
	    console.log(err.message);
	  } else {
		db.collection('sponsorEvents', function(err,col){
			if (err){
				console.log(err);
			}
			else{
				col.remove({'link':process.argv[2]},function(err){
					if(err) console.log(err)
					else{
						console.log('successfully removed!');
					}
				});
			}
		});
	}
});

