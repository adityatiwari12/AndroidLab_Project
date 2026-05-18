import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../services/database_service.dart';

class AddActivitySheet extends ConsumerStatefulWidget {
  const AddActivitySheet({super.key});

  @override
  ConsumerState<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends ConsumerState<AddActivitySheet> {
  int _step = 0;
  ActivityType? _selectedType;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  File? _proofFile;
  String? _proofFileName;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
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
      final activity = buildActivity(
        userId: userId,
        type: _selectedType!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        activityDate: _date,
        proofPath: _proofFile?.path,
        proofFileName: _proofFileName,
      );
      await DatabaseService().insertActivity(activity);
      ref.read(activitiesProvider.notifier).add(activity);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activity submitted for review!', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
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

  bool get _canProceed {
    if (_step == 0) return _selectedType != null;
    if (_step == 1) return _titleCtrl.text.trim().length >= 3;
    if (_step == 2) return _proofFile != null;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
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
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => setState(() => _step--)),
                  Expanded(
                    child: Text(
                      ['Select Type', 'Add Details', 'Upload Proof'][_step],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Row(
                    children: List.generate(3, (i) => Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: i == _step ? 20 : 8, height: 8,
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
                child: [_buildStep0(), _buildStep1(), _buildStep2()][_step],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
              child: ElevatedButton(
                onPressed: _canProceed ? (_step < 2 ? () => setState(() => _step++) : _submit) : null,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(_step < 2 ? 'Next →' : 'Submit for Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    final types = [
      (ActivityType.hackathon, '🏆', 'Hackathon'),
      (ActivityType.achievement, '🎖️', 'Achievement'),
      (ActivityType.certification, '📜', 'Certification'),
      (ActivityType.project, '💻', 'Project'),
      (ActivityType.internship, '💼', 'Internship'),
      (ActivityType.research, '🔬', 'Research'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What are you adding?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2,
          children: types.map((t) {
            final selected = _selectedType == t.$1;
            final color = AppColors.forType(t.$1.name);
            return GestureDetector(
              onTap: () => setState(() => _selectedType = t.$1),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? color : AppColors.border, width: selected ? 2 : 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.$2, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(t.$3, style: GoogleFonts.dmSans(fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? color : AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          onChanged: (_) => setState(() {}),
          maxLength: 150,
          decoration: const InputDecoration(labelText: 'Title *', hintText: 'e.g. Smart India Hackathon 2024'),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 12),
                Text('Activity Date: ${_date.day}/${_date.month}/${_date.year}', style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Description (optional)', hintText: 'Brief description of the activity...', alignLabelWithHint: true),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final fileSizeKB = _proofFile != null ? (_proofFile!.lengthSync() / 1024).toStringAsFixed(0) : null;
    return Column(
      children: [
        GestureDetector(
          onTap: _proofFile == null ? _showPickerOptions : null,
          child: Container(
            height: 160, width: double.infinity,
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
                    child: Text('PDF, JPG, PNG or DOC · max 10 MB', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 12)),
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

        // Preview if it's an image
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
