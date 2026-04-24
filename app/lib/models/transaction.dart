import 'package:flutter/material.dart';

enum TxType { income, expense }

enum TxCategory {
  salary, freelance, investment, sales, rental,
  food, transport, housing, health, education,
  entertainment, shopping, taxes, payroll, others,
}

extension TxCategoryX on TxCategory {
  String get label => switch (this) {
    TxCategory.salary        => 'Salário',
    TxCategory.freelance     => 'Freelance',
    TxCategory.investment    => 'Investimentos',
    TxCategory.sales         => 'Vendas',
    TxCategory.rental        => 'Aluguel receb.',
    TxCategory.food          => 'Alimentação',
    TxCategory.transport     => 'Transporte',
    TxCategory.housing       => 'Moradia',
    TxCategory.health        => 'Saúde',
    TxCategory.education     => 'Educação',
    TxCategory.entertainment => 'Lazer',
    TxCategory.shopping      => 'Compras',
    TxCategory.taxes         => 'Impostos',
    TxCategory.payroll       => 'Folha pgto.',
    TxCategory.others        => 'Outros',
  };

  IconData get icon => switch (this) {
    TxCategory.salary        => Icons.work_rounded,
    TxCategory.freelance     => Icons.laptop_rounded,
    TxCategory.investment    => Icons.trending_up_rounded,
    TxCategory.sales         => Icons.store_rounded,
    TxCategory.rental        => Icons.home_work_rounded,
    TxCategory.food          => Icons.restaurant_rounded,
    TxCategory.transport     => Icons.directions_car_rounded,
    TxCategory.housing       => Icons.home_rounded,
    TxCategory.health        => Icons.favorite_rounded,
    TxCategory.education     => Icons.school_rounded,
    TxCategory.entertainment => Icons.movie_rounded,
    TxCategory.shopping      => Icons.shopping_bag_rounded,
    TxCategory.taxes         => Icons.receipt_rounded,
    TxCategory.payroll       => Icons.people_rounded,
    TxCategory.others        => Icons.category_rounded,
  };

  Color get color => switch (this) {
    TxCategory.salary        => const Color(0xFF0EA5E9),
    TxCategory.freelance     => const Color(0xFF6366F1),
    TxCategory.investment    => const Color(0xFF10B981),
    TxCategory.sales         => const Color(0xFF06B6D4),
    TxCategory.rental        => const Color(0xFF3B82F6),
    TxCategory.food          => const Color(0xFFF59E0B),
    TxCategory.transport     => const Color(0xFF8B5CF6),
    TxCategory.housing       => const Color(0xFFEC4899),
    TxCategory.health        => const Color(0xFFEF4444),
    TxCategory.education     => const Color(0xFF14B8A6),
    TxCategory.entertainment => const Color(0xFFF97316),
    TxCategory.shopping      => const Color(0xFFA855F7),
    TxCategory.taxes         => const Color(0xFF64748B),
    TxCategory.payroll       => const Color(0xFFD97706),
    TxCategory.others        => const Color(0xFF6B7280),
  };
}

const incomeCategories = [
  TxCategory.salary,
  TxCategory.freelance,
  TxCategory.investment,
  TxCategory.sales,
  TxCategory.rental,
];

const expenseCategories = [
  TxCategory.food,
  TxCategory.transport,
  TxCategory.housing,
  TxCategory.health,
  TxCategory.education,
  TxCategory.entertainment,
  TxCategory.shopping,
  TxCategory.taxes,
  TxCategory.payroll,
  TxCategory.others,
];

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TxType type;
  final TxCategory category;
  final DateTime date;
  final String account;
  final String? note;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.account,
    this.note,
  });
}

// ─── Singleton store ──────────────────────────────────────────────────────────

class TransactionStore extends ChangeNotifier {
  static final TransactionStore _i = TransactionStore._();
  static TransactionStore get instance => _i;
  TransactionStore._() {
    _items = _seed();
  }

  late List<Transaction> _items;
  List<Transaction> get all => List.unmodifiable(_items);

  void add(Transaction tx) {
    _items.add(tx);
    _items.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<Transaction> forMonth(int y, int m) {
    final list = _items.where((t) => t.date.year == y && t.date.month == m).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double incomeForMonth(int y, int m) => forMonth(y, m)
      .where((t) => t.type == TxType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double expenseForMonth(int y, int m) => forMonth(y, m)
      .where((t) => t.type == TxType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  Map<TxCategory, double> expensesByCategory(int y, int m) {
    final map = <TxCategory, double>{};
    for (final t in forMonth(y, m).where((t) => t.type == TxType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }
}

// ─── Seed data ────────────────────────────────────────────────────────────────

List<Transaction> _seed() {
  final now = DateTime.now();
  final y = now.year;
  final m = now.month;
  return [
    Transaction(id: '1', title: 'Salário', amount: 8500, type: TxType.income,
        category: TxCategory.salary, date: DateTime(y, m, 5), account: 'PF'),
    Transaction(id: '2', title: 'Projeto freelance', amount: 2200, type: TxType.income,
        category: TxCategory.freelance, date: DateTime(y, m, 8), account: 'PF'),
    Transaction(id: '3', title: 'Faturamento empresa', amount: 12000, type: TxType.income,
        category: TxCategory.sales, date: DateTime(y, m, 10), account: 'PJ'),
    Transaction(id: '4', title: 'Aluguel apartamento', amount: 1800, type: TxType.expense,
        category: TxCategory.housing, date: DateTime(y, m, 1), account: 'PF'),
    Transaction(id: '5', title: 'Supermercado', amount: 650, type: TxType.expense,
        category: TxCategory.food, date: DateTime(y, m, 3), account: 'PF'),
    Transaction(id: '6', title: 'Uber / combustível', amount: 320, type: TxType.expense,
        category: TxCategory.transport, date: DateTime(y, m, 7), account: 'PF'),
    Transaction(id: '7', title: 'Plano de saúde', amount: 480, type: TxType.expense,
        category: TxCategory.health, date: DateTime(y, m, 5), account: 'PF'),
    Transaction(id: '8', title: 'Fornecedores', amount: 3200, type: TxType.expense,
        category: TxCategory.others, date: DateTime(y, m, 12), account: 'PJ'),
    Transaction(id: '9', title: 'Folha de pagamento', amount: 4500, type: TxType.expense,
        category: TxCategory.payroll, date: DateTime(y, m, 5), account: 'PJ'),
    Transaction(id: '10', title: 'Restaurante', amount: 180, type: TxType.expense,
        category: TxCategory.food, date: DateTime(y, m, 15), account: 'PF'),
    Transaction(id: '11', title: 'Netflix / streaming', amount: 85, type: TxType.expense,
        category: TxCategory.entertainment, date: DateTime(y, m, 10), account: 'PF'),
    Transaction(id: '12', title: 'Curso online', amount: 297, type: TxType.expense,
        category: TxCategory.education, date: DateTime(y, m, 18), account: 'PF'),
    Transaction(id: '13', title: 'DAS Simples Nacional', amount: 420, type: TxType.expense,
        category: TxCategory.taxes, date: DateTime(y, m, 20), account: 'PJ'),
  ];
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

const kMonthNames = ['', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio',
    'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

const kDayNames = ['', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez'];

String fmtBRL(double v) {
  final s = v.abs().toStringAsFixed(2).split('.');
  final integer = s[0];
  final buf = StringBuffer();
  for (var i = 0; i < integer.length; i++) {
    if (i > 0 && (integer.length - i) % 3 == 0) buf.write('.');
    buf.write(integer[i]);
  }
  return 'R\$ ${buf.toString()},${s[1]}';
}

String fmtMonth(DateTime d) => '${kMonthNames[d.month]} ${d.year}';

String fmtDateShort(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String fmtDateFull(DateTime d) => '${d.day} de ${kDayNames[d.month]}. de ${d.year}';

String fmtDateGroup(DateTime d) => '${d.day} de ${kMonthNames[d.month]}';
