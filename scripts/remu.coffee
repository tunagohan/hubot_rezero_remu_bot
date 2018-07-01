# Re:ゼロから始める異世界生活 - レム -
# レムが色々発言してくれるよ

remu_lines = [
  "ここから、始めましょう。1から……いいえ、ゼロから!",
  "どうやらすこし混乱されているみたいです",
  "鬼ががってますね",
  "レムはとっても弱いです。\nですからきっと寄りかかってしまいますよ",
  "諦めるのは簡単です。...でも、あなたには似合わない",
  "穀潰しの発言ですよ。聞きました姉様?",
  "未来のお話は笑いながらじゃなきゃ駄目なんですよ",
  "仕事が軌道に乗ったら、その...恥ずかしいですけど...子供とか...",
  "ごちそうさまですっ",
  "別に拗ねてませんよ!!",
  "これからもレムを隣に置いてくれますか?",
  "空っぽで、何もなくて、そんな自分が許せないなら、今、ここからはじめましょ",
  "謹んでお受けします",
  "お疲れ様です"
]

module.exports = (robot) ->
  robot.respond /(あなた|貴方|貴女)は(誰|だれ)(\?|？)/i, (msg) ->
   　msg.send "レムと申します"

  robot.hear /:remu_bot|@remu_bot/i, (msg) ->
    username = msg.message.user.name
    msg.send "@#{username} #{msg.random remu_lines}"

  robot.respond /(レムの画像|remuの画像)頂戴/i, (msg) ->
    imageRemu msg, "リゼロ レム", (url) ->
      msg.send url

  robot.respond /(レムのGIF|remuのGIF)頂戴/i, (msg) ->
    imageRemu msg, "リゼロ レム", true, (url) ->
      msg.send url

# Description:
#   A way to interact with the Google Images API.
#   Path to: node_modules/hubot-google-images/src/google-images.coffee
#
# Configuration
#   HUBOT_GOOGLE_CSE_KEY - Your Google developer API key
#   HUBOT_GOOGLE_CSE_ID - The ID of your Custom Search Engine
#   HUBOT_MUSTACHIFY_URL - Optional. Allow you to use your own mustachify instance.
#   HUBOT_GOOGLE_IMAGES_HEAR - Optional. If set, bot will respond to any line that begins with "image me" or "animate me" without needing to address the bot directly
#   HUBOT_GOOGLE_SAFE_SEARCH - Optional. Search safety level.
#   HUBOT_GOOGLE_IMAGES_FALLBACK - The URL to use when API fails. `{q}` will be replaced with the query string.
#
# Commands:
#   hubot image me <query> - The Original. Queries Google Images for <query> and returns a random top result.
#   hubot animate me <query> - The same thing as `image me`, except adds a few parameters to try to return an animated GIF instead.
#   hubot mustache me <url|query> - Adds a mustache to the specified URL or query result.

imageRemu = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
  if googleCseId
    # Using Google Custom Search API
    googleApiKey = process.env.HUBOT_GOOGLE_CSE_KEY
    if !googleApiKey
      msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_CSE_KEY"
      msg.send "Missing server environment variable HUBOT_GOOGLE_CSE_KEY."
      return
    q =
      q: query,
      searchType:'image',
      safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'high',
      fields:'items(link)',
      cx: googleCseId,
      key: googleApiKey
    if animated is true
      q.fileType = 'gif'
      q.hq = 'animated'
      q.tbs = 'itp:animated'
    if faces is true
      q.imgType = 'face'
    url = 'https://www.googleapis.com/customsearch/v1'
    msg.http(url)
      .query(q)
      .get() (err, res, body) ->
        if err
          if res.statusCode is 403
            msg.send "画像検索上限回数に達しているようです。"
            deprecatedImage(msg, query, animated, faces, cb)
          else
            msg.send "エラーが発生しています\nエラー内容：#{err}"
          return
        if res.statusCode isnt 200
          msg.send "リクエストダメっぽい〜\n#{res.statusCode}"
          return
        response = JSON.parse(body)
        if response?.items
          image = msg.random response.items
          cb ensureResult(image.link, animated)
        else
          msg.send "'#{query}'\n またあとでやって見て"
          ((error) ->
            msg.robot.logger.error error.message
            msg.robot.logger
              .error "(see #{error.extendedHelp})" if error.extendedHelp
          ) error for error in response.error.errors if response.error?.errors
  else
    msg.send "Google Image Search APIが使用できなくなっているよ" +
      "見てこれ [setup up Custom Search Engine API](https://github.com/hubot-scripts/hubot-google-images#cse-setup-details)."
    deprecatedImage(msg, query, animated, faces, cb)

deprecatedImage = (msg, query, animated, faces, cb) ->
  # Show a fallback image
  imgUrl = process.env.HUBOT_GOOGLE_IMAGES_FALLBACK ||
    'http://i.imgur.com/CzFTOkI.png'
  imgUrl = imgUrl.replace(/\{q\}/, encodeURIComponent(query))
  cb ensureResult(imgUrl, animated)

# Forces giphy result to use animated version
ensureResult = (url, animated) ->
  if animated is true
    ensureImageExtension url.replace(
      /(giphy\.com\/.*)\/.+_s.gif$/,
      '$1/giphy.gif')
  else
    ensureImageExtension url

# Forces the URL look like an image URL by adding `#.png`
ensureImageExtension = (url) ->
  if /(png|jpe?g|gif)$/i.test(url)
    url
  else
    "#{url}#.png"
