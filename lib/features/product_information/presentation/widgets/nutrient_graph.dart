import 'package:flutter/material.dart';

class NutrientGraph extends StatefulWidget {
  const NutrientGraph({super.key, required this.title, required this.value});

  final String title;
  final double value;

  /// Determines if a nutrient value is in the healthy range (green/light green zones)
  /// Returns true if position < 0.45 (green or light green), false otherwise (orange or red)
  static bool isHealthy(double value) {
    if (value <= 0) return true;

    // Calculate ticks using the same logic as generateTicks
    double rawStep = value / 4; // numTicks - 1 = 5 - 1 = 4
    double step;

    if (value < 1.0) {
      // For small decimal values
      if (rawStep <= 0.1) {
        step = ((rawStep / 0.05).ceil()) * 0.05;
      } else if (rawStep <= 0.5) {
        step = ((rawStep / 0.1).ceil()) * 0.1;
      } else {
        step = ((rawStep / 0.2).ceil()) * 0.2;
      }
    } else {
      // For values >= 1
      if (rawStep <= 50) {
        step = ((rawStep / 10).ceil()) * 10;
      } else if (rawStep <= 200) {
        step = ((rawStep / 50).ceil()) * 50;
      } else {
        step = ((rawStep / 100).ceil()) * 100;
      }
    }

    List<double> ticks = List.generate(5, (i) => i * step);
    if (ticks.last < value) {
      ticks[ticks.length - 1] = step * 5;
    }

    double maxValue = ticks.last;
    double position = (value / maxValue).clamp(0.0, 1.0);

    // Return true if in green or light green zone (< 45%)
    return position < 0.45;
  }

  @override
  State<NutrientGraph> createState() => _NutrientGraphState();
}

class _NutrientGraphState extends State<NutrientGraph> {
  // Derive unit from title
  String _getUnitFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('calorie')) {
      return 'Cal';
    } else if (lowerTitle.contains('fat') ||
        lowerTitle.contains('protein') ||
        lowerTitle.contains('carb') ||
        lowerTitle.contains('salt') ||
        lowerTitle.contains('sugar')) {
      return 'g';
    } else if (lowerTitle.contains('sodium') ||
        lowerTitle.contains('cholesterol') ||
        lowerTitle.contains('potassium')) {
      return 'mg';
    }
    return ''; // Default to no unit
  }

  List<double> generateTicks(double value, {int numTicks = 5}) {
    if (value <= 0) return List.filled(numTicks, 0.0);

    // Step 1: Find a rough step
    double rawStep = value / (numTicks - 1);

    // Step 2: Round to nearest "nice number"
    double step;

    if (value < 1.0) {
      // For small decimal values (e.g., 0.5g salt)
      if (rawStep <= 0.1) {
        step = ((rawStep / 0.05).ceil()) * 0.05; // round to nearest 0.05
      } else if (rawStep <= 0.5) {
        step = ((rawStep / 0.1).ceil()) * 0.1; // round to nearest 0.1
      } else {
        step = ((rawStep / 0.2).ceil()) * 0.2; // round to nearest 0.2
      }
    } else {
      // For values >= 1 (existing logic)
      if (rawStep <= 50) {
        step = ((rawStep / 10).ceil()) * 10; // round to nearest 10
      } else if (rawStep <= 200) {
        step = ((rawStep / 50).ceil()) * 50; // round to nearest 50
      } else {
        step = ((rawStep / 100).ceil()) * 100; // round to nearest 100
      }
    }

    // Step 3: Generate ticks
    List<double> ticks = List.generate(numTicks, (i) => i * step);

    // Step 4: Make sure last tick >= value
    if (ticks.last < value) {
      ticks[ticks.length - 1] = step * numTicks;
    }

    return ticks;
  }

  @override
  Widget build(BuildContext context) {
    // Generate dynamic ticks based on nutrient value
    List<double> ticks = generateTicks(widget.value);
    double maxValue = ticks.last;

    // Calculate position on the bar (0-maxValue scale)
    double position = (widget.value / maxValue).clamp(0.0, 1.0);

    // Determine color based on position on the bar
    // The bar segments are: Green (0-20%), Light Green (20-45%), Orange (45-70%), Red (70-100%)
    Color indicatorColor;
    if (position < 0.20) {
      indicatorColor = const Color(0xFF10B981); // Green
    } else if (position < 0.45) {
      indicatorColor = const Color(0xFF84CC16); // Light green
    } else if (position < 0.70) {
      indicatorColor = const Color(0xFFF97316); // Orange
    } else {
      indicatorColor = const Color(0xFFEF4444); // Red
    }

    print(indicatorColor);

    return Row(
      children: [
        const Icon(Icons.local_fire_department_outlined),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 25,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Text(
                        '${widget.value.toString()} ${_getUnitFromTitle(widget.title)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      ClipOval(
                        child: Container(
                          height: 20,
                          width: 20,
                          color: indicatorColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Position indicator above the bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Get the actual width of the bar
                      double barWidth = constraints.maxWidth;
                      // Calculate arrow position (subtract half the icon width to center it)
                      double arrowLeft = (barWidth * position) - 16;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // The gradient bar
                          Container(
                            height: 8,
                            child: Row(
                              children: [
                                // Green segment (0-160)
                                Expanded(
                                  flex: 20, // 160/800 * 100 = 20%
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                // Light green segment (160-360)
                                Expanded(
                                  flex: 25, // (360-160)/800 * 100 = 25%
                                  child: Container(
                                    color: const Color(0xFF84CC16),
                                  ),
                                ),
                                // Orange segment (360-560)
                                Expanded(
                                  flex: 25, // (560-360)/800 * 100 = 25%
                                  child: Container(
                                    color: const Color(0xFFF97316),
                                  ),
                                ),
                                // Red segment (560-800)
                                Expanded(
                                  flex: 30, // (800-560)/800 * 100 = 30%
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Position indicator arrow
                          Positioned(
                            left: arrowLeft,
                            top: -30,
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: indicatorColor,
                              size: 32,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Scale labels - dynamically generated
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ticks
                        .map((tick) => _buildLabel(_formatTickLabel(tick)))
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTickLabel(double value) {
    // Remove trailing zeros and unnecessary decimal point
    // e.g., 1.0 -> "1", 0.50 -> "0.5", 0.25 -> "0.25"
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
