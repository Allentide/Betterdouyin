// 在 douyin.com 页面顶部的搜索框里输入 __KW__ 并提交搜索（直接打开搜索链接返回 502 时用）。
// 用法：chrome.sh js <id> search_box.js KW=关键词；执行后等 8 秒左右，再用 search_results.js 读结果。
(function () {
  var kw = '__KW__';
  var input = document.querySelector('input[data-e2e="searchbar-input"]') ||
    [].filter.call(document.querySelectorAll('input'), function (i) { return /搜索/.test(i.placeholder || '') && i.offsetParent !== null; })[0];
  if (!input) return 'search input not found';
  // 不要调用 input.focus()：会把最小化的 Chrome 切到前台
  var setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
  setter.call(input, kw);
  input.dispatchEvent(new Event('input', { bubbles: true }));
  input.dispatchEvent(new Event('change', { bubbles: true }));
  var btn = document.querySelector('[data-e2e="searchbar-button"]') ||
    [].filter.call(document.querySelectorAll('button'), function (b) { return (b.textContent || '').trim() === '搜索'; })[0];
  if (btn) { btn.click(); return 'submitted (button): ' + kw; }
  ['keydown', 'keypress', 'keyup'].forEach(function (t) {
    input.dispatchEvent(new KeyboardEvent(t, { key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true }));
  });
  return 'submitted (enter): ' + kw;
})();
