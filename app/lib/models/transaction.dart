import 'package:flutter/material.dart';
import 'finance.dart';

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

// ─── Transaction ──────────────────────────────────────────────────────────────

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TxType type;
  final TxCategory category;
  final DateTime date;

  /// Conta bancária a que a transação pertence.
  final String accountId;

  /// Cartão usado (opcional — só faz sentido em despesas).
  final String? cardId;

  final String? note;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.accountId,
    this.cardId,
    this.note,
  });

  /// Objeto Account resolvido.
  Account? get account => AccountStore.instance.byId(accountId);

  /// "PF" ou "PJ" derivado da conta.
  String get kind => account?.isPF == true ? 'PF' : 'PJ';

  /// Nome da conta (fallback "?" se não existir).
  String get accountName => account?.name ?? '?';

  /// Cartão resolvido (null se não tiver).
  PaymentCard? get card => cardId == null ? null : CardStore.instance.byId(cardId!);

  Transaction copyWith({
    String? title,
    double? amount,
    TxType? type,
    TxCategory? category,
    DateTime? date,
    String? accountId,
    String? cardId,
    bool clearCard = false,
    String? note,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      cardId: clearCard ? null : (cardId ?? this.cardId),
      note: note ?? this.note,
    );
  }
}

// ─── Month summary ────────────────────────────────────────────────────────────

class MonthSummary {
  final DateTime month;
  final double income;
  final double expense;
  const MonthSummary(
      {required this.month, required this.income, required this.expense});
  double get balance => income - expense;
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

  Map<TxCategory, double> incomesByCategory(int y, int m) {
    final map = <TxCategory, double>{};
    for (final t in forMonth(y, m).where((t) => t.type == TxType.income)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  List<MonthSummary> monthlySeries({
    int lastMonths = 6,
    bool Function(Transaction)? filter,
  }) {
    final now = DateTime.now();
    return List.generate(lastMonths, (i) {
      final dt =
          DateTime(now.year, now.month - (lastMonths - 1 - i));
      var txs = forMonth(dt.year, dt.month);
      if (filter != null) txs = txs.where(filter).toList();
      final inc = txs
          .where((t) => t.type == TxType.income)
          .fold(0.0, (s, t) => s + t.amount);
      final exp = txs
          .where((t) => t.type == TxType.expense)
          .fold(0.0, (s, t) => s + t.amount);
      return MonthSummary(month: dt, income: inc, expense: exp);
    });
  }

  /// Movimentação líquida de uma conta até agora (income - expense).
  double netFlowForAccount(String accountId) {
    double net = 0;
    for (final t in _items.where((t) => t.accountId == accountId)) {
      net += t.type == TxType.income ? t.amount : -t.amount;
    }
    return net;
  }
}

// ─── Seed data ────────────────────────────────────────────────────────────────

List<Transaction> _seed() {
  final now = DateTime.now();
  final y = now.year;
  final m = now.month;

  // Helper: create a transaction with a month offset (0 = current, 1 = last, etc.)
  Transaction tx(
    String id,
    String title,
    double amount,
    TxType type,
    TxCategory cat,
    int mo,
    int day,
    String acc, {
    String? card,
  }) {
    return Transaction(
      id: id,
      title: title,
      amount: amount,
      type: type,
      category: cat,
      date: DateTime(y, m - mo, day),
      accountId: acc,
      cardId: card,
    );
  }

  return [
    // ── Mês atual ────────────────────────────────────────────────────────────
    // income: 8500 + 2200 + 12000 = 22700 | expense ≈ 11932
    tx('1',  'Salário',            8500,  TxType.income,  TxCategory.salary,        0, 5,  'a1'),
    tx('2',  'Projeto freelance',  2200,  TxType.income,  TxCategory.freelance,     0, 8,  'a2'),
    tx('3',  'Faturamento empresa',12000, TxType.income,  TxCategory.sales,         0, 10, 'a4'),
    tx('4',  'Aluguel apartamento',1800,  TxType.expense, TxCategory.housing,       0, 1,  'a2'),
    tx('5',  'Supermercado',       650,   TxType.expense, TxCategory.food,          0, 3,  'a1', card: 'card1'),
    tx('6',  'Uber / combustível', 320,   TxType.expense, TxCategory.transport,     0, 7,  'a1', card: 'card1'),
    tx('7',  'Plano de saúde',     480,   TxType.expense, TxCategory.health,        0, 5,  'a2'),
    tx('8',  'Fornecedores',       3200,  TxType.expense, TxCategory.others,        0, 12, 'a4', card: 'card3'),
    tx('9',  'Folha de pagamento', 4500,  TxType.expense, TxCategory.payroll,       0, 5,  'a4'),
    tx('10', 'Restaurante',        180,   TxType.expense, TxCategory.food,          0, 15, 'a1', card: 'card1'),
    tx('11', 'Netflix / streaming',85,    TxType.expense, TxCategory.entertainment, 0, 10, 'a1', card: 'card1'),
    tx('12', 'Curso online',       297,   TxType.expense, TxCategory.education,     0, 18, 'a2', card: 'card2'),
    tx('13', 'DAS Simples Nacional',420,  TxType.expense, TxCategory.taxes,         0, 20, 'a4'),

    // ── Mês -1 ───────────────────────────────────────────────────────────────
    // income: 8500 + 1800 + 11800 = 22100 | expense ≈ 11275
    tx('b1',  'Salário',            8500,  TxType.income,  TxCategory.salary,        1, 5,  'a1'),
    tx('b2',  'Projeto freelance',  1800,  TxType.income,  TxCategory.freelance,     1, 8,  'a2'),
    tx('b3',  'Faturamento empresa',11800, TxType.income,  TxCategory.sales,         1, 10, 'a4'),
    tx('b4',  'Aluguel apartamento',1800,  TxType.expense, TxCategory.housing,       1, 1,  'a2'),
    tx('b5',  'Supermercado',       560,   TxType.expense, TxCategory.food,          1, 3,  'a1', card: 'card1'),
    tx('b6',  'Uber / combustível', 290,   TxType.expense, TxCategory.transport,     1, 7,  'a1', card: 'card1'),
    tx('b7',  'Plano de saúde',     480,   TxType.expense, TxCategory.health,        1, 5,  'a2'),
    tx('b8',  'Fornecedores',       2800,  TxType.expense, TxCategory.others,        1, 12, 'a4', card: 'card3'),
    tx('b9',  'Folha de pagamento', 4500,  TxType.expense, TxCategory.payroll,       1, 5,  'a4'),
    tx('b10', 'Restaurante',        220,   TxType.expense, TxCategory.food,          1, 15, 'a1', card: 'card1'),
    tx('b11', 'Netflix / streaming',85,    TxType.expense, TxCategory.entertainment, 1, 10, 'a1', card: 'card1'),
    tx('b12', 'Curso online',       150,   TxType.expense, TxCategory.education,     1, 18, 'a2', card: 'card2'),
    tx('b13', 'DAS Simples Nacional',390,  TxType.expense, TxCategory.taxes,         1, 20, 'a4'),

    // ── Mês -2 ───────────────────────────────────────────────────────────────
    // income: 8200 + 2500 + 10500 = 21200 | expense ≈ 10807
    tx('c1',  'Salário',            8200,  TxType.income,  TxCategory.salary,        2, 5,  'a1'),
    tx('c2',  'Projeto freelance',  2500,  TxType.income,  TxCategory.freelance,     2, 8,  'a2'),
    tx('c3',  'Faturamento empresa',10500, TxType.income,  TxCategory.sales,         2, 10, 'a4'),
    tx('c4',  'Aluguel apartamento',1800,  TxType.expense, TxCategory.housing,       2, 1,  'a2'),
    tx('c5',  'Supermercado',       520,   TxType.expense, TxCategory.food,          2, 3,  'a1', card: 'card1'),
    tx('c6',  'Uber / combustível', 350,   TxType.expense, TxCategory.transport,     2, 7,  'a1', card: 'card1'),
    tx('c7',  'Plano de saúde',     480,   TxType.expense, TxCategory.health,        2, 5,  'a2'),
    tx('c8',  'Fornecedores',       2500,  TxType.expense, TxCategory.others,        2, 12, 'a4', card: 'card3'),
    tx('c9',  'Folha de pagamento', 4200,  TxType.expense, TxCategory.payroll,       2, 5,  'a4'),
    tx('c10', 'Restaurante',        200,   TxType.expense, TxCategory.food,          2, 15, 'a1', card: 'card1'),
    tx('c11', 'Netflix / streaming',110,   TxType.expense, TxCategory.entertainment, 2, 10, 'a1', card: 'card1'),
    tx('c12', 'Curso online',       297,   TxType.expense, TxCategory.education,     2, 18, 'a2', card: 'card2'),
    tx('c13', 'DAS Simples Nacional',350,  TxType.expense, TxCategory.taxes,         2, 20, 'a4'),

    // ── Mês -3 ───────────────────────────────────────────────────────────────
    // income: 8200 + 3200 + 9800 = 21200 | expense ≈ 10205
    tx('d1',  'Salário',            8200,  TxType.income,  TxCategory.salary,        3, 5,  'a1'),
    tx('d2',  'Projeto freelance',  3200,  TxType.income,  TxCategory.freelance,     3, 8,  'a2'),
    tx('d3',  'Faturamento empresa',9800,  TxType.income,  TxCategory.sales,         3, 10, 'a4'),
    tx('d4',  'Aluguel apartamento',1800,  TxType.expense, TxCategory.housing,       3, 1,  'a2'),
    tx('d5',  'Supermercado',       490,   TxType.expense, TxCategory.food,          3, 3,  'a1', card: 'card1'),
    tx('d6',  'Uber / combustível', 280,   TxType.expense, TxCategory.transport,     3, 7,  'a1', card: 'card1'),
    tx('d7',  'Plano de saúde',     480,   TxType.expense, TxCategory.health,        3, 5,  'a2'),
    tx('d8',  'Fornecedores',       2200,  TxType.expense, TxCategory.others,        3, 12, 'a4', card: 'card3'),
    tx('d9',  'Folha de pagamento', 4200,  TxType.expense, TxCategory.payroll,       3, 5,  'a4'),
    tx('d10', 'Restaurante',        200,   TxType.expense, TxCategory.food,          3, 15, 'a1', card: 'card1'),
    tx('d11', 'Netflix / streaming',85,    TxType.expense, TxCategory.entertainment, 3, 10, 'a1', card: 'card1'),
    tx('d12', 'Curso online',       150,   TxType.expense, TxCategory.education,     3, 18, 'a2', card: 'card2'),
    tx('d13', 'DAS Simples Nacional',320,  TxType.expense, TxCategory.taxes,         3, 20, 'a4'),

    // ── Mês -4 ───────────────────────────────────────────────────────────────
    // income: 8000 + 1200 + 9500 = 18700 | expense ≈ 9775
    tx('e1',  'Salário',            8000,  TxType.income,  TxCategory.salary,        4, 5,  'a1'),
    tx('e2',  'Projeto freelance',  1200,  TxType.income,  TxCategory.freelance,     4, 8,  'a2'),
    tx('e3',  'Faturamento empresa',9500,  TxType.income,  TxCategory.sales,         4, 10, 'a4'),
    tx('e4',  'Aluguel apartamento',1800,  TxType.expense, TxCategory.housing,       4, 1,  'a2'),
    tx('e5',  'Supermercado',       470,   TxType.expense, TxCategory.food,          4, 3,  'a1', card: 'card1'),
    tx('e6',  'Uber / combustível', 310,   TxType.expense, TxCategory.transport,     4, 7,  'a1', card: 'card1'),
    tx('e7',  'Plano de saúde',     480,   TxType.expense, TxCategory.health,        4, 5,  'a2'),
    tx('e8',  'Fornecedores',       2000,  TxType.expense, TxCategory.others,        4, 12, 'a4', card: 'card3'),
    tx('e9',  'Folha de pagamento', 4000,  TxType.expense, TxCategory.payroll,       4, 5,  'a4'),
    tx('e10', 'Restaurante',        190,   TxType.expense, TxCategory.food,          4, 15, 'a1', card: 'card1'),
    tx('e11', 'Netflix / streaming',85,    TxType.expense, TxCategory.entertainment, 4, 10, 'a1', card: 'card1'),
    tx('e12', 'Curso online',       150,   TxType.expense, TxCategory.education,     4, 18, 'a2', card: 'card2'),
    tx('e13', 'DAS Simples Nacional',290,  TxType.expense, TxCategory.taxes,         4, 20, 'a4'),

    // ── Mês -5 ───────────────────────────────────────────────────────────────
    // income: 8000 + 900 + 8500 = 17400 | expense ≈ 9515
    tx('f1',  'Salário',            8000,  TxType.income,  TxCategory.salary,        5, 5,  'a1'),
    tx('f2',  'Projeto freelance',  900,   TxType.income,  TxCategory.freelance,     5, 8,  'a2'),
    tx('f3',  'Faturamento empresa',8500,  TxType.income,  TxCategory.sales,         5, 10, 'a4'),
    tx('f4',  'Aluguel apartamento',1800,  TxType.expense, TxCategory.housing,       5, 1,  'a2'),
    tx('f5',  'Supermercado',       450,   TxType.expense, TxCategory.food,          5, 3,  'a1', card: 'card1'),
    tx('f6',  'Uber / combustível', 300,   TxType.expense, TxCategory.transport,     5, 7,  'a1', card: 'card1'),
    tx('f7',  'Plano de saúde',     480,   TxType.expense, TxCategory.health,        5, 5,  'a2'),
    tx('f8',  'Fornecedores',       1800,  TxType.expense, TxCategory.others,        5, 12, 'a4', card: 'card3'),
    tx('f9',  'Folha de pagamento', 4000,  TxType.expense, TxCategory.payroll,       5, 5,  'a4'),
    tx('f10', 'Restaurante',        190,   TxType.expense, TxCategory.food,          5, 15, 'a1', card: 'card1'),
    tx('f11', 'Netflix / streaming',85,    TxType.expense, TxCategory.entertainment, 5, 10, 'a1', card: 'card1'),
    tx('f12', 'Curso online',       150,   TxType.expense, TxCategory.education,     5, 18, 'a2', card: 'card2'),
    tx('f13', 'DAS Simples Nacional',260,  TxType.expense, TxCategory.taxes,         5, 20, 'a4'),
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
