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
  uploader = require('./uploadArtist');
        
  function onRequest(req, res, next) {
    var parsed = url.parse(req.url,true);
    var pathname = parsed.pathname;
    var ext = path.extname(pathname);
    
    switch(pathname){
      case '/addArtist': console.log('OH SHIT SOME SUCCESS!\n\n\n'); uploader.uploadLoc(res, parsed.query); break;
	  case '/getArtists': console.log('GETTING ZE ARTISTS!!!!\n\n\n'); uploader.getLocs(res); break;
      default: return;
    }
  }
    
  connect.createServer(
    require('./fileServer')(),
    //remove this once connect reaches v2.0.0 - connect.compress({memLevel:9}),
    connect.logger(),
    onRequest).listen(80);
	//onRequest).listen(8888);
  console.log('Server has started.');
}

