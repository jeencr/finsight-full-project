import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  List<dynamic> _tips = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _assignedExpert = "Loading...";

  // FINSIGHT Colors
  final Color _primaryColor = const Color(0xFFEB1616);
  final Color _secondaryColor = const Color(0xFF191C24);
  final Color _darkColor = const Color(0xFF000000);
  final Color _lightColor = const Color(0xFF6C7293);

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
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
        Uri.parse('$url/view_tip_users/'),
        body: {'lid': lid.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tips = data['tips'] ?? [];
          if (_tips.isNotEmpty) {
            _assignedExpert = _tips.first['Expert'] ?? 'Your Expert';
          }
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
      print('Error loading tips: $e');
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshTips() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadTips();
  }

  Color _getTipColor(String tip) {
    switch (tip?.toLowerCase()) {
      case 'strong buy':
        return Colors.green;
      case 'buy':
        return Colors.lightGreen;
      case 'hold':
        return Colors.orange;
      case 'sell':
        return Colors.red;
      case 'strong sell':
        return Colors.redAccent;
      default:
        return _lightColor;
    }
  }

  IconData _getTipIcon(String tip) {
    switch (tip?.toLowerCase()) {
      case 'strong buy':
        return Icons.rocket_launch;
      case 'buy':
        return Icons.trending_up;
      case 'hold':
        return Icons.pause;
      case 'sell':
        return Icons.trending_down;
      case 'strong sell':
        return Icons.warning;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk?.toLowerCase()) {
      case 'high risk':
        return Colors.red;
      case 'medium risk':
        return Colors.orange;
      case 'low risk':
        return Colors.green;
      case 'safe investment':
        return Colors.blue;
      default:
        return _lightColor;
    }
  }

  String _getRiskLabel(String risk) {
    switch (risk?.toLowerCase()) {
      case 'high risk':
        return 'High Risk';
      case 'medium risk':
        return 'Medium Risk';
      case 'low risk':
        return 'Low Risk';
      case 'safe investment':
        return 'Safe';
      default:
        return risk ?? 'Unknown';
    }
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    String tipType = tip['tips'] ?? 'Not Specified';
    Color tipColor = _getTipColor(tipType);
    IconData tipIcon = _getTipIcon(tipType);

    String riskLevel = tip['recommendation'] ?? 'Not Specified';
    Color riskColor = _getRiskColor(riskLevel);
    String riskLabel = _getRiskLabel(riskLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lightColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Company and Tip Type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tipColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tipColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tipIcon, color: tipColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['company'] ?? 'Unknown Company',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['sector'] ?? 'Unknown Sector',
                        style: TextStyle(
                          color: _lightColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    // Tip Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tipColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tipColor, width: 1),
                      ),
                      child: Text(
                        tipType.toUpperCase(),
                        style: TextStyle(
                          color: tipColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Risk Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: riskColor, width: 1),
                      ),
                      child: Text(
                        riskLabel.toUpperCase(),
                        style: TextStyle(
                          color: riskColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expert Info
                Row(
                  children: [
                    Icon(Icons.person_outline, color: _lightColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Expert: ${tip['Expert'] ?? 'Not Specified'}',
                      style: TextStyle(
                        color: _lightColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tip Content
                const Text(
                  'Investment Recommendation:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tipType,
                  style: TextStyle(
                    color: tipColor,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Risk Assessment
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getRiskIcon(riskLevel),
                        color: riskColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Risk Level: ',
                      style: TextStyle(
                        color: _lightColor,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      riskLabel,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description (if available)
                if (tip['description'] != null && tip['description'].toString().isNotEmpty) ...[
                  const Text(
                    'Detailed Analysis:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip['description'].toString(),
                    style: TextStyle(
                      color: _lightColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _darkColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: _lightColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: View company details
                      print('View details for ${tip['company']}');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: _lightColor.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.info_outline, color: _lightColor, size: 18),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add to watchlist
                      print('Add ${tip['company']} to watchlist');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Watchlist'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(String risk) {
    switch (risk?.toLowerCase()) {
      case 'high risk':
        return Icons.warning;
      case 'medium risk':
        return Icons.timeline;
      case 'low risk':
        return Icons.check_circle_outline;
      case 'safe investment':
        return Icons.security;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline, color: _lightColor, size: 64),
          const SizedBox(height: 24),
          const Text(
            'No Investment Tips Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your assigned expert will provide personalized investment tips soon.',
            style: TextStyle(
              color: _lightColor,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _refreshTips,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh Tips'),
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
          'Expert Tips',
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
            onPressed: _isRefreshing ? null : _refreshTips,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement filter
              print('Filter tips');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryColor,
        backgroundColor: _secondaryColor,
        onRefresh: _refreshTips,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expert Info Card
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
                        child: Icon(Icons.lightbulb, color: _primaryColor, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personalized Tips',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'From: $_assignedExpert',
                              style: TextStyle(
                                color: _lightColor,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_tips.isNotEmpty)
                              Text(
                                '${_tips.length} investment recommendations',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tip Type Legend
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Investment Action Legend',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildLegendItem('Strong Buy', Colors.green),
                          _buildLegendItem('Buy', Colors.lightGreen),
                          _buildLegendItem('Hold', Colors.orange),
                          _buildLegendItem('Sell', Colors.red),
                          _buildLegendItem('Strong Sell', Colors.redAccent),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Risk Level Legend',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildLegendItem('Safe', Colors.blue),
                          _buildLegendItem('Low Risk', Colors.green),
                          _buildLegendItem('Medium Risk', Colors.orange),
                          _buildLegendItem('High Risk', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tips List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Investment Recommendations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_tips.isNotEmpty)
                      Text(
                        '${_tips.length} total',
                        style: TextStyle(
                          color: _lightColor,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Loading State
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFFEB1616)),
                    ),
                  )
                else if (_tips.isEmpty)
                  _buildEmptyState()
                else
                  Column(
                    children: _tips
                        .map((tip) => _buildTipCard(tip))
                        .toList(),
                  ),

                const SizedBox(height: 24),

                // Statistics Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tips Statistics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_tips.isNotEmpty) ...[
                        _buildStatRow('Total Recommendations', _tips.length.toString()),
                        _buildStatRow('Strong Buy', _countTips('Strong Buy').toString()),
                        _buildStatRow('Buy', _countTips('Buy').toString()),
                        _buildStatRow('Hold', _countTips('Hold').toString()),
                        _buildStatRow('Sell', _countTips('Sell').toString()),
                        _buildStatRow('Strong Sell', _countTips('Strong Sell').toString()),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Risk Statistics
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Risk Distribution',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_tips.isNotEmpty) ...[
                        _buildStatRow('Safe Investments', _countRisk('Safe Investment').toString()),
                        _buildStatRow('Low Risk', _countRisk('Low Risk').toString()),
                        _buildStatRow('Medium Risk', _countRisk('Medium Risk').toString()),
                        _buildStatRow('High Risk', _countRisk('High Risk').toString()),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _darkColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _lightColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: _lightColor, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Investment tips are for informational purposes only. Please conduct your own research before investing.',
                          style: TextStyle(
                            color: _lightColor,
                            fontSize: 11,
                            height: 1.4,
                          ),
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

  int _countTips(String type) {
    return _tips.where((tip) => tip['tips']?.toLowerCase() == type.toLowerCase()).length;
  }

  int _countRisk(String risk) {
    return _tips.where((tip) => tip['recommendation']?.toLowerCase() == risk.toLowerCase()).length;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _lightColor,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}