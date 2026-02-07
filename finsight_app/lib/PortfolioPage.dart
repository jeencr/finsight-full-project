import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<dynamic> _portfolios = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  double _totalInvestment = 0;
  double _totalCurrentValue = 0;
  double _totalProfitLoss = 0;

  // FINSIGHT Colors
  final Color _primaryColor = const Color(0xFFEB1616);
  final Color _secondaryColor = const Color(0xFF191C24);
  final Color _darkColor = const Color(0xFF000000);
  final Color _lightColor = const Color(0xFF6C7293);

  @override
  void initState() {
    super.initState();
    _loadPortfolios();
  }

  Future<void> _loadPortfolios() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    int? lid = sh.getInt('lid');
    String? url = sh.getString('url');

    if (lid == null || url == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/get_user_portfolios/'),
        body: {'lid': lid.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _portfolios = data['portfolios'] ?? [];
          _calculateTotals();
          _isLoading = false;
          _isRefreshing = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      print('Error loading portfolios: $e');
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  void _calculateTotals() {
    double totalInvestment = 0;
    double totalCurrentValue = 0;

    for (var portfolio in _portfolios) {
      double currentPrice = portfolio['current_price']?.toDouble() ?? 0;
      double profitLoss = portfolio['profit_loss']?.toDouble() ?? 0;

      // Calculate invested value (current price - profit/loss)
      double investedValue = currentPrice - profitLoss;

      totalInvestment += investedValue;
      totalCurrentValue += currentPrice;
    }

    setState(() {
      _totalInvestment = totalInvestment;
      _totalCurrentValue = totalCurrentValue;
      _totalProfitLoss = totalCurrentValue - totalInvestment;
    });
  }

  Future<void> _refreshPortfolios() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadPortfolios();
  }

  Widget _buildPortfolioCard(Map<String, dynamic> portfolio) {
    double currentPrice = portfolio['current_price']?.toDouble() ?? 0;
    double profitLoss = portfolio['profit_loss']?.toDouble() ?? 0;
    double investedValue = currentPrice - profitLoss;
    double profitLossPercentage = investedValue != 0 ? (profitLoss / investedValue) * 100 : 0;

    bool isProfit = profitLoss >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lightColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name and Expert
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        portfolio['company']?.toString() ?? 'Unknown Company',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline, color: _lightColor, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Expert: ${portfolio['Expert']?.toString() ?? 'Not Assigned'}',
                              style: TextStyle(
                                color: _lightColor,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Profit/Loss Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isProfit ? Colors.green.withOpacity(0.1) : _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isProfit ? Colors.green : _primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${isProfit ? '+' : ''}${profitLossPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isProfit ? Colors.green : _primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price and Value Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: TextStyle(
                        color: _lightColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##0.00').format(currentPrice)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invested Value',
                      style: TextStyle(
                        color: _lightColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##0.00').format(investedValue)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Profit/Loss Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _darkColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profit/Loss',
                    style: TextStyle(
                      color: _lightColor,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '₹${NumberFormat('#,##0.00').format(profitLoss.abs())}',
                    style: TextStyle(
                      color: isProfit ? Colors.green : _primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Performance Indicator
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (investedValue > 0) ? (currentPrice / (investedValue * 1.5)) : 0,
              backgroundColor: _darkColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                isProfit ? Colors.green : _primaryColor,
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, Color valueColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: valueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: valueColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _lightColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkColor,
      appBar: AppBar(
        backgroundColor: _secondaryColor,
        elevation: 0,
        title: const Text(
          'My Portfolio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isRefreshing ? Icons.refresh : Icons.refresh_outlined,
              color: Colors.white,
            ),
            onPressed: _isRefreshing ? null : _refreshPortfolios,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryColor,
        backgroundColor: _secondaryColor,
        onRefresh: _refreshPortfolios,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primaryColor.withOpacity(0.1), _primaryColor.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.account_balance_wallet, color: _primaryColor, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Investment Portfolio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _portfolios.isEmpty
                                  ? 'Add investments to track your portfolio'
                                  : '${_portfolios.length} active investments',
                              style: TextStyle(
                                color: _lightColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Total Stats
                if (_portfolios.isNotEmpty) ...[
                  const Text(
                    'Portfolio Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          'Total Investment',
                          '₹${NumberFormat('#,##0.00').format(_totalInvestment)}',
                          Colors.blue,
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatsCard(
                          'Current Value',
                          '₹${NumberFormat('#,##0.00').format(_totalCurrentValue)}',
                          Colors.white,
                          Icons.account_balance,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildStatsCard(
                    'Total Profit/Loss',
                    '₹${NumberFormat('#,##0.00').format(_totalProfitLoss.abs())}',
                    _totalProfitLoss >= 0 ? Colors.green : _primaryColor,
                    _totalProfitLoss >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  ),

                  const SizedBox(height: 24),
                ],

                // Portfolio List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Investments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_portfolios.isNotEmpty)
                      Text(
                        '${_portfolios.length} holdings',
                        style: TextStyle(
                          color: _lightColor,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFFEB1616)),
                    ),
                  )
                else if (_portfolios.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: _secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: _lightColor, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'No Investments Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start investing to build your portfolio',
                          style: TextStyle(
                            color: _lightColor,
                            fontSize: 14,
                          ),
                            textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to investment page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Start Investing'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _portfolios
                        .map((portfolio) => _buildPortfolioCard(portfolio))
                        .toList(),
                  ),

                const SizedBox(height: 24),

                // Performance Chart Placeholder
                if (_portfolios.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Portfolio Performance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: _darkColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart, color: _lightColor, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'Performance chart would appear here',
                                  style: TextStyle(
                                    color: _lightColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Tips Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Portfolio Tip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Diversify your investments across sectors to minimize risk and maximize returns.',
                              style: TextStyle(
                                color: _lightColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}