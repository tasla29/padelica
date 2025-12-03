import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Payments screen - Shows saved payment methods and transaction history
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  // Mock saved payment card
  final Map<String, dynamic> _savedCard = {
    'cardNumber': '**** **** **** 4242',
    'cardHolder': 'Marko Latas',
    'expiryDate': '12/25',
    'cardType': 'Visa',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Payment Card Section (Top Half)
          _buildPaymentCardSection(),

          // Transactions Section (Bottom Half)
          Expanded(
            child: _buildTransactionsSection(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.hotPink,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Vaša plaćanja',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPaymentCardSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardNavy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sačuvana kartica',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Navigate to edit payment card screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funkcionalnost za izmenu kartice - uskoro!'),
                      backgroundColor: AppColors.hotPink,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.hotPink,
                ),
                label: Text(
                  'Izmeni',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hotPink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Payment Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brightBlue,
                  AppColors.cardNavy.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepNavy.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Card Type Logo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _savedCard['cardType'],
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Chip Icon
                    Icon(
                      Icons.credit_card,
                      color: Colors.white.withOpacity(0.8),
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Card Number
                Text(
                  _savedCard['cardNumber'],
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Card Holder
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vlasnik kartice',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _savedCard['cardHolder'],
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Expiry Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Važi do',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _savedCard['expiryDate'],
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    // Mock transaction data
    final transactions = [
      {
        'id': 'TXN-001',
        'date': '18. Jan 2024',
        'time': '17:00',
        'description': 'Rezervacija - Teren 1',
        'amount': 3500,
        'type': 'outgoing',
        'status': 'completed',
      },
      {
        'id': 'TXN-002',
        'date': '15. Jan 2024',
        'time': '18:00',
        'description': 'Rezervacija - Teren 1',
        'amount': 2500,
        'type': 'outgoing',
        'status': 'completed',
      },
      {
        'id': 'TXN-003',
        'date': '12. Jan 2024',
        'time': '20:00',
        'description': 'Rezervacija - Teren 3',
        'amount': 3500,
        'type': 'outgoing',
        'status': 'completed',
      },
      {
        'id': 'TXN-004',
        'date': '10. Jan 2024',
        'time': '19:00',
        'description': 'Rezervacija - Teren 2',
        'amount': 4500,
        'type': 'outgoing',
        'status': 'completed',
      },
      {
        'id': 'TXN-005',
        'date': '8. Jan 2024',
        'time': '16:00',
        'description': 'Rezervacija - Teren 4',
        'amount': 2500,
        'type': 'outgoing',
        'status': 'completed',
      },
      {
        'id': 'TXN-006',
        'date': '5. Jan 2024',
        'time': '18:30',
        'description': 'Rezervacija - Teren 1',
        'amount': 3500,
        'type': 'outgoing',
        'status': 'completed',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            'Istorija transakcija',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? _buildEmptyTransactionsState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] as int;
    final isOutgoing = transaction['type'] == 'outgoing';
    final isCompleted = transaction['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isOutgoing
                  ? AppColors.hotPink.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
              color: isOutgoing ? AppColors.hotPink : Colors.green.shade300,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction['date'],
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction['time'],
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isOutgoing ? '-' : '+'}$amount RSD',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isOutgoing ? AppColors.hotPink : Colors.green.shade300,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCompleted ? 'Završeno' : 'U toku',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 24),
            Text(
              'Nema transakcija',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vaša istorija transakcija će se pojaviti ovde',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

