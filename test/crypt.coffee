assert = require 'assert'
crypto = require 'crypto'
random = require '../src/rand.coffee'

Crypt = require '../src/crypt.coffee'

crypt = null
key = random.secret()
keyhash = crypto.createHash 'sha256'
keyhash.update key
keysha = keyhash.digest()
iv = random.secret()
ivhash = crypto.createHash 'sha256'
ivhash.update iv
ivsha = ivhash.digest().slice(0, 16)

describe 'crypt', ->
  beforeEach ->
    crypt = new Crypt key, iv
  it 'should encrypt a string given a secret and iv', ->
    cipherText = crypt.enc 'hai there'
    decipher = crypto.createDecipheriv 'aes-256-cbc', keysha, ivsha
    decipher.update cipherText, 'hex'
    assert.equal decipher.final(), 'hai there'
  it 'should decrypt some hex given a secret and iv', ->
    cipher = crypto.createCipheriv 'aes-256-cbc', keysha, ivsha
    cipher.update 'oh hello'
    cipherText = cipher.final 'hex'
    out = crypt.dec cipherText
    assert.equal out, 'oh hello'
