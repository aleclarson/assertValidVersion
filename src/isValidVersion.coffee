
{ isType, assert, assertType } = require "type-utils"
{ fetch } = require "fetch"

inArray = require "in-array"
semver = require "node-semver"
Finder = require "finder"
exec = require "exec"
Q = require "q"

findTagName = Finder
  regex: "<span class=\"tag-name\">([^\<]+)<\/span>"
  group: 1

module.exports = Q.fbind (depName, version) ->

  assertType depName, String
  assertType version, String

  # A github repo is wanted.
  if 0 <= version.indexOf "/"

    [ userName, repoName ] = version.split "/"

    assert userName.length, "Invalid version format!"
    assert repoName.length, "Invalid version format!"

    # A specific tag is wanted.
    if 0 <= repoName.indexOf "#"

      [ repoName, tagName ] = repoName.split "#"

      return fetch "https://github.com/#{userName}/#{repoName}/tags"

      .then (res) ->

        if res._bodyText is "{\"error\":\"Not Found\"}"
          throw Error "Github repository does not exist!"

        tagNames = findTagName.all res._bodyText

        return inArray tagNames, tagName

    return fetch "https://github.com/#{userName}/#{repoName}"

    .then (res) ->

      if res._bodyText is "{\"error\":\"Not Found\"}"
        throw Error "Github repository does not exist!"

      return yes

  # An npm repo is wanted.
  exec "npm view #{depName} --json"

  .then (stdout) ->

    { versions } = JSON.parse stdout

    if semver.validRange version
      version = semver.maxSatisfying versions, version
      return version isnt null

    if semver.valid version
      return inArray versions, version

    throw Error "Invalid version format!"
