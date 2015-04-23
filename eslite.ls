require! <[fs request cheerio bluebird]>

url = (area) -> "http://220.130.125.88/Eslitecorp_WS/WebService/Site/GetSiteList.ashx?sc=TW&sa=#{area}&a=tw&l=b"

get-area = (area) -> new bluebird (res, rej) ->
  (e,r,b) <- request {
    url: url area
    method: \GET
  }, _
  if e or !b => return rej!
  ret = JSON.parse(b)

  return res ret

(ret) <- bluebird.all(<[N M S]> .map -> get-area it).then
ret = ret.reduce(((a,b) -> a ++ b), [])
fs.write-file-sync \eslite.json, JSON.stringify(ret)
