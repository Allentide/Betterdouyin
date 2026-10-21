// 取自己一条作品的视频播放地址和时长，用来下载到本地做逐秒分析（第五节「逐秒对照」）。
// 和 retention.js 一样请求页面自己用的只读接口，后台标签页也能用；标签页要停在 creator.douyin.com 上。
//   chrome.sh js <id> video_url.js ACTION=start ITEM=<作品id>
//   等 3 秒左右
//   chrome.sh js <id> video_url.js ACTION=read
// 输出：{done, item, duration:秒, urls:[可下载的地址，有时效，拿到后尽快下载], error}
// 图文作品没有视频地址，urls 为空。
(function () {
  var action = '__ACTION__', item = '__ITEM__', KEY = 'data-cc-vid', root = document.documentElement;
  if (action === 'read') return root.getAttribute(KEY) || JSON.stringify({ done: false, error: 'not started' });
  if (!/^\d{8,}$/.test(item)) return JSON.stringify({ done: true, error: 'ITEM 要填作品 id（works_table.js 输出里的 id）' });
  if (location.hostname !== 'creator.douyin.com') return JSON.stringify({ done: true, error: '先让标签页停在 creator.douyin.com 的任意页面上' });
  root.setAttribute(KEY, JSON.stringify({ done: false, item: item }));
  fetch('/web/api/creator/item/mget?ids=' + item + '&fields=play_info', { credentials: 'include' })
    .then(function (r) { return r.json(); })
    .then(function (d) {
      var it = (d.items || [])[0] || {}, pi = it.play_info || {}, u = (pi.url && pi.url.url_list) || [];
      var dur = it.video_info && it.video_info.duration ? Math.round(it.video_info.duration / 100) / 10 : null;
      root.setAttribute(KEY, JSON.stringify({ done: true, item: item, duration: dur, urls: u, error: u.length ? '' : '没有视频地址（图文作品，或者作品不是当前登录账号的）' }));
    })
    .catch(function (e) { root.setAttribute(KEY, JSON.stringify({ done: true, item: item, error: String(e) })); });
  return JSON.stringify({ started: true, item: item });
})();
