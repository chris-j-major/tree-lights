const https = require('https'); // or 'https' for https:// URLs
const fs = require('fs');

var lineReader = require('readline').createInterface({
    input: require('fs').createReadStream('temp_urls')
});

lineReader.on('line', function (line) {
    const found = line.match(/gt_([0-9][0-9][0-9][0-9])_/);
    console.log(found);
    const file = fs.createWriteStream(found[1]+".jpg");
    const request = https.get(line, function(response) {
      response.pipe(file);
    });
});


