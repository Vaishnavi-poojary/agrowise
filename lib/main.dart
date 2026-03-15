import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

// ─── CONFIGURATION ──────────────────────────────────────────
const String BASE_URL = 'https://agrowise.onrender.com';
const String WEATHER_API_KEY = '1eb2298216b09cd00d3a80c6cfa7b257';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AgroWiseApp());
}

class AppColors {
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color accent = Color(0xFF76C442);
  static const Color accentLight = Color(0xFFA8E063);
  static const Color gold = Color(0xFFF79C00);
  static const Color bg = Color(0xFFF1F8E9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color soil = Color(0xFF6D4C41);
}

class AgroWiseApp extends StatelessWidget {
  const AgroWiseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: const SplashPage(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAGE 1 — SPLASH
// ═══════════════════════════════════════════════════════════
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(_textCtrl);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) => const HomePage(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2818), Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.accentLight.withOpacity(0.4),
                          width: 2),
                    ),
                    child: const Center(child: _AgroLogo(size: 84)),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Column(children: [
                    const Text('AGROWISE',
                        style: TextStyle(
                          color: AppColors.accentLight,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 7,
                        )),
                    const SizedBox(height: 8),
                    Text('AI CROP ADVISOR',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                          letterSpacing: 5,
                        )),
                  ]),
                ),
              ),
              const SizedBox(height: 64),
              FadeTransition(
                opacity: _textFade,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentLight.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAGE 2 — HOME
// ═══════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _kCtrl = TextEditingController();
  final _phCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _soilType = 'Loamy';
  bool _loadingWeather = false;
  bool _loadingResult = false;
  Map<String, dynamic>? _weather;
  String? _weatherError;
  double? _lat, _lon;

  final List<String> _soilTypes = ['Black', 'Clayey', 'Loamy', 'Red', 'Sandy'];
  final List<String> _quickCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai',
    'Hyderabad',
    'Pune',
    'Kolkata',
    'Mangalore',
    'Udupi',
  ];
  // ── Wake up Render backend on app load ──
  Future<void> _wakeUpBackend() async {
    try {
      await http
          .get(Uri.parse('$BASE_URL/'))
          .timeout(const Duration(seconds: 60));
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _wakeUpBackend(); // silently wakes backend in background
  }

  @override
  void dispose() {
    _nCtrl.dispose();
    _pCtrl.dispose();
    _kCtrl.dispose();
    _phCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // ── BUG 1 FIXED: fetch directly using city name, use wd keys correctly ──
  Future<void> _fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
      _weather = null;
    });
    try {
      final wRes = await http
          .get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather'
            '?q=${Uri.encodeComponent(city.trim())}&appid=$WEATHER_API_KEY&units=metric',
          ))
          .timeout(const Duration(seconds: 10));

      if (wRes.statusCode != 200) {
        throw Exception('City not found. Try "Mumbai" or "Delhi"');
      }
      final wd = json.decode(wRes.body);

      _lat = (wd['coord']['lat'] as num).toDouble();
      _lon = (wd['coord']['lon'] as num).toDouble();

      setState(() {
        _weather = {
          'temperature': (wd['main']['temp'] as num).toDouble(),
          'humidity': (wd['main']['humidity'] as num).toDouble(),
          'rainfall': ((wd['rain'] ?? {})['1h'] ?? 0.0),
          'city': wd['name'],
          'country': wd['sys']['country'],
          'weather_description':
              (wd['weather'][0]['description'] as String).capitalize(),
        };
      });
    } catch (e) {
      setState(() {
        _weatherError = e.toString().replaceAll('Exception: ', '');
        _lat = null;
        _lon = null;
      });
    } finally {
      setState(() {
        _loadingWeather = false;
      });
    }
  }

  Future<void> _getRecommendation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_weather == null || _lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your city and fetch weather first!'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    setState(() {
      _loadingResult = true;
    });
    try {
      final res = await http
          .post(
            Uri.parse('$BASE_URL/recommend'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'nitrogen': double.parse(_nCtrl.text),
              'phosphorus': double.parse(_pCtrl.text),
              'potassium': double.parse(_kCtrl.text),
              'ph': double.parse(_phCtrl.text),
              'soil_type': _soilType,
              'latitude': _lat,
              'longitude': _lon,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await _saveHistory(data);
        if (mounted) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ResultPage(data: data)));
        }
      } else {
        throw Exception('API error ${res.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('timeout')
              ? '⏳ Server is waking up, please try again in 10 seconds!'
              : 'Error: $e'),
          backgroundColor:
              e.toString().contains('timeout') ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _loadingResult = false;
      });
    }
  }

  Future<void> _saveHistory(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('history') ?? [];
    list.insert(
        0,
        json.encode({
          'crop': data['crop_recommendation']['recommended_crop'],
          'fertilizer': data['fertilizer_recommendation']['fertilizer_name'],
          'city': data['location']['city'],
          'date': DateTime.now().toIso8601String(),
          'confidence': data['crop_recommendation']['confidence'],
        }));
    if (list.length > 20) list.removeLast();
    await prefs.setStringList('history', list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(children: [
          const _AgroLogo(size: 28),
          const SizedBox(width: 10),
          const Text('AgroWise',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistoryPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Your Location & Weather'),
              const SizedBox(height: 12),

              // City input row
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtrl,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: _fetchWeatherByCity,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Enter city name (e.g. Udupi)',
                      prefixIcon: const Icon(Icons.location_city_outlined,
                          color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primary.withOpacity(0.3))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primary.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loadingWeather
                        ? null
                        : () => _fetchWeatherByCity(_cityCtrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: _loadingWeather
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search_rounded, size: 22),
                  ),
                ),
              ]),
              const SizedBox(height: 10),

              // Quick city chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickCities
                    .map((city) => GestureDetector(
                          onTap: () {
                            _cityCtrl.text = city;
                            _fetchWeatherByCity(city);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.25)),
                            ),
                            child: Text(city,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),

              _WeatherCard(
                weather: _weather,
                loading: _loadingWeather,
                error: _weatherError,
                onRetry: () => _fetchWeatherByCity(_cityCtrl.text),
              ),
              const SizedBox(height: 24),

              _SectionLabel(
                  icon: Icons.science_outlined, label: 'Soil Nutrients'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _SoilField(
                        ctrl: _nCtrl,
                        label: 'Nitrogen (N)',
                        hint: '0–140',
                        color: const Color(0xFF388E3C))),
                const SizedBox(width: 10),
                Expanded(
                    child: _SoilField(
                        ctrl: _pCtrl,
                        label: 'Phosphorus (P)',
                        hint: '0–145',
                        color: const Color(0xFF1565C0))),
                const SizedBox(width: 10),
                Expanded(
                    child: _SoilField(
                        ctrl: _kCtrl,
                        label: 'Potassium (K)',
                        hint: '0–205',
                        color: const Color(0xFFF57F17))),
              ]),
              const SizedBox(height: 12),
              _SoilField(
                ctrl: _phCtrl,
                label: 'pH Level',
                hint: '0–14',
                color: AppColors.soil,
                isDecimal: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final d = double.tryParse(v);
                  if (d == null || d < 0 || d > 14) return 'Enter 0–14';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _SectionLabel(icon: Icons.layers_outlined, label: 'Soil Type'),
              const SizedBox(height: 12),
              _SoilTypeSelector(
                selected: _soilType,
                options: _soilTypes,
                onChanged: (v) => setState(() => _soilType = v),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loadingResult ? null : _getRecommendation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: _loadingResult
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco_rounded, size: 22),
                            SizedBox(width: 10),
                            Text('Get Recommendation',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAGE 3 — RESULT
// ═══════════════════════════════════════════════════════════
class ResultPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const ResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final crop = data['crop_recommendation'];
    final fert = data['fertilizer_recommendation'];
    final loc = data['location'];
    final wthr = data['weather'];
    final soil = data['soil'];
    final top3 =
        List<Map<String, dynamic>>.from(crop['top_3_alternatives'] ?? []);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Recommendation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BUG 2 FIXED: use correct keys temperature_c and humidity_percent from backend
            _InfoChipRow(
              city: loc['city'],
              country: loc['country'],
              temp: (wthr['temperature_c'] as num).toDouble(),
              humidity: (wthr['humidity_percent'] as num).toDouble(),
            ),
            const SizedBox(height: 20),

            // Crop card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('🌾', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      const Text('Recommended Crop',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    Text(crop['recommended_crop'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${crop['confidence']}% confidence',
                          style: const TextStyle(
                              color: AppColors.accentLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      _CropStat(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Season',
                          value: crop['season']),
                      _CropStat(
                          icon: Icons.schedule_outlined,
                          label: 'Duration',
                          value: crop['duration']),
                      _CropStat(
                          icon: Icons.water_drop_outlined,
                          label: 'Water',
                          value: crop['water_requirement']),
                    ]),
                  ]),
            ),
            const SizedBox(height: 16),

            // Fertilizer card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B4F00), Color(0xFFF79C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.gold.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('🧪', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      const Text('Recommended Fertilizer',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    Text(fert['fertilizer_name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800)),
                    Text(fert['full_name'],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('NPK  ${fert['npk_ratio']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 12),
                    Text(fert['usage_tip'],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.5)),
                  ]),
            ),
            const SizedBox(height: 16),

            _SoilSummaryCard(soil: soil),
            const SizedBox(height: 16),

            if (top3.isNotEmpty) ...[
              _SectionLabel(
                  icon: Icons.format_list_numbered,
                  label: 'Top 3 Alternatives'),
              const SizedBox(height: 12),
              ...top3.map((c) => _AlternativeTile(crop: c)),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAGE 4 — HISTORY
// ═══════════════════════════════════════════════════════════
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('history') ?? [];
    setState(() {
      _history =
          list.map((e) => json.decode(e) as Map<String, dynamic>).toList();
      _loading = false;
    });
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    setState(() => _history = []);
  }

  String _fmt(String iso) {
    final d = DateTime.parse(iso).toLocal();
    return '${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text('Delete all saved recommendations?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (ok == true) _clear();
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _history.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_edu_outlined,
                        size: 72, color: AppColors.textMuted.withOpacity(0.35)),
                    const SizedBox(height: 16),
                    const Text('No history yet',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Your recommendations will appear here',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  ],
                ))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final e = _history[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                              child:
                                  Text('🌾', style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e['crop'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.textDark)),
                                Text('${e['confidence']}%',
                                    style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Fertilizer: ${e['fertilizer']}',
                                style: const TextStyle(
                                    color: AppColors.soil,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text(e['city'] ?? '',
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12)),
                              const Spacer(),
                              Text(_fmt(e['date'] ?? ''),
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11)),
                            ]),
                          ],
                        )),
                      ]),
                    );
                  },
                ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════

class _AgroLogo extends StatelessWidget {
  final double size;
  const _AgroLogo({required this.size});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * .5, h * .9)
        ..quadraticBezierTo(w * .48, h * .6, w * .5, h * .3),
      Paint()
        ..color = const Color(0xFF2E7D32)
        ..strokeWidth = w * .08
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .5, h * .55)
        ..quadraticBezierTo(w * .2, h * .35, w * .08, h * .25)
        ..quadraticBezierTo(w * .28, h * .5, w * .5, h * .55)
        ..close(),
      Paint()
        ..color = const Color(0xFF56AB2F)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .5, h * .45)
        ..quadraticBezierTo(w * .8, h * .25, w * .92, h * .15)
        ..quadraticBezierTo(w * .72, h * .42, w * .5, h * .45)
        ..close(),
      Paint()
        ..color = const Color(0xFF2ECC71)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
        Offset(w * .78, h * .22),
        w * .1,
        Paint()
          ..color = const Color(0xFFF79C00)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()
        ..moveTo(w * .5, h * .3)
        ..quadraticBezierTo(w * .32, h * .18, w * .25, h * .08)
        ..quadraticBezierTo(w * .42, h * .22, w * .5, h * .3)
        ..close(),
      Paint()
        ..color = const Color(0xFF56AB2F)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .5, h * .28)
        ..quadraticBezierTo(w * .65, h * .15, w * .7, h * .06)
        ..quadraticBezierTo(w * .58, h * .2, w * .5, h * .28)
        ..close(),
      Paint()
        ..color = const Color(0xFF2ECC71)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _WeatherCard extends StatelessWidget {
  final Map<String, dynamic>? weather;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  const _WeatherCard(
      {required this.weather,
      required this.loading,
      required this.error,
      required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (!loading && weather == null && error == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: const Row(children: [
          Icon(Icons.cloud_outlined, color: AppColors.textMuted, size: 22),
          SizedBox(width: 10),
          Text('Enter your city above to load weather',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: loading
          ? const Row(children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white54)),
              SizedBox(width: 10),
              Text('Fetching weather...',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ])
          : error != null
              ? Row(children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(error!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13))),
                  GestureDetector(
                    onTap: onRetry,
                    child: const Text('Retry',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline)),
                  ),
                ])
              : Row(children: [
                  const Text('🌤️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${weather!['city']}, ${weather!['country']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      Text(weather!['weather_description'] ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  )),
                  _WStat(
                      value: '${weather!['temperature']}°C',
                      icon: Icons.thermostat_outlined),
                  const SizedBox(width: 16),
                  _WStat(
                      value: '${weather!['humidity']}%',
                      icon: Icons.water_drop_outlined),
                ]),
    );
  }
}

class _WStat extends StatelessWidget {
  final String value;
  final IconData icon;
  const _WStat({required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ]);
}

class _SoilField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final Color color;
  final bool isDecimal;
  final String? Function(String?)? validator;
  const _SoilField(
      {required this.ctrl,
      required this.label,
      required this.hint,
      required this.color,
      this.isDecimal = false,
      this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: color.withOpacity(0.06),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: validator ??
            (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (double.tryParse(v) == null) return 'Invalid';
              return null;
            },
      );
}

class _SoilTypeSelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SoilTypeSelector(
      {required this.selected, required this.options, required this.onChanged});
  static const Map<String, Color> _clr = {
    'Black': Color(0xFF263238),
    'Clayey': Color(0xFF795548),
    'Loamy': Color(0xFF558B2F),
    'Red': Color(0xFFC62828),
    'Sandy': Color(0xFFF9A825),
  };
  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((s) {
          final sel = s == selected;
          final c = _clr[s] ?? AppColors.primary;
          return GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? c : c.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: c.withOpacity(sel ? 1 : 0.3), width: 1.5),
              ),
              child: Text(s,
                  style: TextStyle(
                      color: sel ? Colors.white : c,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          );
        }).toList(),
      );
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textDark)),
      ]);
}

class _CropStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _CropStat(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
            textAlign: TextAlign.center),
      ]));
}

class _InfoChipRow extends StatelessWidget {
  final String city, country;
  final double temp, humidity;
  const _InfoChipRow(
      {required this.city,
      required this.country,
      required this.temp,
      required this.humidity});
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 8, children: [
        _Chip(
            icon: Icons.location_on_outlined,
            label: '$city, $country',
            color: AppColors.primary),
        _Chip(
            icon: Icons.thermostat_outlined,
            label: '${temp}°C',
            color: const Color(0xFFE65100)),
        _Chip(
            icon: Icons.water_drop_outlined,
            label: '$humidity%',
            color: const Color(0xFF1565C0)),
      ]);
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _SoilSummaryCard extends StatelessWidget {
  final Map<String, dynamic> soil;
  const _SoilSummaryCard({required this.soil});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Text('🪱', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Soil Summary',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark)),
          ]),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _SoilVal(
                label: 'N',
                value: '${soil['nitrogen']}',
                color: const Color(0xFF388E3C)),
            _SoilVal(
                label: 'P',
                value: '${soil['phosphorus']}',
                color: const Color(0xFF1565C0)),
            _SoilVal(
                label: 'K',
                value: '${soil['potassium']}',
                color: const Color(0xFFF57F17)),
            _SoilVal(
                label: 'pH', value: '${soil['ph']}', color: AppColors.soil),
            _SoilVal(
                label: 'Soil',
                value: soil['soil_type'],
                color: AppColors.primary),
          ]),
        ]),
      );
}

class _SoilVal extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SoilVal(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ]);
}

class _AlternativeTile extends StatelessWidget {
  final Map<String, dynamic> crop;
  const _AlternativeTile({required this.crop});
  @override
  Widget build(BuildContext context) {
    final conf = (crop['confidence'] as num).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        const Text('🌱', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
            child: Text((crop['crop'] as String).capitalize(),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14))),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: conf / 100,
              backgroundColor: AppColors.accent.withOpacity(0.15),
              color: AppColors.accent,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$conf%',
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

extension StrExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
