module.exports  = function readJsonFromStdin() {
  return new Promise((resolve, reject) => {
    var stdin = process.stdin
    var data = ''

    stdin.resume();
    stdin.setEncoding('utf8');

    stdin.on('data', function (chunk) {
      data += chunk
    });

    stdin.on('error', function (error) {
      reject(error)
    })

    stdin.on('end', function () {
      resolve(JSON.parse(data))
    })
  })
}
