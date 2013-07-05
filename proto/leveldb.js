var levelup = require('levelup');
var db = levelup('./tmp.db');

var split = require('split');
var fs = require('fs');
var words = fs.createReadStream('./frost.txt').pipe(split(/\s+/));

var write = false;

var batch = {}, bs =  [];

if(write)
words.on('data', function(word) {
  word = word.toString().toLowerCase().replace(/\W/g,'');
  if(!word) return;
  var b;
  if(batch[word]) {
    b = batch[word];
  } else {
    b = batch[word] = { type: 'put', key: word, value: 0 };
    bs.push(b);
  }
  b.value++;
});

if(write)
words.on('end', function() {

  console.log(bs.length);

  db.batch(bs, function (err) {
    if (err) return console.log('Ooops!', err);
    console.log('Great success dear leader!');
  });
});


if(!write)
db.createReadStream().on('data', function (data) {
  if(data.value > 20)
    console.log(data.key, '=', data.value);
});
