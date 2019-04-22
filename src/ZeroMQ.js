"use strict"

const zmq = require('zeromq');

/*
 * Effect Callbacks
 */

const timeout = 1000;

const createZeroMqServer = function (asyncPort, syncPort) {
  console.log('Starting server.\nAsync port: ' + asyncPort + ',\nSync port: ' + syncPort + '.');

  const asyncSocket = zmq.socket('push');
  const syncSocket = zmq.socket('req');

  asyncSocket.connect('tcp://localhost:' + asyncPort)
  syncSocket.connect('tcp://localhost:' + syncPort);

  process.on('SIGINT', function () {
    asyncSocket.close();
    syncSocket.close();
  });

  console.log("Server started!");

  return { asyncSocket: asyncSocket, syncSocket: syncSocket };
}

/*
 * Pure Functions
 */

function sendAsync(socket, request) {
  return function () {
    return new Promise(function (resolve, reject) {
      const rejectTimer = setTimeout(function () {
        reject(new Error('request timed out.'));
      }, timeout);

      const clearTimer = function () {
        clearTimeout(rejectTimer);
      }

      socket.send(request);

      // intentionally do not wait for response
      // response is thrown away and ignored
      clearTimer();
      resolve();
    });
  }
}

function sendSync(socket, request) {
  return function () {
    return new Promise(function (resolve, reject) {
      const rejectTimer = setTimeout(function () {
        reject(new Error('request timed out.'));
      }, timeout);

      const clearTimer = function () {
        clearTimeout(rejectTimer);
      }

      socket.once('message', function (message) {
        clearTimer();
        const deserialised = message.toString();
        resolve(deserialised);
      });

      socket.send(request);
    }).then(function (res) {
      return res;
    });
  }
}

exports.createZeroMqServer = createZeroMqServer;
exports.sendAsync = sendAsync;
exports.sendSync = sendSync;