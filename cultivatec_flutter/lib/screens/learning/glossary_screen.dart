import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/core/widgets/blue_header.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  static const List<Map<String, String>> _terms = [
    {
      'term': 'Arduino',
      'def': 'Plataforma de hardware y software de código abierto para crear proyectos electrónicos y robóticos.'
    },
    {
      'term': 'Sensor',
      'def':
          'Dispositivo que detecta cambios en el entorno (luz, temperatura, distancia, etc.) y los convierte en señales eléctricas.'
    },
    {
      'term': 'Actuador',
      'def': 'Componente que convierte energía eléctrica en movimiento o acción física (motor, LED, buzzer).'
    },
    {
      'term': 'LED',
      'def': 'Diodo Emisor de Luz. Componente que emite luz cuando pasa corriente eléctrica a través de él.'
    },
    {
      'term': 'Resistencia',
      'def': 'Componente que limita el flujo de corriente eléctrica en un circuito. Se mide en Ohmios (Ω).'
    },
    {
      'term': 'Circuito',
      'def': 'Camino cerrado por el que fluye la corriente eléctrica, conectando componentes electrónicos.'
    },
    {
      'term': 'Voltaje',
      'def': 'Fuerza que empuja la corriente eléctrica a través de un circuito. Se mide en Voltios (V).'
    },
    {'term': 'Corriente', 'def': 'Flujo de electrones a través de un conductor. Se mide en Amperios (A).'},
    {
      'term': 'Protoboard',
      'def': 'Placa de pruebas con orificios conectados internamente para armar circuitos sin soldar.'
    },
    {
      'term': 'PWM',
      'def': 'Modulación por Ancho de Pulso. Técnica para simular voltajes analógicos usando señales digitales.'
    },
    {
      'term': 'Servo Motor',
      'def': 'Motor que puede rotar a un ángulo específico (0°-180°) con precisión. Usado en brazos robóticos.'
    },
    {'term': 'Motor DC', 'def': 'Motor de corriente directa que gira continuamente. Usado para movimiento de ruedas.'},
    {
      'term': 'Ultrasonido',
      'def': 'Sensor que mide distancia emitiendo ondas sonoras y midiendo el tiempo de rebote (eco).'
    },
    {
      'term': 'Infrarrojo',
      'def': 'Sensor que detecta superficies claras/oscuras o presencia de objetos usando luz infrarroja.'
    },
    {
      'term': 'Variable',
      'def': 'Espacio en la memoria del programa que almacena un dato (número, texto, etc.) con un nombre.'
    },
    {'term': 'Función', 'def': 'Bloque de código con nombre que realiza una tarea específica y puede reutilizarse.'},
    {'term': 'Loop', 'def': 'Estructura que repite un bloque de código varias veces (for, while).'},
    {
      'term': 'Condicional',
      'def': 'Estructura if-else que ejecuta código diferente según una condición sea verdadera o falsa.'
    },
    {'term': 'Digital', 'def': 'Señal que solo tiene dos estados: HIGH (1/encendido) o LOW (0/apagado).'},
    {
      'term': 'Analógico',
      'def': 'Señal con valores continuos (0-1023 en Arduino). Usada para lecturas de sensores variables.'
    },
    {
      'term': 'Microcontrolador',
      'def': 'Chip programable que funciona como el "cerebro" del robot. Ejemplo: ATmega328 en Arduino UNO.'
    },
    {'term': 'Breadboard', 'def': 'Sinónimo de protoboard. Tablero de conexiones para prototipos electrónicos.'},
    {'term': 'GND', 'def': 'Ground (Tierra). Punto de referencia de voltaje 0V en un circuito.'},
    {'term': 'VCC', 'def': 'Voltaje de alimentación positivo del circuito (típicamente 5V o 3.3V en Arduino).'},
    {'term': 'Pin', 'def': 'Punto de conexión en una placa electrónica para enviar o recibir señales.'},
    {'term': 'Sketch', 'def': 'Nombre del programa en Arduino IDE. Contiene setup() y loop().'},
    {
      'term': 'IDE',
      'def': 'Entorno de Desarrollo Integrado. Software para escribir, compilar y subir código al Arduino.'
    },
    {'term': 'Compilar', 'def': 'Traducir código escrito por humanos a instrucciones que la máquina puede entender.'},
    {'term': 'Depurar', 'def': 'Proceso de encontrar y corregir errores (bugs) en un programa.'},
    {
      'term': 'Ley de Ohm',
      'def': 'V = I × R. Relación entre Voltaje, Corriente y Resistencia en un circuito eléctrico.'
    },
    {'term': 'Serie', 'def': 'Conexión donde los componentes están uno detrás de otro. La corriente pasa por todos.'},
    {'term': 'Paralelo', 'def': 'Conexión donde los componentes comparten los mismos puntos de entrada y salida.'},
    {
      'term': 'Robot',
      'def': 'Máquina programable capaz de sentir (sensores), pensar (procesador) y actuar (actuadores).'
    },
    {'term': 'IA', 'def': 'Inteligencia Artificial. Sistemas que pueden aprender y tomar decisiones basadas en datos.'},
    {'term': 'Algoritmo', 'def': 'Secuencia ordenada de pasos para resolver un problema. La receta del programador.'},
    {'term': 'Firmware', 'def': 'Software permanente grabado en un chip que controla el hardware directamente.'},
    {
      'term': 'Capacitor',
      'def': 'Componente que almacena energía eléctrica temporalmente. Usado para filtrar señales.'
    },
    {'term': 'Transistor', 'def': 'Componente semiconductor que amplifica o conmuta señales eléctricas.'},
    {'term': 'Diodo', 'def': 'Componente que permite el paso de corriente en una sola dirección.'},
    {
      'term': 'Potenciómetro',
      'def': 'Resistencia variable que se ajusta girando una perilla. Control de volumen, brillo, etc.'
    },
  ];

  List<Map<String, String>> get _filteredTerms {
    if (_filter.isEmpty) return _terms;
    return _terms
        .where((t) =>
            t['term']!.toLowerCase().contains(_filter.toLowerCase()) ||
            t['def']!.toLowerCase().contains(_filter.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTerms;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              BlueHeader(
                title: 'Glosario',
                subtitle: '${filtered.length} términos de robótica y electrónica',
                trailing: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                  ),
                ),
                mascot: const SizedBox(
                  width: 80,
                  height: 80,
                  child: WokovMascot(pose: WokovPose.curious, size: 80, floating: false, tappable: false),
                ),
                bottom: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: AppTheme.navyDeep, offset: Offset(0, 3), blurRadius: 0)],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 22),
                      hintText: 'Buscar término…',
                      hintStyle: TextStyle(color: AppTheme.textHint, fontWeight: FontWeight.w700),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Term list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final term = filtered[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            term['term']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            term['def']!,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Términos del glosario (término + definición) para otros ejercicios,
/// por ejemplo "Unir pares".
List<Map<String, String>> get glossaryTerms => _GlossaryScreenState._terms;
