import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmeet/core/theme/theme.dart';
import 'package:vmeet/core/utils/meeting_code.dart';
import 'package:vmeet/core/widgets/avatar_widget.dart';
import 'package:vmeet/core/widgets/glass_container.dart';
import 'package:vmeet/core/widgets/glowing_button.dart';
import 'package:vmeet/data/models/meeting_model.dart';
import 'package:vmeet/data/services/permission_service.dart';
import 'package:vmeet/domain/providers/providers.dart';
import 'package:vmeet/presentation/call/call_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showSchedules = true; // Toggle for Scheduled vs History feeds

  // Format date helper without external dependencies
  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final comparisonDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (comparisonDate == today) {
      dateStr = "Today";
    } else if (comparisonDate == today.add(const Duration(days: 1))) {
      dateStr = "Tomorrow";
    } else {
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      dateStr = "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    }

    final hourStr = dt.hour == 0 ? "12" : (dt.hour > 12 ? (dt.hour - 12).toString() : dt.hour.toString());
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final amPmStr = dt.hour >= 12 ? "PM" : "AM";

    return "$dateStr at $hourStr:$minuteStr $amPmStr";
  }

  // Launches the video call and registers the log to history upon call exit
  Future<void> _launchCall({
    required String code,
    required String subject,
    bool startAudioMuted = false,
    bool startVideoMuted = false,
  }) async {
    final permissionsGranted = await PermissionService.hasCameraAndMicPermissions();
    if (!permissionsGranted) {
      final requested = await PermissionService.requestCameraAndMicPermissions();
      if (!requested) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Camera/Microphone access is required to join a call."),
              backgroundColor: VMeetTheme.destructive.withAlpha(200),
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    final profile = ref.read(profileStateProvider);
    final standardizedCode = MeetingCodeGenerator.standardize(code);
    final meetingSubject = subject.isNotEmpty ? subject : "Quick Meeting";

    // 1. Navigate directly to dynamic Jitsi CallScreen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          roomCode: standardizedCode,
          roomName: meetingSubject,
          displayName: profile.displayName,
          initialAudioMuted: startAudioMuted,
          initialVideoMuted: startVideoMuted,
        ),
      ),
    );

    if (!mounted) return;

    // 2. Log to local history when the call session terminates (user returns from CallScreen)
    final historyItem = MeetingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomCode: standardizedCode,
      subject: meetingSubject,
      timestamp: DateTime.now(),
    );
    ref.read(meetingHistoryProvider.notifier).addMeeting(historyItem);
  }

  // Triggers Profile Modification bottom sheet
  void _showEditProfileSheet() {
    final profile = ref.read(profileStateProvider);
    final nameController = TextEditingController(text: profile.displayName);
    int selectedAvatarIdx = profile.avatarIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: GlassContainer(
                borderRadius: 30,
                opacity: 0.12,
                borderSide: const BorderSide(color: VMeetTheme.border, width: 1.5),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Profile",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white60),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // Selected Avatar Preview
                    Center(
                      child: VMeetAvatar(
                        avatarIndex: selectedAvatarIdx,
                        name: nameController.text,
                        size: 90,
                        isSelected: true,
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Nickname field
                    TextField(
                      controller: nameController,
                      onChanged: (text) => setSheetState(() {}),
                      maxLength: 18,
                      style: GoogleFonts.outfit(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "DisplayName",
                        counterText: "",
                        prefixIcon: Icon(Icons.person_outline_rounded, color: VMeetTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Avatar selector
                    Text(
                      "Select Theme",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        VMeetAvatar.avatarGradients.length,
                        (index) => GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedAvatarIdx = index;
                            });
                          },
                          child: VMeetAvatar(
                            avatarIndex: index,
                            name: nameController.text,
                            size: 40,
                            isSelected: selectedAvatarIdx == index,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    
                    GlowingButton(
                      onTap: () async {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) return;
                        
                        await ref.read(profileStateProvider.notifier).saveProfile(
                              newName,
                              selectedAvatarIdx,
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                      text: "Save Changes",
                      icon: Icons.save_rounded,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Opens "Create Meeting" information dialog
  void _showCreateMeetingDialog() {
    final generatedCode = MeetingCodeGenerator.generate();
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassContainer(
            padding: const EdgeInsets.all(28),
            borderRadius: 24,
            borderSide: const BorderSide(color: VMeetTheme.primary, width: 1.2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: VMeetTheme.primary.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_call, color: VMeetTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "New Meeting ID",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  "Share this meeting ID with friends or teammates. Anyone can join instantly for free.",
                  style: GoogleFonts.outfit(color: VMeetTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 25),
                
                // Copyable Code Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VMeetTheme.border, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        generatedCode,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: VMeetTheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: VMeetTheme.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: generatedCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Meeting ID copied to clipboard!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: VMeetTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("CLOSE"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        height: 48,
                        onTap: () {
                          Navigator.pop(context);
                          _launchCall(code: generatedCode, subject: "Quick Meeting");
                        },
                        text: "Start Now",
                        icon: Icons.play_arrow_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Opens "Join Meeting" dialog with active input validation
  void _showJoinMeetingDialog() {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool startAudioMuted = false;
    bool startVideoMuted = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassContainer(
                padding: const EdgeInsets.all(28),
                borderRadius: 24,
                borderSide: const BorderSide(color: VMeetTheme.secondary, width: 1.2),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: VMeetTheme.secondary.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.login_rounded, color: VMeetTheme.secondary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            "Join Meeting",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      
                      // Text field
                      TextFormField(
                        controller: codeController,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Enter Meeting ID",
                          hintText: "e.g. vmt-xyz-abc",
                          prefixIcon: Icon(Icons.vpn_key_outlined, color: VMeetTheme.secondary),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please enter a meeting ID";
                          }
                          if (!MeetingCodeGenerator.isValid(val)) {
                            return "Format must be like vmt-xxx-xxx or 6+ characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Mic Switch
                      // Mic Switch
                      SwitchListTile(
                        value: startAudioMuted,
                        onChanged: (val) {
                          setDialogState(() {
                            startAudioMuted = val;
                          });
                        },
                        title: Text(
                          "Start with Audio Muted",
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70),
                        ),
                        activeThumbColor: VMeetTheme.secondary,
                        activeTrackColor: VMeetTheme.secondary.withAlpha(80),
                        inactiveThumbColor: VMeetTheme.textSecondary,
                        inactiveTrackColor: Colors.white10,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      // Camera Switch
                      SwitchListTile(
                        value: startVideoMuted,
                        onChanged: (val) {
                          setDialogState(() {
                            startVideoMuted = val;
                          });
                        },
                        title: Text(
                          "Start with Camera Off",
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70),
                        ),
                        activeThumbColor: VMeetTheme.secondary,
                        activeTrackColor: VMeetTheme.secondary.withAlpha(80),
                        inactiveThumbColor: VMeetTheme.textSecondary,
                        inactiveTrackColor: Colors.white10,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: VMeetTheme.textSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("CANCEL"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlowingButton(
                              height: 48,
                              gradient: VMeetTheme.secondaryGradient,
                              glowColor: VMeetTheme.secondary,
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(context);
                                  _launchCall(
                                    code: codeController.text,
                                    subject: "Joined Conference",
                                    startAudioMuted: startAudioMuted,
                                    startVideoMuted: startVideoMuted,
                                  );
                                }
                              },
                              text: "Join Call",
                              icon: Icons.videocam_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Opens "Schedule Meeting" sheet with full inputs and Pickers
  void _showScheduleMeetingSheet() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 14, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final formattedDateStr = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
            final formattedTimeStr = selectedTime.format(context);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: GlassContainer(
                borderRadius: 30,
                opacity: 0.12,
                borderSide: const BorderSide(color: VMeetTheme.border, width: 1.5),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Schedule a Meeting",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white60),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // Subject field
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.outfit(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Meeting Subject",
                        hintText: "e.g. Project Sync",
                        prefixIcon: Icon(Icons.edit_calendar_rounded, color: VMeetTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Pickers rows
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: GlassContainer(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 16,
                              opacity: 0.05,
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: VMeetTheme.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("DATE", style: GoogleFonts.outfit(fontSize: 10, color: Colors.white38)),
                                      Text(formattedDateStr, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Time picker
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  selectedTime = picked;
                                });
                              }
                            },
                            child: GlassContainer(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 16,
                              opacity: 0.05,
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, color: VMeetTheme.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("TIME", style: GoogleFonts.outfit(fontSize: 10, color: Colors.white38)),
                                      Text(formattedTimeStr, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    
                    GlowingButton(
                      onTap: () async {
                        final subject = titleController.text.trim();
                        if (subject.isEmpty) return;
                        
                        final meetingDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        final schedule = MeetingModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          roomCode: MeetingCodeGenerator.generate(),
                          subject: subject,
                          timestamp: meetingDateTime,
                          isScheduled: true,
                        );

                        await ref.read(schedulesProvider.notifier).addSchedule(schedule);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Meeting scheduled successfully!"),
                            ),
                          );
                        }
                      },
                      text: "Confirm Schedule",
                      icon: Icons.check_circle_rounded,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileStateProvider);
    final schedules = ref.watch(schedulesProvider);
    final history = ref.watch(meetingHistoryProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: VMeetTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Beautiful Header Profile card
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  borderRadius: 22,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          VMeetAvatar(
                            avatarIndex: profile.avatarIndex,
                            name: profile.displayName,
                            size: 52,
                            isSelected: true,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back,",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: VMeetTheme.textSecondary,
                                ),
                              ),
                              Text(
                                profile.displayName,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Edit profile triggers
                      IconButton(
                        icon: const Icon(Icons.settings_suggest_rounded, color: VMeetTheme.primary),
                        onPressed: _showEditProfileSheet,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Quick Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // New Meeting Action Card
                    Expanded(
                      child: InkWell(
                        onTap: _showCreateMeetingDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: GlassContainer(
                          borderRadius: 20,
                          opacity: 0.08,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: VMeetTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: VMeetTheme.glowShadow(VMeetTheme.primary, radius: 5),
                                ),
                                child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(height: 18),
                              Text("New Call", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text("Start an instant link", style: GoogleFonts.outfit(fontSize: 11, color: VMeetTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Join with ID Action Card
                    Expanded(
                      child: InkWell(
                        onTap: _showJoinMeetingDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: GlassContainer(
                          borderRadius: 20,
                          opacity: 0.08,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: VMeetTheme.secondaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: VMeetTheme.glowShadow(VMeetTheme.secondary, radius: 5),
                                ),
                                child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(height: 18),
                              Text("Join Call", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text("Enter invitation ID", style: GoogleFonts.outfit(fontSize: 11, color: VMeetTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Schedule Action Card
                    Expanded(
                      child: InkWell(
                        onTap: _showScheduleMeetingSheet,
                        borderRadius: BorderRadius.circular(20),
                        child: GlassContainer(
                          borderRadius: 20,
                          opacity: 0.08,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: VMeetTheme.border,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(height: 18),
                              Text("Schedule", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text("Plan a meeting", style: GoogleFonts.outfit(fontSize: 11, color: VMeetTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Sliding Tab Headers (Upcoming vs Past)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Tab 1: Schedules
                    GestureDetector(
                      onTap: () => setState(() => _showSchedules = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _showSchedules ? VMeetTheme.primary.withAlpha(40) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: _showSchedules
                              ? Border.all(color: VMeetTheme.primary.withAlpha(120), width: 1.2)
                              : null,
                        ),
                        child: Text(
                          "Schedules (${schedules.length})",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _showSchedules ? Colors.white : VMeetTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Tab 2: History
                    GestureDetector(
                      onTap: () => setState(() => _showSchedules = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: !_showSchedules ? VMeetTheme.secondary.withAlpha(40) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: !_showSchedules
                              ? Border.all(color: VMeetTheme.secondary.withAlpha(120), width: 1.2)
                              : null,
                        ),
                        child: Text(
                          "History (${history.length})",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: !_showSchedules ? Colors.white : VMeetTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Clear history button
                    if (!_showSchedules && history.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          ref.read(meetingHistoryProvider.notifier).clearHistory();
                        },
                        child: Text(
                          "Clear Log",
                          style: GoogleFonts.outfit(color: VMeetTheme.destructive, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Timeline List Feed
              Expanded(
                child: _showSchedules ? _buildSchedulesFeed(schedules) : _buildHistoryFeed(history),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget generating Scheduled feed
  Widget _buildSchedulesFeed(List<MeetingModel> items) {
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_rounded,
        title: "No Scheduled Meetings",
        subtitle: "Schedule one using the button above to coordinate in advance.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 18,
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 12, color: VMeetTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateTime(item.timestamp),
                          style: GoogleFonts.outfit(fontSize: 11, color: VMeetTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Code: ${item.roomCode}",
                      style: GoogleFonts.outfit(fontSize: 12, color: VMeetTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  GlowingButton(
                    width: 80,
                    height: 36,
                    borderRadius: 10,
                    onTap: () => _launchCall(code: item.roomCode, subject: item.subject),
                    text: "Join",
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: VMeetTheme.destructive, size: 18),
                    onPressed: () {
                      ref.read(schedulesProvider.notifier).removeSchedule(item.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget generating Past History logs
  Widget _buildHistoryFeed(List<MeetingModel> items) {
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: "Meeting History Empty",
        subtitle: "Your completed meetings will be logged here to easily rejoin.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          borderRadius: 18,
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Joined on ${_formatDateTime(item.timestamp)}",
                      style: GoogleFonts.outfit(fontSize: 11, color: VMeetTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.roomCode,
                      style: GoogleFonts.outfit(fontSize: 12, color: VMeetTheme.secondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GlowingButton(
                width: 90,
                height: 36,
                gradient: VMeetTheme.secondaryGradient,
                glowColor: VMeetTheme.secondary,
                borderRadius: 10,
                onTap: () => _launchCall(code: item.roomCode, subject: item.subject),
                text: "Rejoin",
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget for Empty state displays
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: VMeetTheme.textSecondary.withAlpha(150)),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 12, color: VMeetTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
