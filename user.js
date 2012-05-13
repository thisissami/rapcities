var mongodb = require('mongodb'),
  ObjectID = mongodb.ObjectID,
  mongoserver = new mongodb.Server('10.112.0.110', 26374),
  //mongoserver = new mongodb.Server('localhost', 26374),
  dbConnector = new mongodb.Db('uenergy', mongoserver),
  artists, usersCollection;

dbConnector.open(function(err, db){
  if(err) {
    console.log('connector.open error (login.js)');
    console.log(err.message);
  } else {
    console.log('DB opened successfully (login.js)');
    db.createCollection('artistLocations2', function(err, collection) {
      if(err) {
        console.log('error creating songs collection (login.js)');
        console.log(err.message);
      } else {
        artists = collection;
      }
    });
    db.createCollection('users', function(err, collection) {
      if(err) {
        console.log('error creating users collection (login.js)');
        console.log(err.message);
      } else {
        collection.ensureIndex({fbid:1}, function(err) {
          if(err) console.log(err);
        });
        usersCollection = collection;
      }
    });
  }
});

function getQueries(req) {
 parser = require('url');
 var url = parser.parse(req.url, true);
 return url.query;
}

function writeHeader(res, type) {
  if(type == "html")
    res.writeHead(200, {'Content-Type': 'text/html'});
  else if(type == "json")
    res.writeHead(200, {'Content-Type': 'application/json'});
}

function writeError(res, value) {
  writeHeader(res, "json");
  if(value != null)
    res.end('{"response": "error", "value": ' + value + '}');
  else
    res.end('{"response": "error"}');
}

function writeSuccess(res, value) {
  writeHeader(res, "json");
  if(value != null)
    res.end('{"response": "success", "value": ' + value + '}');
  else
    res.end('{"response": "success"}');
}

function writeCursor(res, cursor) {
  writeHeader(res, "json");
  cursor.toArray(function(err, docs) {
    if(err) {
      console.log(err);
      writeError(res, "Error changing cursor to array");
      return;
    }
    res.end(JSON.stringify(docs));
  });
}

function addSong(req, res, next) {
  var query = getQueries(req);
  
  var userid = new ObjectID(query.userid);
  var songid = query.songid;
  if(!query.userid || !songid) {
    writeError(res, "no userid or songid");
  } else {
    usersCollection.findOne({'_id': userid}, function(err, document) {
      if(err) {
        console.log(err);
        writeError(res);
        return;
      }
      if(document) {
        var favs = document.favs;
        var dates = document.dates;
        if(favs.indexOf(songid) != -1) {
          writeError(res, "Already fav'd");
        } else {
          favs.push(songid);
          dates.push(new Date());
        }
        usersCollection.update({'_id': userid}, {'$set': {'favs': favs, 'dates': dates}}, function(err, count) {
          if(err) {
            console.log(err);
            writeError(res);
            return;
          }
          writeSuccess(res);
        });
      } else {
        writeError(res, "No such user");
        return;
      }
    });
    /*
    songsCollection.findOne({'_id': songid, 'likers': userid}, function(err, document) {
      if(err) {
        console.log(err);
        writeError(res);
        return;
      }
      if(document) {
        songsCollection.update({'_id': songid}, {'$pull': {'likers': userid}},
          {'safe': true}, function(err, count) {
            if(count == 1) writeSuccess(res, "liker removed from song");
            else writeError(res, "count was " + count);
          });
      } else {
        songsCollection.update({'_id': songid}, {'$push': {'likers': userid}},
          {'safe': true}, function(err, count) {
            if(count == 1) writeSuccess(res, "liker added to song");
            else writeError(res, "count was " + count);
          });
      }
    });*/
  }
}

function removeSong(req, res, next) {
  var query = getQueries(req);
  
  var userid = new ObjectID(query.userid);
  var songid = query.songid;
  if(!query.userid || !songid) {
    writeError(res, "no userid or songid");
  } else {
    usersCollection.findOne({'_id': userid}, function(err, document) {
      if(err) {
        console.log(err);
        writeError(res);
        return;
      }
      if(document) {
        var favs = document.favs;
        var dates = document.dates;
        var favIndex = favs.indexOf(songid);
        if(favIndex == -1) {
          writeError(res, "No such fav!");
        } else {
          favs.splice(favIndex, 1);
          dates.splice(favIndex, 1);
          usersCollection.update({'_id': userid}, {'$set': {'favs': favs, 'dates': dates}}, function(err, count) {
            if(err) {
              console.log(err);
              writeError(res);
              return;
            }
            writeSuccess(res);
          });
        }
      } else {
        writeError(res, "No such user");
        return;
      }
    });
  }
}

function isFav(req, res, next) {
  var query = getQueries(req);
  
  var userid = new ObjectID(query.userid);
  var songid = query.songid;
  if(!query.userid || !songid) {
    writeError(res, "no userid or songid");
  } else {
    usersCollection.findOne({'_id': userid}, function(err, document) {
      if(err) {
        console.log(err);
        writeError(res);
        return;
      }
      if(document) {
        if(document.favs.indexOf(songid) != -1) {
          writeSuccess(res, 'true');
        } else {
          writeSuccess(res, 'false');
        }
      } else {
        writeError(res, 'No such user');
      }
    });
  }
}

function seeSongs(req, res, next) {
  var query = getQueries(req);
  
  var userid = new ObjectID(query.userid);
  var page = query.page;
  if(!page) page = 1;
  var sortBy = query.sortBy;
  if(!sortBy) sortBy = 'title';
  var order = query.order;
  if(!order) order = 'asc';
  
  if(!query.userid) {
    writeError(res, "no userid");
  } else {
    usersCollection.findOne({'_id': userid}, function(err, document) {
      if(err) {
        console.log(err);
        writeError(res);
        return;
      }
      if(document) {
        var documents = [], index = 0, favs = document.favs, dates = document.dates;
        // Tail-recursive loop to get past asynchronous querying:
        var loopThrough = function() {
          if(index < favs.length) {
            fullid = favs[index].split(' ');
            artists.findOne({'RID': fullid[0]}, function(err, document) {
              if(document) {
                var i, pos; 
                for(i = 0; i < document.topTracks.length; i++){
                  if(document.topTracks[i].RID == fullid[1]){
                    pos = true;
                    break;
                  }
                }
                if(pos)
                  documents.push({'artist':document.name,'song':document.topTracks[i].title,'date':dates[index],'fullid':favs[index]});
                ++index;
                loopThrough();
              }
            });
          } else {
            console.log("breaking out...found " + index);
            // Breakout point of recursive loop
            writeHeader(res, "html");
            // do sorting options
            var titleString = '\'song\'';
            var artistString = '\'artist\'';
            //var genreString = '\'song.genre\'';
            var dateString = '\'date\'';
            var titleArrow = '';
            var artistArrow = '';
            //var genreArrow = '';
            var dateArrow = '';
            if(sortBy == 'title') {
              if(order == 'asc') {
                titleString += ', \'desc\'';
                titleArrow = ' &#x25B2;';
              } else {
                titleString += ', \'asc\'';
                titleArrow = ' &#x25BC;';
              }
            } else if(sortBy == 'artist') {
              if(order == 'asc') {
                artistString += ', \'desc\'';
                artistArrow = ' &#x25B2;';
              } else {
                artistString += ', \'asc\'';
                artistArrow = ' &#x25BC;';
              }
            } /*else if(sortBy == 'song.genre') {
              if(order == 'asc') {
                genreString += ', \'desc\'';
                genreArrow = ' &#x25B2;';
              } else {
                genreString += ', \'asc\'';
                genreArrow = ' &#x25BC;';
              }
            }*/ else if(sortBy == 'date') {
              if(order == 'asc') {
                dateString += ', \'desc\'';
                dateArrow = ' &#x25B2;';
              } else {
                dateString += ', \'asc\'';
                dateArrow = ' &#x25BC;';
              }
            }
            res.write('<table id="userFavs"><thead><tr><td></td>' +
              '<td><a href="javascript:void(0)" onclick="showAndFillOverlay(' + titleString + ')">Title' + titleArrow + '</a></td>' +
              '<td><a href="javascript:void(0)" onclick="showAndFillOverlay(' + artistString + ')">Artist' + artistArrow + '</a></td>' +
              //'<td><a href="javascript:void(0)" onclick="showAndFillOverlay(' + genreString + ')">Genre' + genreArrow + '</a></td>' +
              '<td><a href="javascript:void(0)" onclick="showAndFillOverlay(' + dateString + ')">Date' + dateArrow + '</a></td>' +
              '</tr></thead><tbody>');
            
            documents.sort(function(a, b) {
              var out;
              switch(sortBy) {
              case 'title':
              default:
                out = ((a.title == b.title) ? 0 : ((a.title > b.title) ? 1 : -1));
                break;
              case 'artist':
                out = ((a.artist == b.artist) ? 0 : ((a.title > b.artist) ? 1 : -1));
                break;
              /*case 'song.genre':
                out = ((a.song.genre == b.song.genre) ? 0 : ((a.song.title > b.song.genre) ? 1 : -1));
                break;*/
              case 'date':
                out = ((a.date == b.date) ? 0 : ((a.date > b.date) ? 1 : -1));
                break;
              }
              if(order == 'asc') return out;
              return out * -1;
            });
            var d,j;
            for(j=0; j<documents.length; j++) {
              var d = documents[j];
              res.write('<tr><td><a href="javascript:void(0)" onclick="toggleFav(this, \'' + d.fullid + '\')"><img src="http://rapcities.com/heart.svg" width="20" height="20" border="0" /></a></td>');
              res.write('<td>' + d.song + '</td>');
              res.write('<td>' + d.artist + '</td>');
              //res.write('<td>' + d.song.genre + '</td>');
              res.write('<td>' + (d.date.getMonth()+1) + '/' + d.date.getDate() + '/' + d.date.getFullYear() + '</td>');
              res.write('</tr>');
            }
            res.end('</tbody></table>');
          }
        };
        loopThrough();
      } else {
        writeError(res, "No such user");
      }
    });
  }
}

function countSongs(req, res, next) {
  var query = getQueries(req);
  var userid = new ObjectID(query.userid);
  if(!query.userid) {
    writeError(res, "no userid");
  } else {
    usersCollection.findOne({'_id': userid}, function(err, document) {
      if(err) {
        console.log(err);
        writeError(res);
        return;
      }
      if(document) {
        writeSuccess(res, document.favs.length);
      } else {
        writeError(res, "No such user!");
      }
    });
  }
}

function fbCreate(req, res, next) {
  var query = getQueries(req);
  var fbid = query.fbid;
  if(fbid) {
    usersCollection.findOne({'fbid':fbid}, {'safe': true}, function(err, document) {
      if(err) {
        console.log(err);
      } else {
        var userid = null;
        if(document != null)
          var userid = document._id;
      }
      if(userid != null) {
      console.log("fbid exists, logged in as userid: " + userid);
      writeSuccess(res, '"' + userid + '"');
    } else {
      console.log("new fbid; creating new entry...");
      usersCollection.insert({'fbid':fbid, 'favs':[], 'dates':[]}, {'safe': true}, function(err, records) {
        if(err) { console.log(err); return; }
        userid = records[0]._id;
        console.log("new user created as userid: " + userid);
        writeSuccess(res, '"' + userid + '"');
      });
    }
    });
  } else {
    console.log("Login failed: no fbid.");
    writeError(res, "no fbid given");
  }
}

exports.addSong = addSong;
exports.removeSong = removeSong;
exports.seeSongs = seeSongs;
exports.countSongs = countSongs;
exports.isFav = isFav;
exports.fbCreate = fbCreate;
