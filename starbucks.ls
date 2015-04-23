require! <[fs request bluebird cheerio ../base/index]>

(params) <- index.init \http://www.starbucks.com.tw/stores/storesearch/stores_storesearch.jspx .then
#selCity = 1 - 29
#selRegion = ALL

hash = {}
decodeURIComponent(fs.read-file-sync \curl .toString!).split(\&).map(-> 
  name = it.substring(0,it.indexOf("="))
  value = it.substring(it.indexOf("=")+1).substring(0,10)
  hash[name] = value
)

data = params <<< { selCity: \14, selRegion: \ALL }
data <<< {
  "selCity": \14
  "selRegion": \ALL
  "sbForm:btnByRegion": "sbForm:btnByRegion"
  "AJAXREQUEST": "sbForm:j_id_jsp_201517923_2"
  "sbForm:drive": 1
  "sbForm_SUBMIT": 1
}

get-area = (city-idx) -> new bluebird (res, rej) ->
  data.selCity = city-idx
  (e,r,b) <- request {
    url: \http://www.starbucks.com.tw/stores/storesearch/stores_storesearch.jspx
    method: \POST
    form: data
  }, _
  if e or !b => return rej!
  console.log "fetch: #{city-idx}"
  $ = cheerio.load b
  list = $(".div_bottomspace")
  ret = []
  for idx from 0 til list.length
    item = $(list[idx])
    name = item.find(\.searchstore_name).text!
    address = ""
    tds = item.find("table td table td table td")
    for jdx from 0 til tds.length
      td = $(tds[jdx])
      if td.find("> a").length > 0 =>
        address = td.text!
        break
    if !address or !name => continue
    ret.push {name, address}
  return res ret
(ret) <- bluebird.all([1 to 29].map -> get-area it).then
ret = ret.reduce(((a,b)->a++b),[])
fs.write-file-sync \starbucks.json, JSON.stringify(ret)
