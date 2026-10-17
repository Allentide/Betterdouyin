// 点击页面上文字完全等于 __TEXT__ 的最内层元素（第 __NTH__ 个，从 0 开始）。只用于切换标签、展开、翻页这类只读操作。
// 用法：chrome.sh js <id> click_text.js TEXT=投稿作品 NTH=0（Windows：cdp.ps1 js <id> click_text.js TEXT=投稿作品 NTH=0）
(function () {
  var want = '__TEXT__', nth = parseInt('__NTH__', 10) || 0;
  var deny = /^(删除|删除作品|设置权限|权限设置|置顶|取消置顶|编辑|编辑作品|发布|立即发布|提交|确认|确定|关注|点赞|收藏|分享|转发|举报|发送|回复)$/;
  if (deny.test(want)) return 'refused: ' + want;
  var hits = [];
  function same(el) { return (el.textContent || '').trim() === want; }
  document.querySelectorAll('body *').forEach(function (el) {
    // 取最内层：自己文字匹配，且没有子元素也完全匹配
    if (same(el) && el.offsetParent !== null && !Array.prototype.some.call(el.children, same)) hits.push(el);
  });
  if (!hits[nth]) return 'not found: ' + want + ' (hits=' + hits.length + ')';
  hits[nth].click();
  return 'clicked: ' + want + ' (' + (nth + 1) + '/' + hits.length + ')';
})();
