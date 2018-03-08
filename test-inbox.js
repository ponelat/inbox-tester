const readJsonFromStdin = require('./read-json-stdin')
const Table = require('cli-table')
const jsYaml = require('js-yaml')
const fs = require('fs')
const chalk = require('chalk')
const map = require('lodash')
const debug = require('util').debuglog('inbox-tester')

const args = process.argv.slice(2)
const filterStr = (args[0] || '').toLowerCase()

readJsonFromStdin()
  .then( emails => {
    if(!emails || !emails.length) {
      console.log('No emails found! Please check your filters, and see --help')
      process.exit(1)
    }
    console.log(`Found: ${emails.length} emails!`)


    const suiteDefYaml = fs.readFileSync('./data/tests.yaml', 'utf8')
    const suiteDef = jsYaml.safeLoad(suiteDefYaml)

    const emailToUsername = new RegExp(suiteDef.emailToUsername)
    debug('Using regexp to exract username from email recipient: %s', emailToUsername)
    const emailsWithUser = applyUserToEmails(emails, emailToUsername)

    const tests = filterStr
          ? suiteDef.tests.filter(a => a.name.includes(filterStr))
          : suiteDef.tests

    const headers = suiteDef.users.slice()
    headers.unshift('Test') // add [0] as '', for first column
    const table = new Table({
      head: headers,
      style: {head: ['white'], border: ['white']},
      // colWidths: [100, 200]
    })

    tests
      .map( test => {

        // This should align with the order of headers
        const results = runTest(suiteDef.users, test, emailsWithUser)
        const rows = resultsToTableRow(results)

        // table is an Array, so you can `push`, `unshift`, `splice` and friends
        table.push({[`${test.asUser} / ${test.name}`]: rows})
      })
    console.log(table.toString());
  })
  .catch(err => console.error(err))

/////  functions
function resultsToTableRow(results) {
  return results.map( res => {
    let str = res.emailHit ? 'Y' : 'N'
    if(res.correct)
      return chalk.green(str)
    else
      return chalk.red(`(${str})`)
  })
}

function runTest(allUsers, testDef, emails) {
  var hits = emailHits({subject: testDef.subject}, emails)
  // Logic is: the hit and presence must be same ( either both or none )
  const mustHits = testDef.users
        .reduce((acc, user) => ({
          ...acc,
          [user]: true
        }), {})

  debug('%s mustHits: %j', testDef.name, mustHits)
  debug('%s hits: %j', testDef.name, hits)
  return allUsers.map(user => {
    return {
      user,
      correct: mustHits[user] == hits[user],
      emailHit: hits[user]
    }
  })
}

// TODO: Only handles subject search right now
function emailHits(search, emails) {
  const subjectReg = new RegExp(search.subject, 'i')
  debug('search.subject regexp: %s', search.subject)
  return emails
    .filter(email => {
      const match = subjectReg.test(email.subject)
      debug('email.subject: %s | matched: %s', email.subject, match)
      return match
    })
    .reduce((acc, email) => {
      acc[email.user] = true
      return acc
    }, {})
}

function applyUserToEmails(emails, regexp) {
  return emails.map(email => {
    const user = email.to.replace(regexp, (_, $1) => $1) // everything between first _ and @
    debug('Extracted the following username: %s', user)
    return {
      ...email,
      user
    }
  })
}
