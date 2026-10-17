// 抖音网页版搜索结果页（douyin.com/search/<词>）：取出当前已加载的全部作品卡片的原始数据。
// 返回 JSON：{keyword, count, items:[{id, url, type, images, duration(秒), time, desc, author, author_uid, author_sec_uid, img_urls(图文的第1-3张和最后1张), like, comment, fav, share}], related:[相关搜索词]}
// 搜索结果里没有作者粉丝数（是 0），要去 https://www.douyin.com/user/<author_sec_uid> 读。别人作品的播放量拿不到。
// 传参：js <id> search_results.js SCROLL=1 时，会先把结果列表滚到底触发加载更多（加载需要 2 到 3 秒，之后再用 SCROLL=0 读取）。
(function () {
  var code = function (doScroll) {
    if (doScroll) {
      var sc = [].filter.call(document.querySelectorAll('*'), function (e) { return e.scrollHeight > e.clientHeight + 200 && /auto|scroll/.test(getComputedStyle(e).overflowY); });
      sc.forEach(function (e) { e.scrollTop = e.scrollHeight; e.dispatchEvent(new Event('scroll')); });
      window.scrollTo(0, document.documentElement.scrollHeight); window.dispatchEvent(new Event('scroll'));
      document.documentElement.setAttribute('data-cc-out', JSON.stringify({ scrolled: sc.length }));
      return;
    }
    var seen = {}, items = [], related = {}, kw = '';
    document.querySelectorAll('body *').forEach(function (el) {
      var fk = Object.keys(el).filter(function (k) { return k.indexOf('__reactFiber') === 0; })[0];
      if (!fk) return;
      // 卡片数据在几层之上的组件 props.data.awemeInfo 里
      var p = null, a = null;
      for (var f = el[fk], i = 0; i < 10 && f && !a; i++, f = f.return) {
        p = f.memoizedProps; a = p && p.data && p.data.awemeInfo;
      }
      if (!a || seen[a.awemeId]) return;
      seen[a.awemeId] = 1;
      var s = a.stats || {}, au = a.authorInfo || {};
      if (p.data.logParams && p.data.logParams.search_keyword) kw = p.data.logParams.search_keyword;
      (a.suggestWords || []).forEach(function (g) { (g.words || []).forEach(function (w) { related[w.word] = 1; }); });
      var isImg = a.images && a.images.length > 0;
      items.push({
        id: a.awemeId, url: 'https://www.douyin.com/' + (isImg ? 'note/' : 'video/') + a.awemeId,
        type: isImg ? '图文' : '视频', images: isImg ? a.images.length : 0,
        duration: a.video && a.video.duration ? Math.round(a.video.duration / 1000) : 0,
        time: a.createTime ? new Date(a.createTime * 1000).toLocaleDateString('zh-CN') : '',
        desc: (a.desc || '').replace(/\s+/g, ' ').slice(0, 120),
        author: au.nickname, author_uid: au.uid, author_sec_uid: au.secUid,
        img_urls: isImg ? [0, 1, 2, a.images.length - 1].filter(function (i, k, arr) { return i >= 0 && i < a.images.length && arr.indexOf(i) === k; }).map(function (i) { var u = a.images[i].urlList || a.images[i].url_list || []; return u[0]; }) : [],
        like: s.diggCount, comment: s.commentCount, fav: s.collectCount, share: s.shareCount
      });
    });
    document.querySelectorAll('body *').forEach(function (el) {
      if (el.children.length === 0 && /相关搜索/.test(el.textContent || '')) {
        var box = el.parentElement && el.parentElement.parentElement;
        if (box) box.querySelectorAll('*').forEach(function (c) { var t = (c.textContent || '').trim(); if (c.children.length === 0 && t && t !== '相关搜索' && t.length < 30) related[t] = 1; });
      }
    });
    document.documentElement.setAttribute('data-cc-out', JSON.stringify({ keyword: kw, count: items.length, items: items, related: Object.keys(related) }));
  };
  document.documentElement.removeAttribute('data-cc-out');
  var s = document.createElement('script'); s.textContent = '(' + code.toString() + ')(' + ('__SCROLL__' === '1') + ')';
  (document.head || document.documentElement).appendChild(s); s.remove();
  return document.documentElement.getAttribute('data-cc-out');
})();
