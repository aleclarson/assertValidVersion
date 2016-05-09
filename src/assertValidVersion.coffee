
{ isType, assert, assertType } = require "type-utils"

inArray = require "in-array"
request = require "request"
semver = require "node-semver"
Finder = require "finder"
exec = require "exec"
log = require "log"
Q = require "q"

GITHUB_TAG = Finder
  regex: "<span class=\"tag-name\">([^\<]+)<\/span>"
  group: 1

GITHUB_404 = Finder
  regex: "<title>Page not found &middot; GitHub<\/title>"

NPM_404 = Finder
  regex: "npm ERR! code E404"

module.exports = (depName, version) -> Q.promise (resolve, reject) ->

  assertType depName, String
  assertType version, String

  # Is an NPM package wanted?
  if 0 > version.indexOf "/"
    return resolve assertNpmVersionExists depName, version

  # Nope, a Github repository is wanted.
  [ userName, repoName ] = version.split "/"

  assert userName.length, "Github username must exist!"
  assert repoName.length, "Github repository must exist!"

  url = "https://github.com/#{userName}/"

  # Is a specific tag wanted?
  if 0 <= repoName.indexOf "#"

    [ repoName, tagName ] = repoName.split "#"

    # Load the list of remote tags.
    url += repoName + "/tags"

    return request url, (error, _, body) ->
      error = assertRepoExists body
      return reject error if error
      tagNames = GITHUB_TAG.all body
      return resolve() if inArray tagNames, tagName
      return reject SimpleError "Version does not exist!"

  # The default branch is wanted.
  url += repoName

  # Try loading the Github repository's webpage.
  return request url, (error, _, body) ->
    error = assertRepoExists body
    return reject error if error
    return resolve()

assertNpmVersionExists = (depName, version) ->

  exec "npm view #{depName} --json"

  .fail (error) ->

    if NPM_404.test error.message
      throw SimpleError "Package does not exist in NPM registry!"

    throw error

  .then (stdout) ->

    { versions } = JSON.parse stdout

    if semver.validRange version
      version = semver.maxSatisfying versions, version
      return if version isnt null
      throw SimpleError "Version does not exist inside the given range!"

    if semver.valid version
      return if inArray versions, version
      throw SimpleError "Version does not exist!"

    throw SimpleError "Invalid version formatting!"

SimpleError = (message) ->
  error = Error message
  error.format = "simple"
  return error

assertRepoExists = (body) ->
  return unless GITHUB_404.test body
  return SimpleError "Github repository does not exist!"
