import 'package:flutter/material.dart';
import '../../../../../domain/models/order_model.dart';

class OrderTrackingStepper extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingStepper({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withAlpha(30)),
      ),
      child: Column(
        children: order.trackingSteps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          bool isLast = idx == order.trackingSteps.length - 1;

          return IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: step.isCompleted ? Colors.green : Colors.grey.withAlpha(50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: step.isCompleted ? Colors.green : Colors.grey.withAlpha(100),
                          width: 2,
                        ),
                      ),
                      child: step.isCompleted
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: step.isCompleted ? Colors.green : Colors.grey.withAlpha(50),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: step.isCompleted ? null : Colors.grey,
                          ),
                        ),
                        Text(
                          step.description,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        if (step.isCompleted)
                          Text(
                            '${step.timestamp.hour}:${step.timestamp.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
