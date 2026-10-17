// 投稿列表（数据中心 → 投稿作品 → 投稿列表）：从表格的 React 数据里取出当前页全部作品的原始指标。
// 返回 JSON：{page, pageSize, total, works:[...]}。total > pageSize 时要翻页（click_text.js 点页码），每页都跑一次。
// 详情页网址 = https://creator.douyin.com/creator-micro/work-management/work-detail/<id>
// 原理：Apple 事件 / CDP 执行的代码碰不到页面的 React 内部属性，所以插一段 <script> 到页面里读，再通过 html 上的属性把结果带回来。
(function () {
  var code = function () {
    var out;
    try {
      var cell = document.querySelector('td[role="gridcell"]');
      var fk = Object.keys(cell).filter(function (k) { return k.indexOf('__reactFiber') === 0; })[0], f = cell[fk], ds = null, pg = {};
      for (var i = 0; i < 60 && f; i++, f = f.return) { var p = f.memoizedProps; if (p && p.dataSource && !ds) ds = p.dataSource; if (p && p.pagination && p.pagination.total) { pg = p.pagination; break; } }
      var works = ds.filter(function (r) { return r.id; }).map(function (r) {
        var m = r.metrics || {};
        return {
          id: r.id, time: new Date(r.create_time * 1000).toLocaleString('zh-CN', { hour12: false }),
          type: r.picture_info ? '图文' + r.picture_info.count + '张' : (r.type === 8 ? '长图文' : r.video_info ? '视频' + Math.round(r.video_info.duration / 1000) + '秒' : 'type' + r.type),
          public: r.visibility && r.visibility.status === 1, desc: (r.description || '').slice(0, 80),
          play: m.view_count, like: m.like_count, comment: m.comment_count, share: m.share_count, fav: m.favorite_count,
          fans: m.subscribe_count, unfans: m.unsubscribe_count, home: m.homepage_visit_count,
          cover_ctr: m.cover_click_rate, bounce2s: m.bounce_rate_2s, fin5s: m.completion_rate_5s, fin: m.completion_rate,
          avg_sec: m.avg_view_second, img_avg: m.image_avg_view_count, desc_open: m.description_spread_rate,
          comment_entry: m.comment_entry_rate, comment_rate: m.comment_rate, fan_view: m.fan_view_proportion, dislike: m.dislike_rate
        };
      });
      out = JSON.stringify({ page: pg.currentPage, pageSize: pg.pageSize, total: pg.total, works: works });
    } catch (e) { out = 'error: ' + e.message + '（先确认已进入「投稿列表」且表格已加载）'; }
    document.documentElement.setAttribute('data-cc-out', out);
  };
  document.documentElement.removeAttribute('data-cc-out');
  var s = document.createElement('script'); s.textContent = '(' + code.toString() + ')()';
  (document.head || document.documentElement).appendChild(s); s.remove();
  return document.documentElement.getAttribute('data-cc-out');
})();
