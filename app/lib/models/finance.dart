import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// Company — uma das empresas (PJ) do usuário
// ════════════════════════════════════════════════════════════════════════════

class Company {
  final String id;
  final String name;         // razão social
  final String fantasyName;  // nome fantasia
  final String cnpj;
  final TaxRegime regime;    // Simples, LP, LR, MEI
  final Color color;         // cor de identificação visual
  final bool active;

  const Company({
    required this.id,
    required this.name,
    required this.fantasyName,
    required this.cnpj,
    required this.regime,
    required this.color,
    this.active = true,
  });

  Company copyWith({
    String? name,
    String? fantasyName,
    String? cnpj,
    TaxRegime? regime,
    Color? color,
    bool? active,
  }) {
    return Company(
      id: id,
      name: name ?? this.name,
      fantasyName: fantasyName ?? this.fantasyName,
      cnpj: cnpj ?? this.cnpj,
      regime: regime ?? this.regime,
      color: color ?? this.color,
      active: active ?? this.active,
    );
  }
}

enum TaxRegime { mei, simples, lucroPresumido, lucroReal }

extension TaxRegimeX on TaxRegime {
  String get label => switch (this) {
        TaxRegime.mei => 'MEI',
        TaxRegime.simples => 'Simples Nacional',
        TaxRegime.lucroPresumido => 'Lucro Presumido',
        TaxRegime.lucroReal => 'Lucro Real',
      };
}

class CompanyStore extends ChangeNotifier {
  static final CompanyStore _i = CompanyStore._();
  static CompanyStore get instance => _i;
  CompanyStore._() {
    _items = _seedCompanies();
  }

  late List<Company> _items;
  List<Company> get all => List.unmodifiable(_items);
  List<Company> get active => _items.where((c) => c.active).toList();

  Company? byId(String id) =>
      _items.where((c) => c.id == id).firstOrNull;

  void add(Company c) {
    _items.add(c);
    notifyListeners();
  }

  void update(Company c) {
    final i = _items.indexWhere((x) => x.id == c.id);
    if (i >= 0) {
      _items[i] = c;
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}

List<Company> _seedCompanies() => [
      Company(
        id: 'c1',
        name: 'Chavemestre Soluções Ltda',
        fantasyName: 'Chavemestre',
        cnpj: '12.345.678/0001-99',
        regime: TaxRegime.simples,
        color: const Color(0xFF0EA5E9),
      ),
      Company(
        id: 'c2',
        name: 'DevChave Consultoria ME',
        fantasyName: 'DevChave',
        cnpj: '98.765.432/0001-11',
        regime: TaxRegime.mei,
        color: const Color(0xFF8B5CF6),
      ),
    ];

// ════════════════════════════════════════════════════════════════════════════
// Account — conta bancária (PF ou vinculada a uma PJ)
// ════════════════════════════════════════════════════════════════════════════

class Account {
  final String id;
  final String name;         // "Nubank PF", "Itaú Chavemestre"
  final String bank;
  final String? companyId;   // null = PF
  final AccountType type;
  final double initialBalance;
  final Color color;

  const Account({
    required this.id,
    required this.name,
    required this.bank,
    this.companyId,
    required this.type,
    this.initialBalance = 0,
    required this.color,
  });

  bool get isPF => companyId == null;

  Account copyWith({
    String? name,
    String? bank,
    String? companyId,
    AccountType? type,
    double? initialBalance,
    Color? color,
    bool clearCompany = false,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      bank: bank ?? this.bank,
      companyId: clearCompany ? null : (companyId ?? this.companyId),
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      color: color ?? this.color,
    );
  }
}

enum AccountType { checking, savings, digital, investment, cash }

extension AccountTypeX on AccountType {
  String get label => switch (this) {
        AccountType.checking => 'Corrente',
        AccountType.savings => 'Poupança',
        AccountType.digital => 'Digital',
        AccountType.investment => 'Investimentos',
        AccountType.cash => 'Dinheiro',
      };

  IconData get icon => switch (this) {
        AccountType.checking => Icons.account_balance_rounded,
        AccountType.savings => Icons.savings_rounded,
        AccountType.digital => Icons.smartphone_rounded,
        AccountType.investment => Icons.trending_up_rounded,
        AccountType.cash => Icons.payments_rounded,
      };
}

class AccountStore extends ChangeNotifier {
  static final AccountStore _i = AccountStore._();
  static AccountStore get instance => _i;
  AccountStore._() {
    _items = _seedAccounts();
  }

  late List<Account> _items;
  List<Account> get all => List.unmodifiable(_items);

  List<Account> pfAccounts() =>
      _items.where((a) => a.isPF).toList();

  List<Account> forCompany(String companyId) =>
      _items.where((a) => a.companyId == companyId).toList();

  Account? byId(String id) =>
      _items.where((a) => a.id == id).firstOrNull;

  void add(Account a) {
    _items.add(a);
    notifyListeners();
  }

  void update(Account a) {
    final i = _items.indexWhere((x) => x.id == a.id);
    if (i >= 0) {
      _items[i] = a;
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}

List<Account> _seedAccounts() => [
      // PF
      Account(
        id: 'a1',
        name: 'Nubank',
        bank: 'Nubank',
        type: AccountType.digital,
        initialBalance: 8500,
        color: const Color(0xFF8A05BE),
      ),
      Account(
        id: 'a2',
        name: 'Itaú PF',
        bank: 'Itaú',
        type: AccountType.checking,
        initialBalance: 12300,
        color: const Color(0xFFEC7000),
      ),
      Account(
        id: 'a3',
        name: 'Inter Poupança',
        bank: 'Inter',
        type: AccountType.savings,
        initialBalance: 1300,
        color: const Color(0xFFFF7A00),
      ),
      // PJ c1 (Chavemestre)
      Account(
        id: 'a4',
        name: 'Itaú Chavemestre',
        bank: 'Itaú',
        companyId: 'c1',
        type: AccountType.checking,
        initialBalance: 22000,
        color: const Color(0xFFEC7000),
      ),
      Account(
        id: 'a5',
        name: 'BTG CDB Chavemestre',
        bank: 'BTG Pactual',
        companyId: 'c1',
        type: AccountType.investment,
        initialBalance: 4220,
        color: const Color(0xFF1A1A1A),
      ),
      // PJ c2 (DevChave)
      Account(
        id: 'a6',
        name: 'Inter DevChave',
        bank: 'Inter',
        companyId: 'c2',
        type: AccountType.digital,
        initialBalance: 0,
        color: const Color(0xFFFF7A00),
      ),
    ];

// ════════════════════════════════════════════════════════════════════════════
// Card — cartão de crédito/débito vinculado a uma conta
// ════════════════════════════════════════════════════════════════════════════

class PaymentCard {
  final String id;
  final String name;
  final String accountId;    // conta responsável pela fatura
  final CardBrand brand;
  final CardType type;
  final double limit;
  final int closingDay;      // dia de fechamento da fatura
  final int dueDay;          // dia de vencimento

  const PaymentCard({
    required this.id,
    required this.name,
    required this.accountId,
    required this.brand,
    required this.type,
    this.limit = 0,
    required this.closingDay,
    required this.dueDay,
  });

  PaymentCard copyWith({
    String? name,
    String? accountId,
    CardBrand? brand,
    CardType? type,
    double? limit,
    int? closingDay,
    int? dueDay,
  }) {
    return PaymentCard(
      id: id,
      name: name ?? this.name,
      accountId: accountId ?? this.accountId,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      limit: limit ?? this.limit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
    );
  }
}

enum CardBrand { visa, mastercard, elo, amex, hipercard, other }

extension CardBrandX on CardBrand {
  String get label => switch (this) {
        CardBrand.visa => 'Visa',
        CardBrand.mastercard => 'Mastercard',
        CardBrand.elo => 'Elo',
        CardBrand.amex => 'Amex',
        CardBrand.hipercard => 'Hipercard',
        CardBrand.other => 'Outra',
      };
}

enum CardType { credit, debit, multiple }

extension CardTypeX on CardType {
  String get label => switch (this) {
        CardType.credit => 'Crédito',
        CardType.debit => 'Débito',
        CardType.multiple => 'Múltiplo',
      };

  IconData get icon => switch (this) {
        CardType.credit => Icons.credit_card_rounded,
        CardType.debit => Icons.payment_rounded,
        CardType.multiple => Icons.credit_card_rounded,
      };
}

class CardStore extends ChangeNotifier {
  static final CardStore _i = CardStore._();
  static CardStore get instance => _i;
  CardStore._() {
    _items = _seedCards();
  }

  late List<PaymentCard> _items;
  List<PaymentCard> get all => List.unmodifiable(_items);

  PaymentCard? byId(String id) =>
      _items.where((c) => c.id == id).firstOrNull;

  List<PaymentCard> forAccount(String accountId) =>
      _items.where((c) => c.accountId == accountId).toList();

  void add(PaymentCard c) {
    _items.add(c);
    notifyListeners();
  }

  void update(PaymentCard c) {
    final i = _items.indexWhere((x) => x.id == c.id);
    if (i >= 0) {
      _items[i] = c;
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}

List<PaymentCard> _seedCards() => [
      const PaymentCard(
        id: 'card1',
        name: 'Nubank Mastercard',
        accountId: 'a1',
        brand: CardBrand.mastercard,
        type: CardType.multiple,
        limit: 8000,
        closingDay: 15,
        dueDay: 22,
      ),
      const PaymentCard(
        id: 'card2',
        name: 'Itaú Personnalité Visa',
        accountId: 'a2',
        brand: CardBrand.visa,
        type: CardType.credit,
        limit: 15000,
        closingDay: 3,
        dueDay: 10,
      ),
      const PaymentCard(
        id: 'card3',
        name: 'Inter Mastercard PJ',
        accountId: 'a4',
        brand: CardBrand.mastercard,
        type: CardType.credit,
        limit: 20000,
        closingDay: 28,
        dueDay: 5,
      ),
    ];
