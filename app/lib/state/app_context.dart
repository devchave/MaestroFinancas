import 'package:flutter/material.dart';
import '../models/finance.dart';
import '../models/transaction.dart';

enum _CtxKind { all, pf, company }

/// Contexto global do app — filtra dados exibidos em todas as telas.
///
/// Usuário escolhe entre:
/// - **Todos**: PF + todas as empresas (sem filtro)
/// - **PF**: apenas conta/transações pessoais
/// - **Empresa X**: apenas de uma PJ específica
///
/// As ferramentas consomem `AppContext.instance` via `ListenableBuilder`
/// e filtram via helpers `matchesAccount` / `matchesTransaction`.
class AppContext extends ChangeNotifier {
  static final AppContext _i = AppContext._();
  static AppContext get instance => _i;
  AppContext._();

  _CtxKind _kind = _CtxKind.all;
  String? _companyId;

  bool get isAll => _kind == _CtxKind.all;
  bool get isPF => _kind == _CtxKind.pf;
  bool get isCompany => _kind == _CtxKind.company;
  bool isSpecificCompany(String id) => isCompany && _companyId == id;
  String? get selectedCompanyId => _companyId;

  /// Rótulo amigável do contexto atual (p/ headers).
  String get label {
    if (isAll) return 'Todos';
    if (isPF) return 'Pessoa física';
    final c = CompanyStore.instance.byId(_companyId ?? '');
    return c?.fantasyName ?? 'Empresa';
  }

  /// Cor de destaque do contexto.
  Color get color {
    if (isAll) return const Color(0xFF64748B); // slate-500
    if (isPF) return const Color(0xFF0284C7);  // accent1-ish
    final c = CompanyStore.instance.byId(_companyId ?? '');
    return c?.color ?? const Color(0xFF64748B);
  }

  void setAll() {
    _kind = _CtxKind.all;
    _companyId = null;
    notifyListeners();
  }

  void setPF() {
    _kind = _CtxKind.pf;
    _companyId = null;
    notifyListeners();
  }

  void setCompany(String id) {
    _kind = _CtxKind.company;
    _companyId = id;
    notifyListeners();
  }

  /// Testa se uma conta faz parte do contexto atual.
  bool matchesAccount(Account a) {
    if (isAll) return true;
    if (isPF) return a.isPF;
    return a.companyId == _companyId;
  }

  /// Testa se uma transação faz parte do contexto atual.
  bool matchesTransaction(Transaction t) {
    final a = t.account;
    if (a == null) return isAll;
    return matchesAccount(a);
  }

  /// Lista filtrada de contas.
  List<Account> filterAccounts(List<Account> all) =>
      all.where(matchesAccount).toList();

  /// Lista filtrada de transações.
  List<Transaction> filterTransactions(List<Transaction> all) =>
      all.where(matchesTransaction).toList();
}
