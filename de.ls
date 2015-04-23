require! <[fs bluebird request cheerio]>

get-area = (area-code) -> new bluebird (res, rej) ->
  (e,r,b) <- request {
    url: "http://www.dataexpress.com.tw/location.php?KindID=#{area-code}"
    method: \GET
  }, _
  if e or !b => return rej!
  $ = cheerio.load b
  list = $(".loc_main_tit a")
  ret = []
  for idx from 0 til list.length
    name = $(list[idx]).attr("title")
    address = $(list[idx]).text!
    if !address or !name => continue
    ret.push {name, address}
  return res ret

(ret) <- bluebird.all([1 to 12]map(-> get-area it)).then
ret = ret.reduce(((a,b) -> a ++ b), [])
fs.write-file-sync \de.json, JSON.stringify(ret)
