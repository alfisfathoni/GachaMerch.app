import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/cyber_loading.dart';
import '../theme.dart';

class WutheringTerminalPage extends StatefulWidget {
  const WutheringTerminalPage({super.key});

  @override
  State<WutheringTerminalPage> createState() => _WutheringTerminalPageState();
}

class _WutheringTerminalPageState extends State<WutheringTerminalPage> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    _fetchFuture = txProvider.fetchTransactions(
      token: auth.token,
      userId: auth.userId,
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day.toString().padLeft(2, '0')}-${months[dt.month - 1]}-${dt.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CyberLoading(label: 'DECRYPTING TRANSFERS...'),
          );
        }

        return Consumer<TransactionProvider>(
          builder: (context, txProvider, _) {
            if (txProvider.errorMessage.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'TERMINAL ERROR',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.redAccent,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        txProvider.errorMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('RETRY'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: AppTheme.darkBg,
                        ),
                        onPressed: () {
                          setState(() => _loadTransactions());
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            final transactions = txProvider.transactions;

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.accentColor.withOpacity(0.6),
                          AppTheme.primaryColor.withOpacity(0.3),
                        ],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'NO TRANSACTIONS YET',
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your purchase history will\nappear here after checkout.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.accentColor,
              backgroundColor: AppTheme.cardColor,
              onRefresh: () async => setState(() => _loadTransactions()),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: transactions.length,
                itemBuilder: (ctx, i) => _buildTransactionCard(transactions[i]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(AppTransaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.accentColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.containerBg.withOpacity(0.4),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentColor,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'TXN #${tx.id.toString().padLeft(5, '0')}',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // SYNCHRONIZED badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3B21),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF00FF85).withOpacity(0.6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF85).withOpacity(0.15),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          tx.status,
                          style: GoogleFonts.orbitron(
                            fontSize: 8.5,
                            color: const Color(0xFF00FF85),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.productName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _detailItem('QUANTITY', 'x${tx.quantity}', AppTheme.accentColor),
                          ),
                          Expanded(
                            child: _detailItem(
                              'TOTAL CREDITS',
                              'Rp ${tx.totalPrice.toStringAsFixed(0)}',
                              AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _detailItem('PLAYER UID', tx.uid, Colors.white70),
                          ),
                          Expanded(
                            child: _detailItem('SERVER GATEWAY', tx.server, Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Timestamp
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11, color: Colors.grey[500]),
                          const SizedBox(width: 5),
                          Text(
                            _formatDate(tx.createdAt),
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              color: Colors.grey[500],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 8,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 11,
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
