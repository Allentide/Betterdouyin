// 读取整页可见文字，包括 shadow DOM 和同源 iframe（创作者中心是微前端，document.body.innerText 只能拿到导航栏）。
// 返回字符串。调试模式（Mac 的 chrome.sh js / Windows 的 cdp.ps1 eval）通用。
(function () {
  var out = [];
  function walk(root) {
    var els = root.querySelectorAll('*');
    for (var i = 0; i < els.length; i++) {
      var el = els[i];
      if (el.shadowRoot) {
        var inner = [];
        el.shadowRoot.querySelectorAll('*').forEach(function (c) {
          if (c.children.length === 0 && c.textContent.trim()) inner.push(c.textContent.trim());
        });
        if (inner.length) out.push('[shadow] ' + inner.join(' | '));
        walk(el.shadowRoot);
      }
      if (el.tagName === 'IFRAME') {
        try { if (el.contentDocument && el.contentDocument.body) out.push('[iframe] ' + el.contentDocument.body.innerText); } catch (e) {}
      }
    }
  }
  out.push(document.body ? document.body.innerText : '');
  walk(document);
  return out.join('\n');
})();
