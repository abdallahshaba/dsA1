import 'package:flutter/material.dart';
import 'dijkstra.dart';
import 'app_locale.dart';

class RouteCostPage extends StatefulWidget {
  final RouteResult? result;
  final String start;
  final String end;
  const RouteCostPage({super.key, this.result, required this.start, required this.end});
  @override
  State<RouteCostPage> createState() => _RouteCostPageState();
}

class _RouteCostPageState extends State<RouteCostPage> {
  double _fuelConsumption = 8.0; // L/100km
  double _fuelPrice = 12.5; // EGP/L
  double _avgSpeed = 90.0; // km/h
  bool _calculated = false;

  double get _fuelNeeded => (widget.result!.distance * _fuelConsumption) / 100;
  double get _fuelCost => _fuelNeeded * _fuelPrice;
  double get _travelHours => widget.result!.distance / _avgSpeed;
  int get _hours => _travelHours.floor();
  int get _minutes => ((_travelHours - _hours) * 60).round();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('Route Cost Estimator'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: widget.result == null || !widget.result!.pathFound
          ? Center(child: Padding(padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(L.t('Please find a route first from the home page'), textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: cs.onSurfaceVariant)),
              ])))
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Route summary
                Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.tertiary]), borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    const Icon(Icons.directions_car, color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    Text(L.t('Route Summary'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${widget.start} → ${widget.end}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${widget.result!.distance} km • ${widget.result!.hops} ${L.t(widget.result!.hops == 1 ? 'stop' : 'stops')}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  ])),
                const SizedBox(height: 16),

                // Parameters
                Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(L.t('Fuel Consumption'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                    Row(children: [
                      Expanded(child: Slider(value: _fuelConsumption, min: 4, max: 20, divisions: 32,
                          onChanged: (v) => setState(() { _fuelConsumption = v; _calculated = false; }))),
                      SizedBox(width: 70, child: Text('${_fuelConsumption.toStringAsFixed(1)} ${L.t('L/100km')}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary))),
                    ]),
                    const SizedBox(height: 8),
                    Text(L.t('Fuel Price'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                    Row(children: [
                      Expanded(child: Slider(value: _fuelPrice, min: 5, max: 30, divisions: 50,
                          onChanged: (v) => setState(() { _fuelPrice = v; _calculated = false; }))),
                      SizedBox(width: 70, child: Text('${_fuelPrice.toStringAsFixed(1)} ${L.t('EGP/L')}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary))),
                    ]),
                    const SizedBox(height: 8),
                    Text(L.t('Average Speed'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                    Row(children: [
                      Expanded(child: Slider(value: _avgSpeed, min: 40, max: 140, divisions: 20,
                          onChanged: (v) => setState(() { _avgSpeed = v; _calculated = false; }))),
                      SizedBox(width: 70, child: Text('${_avgSpeed.toInt()} ${L.t('km/h')}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary))),
                    ]),
                  ])),
                const SizedBox(height: 12),

                ElevatedButton.icon(onPressed: () => setState(() => _calculated = true),
                    style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.calculate), label: Text(L.t('Calculate'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(height: 16),

                if (_calculated) ...[
                  // Results
                  Row(children: [
                    Expanded(child: _resultCard(Icons.local_gas_station, L.t('Fuel Needed'), '${_fuelNeeded.toStringAsFixed(1)} ${L.t('liters')}', Colors.orange, cs)),
                    const SizedBox(width: 10),
                    Expanded(child: _resultCard(Icons.attach_money, L.t('Estimated Fuel Cost'), '${_fuelCost.toStringAsFixed(0)} ${L.t('EGP')}', Colors.green, cs)),
                  ]),
                  const SizedBox(height: 10),
                  _resultCard(Icons.timer, L.t('Estimated Travel Time'), '$_hours ${L.t('hours')} $_minutes ${L.t('minutes')}', Colors.blue, cs),
                  const SizedBox(height: 12),

                  // Route path
                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(L.t('Route Details'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                      const SizedBox(height: 8),
                      Text(widget.result!.path.join(' → '), style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, height: 1.5)),
                    ])),
                ],
                const SizedBox(height: 20),
              ],
            )),
    );
  }

  Widget _resultCard(IconData icon, String label, String value, Color color, ColorScheme cs) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, color: color, size: 28), const SizedBox(height: 8),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant), textAlign: TextAlign.center),
    ]),
  );
}
