import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../services/database_service.dart';

class AddCodingSheet extends ConsumerStatefulWidget {
  const AddCodingSheet({super.key});

  @override
  ConsumerState<AddCodingSheet> createState() => _AddCodingSheetState();
}

class _AddCodingSheetState extends ConsumerState<AddCodingSheet> {
  int _step = 0;
  CodingType? _type;
  CodingPlatform? _platform;
  final _valueCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  DifficultyLevel? _difficulty;
  File? _proofFile;
  String? _proofFileName;
  bool _loading = false;

  @override
  void dispose() {
    _valueCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed {
    if (_step == 0) return _type != null;
    if (_step == 1) return _platform != null;
    if (_step == 2) {
      if (_type == CodingType.milestone) return _valueCtrl.text.isNotEmpty;
      if (_type == CodingType.contest) return _titleCtrl.text.isNotEmpty && _valueCtrl.text.isNotEmpty;
      if (_type == CodingType.notableProblem) return _titleCtrl.text.isNotEmpty && _difficulty != null;
    }
    if (_step == 3) return _proofFile != null;
    return false;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _proofFile = File(result.files.single.path!);
        _proofFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _proofFile = File(picked.path);
        _proofFileName = picked.name;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _proofFile = File(picked.path);
        _proofFileName = picked.name;
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                title: Text('Choose PDF / Document', style: GoogleFonts.dmSans()),
                onTap: () { Navigator.pop(ctx); _pickFile(); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Choose from Gallery', style: GoogleFonts.dmSans()),
                onTap: () { Navigator.pop(ctx); _pickFromGallery(); },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Take a Photo', style: GoogleFonts.dmSans()),
                onTap: () { Navigator.pop(ctx); _pickFromCamera(); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final userId = ref.read(authProvider).currentUser!.id;
    setState(() => _loading = true);
    try {
      final coding = buildCoding(
        userId: userId,
        platform: _platform!,
        type: _type!,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        value: _valueCtrl.text.isEmpty ? null : int.tryParse(_valueCtrl.text),
        difficulty: _difficulty,
        proofPath: _proofFile?.path,
        proofFileName: _proofFileName,
      );
      await DatabaseService().insertCodingActivity(coding);
      ref.read(codingProvider.notifier).add(coding);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coding entry submitted!', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepTitles = ['Entry Type', 'Platform', 'Details', 'Proof'];
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => setState(() => _step--)),
                  Expanded(
                    child: Text(stepTitles[_step], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
                  ),
                  Row(
                    children: List.generate(4, (i) => Container(
                      margin: const EdgeInsets.only(left: 5),
                      width: i == _step ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _step ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: [_buildStep0(), _buildStep1(), _buildStep2(), _buildStep3()][_step],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
              child: ElevatedButton(
                onPressed: _canProceed ? (_step < 3 ? () => setState(() => _step++) : _submit) : null,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(_step < 3 ? 'Next →' : 'Submit Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    final types = [
      (CodingType.milestone, '📊', 'Milestone', 'Track problems solved'),
      (CodingType.contest, '🏅', 'Contest', 'Log a competition result'),
      (CodingType.notableProblem, '⭐', 'Notable Problem', 'Highlight a hard solve'),
    ];
    return Column(
      children: types.map((t) {
        final selected = _type == t.$1;
        return GestureDetector(
          onTap: () => setState(() => _type = t.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryLight : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Text(t.$2, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.$3, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: selected ? AppColors.primary : AppColors.textPrimary)),
                      Text(t.$4, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep1() {
    final platforms = [
      (CodingPlatform.leetcode, '🟠', 'LeetCode', const Color(0xFFFFA116)),
      (CodingPlatform.codeforces, '🔵', 'Codeforces', const Color(0xFF1F8ACB)),
      (CodingPlatform.codechef, '🟣', 'CodeChef', const Color(0xFF6B40B6)),
      (CodingPlatform.other, '⚪', 'Other', AppColors.textSecondary),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: platforms.map((p) {
        final selected = _platform == p.$1;
        return GestureDetector(
          onTap: () => setState(() => _platform = p.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? p.$4.withOpacity(0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? p.$4 : AppColors.border, width: selected ? 2 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.$2, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(p.$3, style: GoogleFonts.dmSans(fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? p.$4 : AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        if (_type == CodingType.milestone) ...[
          TextField(
            controller: _valueCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Problems Solved *', hintText: 'e.g. 250'),
          ),
          if (_valueCtrl.text.isNotEmpty && int.tryParse(_valueCtrl.text) != null &&
              int.parse(_valueCtrl.text) % 50 != 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Milestones are typically round numbers (50, 100, 200…)', style: GoogleFonts.dmSans(color: AppColors.warning, fontSize: 12))),
                ],
              ),
            ),
          ],
        ],
        if (_type == CodingType.contest) ...[
          TextField(controller: _titleCtrl, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Contest Name *', hintText: 'e.g. Biweekly Contest 128')),
          const SizedBox(height: 16),
          TextField(
            controller: _valueCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Your Rank *', hintText: 'e.g. 1502'),
          ),
        ],
        if (_type == CodingType.notableProblem) ...[
          TextField(controller: _titleCtrl, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Problem Name *', hintText: 'e.g. Merge K Sorted Lists')),
          const SizedBox(height: 16),
          Text('Difficulty *', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: DifficultyLevel.values.map((d) {
              final colors = {DifficultyLevel.easy: AppColors.success, DifficultyLevel.medium: AppColors.warning, DifficultyLevel.hard: AppColors.error};
              final c = colors[d]!;
              final sel = _difficulty == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? c.withOpacity(0.1) : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? c : AppColors.border, width: sel ? 2 : 1),
                    ),
                    child: Center(child: Text(d.name[0].toUpperCase() + d.name.substring(1), style: GoogleFonts.dmSans(color: sel ? c : AppColors.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.w400))),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    final fileSizeKB = _proofFile != null ? (_proofFile!.lengthSync() / 1024).toStringAsFixed(0) : null;
    return Column(
      children: [
        GestureDetector(
          onTap: _proofFile == null ? _showPickerOptions : null,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _proofFile != null ? AppColors.successLight : AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _proofFile != null ? AppColors.success : AppColors.primary, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _proofFile != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                  size: 44, color: _proofFile != null ? AppColors.success : AppColors.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  _proofFile != null ? (_proofFileName ?? 'File selected') : 'Tap to upload proof',
                  style: GoogleFonts.dmSans(color: _proofFile != null ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                if (_proofFile == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('PDF, JPG or PNG · max 10 MB', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
        if (_proofFile != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Icon(
                  _proofFileName?.endsWith('.pdf') == true ? Icons.picture_as_pdf : Icons.image_outlined,
                  color: AppColors.textMuted, size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_proofFileName ?? 'file', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      Text('$fileSizeKB KB', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() { _proofFile = null; _proofFileName = null; }),
                  child: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showPickerOptions,
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: Text('Change file', style: GoogleFonts.dmSans(fontSize: 13)),
          ),
        ],
        if (_proofFile != null && (_proofFileName?.endsWith('.jpg') == true || _proofFileName?.endsWith('.jpeg') == true || _proofFileName?.endsWith('.png') == true)) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_proofFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
      ],
    );
  }
}
