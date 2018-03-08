var gmailApiSync = require('gmail-api-sync');
var fs = require('fs')

//Load Google Api Project client secret.
gmailApiSync.setClientSecretsFile('./data/client_secret.json');
gmailApiSync.getNewServerAuthCode(['https://www.googleapis.com/auth/gmail.readonly'] ,function(message){
    console.log(message);
});
