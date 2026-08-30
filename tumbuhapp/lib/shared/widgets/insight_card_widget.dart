import 'package:flutter/material.dart';
import '../../core/constant/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../models/insight_model.dart';
import 'loading_widget.dart';

class InsightCard extends StatefulWidget {
  final String? insightTeks;
  final String? createdAt;
  final bool isLoading;
  final InsightStatus? status;
  final bool pollingTimedOut;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  const InsightCard({
    super.key,
    this.insightTeks,
    this.createdAt,
    this.isLoading = false,
    this.status,
    this.pollingTimedOut = false,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primarySurface),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────
          _buildHeader(),

          // ── Content ───────────────────────
          if (widget.errorMessage != null)
            _buildMessageState(
              icon: Icons.wifi_off_outlined,
              message: widget.errorMessage!,
              actionLabel: 'Coba lagi',
            )
          else if (widget.status == InsightStatus.failed)
            _buildMessageState(
              icon: Icons.error_outline,
              message: 'Insight belum dapat tersedia saat ini.',
              actionLabel: 'Periksa kembali',
            )
          else if (widget.status == InsightStatus.superseded)
            _buildMessageState(
              icon: Icons.history_outlined,
              message: 'AI Insight tidak dibuat untuk pengukuran historis '
                  'ini. Silakan lihat insight pada pengukuran terbaru.',
            )
          else if (widget.pollingTimedOut)
            _buildMessageState(
              icon: Icons.schedule_outlined,
              message: 'Analisis masih berlangsung lebih lama dari biasanya.',
              actionLabel: 'Periksa kembali',
            )
          else if (widget.isLoading ||
              widget.status == InsightStatus.pending ||
              widget.status == InsightStatus.processing)
            _buildLoadingState()
          else if (widget.insightTeks == null || widget.insightTeks!.isEmpty)
            _buildEmptyState()
          else
            _buildContent(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if (widget.createdAt != null)
                  Text(
                    FormatUtils.formatTanggal(widget.createdAt),
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
          // Expand/collapse button
          if (!widget.isLoading && widget.insightTeks != null)
            IconButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              icon: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  // ── Loading State ─────────────────────────────

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Sedang menganalisis data anak...',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
          SizedBox(height: 16),
          ShimmerCard(height: 16),
          SizedBox(height: 8),
          ShimmerCard(height: 16),
          SizedBox(height: 8),
          ShimmerCard(height: 16, width: 200),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Insight belum tersedia untuk pengukuran ini.',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String message,
    String? actionLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message, style: AppTextStyles.bodySecondary),
              ),
            ],
          ),
          if (widget.onRefresh != null && actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  // ── Content ───────────────────────────────────

  Widget _buildContent() {
    final sections = _parseSections(widget.insightTeks!);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview — tampil hanya jika tidak expanded
          if (sections.isNotEmpty && !_isExpanded)
            _buildPreview(sections.first),

          // Detail — tampil saat expanded
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),
            ...sections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              return _buildSection(section, index);
            }),
          ],

          // Toggle text
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'Sembunyikan' : 'Lihat selengkapnya',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Preview (2 baris pertama) ─────────────────

  Widget _buildPreview(Map<String, String> section) {
    return Text(
      section['content'] ?? '',
      style: AppTextStyles.body,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Section ───────────────────────────────────

  Widget _buildSection(Map<String, String> section, int index) {
    final icons = [
      Icons.favorite_outline,
      Icons.lightbulb_outline,
      Icons.medical_services_outlined,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                icons[index % icons.length],
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  section['title'] ?? '',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Section content
          Text(
            section['content'] ?? '',
            style: AppTextStyles.body.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Parse Sections dari teks Gemini ───────────

  List<Map<String, String>> _parseSections(String teks) {
    final cleanTeks = teks.replaceAll('\\', '');
    final sections = <Map<String, String>>[];

    // Split berdasarkan pola **1. Title**, **2. Title**, dst
    final regex = RegExp(r'\*\*\d+\.\s(.+?)\*\*\n([\s\S]+?)(?=\*\*\d+\.|$)');
    final matches = regex.allMatches(cleanTeks);

    if (matches.isEmpty) {
      // Tidak ada format section → tampilkan sebagai satu blok
      sections.add({
        'title': 'Insight',
        'content': cleanTeks
            .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1] ?? '')
            .trim(),
      });
      return sections;
    }

    for (final match in matches) {
      sections.add({
        'title': match.group(1)?.trim() ?? '',
        'content': (match.group(2) ?? '')
            .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1] ?? '')
            .replaceAll(RegExp(r'^\d+\.\s', multiLine: true), '• ')
            .trim(),
      });
    }

    return sections;
  }
}
