import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const GeoCapitalApp());
}

class GeoCapitalApp extends StatelessWidget {
  const GeoCapitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omni-Capital Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF38BDF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 1. TELA DE ABERTURA (SPLASH)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.public, size: 100, color: Colors.blueAccent),
            ),
            const SizedBox(height: 30),
            const Text(
              'OMNI-CAPITAL ENGINE',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text('Global Asset Intelligence & Risk Control', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text('Estabelecendo conexão segura com Oracle RAG...', style: TextStyle(fontSize: 12, color: Colors.white54, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. TELA DE LOGIN (Autenticação Google)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _fazendoLogin = false;

  void _simularLoginGoogle() {
    setState(() { _fazendoLogin = true; });
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text(
              "Acesso Restrito",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "Faça login com sua conta corporativa para acessar a Sala de Controle.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            _fazendoLogin
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.blueAccent),
                    label: const Text("Continuar com o Google Workspace", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _simularLoginGoogle,
                  ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. PAINEL PRINCIPAL COM MENU LATERAL
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _carregando = false;

  final List<Map<String, String>> ativosFinanceiros = [
    {"nome": "Petróleo Brent", "valor": "US\$ 96.28"},
    {"nome": "Soja (Saca)", "valor": "US\$ 1293.75"},
    {"nome": "ExxonMobil (EUA)", "valor": "US\$ 159.47"},
    {"nome": "Chevron (EUA)", "valor": "US\$ 208.60"},
    {"nome": "Shell (Europa)", "valor": "US\$ 92.95"},
    {"nome": "Vale (Brasil)", "valor": "US\$ 15.27"},
    {"nome": "Bunge (Agro)", "valor": "US\$ 118.71"},
  ];

  Future<void> _acionarMotorSoberania() async {
    setState(() { _carregando = true; });

    try {
      final url = Uri.parse('https://geocapital.sandlj.com.br/api/v1/validar-alerta');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id_operacao": "Navio Sonda BP (Pacifico)",
          "lat": 21.5,
          "lon": -120.0,
          "tipo_alerta": "FURACAO",
          "confianca_api_externa": 0.95,
          "temperatura_local": 28.0
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _mostrarAlertaExecutivo(data['status_soberania'], data['justificativa_motor']);
      } else {
        _mostrarAlertaExecutivo("ERRO DE API", "Código: ${response.statusCode}");
      }
    } catch (e) {
      _mostrarAlertaExecutivo("FALHA DE REDE", "Não foi possível contatar o servidor Ubuntu.");
    } finally {
      setState(() { _carregando = false; });
    }
  }

  void _mostrarAlertaExecutivo(String status, String justificativa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.shield, color: Colors.greenAccent),
            const SizedBox(width: 10),
            const Text("DECISÃO DA IA", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 16)),
            const SizedBox(height: 12),
            Text(justificativa, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("CIENTE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E293B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0F172A)),
              accountName: const Text("Leonardo (CEO)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text("leonardo@coreenergy.com", style: TextStyle(color: Colors.blueAccent)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF0F172A), size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.white),
              title: const Text('Painel Global', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text('Auditoria RAG (Oracle)', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Configurações do Firebase', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sair da Conta', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginScreen())),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('DASHBOARD GLOBAL', style: TextStyle(fontSize: 18)),
        actions: [
          _carregando
              ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Center(child: CircularProgressIndicator(color: Colors.redAccent)))
              : IconButton(
                  icon: const Icon(Icons.notifications_active, color: Colors.redAccent),
                  onPressed: _acionarMotorSoberania,
                  tooltip: 'Simular Alerta NASA',
                )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              itemCount: ativosFinanceiros.length,
              itemBuilder: (context, index) {
                final ativo = ativosFinanceiros[index];
                return Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    color: const Color(0xFF1E293B),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(ativo["nome"]!, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(ativo["valor"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(10.0, -30.0),
                initialZoom: 2.0,
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.geocapital.app'),
                MarkerLayer(
                  markers: [
                    _buildMarker(28.5, -90.0, Colors.greenAccent),
                    _buildMarker(57.0, 2.0, Colors.greenAccent),
                    _buildMarker(-23.8, -42.2, Colors.greenAccent),
                    _buildMarker(-6.0, -50.1, Colors.greenAccent),
                    _buildMarker(-12.5, -55.7, Colors.greenAccent),
                    _buildMarker(21.5, -120.0, Colors.orangeAccent),
                    Marker(point: const LatLng(21.5, -124.0), width: 40, height: 40, child: const Icon(Icons.cyclone, color: Colors.redAccent, size: 40)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(double lat, double lon, Color color) {
    return Marker(point: LatLng(lat, lon), width: 30, height: 30, child: Icon(Icons.location_on, color: color, size: 30));
  }
}