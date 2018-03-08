#!/bin/bash

DOWNLOAD=true
TEST=true
EMAIL_FILTER="in:inbox"
TEST_FILTER=
HELP=

chmod a+rw ./data

help() {
  echo 'Usage: docker run -it --rm [Env] -v path/to/data:/data ponelat/inbox-tester [Options]'
  echo
  echo Quick Start
  echo 1. Create ./data folder and run this...
  echo "docker run -it --rm -v \"\$PWD\"/data:/data ponelat/inbox-tester"
  echo 2. Follow steps to get your client_secret.json and access_token.json
  echo 2.1 Both will be stored in ./data
  echo 'You should see a table of results ( likely empty )'
  echo 'Modify the generated to ./data/tests.yaml and enjoy!'
  echo
  echo
  echo Options:
  echo
  echo "-s|--skip-download"
  echo "skip downloading email, and instead use data/inbox.json"
  echo
  echo "-d|--skip-tests"
  echo "_JUST_ download the emails into data/inbox.json"
  echo
  echo "-f|--email-filter <filter>"
  echo "filter to use when fetching emails"
  echo 'see: https://support.google.com/mail/answer/7190?hl=en'
  echo
  echo "-t|--test-filter <filter>"
  echo "filter to use on which tests to run"
  echo "We simply look for the substring of the test.name"
  echo "eg: 'rep' will match comment-reply"
  echo
  echo Env:
  echo
  echo '-v "SERVER_AUTH=<server-auth>"'
  echo "Used to generate a access_token, we'll prompt you for this only once"
  echo
  echo '-v "DEBUG_NODE=inbox-tester"'
  echo "To dump some debug lines, helpful in debugging"
  echo
  echo "Files:"
  echo "in the ./data volume"
  echo
  echo ./data/client_secret.json
  echo "The client secret configured in Gmail API"
  echo "See: Step 1 of..."
  echo 'https://developers.google.com/gmail/api/quickstart/nodejs#prerequisites'
  echo
  echo ./data/access_token.json
  echo The access token _generated from_ from given SERVER_AUTH string
  echo
  echo ./data/tests.yaml
  echo The test definitions for your emails
  echo Feel free to modify as you like
  echo "We'll initially generate a silly one for you"
  echo
  echo ./data/inbox.json
  echo Generated by downloading emails
  echo Feel free to modify as you like, if you need to.
  echo Useful to look at, and inspect.

  exit 1
}

# Copied from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# Best way to parse cli args in bash I've found...
POSITIONAL=()
while [[ $# -gt 0 ]] ;  do
key="$1"
case $key in
    -s|--skip-download)
    DOWNLOAD=
    shift # past argument
    ;;
    -h|--help)
    HELP=true
    shift # past argument
    ;;
    -d|--skip-tests)
    TEST=
    shift # past argument
    ;;
    -f|--email-filter)
    EMAIL_FILTER="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--test-filter)
    TEST_FILTER="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
# Done copy
####

[ $HELP ] && help

./ensure-access-token.sh
[ "$?" != "0" ] && exit 1

# Ensure tests.yaml, or copy over skeleton
if [ ! -f ./data/tests.yaml ] ; then
  echo 'No tests.yaml found in data/'
  echo 'Copying in skeleton, please edit to suit!'
  echo
  cp ./tests.yaml.ori ./data/tests.yaml
  chmod a+rw ./data/tests.yaml
fi


if [ $DOWNLOAD ] ; then
  echo Downloading emails into /data/inbox.json
  echo -n with the email filter \"$EMAIL_FILTER\"...
  node ./inbox-emails.js "$EMAIL_FILTER" > ./data/inbox.json
  chmod a+rw ./data/inbox.json
  echo done
else
  echo Skipping download
  echo Using ./data/inbox.json
fi

if [ $TEST ] ; then
  echo Testing emails against ./tests.js
  echo Filtering tests by \"$TEST_FILTER\"
  cat ./data/inbox.json  | node ./test-inbox.js "$TEST_FILTER"
else
  echo Skipped tests
fi


echo Done