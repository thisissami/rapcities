var api = require('7digital-api'),
	tracks = new api.Tracks();

function getTrack(response, query){
var id;
if(query.id) id = parseInt(query.id);
else{ console.log('get track innappropriate query'); return;}

tracks.getPreview({ trackId: id, redirect: false}, function processPreview(err, data) {
	if (err) {
		throw new Error(err);
	}

	if(data.url){
		response.writeHead(200, {'Content-Type': 'application/json'});
		response.end('{\"url\":\"'+data.url+'\"}');
	}
	else{console.log('no url');}
});
}

exports.getTrack = getTrack;