import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monthly Report Entry',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MonthlyReportScreen(),
      },
    );
  }
}

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _DailyData {
  int day;
  String encroachment;
  String tlp;
  String wp;
  String rowPillarsDamaged;

  _DailyData({
    required this.day,
    this.encroachment = '',
    this.tlp = '',
    this.wp = '',
    this.rowPillarsDamaged = '',
  });
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final int daysInMonth = 31;
  late List<_DailyData> monthData;

  @override
  void initState() {
    super.initState();
    monthData = List.generate(daysInMonth, (index) => _DailyData(day: index + 1));
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Monthly Report'];
    excel.setDefaultSheet('Monthly Report');

    // Add headers
    List<String> headers = [
      'Date',
      'Encroachment in no.s',
      'No. TLP',
      'WP',
      'ROW Pillars damaged'
    ];
    
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // Add data
    for (var data in monthData) {
      List<CellValue> row = [
        TextCellValue(data.day.toString()),
        TextCellValue(data.encroachment),
        TextCellValue(data.tlp),
        TextCellValue(data.wp),
        TextCellValue(data.rowPillarsDamaged),
      ];
      sheetObject.appendRow(row);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      await FileSaver.instance.saveFile(
        name: 'Monthly_Report',
        bytes: Uint8List.fromList(fileBytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel file exported successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to Excel',
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return ListView.builder(
            itemCount: monthData.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isMobile 
                      ? _buildMobileRow(index)
                      : _buildDesktopRow(index),
                ),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportToExcel,
        icon: const Icon(Icons.table_chart),
        label: const Text('Export Excel'),
      ),
    );
  }

  Widget _buildMobileRow(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Day ${monthData[index].day}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildTextField('Encroachment (no.s)', (val) => monthData[index].encroachment = val, monthData[index].encroachment),
        const SizedBox(height: 8),
        _buildTextField('No. TLP', (val) => monthData[index].tlp = val, monthData[index].tlp),
        const SizedBox(height: 8),
        _buildTextField('WP', (val) => monthData[index].wp = val, monthData[index].wp),
        const SizedBox(height: 8),
        _buildTextField('ROW Pillars Damaged', (val) => monthData[index].rowPillarsDamaged = val, monthData[index].rowPillarsDamaged),
      ],
    );
  }

  Widget _buildDesktopRow(int index) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text('Day ${monthData[index].day}', style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 16),
        Expanded(child: _buildTextField('Encroachment (no.s)', (val) => monthData[index].encroachment = val, monthData[index].encroachment)),
        const SizedBox(width: 16),
        Expanded(child: _buildTextField('No. TLP', (val) => monthData[index].tlp = val, monthData[index].tlp)),
        const SizedBox(width: 16),
        Expanded(child: _buildTextField('WP', (val) => monthData[index].wp = val, monthData[index].wp)),
        const SizedBox(width: 16),
        Expanded(child: _buildTextField('ROW Pillars Damaged', (val) => monthData[index].rowPillarsDamaged = val, monthData[index].rowPillarsDamaged)),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, String initialValue) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: initialValue,
          selection: TextSelection.collapsed(offset: initialValue.length),
        ),
      ),
    );
  }
}
