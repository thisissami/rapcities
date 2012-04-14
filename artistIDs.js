/**
 * Iterate through the artists in the database and
 * add information such as biographies and news to them.
 */
var mongodb = require('mongodb');
var mongoserver = new mongodb.Server('10.112.0.110', 26374);
//var mongoserver = new mongodb.Server('localhost', 26374);
var dbConnector = new mongodb.Db('uenergy', mongoserver);
var http = require('http');

var base = '/api/v4/artist/search?api_key=AOGW6OBBGGYABOKGX&limit=true&bucket=id:7digital-US&results=1&format=json';
var request = {
  'host' : 'developer.echonest.com',
  'port' : 80
}
var done = false;
var rateLimit = 2*1000;

dbConnector.open(function(err, db) {
  if(err) {
    console.log(err.message);
  } else {
    db.collection('artists', function(err, art) {
      if(err) {
        console.log(err.message);
      } else 
	arts = art;
{
	db.collection('artistLocations2',function(err,collection){
		if(err){
			console.log(err.message);
		} else {
        cursor = collection.find({});
        //global var
        cursor.count(function(err, tot) {
          if(err) {
            console.log(err.message);
          } else {
            total = tot;
            //global var
            console.log('Number of artists: ' + total);
            intervalID = setInterval(doNext, rateLimit, collection);
            //global var
          }
        });
      }
});}
    });
  }
});
var totCount = 0;
var count = 0;
function doNext(artLocs) {
  cursor.nextObject(function(err, artist) {
    if(err) {
      console.log(err.message);
    } else if(artist != null) {
      count++;

      //get from echonest the information for this artist ID
      request['path'] = base + '&name=' + (((artist.name).replace(/ /g, '%20')).replace(/&/g, '%26'));
      console.log('Getting info from artist: ' + artist.name);

      http.get(request, function(response) {
        var body = '';
        response.on('data', function(data) {
          body += data;
        });

        response.on('end', function() {
          var results = JSON.parse(body);
          if(results.response.status.code == 0) {
            echo_artist = results.response.artists[0];
console.log(JSON.stringify(echo_artist));
if(echo_artist.id){
			artLocs.findAndModify({'_id':artist._id}, [['_id','asc']],
			{$set : {
				'echoID': echo_artist.id,
					'7id': echo_artist.foreign_ids[0].foreign_id,
			}},function(err){if(err)console.log(err)});
            arts.insert({
              '_id' : echo_artist.id,
				'7id':echo_artist.foreign_ids[0].foreign_id,
				'name':echo_artist.name,
            }, {safe: true}, function(err) {
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
                  process.exit();
                }
              }
            });
          }else console.log('\n\nskipping this guy \n\n');} else {
            console.log('response error for artist ' + artist.name + ": " + JSON.stringify(results.response))
          }
        });
      }).on('error', function(e) {
        console.log('request error');
        console.log(e.message);
      });
    } else {
      done = true;
      clearInterval(intervalID);
      if(count <= 0) {
        console.log('total count: ' + totCount);
        process.exit();
      }
    }
  })
}