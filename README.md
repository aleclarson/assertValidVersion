
# assertValidVersion 1.0.0 ![experimental](https://img.shields.io/badge/stability-experimental-EC5315.svg?style=flat)

Validate an entry in the `"dependencies"` object inside any `package.json`!

```coffee
assertValidVersion = require "assertValidVersion"

promise = assertValidVersion moduleName, versionString
```

---

### "Does an NPM package have a specific version?"

```coffee
assertValidVersion "underscore", "1.8.3"

.then ->
  # The version is valid!
  # Since `npm view underscore` includes
  # '1.0.1' in the list of NPM versions.

.fail (error) ->
  # An error is thrown if:
  #   • the NPM package does not exist
  #   • the given version does not exist
  #   • the given version is not properly formatted
```

- Supports version ranges! (eg: `>=1.0.0`)

---

### "Does a Github repository have a specific tag?"

```coffee
assertValidVersion "Type", "aleclarson/Type#1.0.0"

.then ->
  # The version is valid!
  # Since 'github.com/aleclarson/Type/tags' includes
  # '1.0.0' in the list of remote tags.

.fail (error) ->
  # An error is thrown if:
  #   • the Github repository does not exist
  #   • the given tag is not included in the list of remote tags
  #   • the given version is not properly formatted
```
