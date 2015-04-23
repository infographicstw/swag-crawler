require! <[fs request bluebird]>

get-coord = (item) -> new bluebird (res, rej) ->
  (e,r,b) <- request {
    url: "http://maps.googleapis.com/maps/api/geocode/json?address=#{item.address}&sensor=false"
    method: \GET
  }, _
  if e or !b => return rej!
  data = JSON.parse(b)
  if data.[]results.length == 0 => 
    item.latlng = 0
    return res!
  item.latlng = data.results.0.geometry.location
  return res!

if fs.exists-sync \final.json =>
  list = JSON.parse(fs.read-file-sync \final.json .toString!)
else
  list = []
  add-file = (file, type) ->
    data = JSON.parse(fs.read-file-sync file .toString!)
    for item in data => list.push (item <<< {type})
  add-file \de.json, \apple
  add-file \studio-a.json, \apple
  add-file \starbucks.json, \starbucks
  add-file \eslite.json, \eslite
  list = list.map(-> {type:it.type, address:(it.address or it.Addr).replace /[（(]([^）)]+)[）)]/, "$1"})

list2 = list.filter -> !it.latlng

get-coord-iter = ->
  console.log "remain: #{list2.length}"
  if !list2.length => 
    return
  item = list2.splice 0,1 .0
  get-coord item .then ->
    if !item.latlng => list2 ++= [item]
    else 
      console.log item.latlng
      fs.write-file-sync \final.json, JSON.stringify(list)
    setTimeout (->
      get-coord-iter!
    ), 500 + Math.random! * 500

get-coord-iter!
#(ret) <- bluebird.all(list.filter(->!it.latlng).map(-> get-coord it)).then
#fs.write-file-sync \final.json, JSON.stringify(list)
