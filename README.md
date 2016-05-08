
# isValidVersion 1.0.0 ![experimental](https://img.shields.io/badge/stability-experimental-EC5315.svg?style=flat)

Check if a `key: value` pair matches the requirements of the
`dependencies` object in a `package.json` file!

```coffee
isValidVersion = require "isValidVersion"

isValidVersion moduleName, versionString
```

**TODO:** Write tests!

---

### "Does an NPM package have a specific version?"

```coffee
isValidVersion "has", "1.0.1"

.then (isValid) ->
  # `npm view has` is used to retrieve all
  # published versions. If a version named
  # '1.0.1' exists, then `isValid` equals true.

.done() # An error is thrown if the NPM package does not exist.
```

- Supports version ranges! (eg: `>=1.0.0`)

---

### "Does a Github repository have a specific tag?"

```coffee
isValidVersion "isValidVersion", "aleclarson/isValidVersion#1.0.0"

.then (isValid) ->
  # Since 'github.com/aleclarson/isValidVersion/tags'
  # displays '1.0.0' in its list of tags, `isValid` equals true.

.done() # An error is thrown if the Github repository does not exist.
```
