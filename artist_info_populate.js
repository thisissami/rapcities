/**
 * Iterate through the artists in the database and
 * add information such as biographies and news to them.
 */
var mongodb = require('mongodb');
//var mongoserver = new mongodb.Server('localhost', 26374);
var mongoserver = new mongodb.Server('10.112.0.110', 26374);
var dbConnector = new mongodb.Db('uenergy', mongoserver);
var http = require('http');

var base = '/api/v4/artist/profile?api_key=AOGW6OBBGGYABOKGX&bucket=news&bucket=biographies&bucket=blogs&bucket=images&bucket=video';
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
    db.collection('artists', function(err, collection) {
      if(err) {
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
    });
  }
});
var totCount = 0;
var count = 0;
function doNext(artists) {
  cursor.nextObject(function(err, artist) {
    if(err) {
      console.log(err.message);
    } else if(artist != null) {
      count++;

      //get from echonest the information for this artist ID
      request['path'] = base + '&id=' + artist._id;
      console.log('Getting info from artist: ' + artist._id);

      http.get(request, function(response) {
        var body = '';
        response.on('data', function(data) {
          body += data;
        });

        response.on('end', function() {
          var results = JSON.parse(body);
          if(results.response.status.code == 0) {
            echo_artist = results.response.artist;
            artists.findAndModify({
              '_id' : artist._id
            }, [['_id', 'asc']], {
              $set : {
                'biographies' : echo_artist.biographies,
                'blogs' : echo_artist.blogs,
                'images' : echo_artist.images,
                'news' : echo_artist.news,
                'videos': echo_artist.video
              }
            }, function(err) {
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
          } else {
            console.log('response error for artist ' + artist._id + ": " + JSON.stringify(results.response))
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