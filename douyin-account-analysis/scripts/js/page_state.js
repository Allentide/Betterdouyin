// 检查当前页面状态：有没有登录、有没有弹出安全验证、是不是错误页。每打开一个新页面后先跑一次。
// 返回 JSON：{url, title, state, hint}
//   state: ok | error_page | captcha | need_login_creator | need_login_web | loading
//   hint: 发现问题时，应该原样（或翻译成用户的语言）转告用户的话
(function () {
  var url = location.href, title = document.title || '';
  var text = (document.body && document.body.innerText) || '';
  function visibleLeaf(re) {
    return [].some.call(document.querySelectorAll('button, a, span, div, p'), function (el) {
      return el.children.length === 0 && re.test((el.textContent || '').trim()) && el.offsetParent !== null;
    });
  }
  var r = { url: url, title: title, state: 'ok', hint: '' };
  if (/502 Bad Gateway|无法访问此网站|ERR_|This site can.t be reached/.test(title + text.slice(0, 300))) {
    r.state = 'error_page';
    r.hint = '页面打不开（' + title + '）。在 douyin.com 上搜索时，改用 search_box.js 从首页搜索框搜；其他页面等 1 分钟再试。';
  } else if (/安全验证|拖动滑块|向右滑动|请完成验证|验证码/.test(text) || [].some.call(document.querySelectorAll('iframe[src*="captcha"], iframe[src*="verify"], #captcha_container'), function (f) {
    // 页面里常年埋着一个隐藏的验证 iframe，只有显示出来才算
    var b = f.getBoundingClientRect(); return b.width > 50 && b.height > 50 && getComputedStyle(f).display !== 'none';
  })) {
    r.state = 'captcha';
    r.hint = '抖音弹出了安全验证，请你在 Chrome 里手动完成验证（拖动滑块或输入验证码），完成后告诉我，我再继续。';
  } else if (/creator\.douyin\.com/.test(url) && !/数据中心|内容管理/.test(text)) {
    r.state = text.length < 50 ? 'loading' : 'need_login_creator';
    if (r.state === 'need_login_creator') r.hint = '你还没有登录抖音创作者中心。请在 Chrome（Windows 调试模式下是「抖音分析专用Chrome」窗口）里打开 creator.douyin.com，用抖音 App 扫码登录，登录好后告诉我。';
  } else if (/douyin\.com/.test(url) && (visibleLeaf(/^(登录|立即登录|扫码登录|登录后查看更多)$/) || /扫码登录|登录后即可|请先登录/.test(text.slice(0, 3000)))) {
    r.state = 'need_login_web';
    r.hint = '抖音网页版还没有登录，搜索结果可能很少或者被登录框挡住。请在 Chrome 里打开 www.douyin.com，点右上角「登录」，用抖音 App 扫码登录，普通账号就行，登录好后告诉我。';
  } else if (text.length < 50) {
    r.state = 'loading';
  }
  return JSON.stringify(r);
})();
