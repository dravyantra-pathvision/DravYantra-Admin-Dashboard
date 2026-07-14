import 'package:flutter/material.dart';
import '../../app/theme.dart';

class RecentTable<T> extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<T> items;
  final List<Widget> Function(T item) rowBuilder;
  final VoidCallback? onViewAll;

  const RecentTable({
    super.key,
    required this.title,
    required this.columns,
    required this.items,
    required this.rowBuilder,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All', style: TextStyle(color: AdminTheme.primaryLight)),
                  ),
              ],
            ),
          ),
          
          // Table
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text('No data available', style: TextStyle(color: AdminTheme.textMuted)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AdminTheme.surface),
                    headingTextStyle: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    dataTextStyle: const TextStyle(
                      color: AdminTheme.textPrimary,
                      fontSize: 14,
                    ),
                    dividerThickness: 1,
                    columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
                    rows: items.map((item) {
                      return DataRow(
                        cells: rowBuilder(item).map((widget) => DataCell(widget)).toList(),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
