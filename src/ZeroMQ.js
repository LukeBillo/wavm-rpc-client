"use strict"

const zmq = require('zeromq');

const onMessageReceived = function(message) {
  console.log('Remote: ' + message);
}

/*
 * Effect Callbacks
 */

const createZeroMqServer = function(port) {
    console.log('Starting server on port ' + port + '...');
    const socket = zmq.socket('req');

    socket.on('message', onMessageReceived);
    socket.connect('tcp://localhost:' + port);

    process.on('SIGINT', function() {
      socket.close();
    });

    console.log("Server started!");

    return socket;
}

/*
 * Pure Functions
 */

function sendRemote(socket, message) {
  socket.send(message);
}

exports.createZeroMqServer = createZeroMqServer;
exports.sendRemote = sendRemote;