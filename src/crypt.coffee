forge = require 'node-forge'

# When running in browser it's under a property
forge = forge.forge if forge.forge

Crypt = (key, iv) ->
  @enc = (input) =>
    keysha = forge.md.sha256.create().update(key).digest()
    ivsha = forge.md.sha256.create().update(iv).digest() #only the first 16 bytes of this gets read
    cipher = forge.cipher.createCipher 'AES-CBC', keysha
    cipher.start {iv: ivsha}
    cipher.update forge.util.createBuffer input
    cipher.finish()
    return cipher.output.toHex()
  @dec = (input) ->
    keysha = forge.md.sha256.create().update(key).digest()
    ivsha = forge.md.sha256.create().update(iv).digest() #only the first 16 bytes of this gets read
    input = forge.util.hexToBytes input
    decipher = forge.cipher.createDecipher 'AES-CBC', keysha
    decipher.start {iv: ivsha}
    decipher.update forge.util.createBuffer input
    decipher.finish()
    return decipher.output.getBytes()
  return this

module.exports = Crypt
