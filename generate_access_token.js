var gmailApiSync = require('gmail-api-sync');
var args = process.argv.slice(2);
var serverAuthCode = args[0];

gmailApiSync.setClientSecretsFile('./data/client_secret.json');
gmailApiSync.getNewAccesToken(serverAuthCode,function(err,token){
  if(err) {
    console.error(err);
    process.exit(1)
  }
  else {
    console.log(JSON.stringify(token));
  }
});
