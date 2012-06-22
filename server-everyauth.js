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
  everyauth = require('everyauth');
  redistore = require('connect-redis')(connect);

everyauth.debug = true;
everyauth.facebook
	.myHostname('http://localhost:8888')
	.appId('300271166724919')
	.appSecret('b4ba0065d5002941b871610d00afd80b')
	.scope('email,user_location,user_birthday')
	.handleAuthCallbackError( function(req,res){console.log(res)})
	.redirectPath('/')
	.findOrCreateUser(function(session, accessToken, accessTokExtra, fbUserData){
		console.log('oh fbhello!');
		console.log(accessToken + '    ' + JSON.stringify(accessTokExtra) + '\n\n');
		console.log(fbUserData);
		var promise = this.Promise();
		var toUpload = {
			'name':fbUserData.name,
			'birthday':fbUserData.birthday,
			'location':fbUserData.location,
			'email':fbUserData.email,
			'gender':fbUserData.gender,
			'fbid':fbUserData.id
		}
		users.fbCreate(toUpload, accessToken, promise);
		return promise;		
	})
	.moduleErrback(function(err){console.log(err)});
        
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
      case '/seeSongs':break; // users.seeSongs(req, res, next); break;
      case '/addSong': break; //users.addSong(req, res, next); break;
      case '/removeSong': break; //users.removeSong(req, res, next); break;
      case '/countSongs': break; //users.countSongs(req, res, next); break;
      case '/isFav': break; //users.isFav(req, res, next); break;
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
	
	function checkLoggedIn(req, res, next){
		console.log("req.loggedIn: " + req.user);
		if(req.user)
			next();
		else{
			console.log('\nNot LOGGED IN\n');
			if(req.socket.remoteAddress || req.socket.socket.remoteAddress == '127.0.0.1'){
		      	var folder,contentType;
				console.log('req url = '+req.url);
	  		   	if(req.url == '/'){
		        	folder = __dirname + '/files/landing.html';
		        	contentType = 'text/html; charset=utf-8';
			    }
				else if(req.url == '/landing.gif'){
					folder = __dirname+'/files/landing.gif';
					contentType = 'image/gif';
				}
				else if(req.url == '/facebookLanding.png'){
					folder = __dirname+'/files/facebookLanding.png';
					contentType = 'image/png';
				}
				/*else if(req.url == '/auth/facebook'){
					next();
					return;
				}*/
				if(folder){
					console.log('got to folder part\n\n');
			        fs.readFile(folder, function(error, content){
			          if(error){
			            res.writeHead(500);
			            res.end();
			          }
			          else{
			            res.writeHead(200, {'Content-Type': contentType});
			            res.end(content);
			          }
			        });
			      }
					else{ res.writeHead(500); res.end();}
			}
			else {res.writeHead(500); res.end();}
		}
	}
    
  connect.createServer(
	checkWWW,
	connect.cookieParser(),
	connect.bodyParser(),
	connect.session({store: new redistore, secret:'wakajakamadaka'}),
	everyauth.middleware(), 
	checkLoggedIn,
    require('./fileServer')(),
    connect.compress({memLevel:9}),
    connect.logger(),
    //onRequest).listen(80);
	onRequest).listen(8888);
  console.log('Server has started.');
}

