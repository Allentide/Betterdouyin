// 读出当前页所有图表（ECharts，画在 canvas 上，页面文字里读不到）的数据：性别、年龄、留存曲线、粉丝趋势等。
// 返回 JSON 数组，每项 {title, x, series:[{name, data}]}。title 取图表上方最近的标题文字，仅供辨认。
(function () {
  var code = function () {
    var res = [];
    document.querySelectorAll('canvas').forEach(function (cv) {
      var opt = null, el = cv;
      for (var up = 0; up < 6 && el && !opt; up++, el = el.parentElement) {
        var fk = Object.keys(el).filter(function (k) { return k.indexOf('__reactFiber') === 0; })[0];
        if (!fk) continue;
        for (var f = el[fk], i = 0; i < 15 && f && !opt; i++, f = f.return) {
          var p = f.memoizedProps;
          if (p && p.option && p.option.series) opt = p.option;
        }
      }
      if (!opt) return;
      // 往上找最近的一段短标题
      var title = '', box = cv;
      for (var k = 0; k < 8 && box && !title; k++, box = box.parentElement) {
        var prev = box.previousElementSibling;
        if (prev && prev.innerText && prev.innerText.trim().length < 30) title = prev.innerText.trim().replace(/\s+/g, ' ');
      }
      var xa = [].concat(opt.xAxis || [])[0];
      var series = [].concat(opt.series).map(function (s) {
        return { name: s.name || s.type || '', data: (s.data || []).map(function (d) { return (d && typeof d === 'object') ? [d.name, d.value] : d; }) };
      });
      res.push({ title: title, x: (xa && xa.data) || null, series: series });
    });
    document.documentElement.setAttribute('data-cc-out', JSON.stringify(res));
  };
  document.documentElement.removeAttribute('data-cc-out');
  var s = document.createElement('script'); s.textContent = '(' + code.toString() + ')()';
  (document.head || document.documentElement).appendChild(s); s.remove();
  return document.documentElement.getAttribute('data-cc-out');
})();
