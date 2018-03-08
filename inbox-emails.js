var gmailApiSync = require('gmail-api-sync');

gmailApiSync.setClientSecretsFile('./data/client_secret.json');
var accessToken
try {
  accessToken = require('./data/access_token.json')
  if(!accessToken)
    throw new Error('No data in ./data/access_token.json file! Delete it and try again')
} catch(e) {
  console.log(e)
  process.exit(1)
}


var str = process.argv.slice(2).join(' ')
var options = { query: str, format: 'metadata' }

gmailApiSync.authorizeWithToken(accessToken, function (err, oauth) {
    if (err) {
        console.log('Something went wrong: ' + err);
        return;
    }
    else {
        gmailApiSync.queryMessages(oauth, options, function (err, response) {
            if (err) {
                console.log('Something went wrong: ' + err);
              process.exit(1)
            }
          console.log(JSON.stringify(response.emails))

          // var emails = response.emails || []
          // // var grouped = emails.reduce((acc, e) => {
          // //   var username = extractUsername(e.to)
          // //   acc[username] = acc[username] || []
          // //   acc[username].push(e)
          // //   return acc
          // // }, {})
          // console.log(JSON.stringify(grouped));
        });
    }
});
