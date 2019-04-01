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

function sendAsync(socket, message) {
  return function() {
    console.log(message);
    socket.send(message);
  }
}

function sendSync(socket, message) {
  const reply = new Promise(function(resolve, reject) {
    const rejectTimer = setTimeout(function() {
      reject(new Error('request timed out.'));
    }, this.timeout);

    const clearTimer = function() {
      clearTimeout(rejectTimer);
    } 

    this.socket.once('message', function(message) {
      clearTimer();
      resolve(message);
    });

    this.socket.send(message);
  }).then(function(res) {
    return res;
  });
}

exports.createZeroMqServer = createZeroMqServer;
exports.sendAsync = sendAsync;
exports.sendSync = sendSync;