var http = require('http');
var mongodb = require('mongodb');
var mongoserver = new mongodb.Server('localhost', 26374);
var dbConnector = new mongodb.Db('uenergy', mongoserver);

/**
 * Look up the artist in the db and get its info.
 */
function get(res, query) {
  console.log('getting artist info...');
  
  dbConnector.open(function(err, db) {
    db.collection('artists', function(err, collection) {
      if(err) {
        console.log(err);
      } else {
        res.writeHead(200, {
          'Content-Type' : 'application/json'
        });
        collection.findOne({_id: query.id}, function(err, object) {
          if(err) {
            console.log('Error finding artist: ' + err);
          }
          else {
            res.end(JSON.stringify(object))
          }
        });
      }
    })
  });
}

exports.get = get;
