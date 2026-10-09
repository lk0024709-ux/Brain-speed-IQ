import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const BrainSpeedApp()); }
const bg = Color(0xFF10101B), panel = Color(0xFF1B1B2B), purple = Color(0xFF9A6BFF), cyan = Color(0xFF5BE7E8), pink = Color(0xFFFF6E9F), lime = Color(0xFFC5F36B);

class BrainSpeedApp extends StatelessWidget {
  const BrainSpeedApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'BrainSpeed IQ', debugShowCheckedModeBanner: false, theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: bg, colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark)), home: const HomeScreen());
}
enum Mode { reflex, memory, logic }
extension ModeInfo on Mode {
  String get title => switch (this) { Mode.reflex => 'REFLEX RUSH', Mode.memory => 'MEMORY MATRIX', Mode.logic => 'PATTERN BREAKER' };
  String get description => switch (this) { Mode.reflex => 'Tap the target quickly', Mode.memory => 'Remember and repeat numbers', Mode.logic => 'Find the missing number' };
  String get emoji => switch (this) { Mode.reflex => '⚡', Mode.memory => '🧠', Mode.logic => '🔢' };
  Color get tint => switch (this) { Mode.reflex => cyan, Mode.memory => pink, Mode.logic => lime };
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int xp = 0, best = 0; bool loading = true;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { xp = p.getInt('xp') ?? 0; best = p.getInt('best') ?? 0; loading = false; });
  }
  String get rank => xp >= 2500 ? 'S-RANK LEGEND' : xp >= 1200 ? 'A-RANK ELITE' : xp >= 500 ? 'B-RANK RISING' : 'C-RANK ROOKIE';
  Future<void> play(Mode mode) async {
    final r = await Navigator.push<SessionResult>(context, MaterialPageRoute(builder: (_) => GameScreen(mode: mode)));
    if (r == null || !mounted) return;
    final p = await SharedPreferences.getInstance();
    xp += r.xp; best = max(best, r.score);
    await p.setInt('xp', xp); await p.setInt('best', best);
    if (mounted) setState(() {});
  }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(20), children: [
    Row(children: [const Icon(Icons.bolt, color: cyan, size: 40), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('BRAIN SPEED', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.4)), Text('IQ TRAINING ARENA', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2))])), IconButton(onPressed: () => showAboutDialog(context: context, applicationName: 'BrainSpeed IQ', children: const [Text('This is a brain-training game, not a clinically validated IQ assessment.')]), icon: const Icon(Icons.info_outline))]),
    const SizedBox(height: 22),
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF30244D), Color(0xFF172B35)])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('YOUR CURRENT RANK', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 2))), Text(rank, style: const TextStyle(color: lime, fontWeight: FontWeight.w900, fontSize: 10))]),
      const SizedBox(height: 8), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('$xp', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900)), const Padding(padding: EdgeInsets.only(left: 8, bottom: 7), child: Text('XP', style: TextStyle(color: cyan, fontWeight: FontWeight.bold))), const Spacer(), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('BEST SCORE', style: TextStyle(color: Colors.white54, fontSize: 9)), Text('$best', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])]),
      const SizedBox(height: 14), LinearProgressIndicator(value: (xp % 500) / 500, color: cyan, backgroundColor: Colors.white12),
      const SizedBox(height: 8), Text((500 - xp % 500).toString() + ' XP TO NEXT LEVEL', style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ])),
    const SizedBox(height: 28), const Text('CHOOSE YOUR TRAINING', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.2)), const SizedBox(height: 14),
    for (final m in Mode.values) Padding(padding: const EdgeInsets.only(bottom: 12), child: Material(color: panel, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: () => play(m), borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: m.tint.withValues(alpha: .35))), child: Row(children: [Text(m.emoji, style: const TextStyle(fontSize: 30)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.title, style: TextStyle(color: m.tint, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(m.description, style: const TextStyle(color: Colors.white60, fontSize: 11))])), Icon(Icons.arrow_forward_ios, color: m.tint, size: 16)]))))),
    const Text('For fun and personal progress only. Scores are not an IQ diagnosis.', style: TextStyle(color: Colors.white54, fontSize: 11)),
  ])));
}
class SessionResult { const SessionResult(this.score, this.xp); final int score, xp; }
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.mode}); final Mode mode;
  @override State<GameScreen> createState() => _GameScreenState();
}
class _GameScreenState extends State<GameScreen> {
  final random = Random(); Timer? timer; int seconds = 30, score = 0, round = 0, target = 0, startedAt = 0;
  bool started = false, done = false, showing = true, targetVisible = false;
  List<int> sequence = [], entered = []; String message = 'Ready when you are.';
  @override void dispose() { timer?.cancel(); super.dispose(); }
  void start() {
    setState(() { started = true; done = false; seconds = 30; score = 0; round = 0; });
    timer?.cancel(); timer = Timer.periodic(const Duration(seconds: 1), (t) { if (!mounted) return; if (seconds <= 1) { t.cancel(); setState(() => seconds = 0); finish(); } else { setState(() => seconds--); } });
    next();
  }
  void next() {
    if (!mounted || done) return;
    setState(() {
      round++;
      if (widget.mode == Mode.reflex) { targetVisible = true; startedAt = DateTime.now().millisecondsSinceEpoch; message = 'TAP THE TARGET!'; }
      else if (widget.mode == Mode.memory) {
        sequence = List.generate(min(3 + round ~/ 3, 7), (_) => random.nextInt(9) + 1); entered = []; showing = true; message = 'MEMORIZE THE SEQUENCE';
        Future<void>.delayed(Duration(milliseconds: 900 + sequence.length * 250), () { if (!mounted || done) return; setState(() { showing = false; message = 'REPEAT IT IN ORDER'; }); });
      } else { target = random.nextInt(8) + 2; message = 'WHAT COMES NEXT?'; }
    });
  }
  void tapTarget() {
    if (!started || done || !targetVisible) return;
    final points = max(1, 100 - (DateTime.now().millisecondsSinceEpoch - startedAt) ~/ 8);
    setState(() { targetVisible = false; score += points; message = 'NICE! +' + points.toString(); });
    Future<void>.delayed(const Duration(milliseconds: 450), next);
  }
  void enter(int n) {
    if (showing || done || !started || entered.length >= sequence.length) return;
    final i = entered.length; setState(() => entered.add(n));
    if (sequence[i] != n) { setState(() => message = 'NOT QUITE — NEXT ROUND'); Future<void>.delayed(const Duration(milliseconds: 500), next); }
    else if (entered.length == sequence.length) { setState(() { score += 100 + sequence.length * 20; message = 'PERFECT MEMORY!'; }); Future<void>.delayed(const Duration(milliseconds: 500), next); }
  }
  void answer(int n) { if (!started || done) return; setState(() { if (n == target * 5) { score += 100; message = 'CORRECT! +100'; } else { message = 'KEEP GOING!'; } }); Future<void>.delayed(const Duration(milliseconds: 450), next); }
  void finish() { if (done) return; timer?.cancel(); setState(() { done = true; started = false; message = 'TRAINING COMPLETE'; }); }
  void home() { timer?.cancel(); Navigator.pop(context, SessionResult(score, max(10, score ~/ 10))); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.mode.title), backgroundColor: bg), body: SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
    Row(children: [Expanded(child: stat('TIME', seconds.toString() + ' s', pink)), const SizedBox(width: 8), Expanded(child: stat('SCORE', score.toString(), cyan)), const SizedBox(width: 8), Expanded(child: stat('ROUND', round.toString(), lime))]),
    const SizedBox(height: 16), LinearProgressIndicator(value: seconds / 30, color: widget.mode.tint, backgroundColor: Colors.white12), const SizedBox(height: 22),
    Expanded(child: Center(child: done ? Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events, color: lime, size: 64), const Text('SESSION COMPLETE', style: TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 10), Text(score.toString(), style: const TextStyle(fontSize: 46, color: cyan, fontWeight: FontWeight.w900)), FilledButton(onPressed: home, child: const Text('CONTINUE'))]) : !started ? Column(mainAxisSize: MainAxisSize.min, children: [Text(widget.mode.emoji, style: const TextStyle(fontSize: 55)), const SizedBox(height: 12), Text(widget.mode.description, textAlign: TextAlign.center), const SizedBox(height: 18), FilledButton(onPressed: start, child: const Text('START TRAINING'))]) : challenge())),
    const SizedBox(height: 12), Text(message, textAlign: TextAlign.center, style: TextStyle(color: widget.mode.tint, fontWeight: FontWeight.w900, fontSize: 12)), const SizedBox(height: 10),
    if (started) SizedBox(width: double.infinity, child: OutlinedButton(onPressed: finish, child: const Text('END SESSION'))),
  ]))));
  Widget stat(String label, String value, Color color) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)), child: Column(children: [Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 17))]));
  Widget tile(String value, Color color, {VoidCallback? onTap, double? size}) => Material(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(16), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(width: size, height: size, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: .65), width: 1.5)), child: Center(child: Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900))))));
  Widget challenge() {
    if (widget.mode == Mode.reflex) return GestureDetector(onTap: tapTarget, child: Container(width: targetVisible ? 190 : 130, height: targetVisible ? 190 : 130, decoration: BoxDecoration(shape: BoxShape.circle, color: cyan.withValues(alpha: .12), border: Border.all(color: cyan, width: 3)), child: const Icon(Icons.bolt, color: cyan, size: 65)));
    if (widget.mode == Mode.memory) {
      if (showing) return Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: sequence.map((n) => tile(n.toString(), pink, size: 62)).toList());
      return GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: List.generate(9, (i) => tile(entered.contains(i + 1) ? '✓' : (i + 1).toString(), pink, onTap: entered.contains(i + 1) ? null : () => enter(i + 1))));
    }
    final options = <int>{target * 5, target * 4, target * 5 + 2, target * 3}.toList()..shuffle(random);
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(target.toString() + ' • ' + (target * 2).toString() + ' • ' + (target * 3).toString() + ' • ' + (target * 4).toString() + ' • ?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 22), GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: options.map((n) => tile(n.toString(), lime, onTap: () => answer(n))).toList())]);
  }
}
