var static = require('node-static');
var http = require('http')

var file = new static.Server();
var port = 3031;

http.createServer(function (request, response) {
  request.addListener('end', function () {
    file.serve(request, response);
  }).resume();
}).listen(port);

console.log(require('cowsay').say({
    text : 'Your server is up and running on port ' + port + ', boss!',
    e : 'oO',
    T : 'U '
}));
