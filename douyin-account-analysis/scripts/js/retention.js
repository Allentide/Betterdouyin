// 读一条作品的逐秒留存：当前作品 + 同类作品，就是作品详情页「流量分析 → 观看趋势 → 留存分析」那张图的数据。
// 那张图是画在 canvas 上的，窗口最小化时根本不画，charts.js 和鼠标悬停都读不到；
// 所以直接请求页面自己用的数据接口（只读的 GET，带登录状态），后台标签页也能用。
// 标签页要停在 creator.douyin.com 的任意页面上（同源请求），然后分两步：
//   chrome.sh js <id> retention.js ACTION=start ITEM=<作品id>   发出请求，立即返回
//   等 3 秒左右
//   chrome.sh js <id> retention.js ACTION=read                  返回 JSON；done:false 就再等几秒重读
// 输出：{done, item, points:[{t:秒, cur:当前作品留存%, peer:同类作品留存%}], valleys:后台标出的低谷, error}
// 留存是「看到第 t 秒的人占总播放的百分比」，第 0 秒是 100%。
(function () {
  var action = '__ACTION__', item = '__ITEM__', KEY = 'data-cc-ret', root = document.documentElement;
  if (action === 'read') return root.getAttribute(KEY) || JSON.stringify({ done: false, error: 'not started' });
  if (!/^\d{8,}$/.test(item)) return JSON.stringify({ done: true, error: 'ITEM 要填作品 id（works_table.js 输出里的 id）' });
  if (location.hostname !== 'creator.douyin.com') return JSON.stringify({ done: true, error: '先让标签页停在 creator.douyin.com 的任意页面上' });
  root.setAttribute(KEY, JSON.stringify({ done: false, item: item }));
  fetch('/janus/douyin/creator/data/realtime/analysis/data_center?user_id=&item_id=' + item + '&analysis_type=1', { credentials: 'include' })
    .then(function (r) { return r.json(); })
    .then(function (d) {
      var at = d.analysis_trend || {}, cur = at.current_item || [], peer = at.similar_author || [], pm = {};
      peer.forEach(function (p) { pm[p.key] = p.value; });
      function sec(k) { var m = String(k).match(/(\d+):(\d+)/); return m ? (+m[1]) * 60 + (+m[2]) : +k; }
      function pct(v) { return v == null ? null : Math.round(v * 10000) / 100; }
      var points = cur.map(function (p) { return { t: sec(p.key), cur: pct(p.value), peer: pct(pm[p.key]) }; });
      var err = d.status_code ? (d.status_msg || ('status_code ' + d.status_code)) : (points.length ? '' : '没有留存数据（发布不满 48 小时，或者播放太少）');
      root.setAttribute(KEY, JSON.stringify({ done: true, item: item, points: points, valleys: d.valley_list || {}, error: err }));
    })
    .catch(function (e) { root.setAttribute(KEY, JSON.stringify({ done: true, item: item, error: String(e) })); });
  return JSON.stringify({ started: true, item: item });
})();
