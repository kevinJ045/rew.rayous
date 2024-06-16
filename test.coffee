{ createRouter } = imp './main.coffee'
Svr = imp 'serve'



server = Svr::create fetch: createRouter realpath './test-app'

server
  .port 3456
  .listen
  .log 'Listening $port'