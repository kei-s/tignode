_ = require 'underscore'

class TypableMap
  @roma: "a i u e o ka ki ku ke ko sa shi su se so
 ta chi tsu te to na ni nu ne no ha hi fu he ho
 ma mi mu me mo ya yu yo ra ri ru re ro
 wa wo n
 ga gi gu ge go za ji zu ze zo da de do
 ba bi bu be bo pa pi pu pe po
 kya kyu kyo sha shu sho cha chu cho
 nya nyu nyo hya hyu hyo mya myu myo
 rya ryu ryo
 gya gyu gyo ja ju jo bya byu byo
 pya pyu pyo".split(" ")

  @divmod: (a, b) ->
    [Math.floor(a / b), a % b]

  constructor: (length)->
    @seq = TypableMap.roma
    @map = {}
    @n = 0
    @length = length || @seq.length

  generate: (n) ->
    ret = []
    loop
      [n, r] = TypableMap.divmod(n, @seq.length)
      ret.push @seq[r]
      break unless n > 0
    ret.reverse().join("")

  push: (obj) ->
    id = this.generate(@n)
    @map[id] = obj
    @n += 1
    @n = @n % @length
    id

  get: (id) ->
    @map[id]

  clear: ->
    @n = 0
    @map = {}

module.exports = TypableMap
