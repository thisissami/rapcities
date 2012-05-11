var mongodb = require('mongodb'),
  mongoserver = new mongodb.Server('localhost', 26374),
  dbConnector = new mongodb.Db('uenergy', mongoserver);

var songs, jazzDE, popDE, rockDE, electroDE, hiphopDE, rbDE, countryDE, bluesDE, skaDE, latinDE, moodDE;

dbConnector.open(function(err, db){
  if(err){
    console.log('oh shit! connector.open error!');
    console.log(err.message);
  }
  else{
    console.log('opened successfully');
    db.createCollection('songs', function(err, song){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
        console.log('songs created');
        songs = song;
        db.createCollection('rbDE', function(err, rb){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      rb.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('rb created');
        rbDE = rb;
        db.createCollection('hiphopDE', function(err, hiphop){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      hiphop.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('hiphop created');
        hiphopDE = hiphop;
        db.createCollection('skaDE', function(err, ska){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      ska.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('ska created');
        skaDE = ska;
        db.createCollection('latinDE', function(err, latin){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      latin.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('latin created');
        latinDE = latin;
        db.createCollection('countryDE', function(err, country){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      country.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('country created');
        countryDE = country;
        db.createCollection('bluesDE', function(err, blues){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      blues.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('blues created');
        bluesDE = blues;
        db.createCollection('electroDE', function(err, electro){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      electro.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('electro created');
        electroDE = electro;
        db.createCollection('rockDE', function(err, rock){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      rock.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('rock created');
        rockDE = rock;
        db.createCollection('popDE', function(err, pop){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      pop.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('pop created');
        popDE = pop;
        
    db.createCollection('jazzDE', function(err, jazz){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      jazz.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('jazz created');
        jazzDE = jazz;
        
    db.createCollection('moodDE', function(err, mood){
      if(err){
        console.log('oh shit! db.createCollection error!');
        console.log(err);
        return;
      }
      mood.ensureIndex({pos:'2d',hottness:-1,style:1},{min:-0.001,max:1.001},function(err){
              if(err)
                console.log(err.message);
            });
        console.log('moods created');
        moodDE = mood;
        doStuff();
        
    });});});});});});});});});});});});
  }
});

function doStuff(){
  var count = 11;
  songs.find({'song.genre':'Jazz'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(jazzDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Latin American'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(latinDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Ska'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(skaDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Hip Hop'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(hiphopDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Country/Folk'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(countryDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'R&B'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(rbDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Pop'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(popDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Rock'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(rockDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Blues'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(bluesDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.genre':'Electronic'},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.style':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(electroDE,doc);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  songs.find({'song.mood':{'$exists':true}},{'song.audio_summary.danceability':true,
            'song.audio_summary.energy':true, 'song.song_hotttnesss':true, 'song.mood':true}).each(function(err,doc){
    if(err)
      console.log(err);
    else if(doc)
      insert(moodDE,doc,3);
    else{
      count--;
      if(count == 0){
        console.log('done!');
        setTimeout(process.exit,2000);
      }
    }
  });
  
}

var count2 = 0;
    
    function insert(geo,song,mode){
                var DE = {}
                DE['_id'] = song._id;
                if(mode == undefined || mode == null)
                  DE['style'] = song.song.style;
                else
                  DE['mood'] = song.song.mood;
                DE['pos'] = Array(song.song.audio_summary.danceability,song.song.audio_summary.energy);
                DE['hottness'] = song.song.song_hotttnesss;
 /*               var hot = song.song.song_hotttnesss;
                if(hot < 0.05 || hot == null)
                  DE['hottness'] = 0.05;
                else if(hot < 0.1)
                  DE['hottness'] = 0.1;
                else if(hot < 0.15)
                  DE['hottness'] = 0.15;
                else if(hot < 0.2)
                  DE['hottness'] = 0.2;
                else if(hot < 0.25)
                  DE['hottness'] = 0.25;
                else if(hot < 0.3)
                  DE['hottness'] = 0.3;
                else if(hot < 0.35)
                  DE['hottness'] = 0.35;
                else if(hot < 0.4)
                  DE['hottness'] = 0.4;
                else if(hot < 0.45)
                  DE['hottness'] = 0.45;
                else if(hot < 0.5)
                  DE['hottness'] = 0.5;
                else if(hot < 0.55)
                  DE['hottness'] = 0.55;
                else if(hot < 0.6)
                  DE['hottness'] = 0.6;
                else if(hot < 0.65)
                  DE['hottness'] = 0.65;
                else if(hot < 0.7)
                  DE['hottness'] = 0.7;
                else if(hot < 0.75)
                  DE['hottness'] = 0.75;
                else if(hot < 0.8)
                  DE['hottness'] = 0.8;
                else if(hot < 0.85)
                  DE['hottness'] = 0.85;
                else if(hot < 0.9)
                  DE['hottness'] = 0.9;
                else if(hot < 0.95)
                  DE['hottness'] = 0.95;
                else
                  DE['hottness'] = 1;
                */
                geo.insert(DE, {safe:true},function(err){
                  if(err){
                    console.log('insert error');
                    console.log(err.message);
                  }
                  else{
                    count2++;
                    if(count2%1000 == 0)
                      console.log(count2);
                  }
                });
              }
              
