var cluster = require('cluster'),
    numCPUs = require('os').cpus().length;

    
if(cluster.isMaster){
  console.log(numCPUs + ' cores on this machine.');
  for(var i = 0; i < numCPUs; i++)
    cluster.fork();
    
  cluster.on('death', function(worker){
    console.log('worker ' + worker.pid + ' died.');
    cluster.fork();
  });
  process.on("SIGTERM", process.exit);
  process.on("SIGINT", process.exit);
  process.on("SIGKILL", process.exit);
  /*process.on("SIGTERM", websiteDown);
  process.on('exit',websiteDown);
  process.on('SIGINT', websiteDown);*/
}
else{
  connect = require('connect'),
  url = require('url'),
  path = require('path'),
  fs = require('fs');
  uploader = require('./uploadArtist'),
  digital7 = require('./7Dconnect'),
  artistInfo = require('./artistInfo');
  users = require('./user');
  http = require('http');
        
  function onRequest(req, res, next) {
    var parsed = url.parse(req.url,true);
    var pathname = parsed.pathname;
    var ext = path.extname(pathname);
    
    switch(pathname){
      case '/addArtist': console.log('OH SHIT SOME SUCCESS!'); uploader.uploadLoc(res, parsed.query); break;
	  case '/getArtists': console.log('GETTING ZE ARTISTS!!!!'); uploader.getLocs(res, parsed.query); break;
	  case '/addEvent': console.log('OH SHIT ADDING AN EVENT!!!!'); uploader.uploadEvent(res, parsed.query); break;
      case '/getEvents': console.log('OH SHIT GETTING AN EVENT!!!!'); uploader.getEvents(res, parsed.query); break;
	  case '/getArtistInfo': console.log('getting artist info'); artistInfo.get(res, parsed.query); break;
	  case '/getBio': artistInfo.getBio(res, parsed.query); break;
	  case '/getTrack': console.log('getting track'); digital7.getTrack(res, parsed.query); break;
      case '/seeSongs': users.seeSongs(req, res, next); break;
      case '/addSong': users.addSong(req, res, next); break;
      case '/removeSong': users.removeSong(req, res, next); break;
      case '/countSongs': users.countSongs(req, res, next); break;
      case '/isFav': users.isFav(req, res, next); break;
      case '/fbCreate': users.fbCreate(req, res, next); break;
      default: return;
    }
  }

	function checkWWW(req, res, next){
		if(req.headers.host.match(/^www/)){
			console.log('www');
			res.writeHead(301, {'location':'http://'+req.headers.host.replace(/^www\./,'')+req.url});
			res.end();
		} else	next();
	}
    
  connect.createServer(
	checkWWW,
    require('./fileServer')(),
    //remove this once connect reaches v2.0.0 - connect.compress({memLevel:9}),
    connect.logger(),
    onRequest).listen(80);
	//onRequest).listen(8888);
  console.log('Server has started.');
}

