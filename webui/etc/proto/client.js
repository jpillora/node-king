var domready = require('domready');
var shoe = require('shoe');
var dnode = require('../../');

function init() {
  var result = document.getElementById('result');
  var stream = shoe('/dnode');
  
  window.d = dnode({

    show: function(s, cb) {
      result.textContent = s;
      cb();
    }

  });

  d.on('remote', ready);
  d.pipe(stream).pipe(d);
}

function ready(remote){
  window.remote = remote;
  remote.transform('beep', function (s) {
    result.textContent = 'beep => ' + s;
  });

  remote.caps('hello world', function(s) {
    result.textContent += ' ' + s;
  });

}

window.I = function() { console.log(arguments); };

domready(init);