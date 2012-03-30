var mongodb = require('mongodb');
//var mongoserver = new mongodb.Server('localhost', 26374);
var mongoserver = new mongodb.Server('10.112.0.110', 26374);
var dbConnector = new mongodb.Db('uenergy', mongoserver);
var http = require('http');

dbConnector.open(function(err, db) {
  if(err) {
    console.log(err.message);
  } else {
    db.collection('artistLocations2', function(err, artlocs) {
      if(err) {
        console.log(err.message);
      } else {
	db.collection('artistLocations',function(err,collection){
		if(err){
			console.log(err.message);
		} else {
        collection.find().forEach(function(data){
			artlocs.insert(data);
});
       
      }
});}
    });
  }
});
