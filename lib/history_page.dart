import 'package:flutter/material.dart';
import 'route_history.dart';
import 'app_locale.dart';

class HistoryPage extends StatelessWidget {
  final List<RouteHistory> history;
  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('Search History'), style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: history.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.history, size: 64, color: cs.onSurfaceVariant.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(L.t('No search history yet'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (_, i) {
                final h = history[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.my_location, size: 16, color: cs.primary), const SizedBox(width: 6),
                      Text(h.start, style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 14)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Icon(Icons.flag, size: 16, color: Colors.green), const SizedBox(width: 4),
                      Text(h.end, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('${h.distance} km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
                      const SizedBox(width: 8),
                      Text('• ${h.hops} ${L.t(h.hops == 1 ? 'stop' : 'stops')}', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      Text('• ${L.t('via')} ${h.path.length > 2 ? h.path.sublist(1, h.path.length - 1).join(', ') : '—'}',
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 4),
                    Text('${h.timestamp.hour}:${h.timestamp.minute.toString().padLeft(2, '0')} — ${h.timestamp.day}/${h.timestamp.month}/${h.timestamp.year}',
                        style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant.withOpacity(0.6))),
                  ]),
                );
              },
            ),
    );
  }
}