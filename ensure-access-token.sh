#!/bin/bash

if [ ! -f ./data/client_secret.json ] ; then
  echo 'Missing data/client_secret.json'
  echo
  echo 'To generate one, please follow Step 1 ( only ) of the Google API guide'
  echo
  echo 'Step 1: Turn on the Gmail API'
  echo 'https://developers.google.com/gmail/api/quickstart/nodejs#prerequisites'
  echo
  echo 'After you download the client_secret.json file'
  echo 'place it into ./data/ and we can proceed.'

  out=./data/waiting_for_client_secret_json.txt
  echo 'Go get your client_secret.json and put it in this folder' > $out
  echo 'To generate one, please follow Step 1 ( only ) of the Google API guide' >> $out
  echo >> $out
  echo 'Step 1: Turn on the Gmail API' >> $out
  echo 'https://developers.google.com/gmail/api/quickstart/nodejs#prerequisites' >> $out
  echo I made a note $out
  echo "Once that's done, run the same command again"
  exit 1
fi

if [ ! -f ./data/access_token.json ] ; then
  if [ "$SERVER_AUTH" = "" ] ; then
    echo 'Missing data/access_token.json'
    echo
    node ./generate_server_auth.js
    echo
    echo 'It will grant this app, read access to your email account'
    echo 'Please then provide the generated SERVER_AUTH string as an environment variable'

    echo "I'll wait for you to get the SERVER_AUTH string."
    echo
    echo "| Alternatively, you can provide it as an environment variable..."
    echo '| -- docker run --rm -v /some/data:/data -e "SERVER_AUTH=<server-auth>" ponelat/inbox-tester'
    echo '| -- where "/some/data" is your local folder, which will contain client_secret.json'
    echo '| -- where "<server-auth>" is the string provided by Google'

    echo -n "Enter Server Auth: "
    read SERVER_AUTH < /dev/stdin
  else
    echo Using env variable SERVER_AUTH to generate access_token into data/
  fi

  echo $SERVER_AUTH

  node ./generate_access_token.js $SERVER_AUTH | sed 's/.*{/{/' > data/access_token.json
fi

chmod a+rw -R ./data/
