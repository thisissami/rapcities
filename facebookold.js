var mongodb = require('mongodb'),
  mongoserver = new mongodb.Server('localhost', 26374),
  dbConnector = new mongodb.Db('uenergy', mongoserver);

var done = false; 
var count = 0;
var totcount = 0;

dbConnector.open(function(err, db){
  if(err){
    console.log('oh shit! connector.open error!');
    console.log(err);
  }
  else{
    console.log('opened successfully');
    db.createCollection('artistLocations', function(err, artists){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
      }
      else{
        console.log('artists created');

          artists.find().each(function(err,doc){
            if(err){
              console.log('each error...');
              console.log(err);
            }
            else if(doc != null){
              artists.findOne({'_id':doc._id},{'artist.foreign_ids[0].foreign_id':true},function(err,fb){
                if(err){
                  console.log('findone facebook artists error');
                  console.log(err);
                }
                else if(fb.artist != undefined && fb.artist.foreign_ids != undefined && fb.artist.foreign_ids[0].foreign_id != undefined){
                  count++;
                  totcount++;
                  var facebook = 'http://facebook.com/pages/';
                  var fbookarr = fb.artist.foreign_ids[0].foreign_id.split(':');
                  facebook += fbookarr[1]+'/'+fbookarr[2];
                  doc.song.facebook = facebook;
                  songs.findAndModify({'_id':doc._id},[['_id','asc']],doc,{},function(err){
                    if(err){
                      console.log('find and modify error');
                      console.log(err);
                    }
                    else{
                      count--;
                      if(count == 0 && done == true){
                        console.log('totcount: ' + totcount);
                        process.exit();
                      }
                    }
                  });
                }
              });
            }
            else{done=true; if(count == 0){ console.log('totcount: '+totcount); process.exit();}}
          });
        });
      }
    });
  }
});
