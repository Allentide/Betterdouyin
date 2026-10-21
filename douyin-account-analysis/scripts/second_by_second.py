#!/usr/bin/env python3
# 逐秒对照：把一条视频每一秒的画面、台词，和后台留存曲线（当前作品 vs 同类作品）对齐，
# 找出「比同类明显多走人」的那几秒。用法见 SKILL.md 第五节「逐秒对照」。
#
#   python3 second_by_second.py <视频.mp4> <retention.json> <输出目录> [--views 播放量] [--asr auto|off] [--max 秒]
#
# retention.json 是 retention.js ACTION=read 的输出。--views 用来把百分比换算成人数、判断差异是不是样本太小造成的。
# 输出目录里：
#   report.md     逐秒表：留存、这一秒走了多少（占还在看的人）、同类走了多少、是否明显多走、这一秒说了什么
#   seconds.json  同一份数据，给程序用
#   sheet.jpg     联系表：每一秒两帧画面 + 数字，明显多走的秒标红。AI 必须打开看
#   frames/       每 0.5 秒一帧（720 宽），看清屏幕上的字用
# 依赖：ffmpeg、Pillow。台词识别（可选）：Mac 上用 uvx 跑 mlx-whisper，第一次会下载约 1.6GB 模型。
import argparse, json, math, os, shutil, subprocess, sys

ap = argparse.ArgumentParser()
ap.add_argument('video'); ap.add_argument('retention'); ap.add_argument('out')
ap.add_argument('--views', type=int, default=0, help='播放量，用来算人数和显著性')
ap.add_argument('--asr', default='auto', choices=['auto', 'off'])
ap.add_argument('--max', type=float, default=30, help='最多分析前多少秒（默认 30）')
ap.add_argument('--asr-model', default='mlx-community/whisper-large-v3-turbo')
a = ap.parse_args()

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit('缺少 Pillow：先执行 python3 -m pip install pillow')
if not shutil.which('ffmpeg'):
    sys.exit('缺少 ffmpeg：Mac 用 brew install ffmpeg，Windows 用 winget install ffmpeg')

os.makedirs(a.out, exist_ok=True)
FR = os.path.join(a.out, 'frames'); os.makedirs(FR, exist_ok=True)

# ---------- 留存 → 每一秒的流失 ----------
ret = json.load(open(a.retention, encoding='utf-8'))
pts = {p['t']: p for p in ret.get('points', []) if p.get('cur') is not None}
if len(pts) < 3:
    sys.exit('retention.json 里没有留存数据：' + str(ret.get('error')))
dur = float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', a.video],
                           capture_output=True, text=True).stdout.strip() or 0)
last = int(min(max(pts), a.max, math.ceil(dur) if dur else max(pts)))

rows = []
for t in range(1, last + 1):
    p0, p1 = pts.get(t - 1), pts.get(t)
    if not p0 or not p1 or p0['cur'] <= 0: continue
    lc, lp = p0['cur'] - p1['cur'], (p0['peer'] - p1['peer']) if p0.get('peer') is not None and p1.get('peer') is not None else None
    rc = lc / p0['cur']                                  # 这一秒走的人，占「这一秒开始时还在看的人」的比例
    rp = lp / p0['peer'] if lp is not None and p0['peer'] > 0 else None
    r = {'from': t - 1, 'to': t, 'cur': p1['cur'], 'peer': p1.get('peer'), 'lost_rate': round(rc * 100, 1),
         'peer_lost_rate': round(rp * 100, 1) if rp is not None else None}
    # 判断「明显多走」：差距要够大，还要排除样本太小的偶然波动（二项分布 z 值）
    verdict = ''
    if rp is not None:
        diff = rc - rp
        if a.views:
            n = a.views * p0['cur'] / 100
            r['watching'] = round(n); r['left_people'] = round(a.views * lc / 100)
            se = math.sqrt(max(rp * (1 - rp), 1e-4) / max(n, 1))
            z = diff / se; r['z'] = round(z, 1)
            if n * rp < 5 or r['left_people'] < 5: verdict = '人太少，不判断' if abs(diff) >= .05 else ''
            elif diff >= .05 and z >= 3: verdict = '明显多走'
            elif diff >= .05 and z >= 2: verdict = '可能多走'
            elif diff <= -.05 and z <= -2: verdict = '比同类留得住'
        else:
            if diff >= .08 and rc >= 1.3 * rp: verdict = '明显多走（未给播放量，未排除样本波动）'
            elif diff <= -.08: verdict = '比同类留得住'
    r['verdict'] = verdict
    rows.append(r)

# ---------- 台词（可选） ----------
words, segs, asr_note = [], [], ''
if a.asr == 'auto':
    wav = os.path.join(a.out, 'audio.wav')
    subprocess.run(['ffmpeg', '-loglevel', 'error', '-y', '-i', a.video, '-t', str(last + 2), '-ac', '1', '-ar', '16000', wav])
    has_audio = os.path.exists(wav) and os.path.getsize(wav) > 10000
    if has_audio and sys.platform == 'darwin' and shutil.which('uvx'):
        r = subprocess.run(['uvx', '--from', 'mlx-whisper', 'mlx_whisper', wav, '--model', a.asr_model, '--language', 'zh',
                            '--word-timestamps', 'True', '--output-format', 'json', '--output-dir', a.out],
                           capture_output=True, text=True)
        jf = os.path.join(a.out, 'audio.json')
        if os.path.exists(jf):
            d = json.load(open(jf, encoding='utf-8'))
            segs = [(s['start'], s['end'], s['text'].strip()) for s in d.get('segments', [])]
            words = [(w['start'], w['end'], w['word']) for s in d.get('segments', []) for w in s.get('words', [])]
        else:
            asr_note = '台词识别失败：' + (r.stderr or '')[-300:]
    elif not has_audio:
        asr_note = '视频没有声音'
    else:
        asr_note = '这台电脑没有可用的台词识别（Mac 需要 uv）。台词请从画面字幕里读'
else:
    asr_note = '没有识别台词（--asr off）'

for r in rows:
    w = ''.join(x[2] for x in words if r['from'] <= x[0] < r['to']).strip()
    r['speech'] = w
    # 这一秒里说完的整句话：观众常常在一句话说完、听懂了在讲什么的时候离开
    r['sentence_end'] = [f'「{s[2]}」{s[1]:.1f}s 说完' for s in segs if r['from'] <= s[1] < r['to']]

# ---------- 抽帧 ----------
subprocess.run(['ffmpeg', '-loglevel', 'error', '-y', '-i', a.video, '-t', str(last), '-vf', 'fps=2,scale=720:-2',
                os.path.join(FR, 'f%03d.jpg')])
# 重命名成带时间的文件名，方便 AI 直接按秒打开
named = {}
for f in sorted(os.listdir(FR)):
    if f.startswith('f') and f.endswith('.jpg'):
        k = int(f[1:4]); t = (k - 1) / 2
        dst = os.path.join(FR, f't{t:05.1f}s.jpg'); os.replace(os.path.join(FR, f), dst); named[k] = dst
def frame(t):
    return named.get(int(t * 2) + 1)

# ---------- 联系表 ----------
def font(sz):
    for p in ['/System/Library/Fonts/Hiragino Sans GB.ttc', '/System/Library/Fonts/STHeiti Medium.ttc',
              'C:/Windows/Fonts/msyh.ttc', 'C:/Windows/Fonts/simhei.ttf', '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc']:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, sz)
            except OSError: pass
    return ImageFont.load_default()
FW, FH, COLS, LH = 240, 427, 4, 120
f1, f2 = font(26), font(22)
cells = len(rows); nrow = math.ceil(cells / COLS)
sheet = Image.new('RGB', (COLS * (2 * FW + 16), nrow * (FH + LH + 16)), 'white'); d = ImageDraw.Draw(sheet)
for i, r in enumerate(rows):
    x, y = (i % COLS) * (2 * FW + 16), (i // COLS) * (FH + LH + 16)
    bad = r['verdict'].startswith('明显') or r['verdict'].startswith('可能')
    good = r['verdict'].startswith('比同类')
    col = (220, 30, 60) if bad else (20, 140, 80) if good else (30, 30, 30)
    if bad or good: d.rectangle((x, y, x + 2 * FW + 8, y + FH + LH + 8), outline=col, width=6)
    d.text((x + 10, y + 6), f"{r['from']}–{r['to']} 秒  走了 {r['lost_rate']}%（同类 {r['peer_lost_rate']}%）", font=f1, fill=col)
    d.text((x + 10, y + 40), (r['verdict'] or ' ') + (f"  约 {r['left_people']} 人" if 'left_people' in r else ''), font=f1, fill=col)
    d.text((x + 10, y + 76), (r['speech'] or '')[:20], font=f2, fill=(90, 90, 90))
    for j, tt in enumerate((r['from'] + .0, r['from'] + .5)):
        p = frame(tt)
        if p: sheet.paste(Image.open(p).resize((FW, FH)), (x + 4 + j * FW, y + LH))
sheet.save(os.path.join(a.out, 'sheet.jpg'), quality=85)

# ---------- 报告 ----------
json.dump({'rows': rows, 'segments': segs, 'asr_note': asr_note, 'valleys': ret.get('valleys')},
          open(os.path.join(a.out, 'seconds.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
L = ['# 逐秒对照', '',
     '「走了」= 这一秒开始时还在看的人里，这一秒内离开的比例。和同类比较的是这个比例，不是总留存。',
     '判断标准：比同类多走 5 个百分点以上，且排除样本波动（z≥3 为明显，z≥2 为可能）；这一秒走的人不到 5 个时不判断。' if a.views else
     '没有给播放量，无法排除样本波动，结论要说得保守。', '']
if asr_note: L += ['> ' + asr_note, '']
L += ['| 秒 | 留存 | 同类留存 | 这一秒走了 | 同类走了 | 结论 | 这一秒说的话 | 这一秒说完的句子 | 画面（AI 看图后填写） |',
      '|---|---|---|---|---|---|---|---|---|']
for r in rows:
    L.append(f"| {r['from']}–{r['to']} | {r['cur']}% | {r['peer']}% | {r['lost_rate']}%"
             + (f"（约 {r['left_people']} 人）" if 'left_people' in r else '')
             + f" | {r['peer_lost_rate']}% | {r['verdict']} | {r['speech']} | {'；'.join(r['sentence_end'])} |  |")
L += ['', f"后台标出的低谷：{json.dumps(ret.get('valleys'), ensure_ascii=False)}", '',
      '下一步（给 AI）：打开 sheet.jpg，再打开「明显多走」那几秒的 frames/t*.jpg，把每一秒屏幕上是什么填进最后一列；'
      '结论只针对标红的秒，其他秒不要套通用规则。']
open(os.path.join(a.out, 'report.md'), 'w', encoding='utf-8').write('\n'.join(L) + '\n')
print('\n'.join(L))
