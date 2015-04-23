require! <[fs request cheerio bluebird]>

init = (url) -> new bluebird (res, rej) ->
  (e,r,b) <- request {
    url: url
    method: \GET
  }, _
  if e or !b => return rej!
  $ = cheerio.load b
  params = {}
  for item in $("input") =>
    params[$(item).attr("name")] = $(item).attr("value")
  res params

_fetch-inner = (crawler) -> new bluebird (res, rej) ->
  request-options = crawler.iterate!
  if !request-options => return res true
  (e,r,b) <- request request-options, _
  if e or !b => return rej e
  crawler.parse b, request-options
  return res false

_fetch = (crawler, res, rej) ->
  _fetch-inner crawler .then (fin = false) ->
    if fin => return res!
    else _fetch crawler, res, rej
  .catch (e) -> return rej e

fetch = (crawler) -> new bluebird (res, rej) ->
  _fetch crawler, res, rej

save = -> fs.write-file-sync "#{(@name or 'untitled')}.json", JSON.stringify(@{state,data})
resume = -> 
  name = "#{(@name or 'untitled')}.json"
  if fs.exists-sync name => @ <<< JSON.parse(fs.read-file-sync name .toString!)
  @resume = null

crawler-sample = do
  config: {} # configuration used by crawler itself
  iterate: -> # get next url to crawl. return request option or null for eof
  parse: -> # parse returned content and store in data

module.exports = {
  init
  fetch
  resume
  save
}
