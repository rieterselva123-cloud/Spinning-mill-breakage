import 'package:flutter/material.dart';

void main() {
  runApp(const BreakageApp());
}

// =====================================================
// MACHINE MODEL
// =====================================================

class Machine {
  final int no;
  String eb100sh;
  String remarks;

  Machine({
    required this.no,
    this.eb100sh = '',
    this.remarks = '',
  });

  double get value => double.tryParse(eb100sh) ?? 0;

  String get status {
    if (eb100sh.trim().isEmpty) return 'NO DATA';
    if (value < 5.0) return 'LOW';
    if (value <= 8.0) return 'AVERAGE';
    return 'HIGH';
  }
}

// =====================================================
// APP
// =====================================================

class BreakageApp extends StatelessWidget {
  const BreakageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spinning Mill Breakage',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

// =====================================================
// HOME PAGE
// =====================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dateController = TextEditingController();
  final supervisorController = TextEditingController();

  String shift = 'A';
  String filter = 'ALL';

  late List<Machine> machines;

  late List<TextEditingController> ebControllers;
  late List<TextEditingController> remarkControllers;

  @override
  void initState() {
    super.initState();

    dateController.text = '31-08-2026';

    machines = List.generate(
      33,
      (i) => Machine(no: i + 1),
    );

    ebControllers = List.generate(
      33,
      (_) => TextEditingController(),
    );

    remarkControllers = List.generate(
      33,
      (_) => TextEditingController(),
    );

    // Demo data
    setMachine(
      3,
      '8.42',
      'High breakage',
    );

    setMachine(
      19,
      '9.42',
      'Breakage needs attention',
    );

    setMachine(
      26,
      '8.28',
      'High breakage',
    );
  }

  void setMachine(
    int no,
    String eb,
    String remark,
  ) {
    final index = no - 1;

    machines[index].eb100sh = eb;
    machines[index].remarks = remark;

    ebControllers[index].text = eb;
    remarkControllers[index].text = remark;
  }

  @override
  void dispose() {
    dateController.dispose();
    supervisorController.dispose();

    for (final c in ebControllers) {
      c.dispose();
    }

    for (final c in remarkControllers) {
      c.dispose();
    }

    super.dispose();
  }

  // =====================================================
  // FILTERED DATA
  // =====================================================

  List<Machine> get filteredMachines {
    final entered = machines.where(
      (m) => m.eb100sh.trim().isNotEmpty,
    );

    if (filter == 'ALL') {
      return entered.toList();
    }

    return entered
        .where((m) => m.status == filter)
        .toList();
  }

  int countStatus(String status) {
    return machines
        .where(
          (m) =>
              m.eb100sh.trim().isNotEmpty &&
              m.status == status,
        )
        .length;
  }

  Color statusColor(String status) {
    switch (status) {
      case 'HIGH':
        return Colors.red;
      case 'AVERAGE':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // MACHINE CARD
  // =====================================================

  Widget machineCard(int index) {
    final machine = machines[index];

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      statusColor(machine.status),
                  child: Text(
                    '${machine.no}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'MACHINE ${machine.no}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (machine.eb100sh.isNotEmpty)
                  Chip(
                    backgroundColor:
                        statusColor(machine.status),
                    label: Text(
                      machine.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // EB/100SH
            TextField(
              controller: ebControllers[index],
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'EB / 100SH',
                hintText: 'Example: 8.42',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              onChanged: (value) {
                machines[index].eb100sh = value;
                setState(() {});
              },
            ),

            const SizedBox(height: 10),

            // REMARKS
            TextField(
              controller: remarkControllers[index],
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                hintText: 'Type your remarks...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              onChanged: (value) {
                machines[index].remarks = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // FILTER BUTTON
  // =====================================================

  Widget filterButton(
    String title,
    String value,
    Color color,
  ) {
    final selected = filter == value;

    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selected ? color : Colors.grey.shade200,
            foregroundColor:
                selected ? Colors.white : Colors.black,
          ),
          onPressed: () {
            setState(() {
              filter = value;
            });
          },
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // REPORT
  // =====================================================

  void openReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportPage(
          machines: filteredMachines,
          filter: filter,
          date: dateController.text,
          shift: shift,
          supervisor: supervisorController.text,
        ),
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '33 MACHINE BREAKAGE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // DATE + SHIFT
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child:
                      DropdownButtonFormField<String>(
                    value: shift,
                    decoration:
                        const InputDecoration(
                      labelText: 'Shift',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'A',
                        child: Text('A Shift'),
                      ),
                      DropdownMenuItem(
                        value: 'B',
                        child: Text('B Shift'),
                      ),
                      DropdownMenuItem(
                        value: 'C',
                        child: Text('C Shift'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          shift = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // SUPERVISOR
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: TextField(
              controller: supervisorController,
              decoration: const InputDecoration(
                labelText: 'Supervisor',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // SUMMARY
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                summaryItem(
                  'HIGH',
                  countStatus('HIGH'),
                ),
                summaryItem(
                  'AVERAGE',
                  countStatus('AVERAGE'),
                ),
                summaryItem(
                  'LOW',
                  countStatus('LOW'),
                ),
              ],
            ),
          ),

          // FILTERS
          Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                filterButton(
                  'ALL',
                  'ALL',
                  Colors.blue,
                ),
                filterButton(
                  '🔴 HIGH',
                  'HIGH',
                  Colors.red,
                ),
                filterButton(
                  '🟡 AVG',
                  'AVERAGE',
                  Colors.orange,
                ),
                filterButton(
                  '🟢 LOW',
                  'LOW',
                  Colors.green,
                ),
              ],
            ),
          ),

          // MACHINES
          Expanded(
            child: ListView.builder(
              itemCount: machines.length,
              itemBuilder: (context, index) {
                return machineCard(index);
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: openReport,
        icon: const Icon(Icons.description),
        label: const Text('REPORT'),
      ),
    );
  }

  Widget summaryItem(
    String title,
    int count,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// REPORT PAGE
// =====================================================

class ReportPage extends StatelessWidget {
  final List<Machine> machines;
  final String filter;
  final String date;
  final String shift;
  final String supervisor;

  const ReportPage({
    super.key,
    required this.machines,
    required this.filter,
    required this.date,
    required this.shift,
    required this.supervisor,
  });

  Color statusColor(String status) {
    if (status == 'HIGH') return Colors.red;
    if (status == 'AVERAGE') return Colors.orange;
    return Colors.green;
  }

  double get average {
    if (machines.isEmpty) return 0;

    return machines
            .map((m) => m.value)
            .reduce((a, b) => a + b) /
        machines.length;
  }

  Machine? get highest {
    if (machines.isEmpty) return null;

    final list = [...machines];

    list.sort(
      (a, b) => b.value.compareTo(a.value),
    );

    return list.first;
  }

  Machine? get lowest {
    if (machines.isEmpty) return null;

    final list = [...machines];

    list.sort(
      (a, b) => a.value.compareTo(b.value),
    );

    return list.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,

      appBar: AppBar(
        title: const Text('BREAKAGE REPORT'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Container(
            width: 700,
            color: Colors.white,
            padding: const EdgeInsets.all(25),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'SPINNING MILL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'BREAKAGE ANALYSIS REPORT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: $date'),
                    Text('Shift: $shift'),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  'Supervisor: $supervisor',
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(10),
                  color: statusColor(
                    filter == 'ALL'
                        ? 'AVERAGE'
                        : filter,
                  ),
                  child: Text(
                    filter == 'ALL'
                        ? 'ALL MACHINES'
                        : '$filter BREAKAGE MACHINES',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // TABLE HEADER
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.black87,
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 55,
                        child: Text(
                          'MC',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          'EB/100SH',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'REMARKS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 75,
                        child: Text(
                          'STATUS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ROWS
                ...machines.map(
                  (m) => Container(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 55,
                          child: Text(
                            '${m.no}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 100,
                          child: Text(
                            m.value.toStringAsFixed(2),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            m.remarks.isEmpty
                                ? '-'
                                : m.remarks,
                          ),
                        ),

                        SizedBox(
                          width: 75,
                          child: Text(
                            m.status,
                            style: TextStyle(
                              color:
                                  statusColor(m.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // SUMMARY
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SUMMARY',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Total Machines: '
                        '${machines.length}',
                      ),

                      Text(
                        'Average EB/100SH: '
                        '${average.toStringAsFixed(2)}',
                      ),

                      if (highest != null)
                        Text(
                          'Highest: MC ${highest!.no} '
                          '- ${highest!.value.toStringAsFixed(2)}',
                        ),

                      if (lowest != null)
                        Text(
                          'Lowest: MC ${lowest!.no} '
                          '- ${lowest!.value.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'BREAKAGE STANDARD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text('🟢 LOW       < 5.00'),
                const Text('🟡 AVERAGE   5.00 - 8.00'),
                const Text('🔴 HIGH      > 8.00'),

                const SizedBox(height: 20),

                const Text(
                  '33 Machine Breakage Analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
