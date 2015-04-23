require! <[fs cheerio request bluebird]>

get-area = (area-code) -> new bluebird (res, rej) ->
  (e,r,b) <- request {
    url: "http://www.studioa.com.tw/product.php?menu_id=4&item_id=#{area-code}"
    method: \GET
  }, _
  console.log area-code
  if e or !b => return rej!
  $ = cheerio.load b
  list = $('.store-info span')
  hash = {}
  for idx from 0 til list.length
    item = $(list[idx])
    text = item.text!
    text = text.replace /\s+/g, ''
    text = text.replace /^[0-9 /-]+/, ''
    text = text.replace /營業時間/, ' '
    if !text => continue
    address = text.split(' ').0
    if !/[鄉鎮市區路]/.exec(address) => continue
    hash[address] = 1
  ret = [{address:k} for k of hash]
  return res ret

(ret) <- bluebird.all(<[6 7 20 21 45]>map(-> get-area it)).then
ret = ret.reduce(((a,b) -> a ++ b), [])
fs.write-file-sync \studio-a.json, JSON.stringify(ret)
