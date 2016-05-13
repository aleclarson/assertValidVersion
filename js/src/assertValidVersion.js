var Finder, GITHUB_404, GITHUB_TAG, NPM_404, Q, SimpleError, assert, assertNpmVersionExists, assertRepoExists, assertType, exec, inArray, isType, log, request, semver;

assertType = require("assertType");

inArray = require("in-array");

request = require("request");

semver = require("node-semver");

Finder = require("finder");

isType = require("isType");

assert = require("assert");

exec = require("exec");

log = require("log");

Q = require("q");

GITHUB_TAG = Finder({
  regex: "<span class=\"tag-name\">([^\<]+)<\/span>",
  group: 1
});

GITHUB_404 = Finder({
  regex: "<title>Page not found &middot; GitHub<\/title>"
});

NPM_404 = Finder({
  regex: "npm ERR! code E404"
});

module.exports = function(depName, version) {
  return Q.promise(function(resolve, reject) {
    var ref, ref1, repoName, tagName, url, userName;
    assertType(depName, String);
    assertType(version, String);
    if (0 > version.indexOf("/")) {
      return resolve(assertNpmVersionExists(depName, version));
    }
    ref = version.split("/"), userName = ref[0], repoName = ref[1];
    assert(userName.length, "Github username must exist!");
    assert(repoName.length, "Github repository must exist!");
    url = "https://github.com/" + userName + "/";
    if (0 <= repoName.indexOf("#")) {
      ref1 = repoName.split("#"), repoName = ref1[0], tagName = ref1[1];
      url += repoName + "/tags";
      return request(url, function(error, _, body) {
        var tagNames;
        error = assertRepoExists(body);
        if (error) {
          return reject(error);
        }
        tagNames = GITHUB_TAG.all(body);
        if (inArray(tagNames, tagName)) {
          return resolve();
        }
        return reject(SimpleError("Version does not exist!"));
      });
    }
    url += repoName;
    return request(url, function(error, _, body) {
      error = assertRepoExists(body);
      if (error) {
        return reject(error);
      }
      return resolve();
    });
  });
};

assertNpmVersionExists = function(depName, version) {
  return exec("npm view " + depName + " --json").fail(function(error) {
    if (NPM_404.test(error.message)) {
      throw SimpleError("Package does not exist in NPM registry!");
    }
    throw error;
  }).then(function(stdout) {
    var versions;
    versions = JSON.parse(stdout).versions;
    if (semver.validRange(version)) {
      version = semver.maxSatisfying(versions, version);
      if (version !== null) {
        return;
      }
      throw SimpleError("Version does not exist inside the given range!");
    }
    if (semver.valid(version)) {
      if (inArray(versions, version)) {
        return;
      }
      throw SimpleError("Version does not exist!");
    }
    throw SimpleError("Invalid version formatting!");
  });
};

SimpleError = function(message) {
  var error;
  error = Error(message);
  error.format = "simple";
  return error;
};

assertRepoExists = function(body) {
  if (!GITHUB_404.test(body)) {
    return;
  }
  return SimpleError("Github repository does not exist!");
};

//# sourceMappingURL=../../map/src/assertValidVersion.map
