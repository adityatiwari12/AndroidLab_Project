# MyCSIT — AI Build Prompts (v2)

Use these prompts sequentially in Cursor, Claude Code, or any AI coding assistant.
Each prompt is self-contained. Run them in the order shown.

---

# ═══════════════════════════════════════════
# PART 1: FLUTTER MOBILE APP (Student)
# ═══════════════════════════════════════════

---

## Prompt M1 — Project Setup + Supabase + Theme

```
Create a new Flutter project named "mycsit" for Android and iOS.

DEPENDENCIES (add to pubspec.yaml):
  supabase_flutter: ^2.0.0
  flutter_riverpod: ^2.4.0
  go_router: ^13.0.0
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0
  file_picker: ^8.0.0
  flutter_image_compress: ^2.1.0
  image_picker: ^1.0.7
  intl: ^0.19.0
  uuid: ^4.3.0
  excel: ^4.0.2          ← dart Excel parser
  shimmer: ^3.0.0        ← loading skeletons

FOLDER STRUCTURE:
lib/
  core/
    constants/   → app_colors.dart, app_text_styles.dart, app_spacing.dart
    theme/       → app_theme.dart
    utils/       → validators.dart, formatters.dart, file_helpers.dart
  data/
    models/      → user_model.dart, activity_model.dart, coding_model.dart, academic_model.dart
    repositories/→ auth_repo.dart, activity_repo.dart, coding_repo.dart, academic_repo.dart, social_repo.dart
  features/
    auth/        → login_screen.dart, register_screen.dart, pending_screen.dart, rejected_screen.dart
    dashboard/   → dashboard_tab.dart
    profile/     → profile_tab.dart, social_links_sheet.dart
    activities/  → activity_list_tab.dart, add_activity_sheet.dart, activity_detail_screen.dart
    coding/      → coding_tab.dart, add_coding_sheet.dart
    academics/   → academics_screen.dart
    timeline/    → timeline_screen.dart
    rank/        → my_rank_screen.dart
    notifications/ → notifications_screen.dart
  shared/
    widgets/     → status_badge.dart, entry_card.dart, score_card.dart, proof_upload_widget.dart, loading_skeleton.dart

SUPABASE INIT in main.dart:
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

THEME (app_theme.dart):
  primaryColor:  Color(0xFFFF6B35)
  backgroundColor: Color(0xFFF7F8FA)
  surfaceColor:  Colors.white
  Fonts: Poppins (headings, via google_fonts) + DM Sans (body)
  cardTheme: radius 16px, elevation 2, white
  inputDecorationTheme: outlined, radius 12px, coral focus border

GO_ROUTER ROUTES:
  /             → SplashScreen
  /login        → LoginScreen
  /register     → RegisterScreen
  /pending      → PendingApprovalScreen
  /rejected     → AccountRejectedScreen
  /home         → HomeShell (ShellRoute with bottom nav, 4 tabs)
    /home/dashboard
    /home/timeline
    /home/profile
    /home/notifications
  /activities/:id → ActivityDetailScreen
  /coding/:id     → CodingDetailScreen
  /rank           → MyRankScreen
  /academics      → AcademicsScreen

AUTH REDIRECT in go_router:
  No auth user → /login
  status = pending → /pending
  status = rejected → /rejected
  status = active → /home/dashboard
```

---

## Prompt M2 — Auth Screens

```
Build auth screens for MyCSIT Flutter app. Use the AppTheme already set up.

Design language: white/off-white background, coral (#FF6B35) primary color, 
Poppins Bold headings, DM Sans body, pill-shaped coral buttons (border-radius: 9999).

── LoginScreen (/login) ──────────────────────────────────────────
- Top padding 80px
- "Welcome Back 👋" Poppins Bold 28px
- "Log in with your college credentials" DM Sans 14px muted
- Gap 40px
- TextField: Roll Number (outlined, radius 12, coral focusBorder)
- TextField: Password (show/hide suffix icon)
- Gap 24px
- ElevatedButton: "Login" (full width, 52px, coral, pill)
- Gap 16px
- TextButton: "New here? Register →" (coral text, centered)
- Loading state: button shows CircularProgressIndicator

On submit:
  1. Query Supabase roster to confirm roll number exists
  2. supabase.auth.signInWithPassword(email: "${rollNo}@mycsit.aitr.ac.in", password)
  3. Fetch users.status → route accordingly
  Error handling: show SnackBar for wrong credentials

── RegisterScreen (/register) ────────────────────────────────────
- Back arrow AppBar (no elevation)
- "Create Account" Poppins Bold 26px
- Roll Number TextField
  → On blur/submit: query roster.
    If found: show green chip "✓ [Name] – CSIT1, Year 2" below field
    If not found: show red error "Roll number not recognized"
  → Auto-fill class + year from roster (shown as disabled chips)
- Full Name TextField (editable, pre-filled from roster)
- Password + Confirm Password fields
- "Register" coral pill button
- Validation: passwords match, all fields required
On submit:
  1. supabase.auth.signUp(email, password)
  2. Insert into users table
  3. Update roster.is_registered = true
  4. Navigate to /pending

── PendingApprovalScreen (/pending) ──────────────────────────────
- Centered: Icon(Icons.hourglass_top_rounded) size 80, coral
- "Awaiting Approval" Poppins SemiBold 22px
- "Your account is being reviewed by faculty." DM Sans 14px muted
- Gap 48px
- OutlinedButton: "Logout" (coral border)
- Background timer: polls Supabase every 30s for status change
  On status = active: navigate to /home/dashboard

── AccountRejectedScreen (/rejected) ─────────────────────────────
- Icon(Icons.cancel_rounded) size 80, red
- "Registration Not Approved"
- "Please contact your faculty coordinator for assistance."
- OutlinedButton: "Logout"
```

---

## Prompt M3 — Riverpod Auth State

```
Implement full auth state management with Riverpod for MyCSIT Flutter app.

1. Create SupabaseService singleton (lib/core/supabase_service.dart):
   - Exposes supabase client
   - getUserStatus(uid): Future<String>
   - Streams: authStateChanges

2. AuthState class:
   enum AuthStatus { loading, unauthenticated, pending, active, rejected }
   class AuthState { AuthStatus status; User? user; String? error; }

3. AuthNotifier (StateNotifier<AuthState>):
   - init(): listens to supabase.auth.onAuthStateChange
   - On SIGNED_IN: fetch users.status → update state
   - On SIGNED_OUT: state = unauthenticated
   - signIn(rollNo, password): constructs email, calls signInWithPassword
   - register(rollNo, fullName, password): full registration flow
   - signOut(): supabase.auth.signOut()
   - startPolling(): Timer.periodic(30s) checks status if state = pending
   - stopPolling(): cancels timer

4. Provide via ProviderScope in main.dart

5. go_router redirect reads authProvider state:
   - AuthStatus.loading → null (stay)
   - AuthStatus.unauthenticated → /login
   - AuthStatus.pending → /pending
   - AuthStatus.rejected → /rejected
   - AuthStatus.active → /home/dashboard (redirect away from /login)

6. LoginScreen and RegisterScreen read authProvider for loading/error states
```

---

## Prompt M4 — Home Dashboard + Score Card

```
Build the Home Dashboard tab for MyCSIT Flutter app (DashboardTab widget).

This is Tab 1 of the bottom nav shell. Uses SingleChildScrollView.

TOP BAR (custom, not AppBar):
  Row:
    Left: CircleAvatar(radius:20) + "Hi, [firstName] 👋" Poppins SemiBold 18px
    Right: IconButton(Icons.notifications_rounded, coral)
  Padding: 20px horizontal, 16px top

SCORE CARD:
  Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
        begin: Alignment.topLeft, end: Alignment.bottomRight
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Color(0x44FF6B35), blurRadius:20, offset:Offset(0,8))]
    ),
    padding: 20px,
    child: Row(
      Left: Column(
        CircularProgressIndicator (white, strokeWidth 6, value: completeness/100)
        Text("[completeness]%" white Poppins Bold 18px)
        Text("Profile" white 70% opacity 12px)
      )
      Right: Column(
        Text(totalScore, JetBrains Mono Bold 42px white)
        Text("Total Score" white 70% opacity 12px)
        Gap 12px
        Row of 3 mini chips (hackathon_score | project_score | coding_score)
          each: white 15% opacity bg, white text 11px, pill shape
      )
    )
  )
  Tap → navigate to /rank

QUICK ACTIONS (horizontal scroll):
  Row of 4 cards (each 72×80px, white, radius 16px, shadow):
    [+ Activity] icon: add_task, coral
    [+ Coding] icon: code_rounded, coral
    [Timeline] icon: timeline_rounded, coral
    [Academics] icon: school_rounded, coral

RECENT ENTRIES section (Poppins SemiBold 16px header):
  FutureBuilder fetches last 3 from activities + coding_activities, merged by created_at
  Each: EntryCard widget (type color bar + title + date + StatusBadge)
  "See All →" right-aligned coral TextButton

MARKS SNAPSHOT:
  FutureBuilder fetches academic_records
  Horizontal ListView of SemesterCard widgets:
    White card 120×80px: "Sem [n]" + CGPA badge + "[x] subjects"

Data providers (Riverpod FutureProviders):
  - dashboardScoreProvider: fetches score_cache for current user
  - recentEntriesProvider: merged last 3 activities + coding
  - semesterSnapshotProvider: academic_records list
```

---

## Prompt M5 — Activity System

```
Build the complete Activity feature for MyCSIT Flutter app.

── ActivityModel (data/models/activity_model.dart) ────────────────
Fields: id, userId, type, title, description, activityDate, proofPath,
        status, rejectionReason, reviewedBy, reviewedAt, createdAt, updatedAt
Include: fromJson(Map), toJson(), copyWith()
Enum: ActivityType { hackathon, achievement, certification, project, internship, research }
Enum: EntryStatus { pending, approved, rejected }

── ActivityRepository ──────────────────────────────────────────────
Methods:
  Stream<List<ActivityModel>> watchActivities(userId, {type?, status?}):
    Supabase .from('activities').stream(primaryKey:['id'])
    .eq('user_id', userId).eq('is_deleted', false).order('created_at', asc:false)

  Future<void> submitActivity(ActivityModel data, File proofFile):
    1. Upload file to Supabase Storage 'proofs' bucket at path: userId/activities/uuid.ext
    2. Insert into activities table with proof_path

  Future<void> resubmitActivity(String id, ActivityModel updated, File? newProof):
    If newProof provided: upload to storage
    Update activities where id=id AND status='rejected'

── AddActivitySheet (showModalBottomSheet) ─────────────────────────
DraggableScrollableSheet, initialChildSize: 0.9

STEP 1 — Type Selection:
  "What are you adding?" Poppins SemiBold 18px
  3×2 GridView of TypeTile widgets (each ~100px height):
    [🏆 Hackathon] [🎖 Achievement] [📜 Certification]
    [💻 Project]   [💼 Internship]  [🔬 Research]
  TypeTile: white card, radius 16px, icon+label. Selected: coral border+bg(#FFF3EE)
  "Next →" coral pill button (disabled until selection made)

STEP 2 — Details:
  Title TextField (required, 3–150 chars)
  Date picker row: "Activity Date" label + tappable date chip
    showDatePicker: lastDate: DateTime.now()
  Description TextField (multiline, 3 lines, optional)
  "Next →" button

STEP 3 — Proof Upload:
  ProofUploadWidget:
    DashedBorder container (coral dash, radius 16px, 120px height)
    Icon(upload_file, coral, 32px) + "Tap to upload proof (PDF or image)"
    On tap: FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','jpg','jpeg','png'])
    On file selected: show filename + size + green checkmark
  "Submit" coral pill button (disabled until file selected)
  On submit: show LinearProgressIndicator while uploading, then close sheet + show SnackBar

── ActivityListTab ─────────────────────────────────────────────────
Filter chips row (horizontal scroll): All | Hackathon | Certification | ... | Research
Status segmented control: All / Pending / Approved / Rejected
ListView of EntryCard:
  Left: 4px vertical colored bar (use ActivityTypeColors map)
  Title DM Sans Medium 14px + date DM Sans 12px muted
  Right: StatusBadge widget
Empty state per filter combo

── ActivityDetailScreen (/activities/:id) ───────────────────────────
Fetches single activity from Supabase
Shows all fields
Proof: if PDF → Icon + "View Proof" OutlinedButton (opens signedUrl)
       if image → CachedNetworkImage thumbnail (signed URL)
If rejected: red card with rejection_reason text + "Edit & Resubmit" button
If approved: green check card "Approved by faculty"
```

---

## Prompt M6 — Coding Activity System

```
Build the Coding Activity feature for MyCSIT Flutter app.

── CodingActivityModel ─────────────────────────────────────────────
Fields: id, userId, platform, type, title, value(int?), contestName,
        difficulty, proofPath, status, rejectionReason, createdAt
Enums: CodingPlatform { leetcode, codeforces, codechef, other }
       CodingType { milestone, contest, notableProblem }
       DifficultyLevel { easy, medium, hard }

── CodingTab ────────────────────────────────────────────────────────
TabBar with 3 tabs: Milestones | Contests | Notable Problems
Each tab: filtered stream of coding_activities
CodingEntryCard:
  Left: platform colored circle (LeetCode: #FFA116, CF: #1F8ACB, CC: #6B40B6, Other: #6B7280)
  Platform name + type badge + title
  Value display: "200 problems" or "Rank #1,200"
  Right: StatusBadge
FAB (coral, Icons.add): opens AddCodingSheet

── AddCodingSheet ─────────────────────────────────────────────────
4 steps:

STEP 1 — Entry Type (3 large cards, full-width):
  [📊 Milestone — Track problems solved]
  [🏅 Contest — Log a competition result]  
  [⭐ Notable Problem — Highlight a hard solve]
  Selected: coral border

STEP 2 — Platform:
  Row of 4 platform chips (icon + name):
  LeetCode (orange) | Codeforces (blue) | CodeChef (purple) | Other (grey)

STEP 3 — Details (conditional by type):
  IF milestone:
    "Problems Solved" NumberTextField (integer > 0)
    Real-time warning if not divisible by 50:
      amber Container "Milestones are typically round numbers (50, 100, 200...)"
  IF contest:
    "Contest Name" TextField
    "Your Rank" NumberTextField (integer ≥ 1, validated)
  IF notableProblem:
    "Problem Name" TextField
    "Difficulty" DropdownButton (Easy/Medium/Hard)

STEP 4 — Proof Upload (same ProofUploadWidget as activities)

On submit: upload proof → insert into coding_activities
```

---

## Prompt M7 — Profile + Social Links + My Rank

```
Build ProfileTab, SocialLinksSheet, and MyRankScreen.

── ProfileTab ──────────────────────────────────────────────────────
SingleChildScrollView:

1. HEADER (Stack):
   Container(height:120, gradient coral #FF6B35→#FF9F1C)
   Positioned avatar (bottom:-40):
     Stack:
       CircleAvatar(radius:44, white border 3px, image from profile_photo signed URL or initials)
       Positioned(bottom:0, right:0): InkWell → ImagePicker → compress → upload to 'avatars' bucket
         Small coral circle with edit icon

2. NAME + INFO (padding top 48px):
   Name Poppins Bold 20px centered
   "CSIT1 • Year 2 • Roll: 0191..." DM Sans 13px muted centered

3. PROFILE COMPLETENESS CARD:
   White card, radius 16px
   "Profile Completeness" label + percentage right
   LinearProgressIndicator (coral, 8px height, rounded, value: completeness/100)
   Wrap of missing field chips: "Add GitHub +" each in grey outlined pill

4. ONLINE PRESENCE SECTION:
   "Online Presence" Poppins SemiBold 16px
   GridView.count(crossAxisCount:2):
     PlatformTile for each: LinkedIn, GitHub, LeetCode, Codeforces, CodeChef, Portfolio
       White card, radius 12px, platform icon + name
       If linked: coral username text + coral check icon top-right
       If unlinked: "Tap to add" muted text
       OnTap → SocialLinksSheet

5. LOGOUT tile (red, bottom)

── SocialLinksSheet ────────────────────────────────────────────────
Bottom sheet: platform name + icon heading
TextField: "Enter [Platform] URL"
Platform-specific URL validation:
  linkedin: must contain 'linkedin.com/in/'
  github: must contain 'github.com/'
  leetcode: must contain 'leetcode.com/u/' or 'leetcode.com/'
  others: valid URL format only
Save → upsert into social_links table

── MyRankScreen (/rank) ────────────────────────────────────────────
Fetches:
  1. score_cache for current user
  2. Call supabase.rpc('leaderboard_period', {p_class: userClass, p_year: userYear})
     Find user's rank in result

Display:
  "Your Rank" Poppins SemiBold 20px
  Large rank: "#12 of 58" in CSIT1 – Year 2" JetBrains Mono Bold 48px coral
  
  Score breakdown (4 rows):
    Each row: type label + colored pill weight (35%) + LinearProgressIndicator + score value
    Row 1: 🏆 Hackathons [35%] ████░░ 67.5
    Row 2: 💼 Projects   [25%] ██░░░░ 40.0
    Row 3: 🎓 Academic   [25%] ███░░░ 55.0
    Row 4: 💻 Coding     [15%] █░░░░░ 22.5
    
  Total score: large coral number + "/ 100"
  
  Note text (muted 12px): "Department leaderboard is visible to faculty"
```

---

## Prompt M8 — Timeline, Academics, Notifications

```
Build the remaining screens for MyCSIT Flutter app.

── TimelineScreen ──────────────────────────────────────────────────
Merged chronological feed of activities + coding_activities.

Data: Fetch both lists, merge into List<TimelineEntry> (sealed class with ActivityEntry | CodingEntry),
sort by createdAt desc, paginate 15 at a time.

Filter chips row (SingleChildScrollView horizontal):
  All | Hackathon | Certification | Research | Project | Internship | Achievement | Milestone | Contest

Status segmented control: All / Pending / Approved / Rejected

TimelineEntryCard:
  Left: 4px colored vertical bar (color by type, see UI_design.md type colors)
  Content:
    Row: TypeBadge (pill) + StatusBadge (pill, right-aligned)
    Title DM Sans Medium 14px
    Date + platform (if coding) DM Sans 12px muted
  Tap → respective detail screen

Load more: when scrolled to 80% → fetch next page

Empty state: timeline icon + "Your journey starts here" + "Add Entry" button

── AcademicsScreen ─────────────────────────────────────────────────
Fetches: academic_records with subject_marks + attendance (all semesters)

Top: CGPA trend row (horizontal scroll of semester CGPA chips)

Per semester ExpansionTile:
  Title: "Semester [n] — CGPA: [x]"
  Expanded:
    Subjects table: 3 columns (Subject | Marks | %)
    Attendance card: circular gauge (coral) showing percentage
      Red < 75%, Amber 75-85%, Green > 85%

Empty state if no records: "Marks not entered yet by faculty"

── NotificationsScreen ─────────────────────────────────────────────
ListView from notifications table, ordered by created_at desc.

NotificationTile:
  Leading: Icon in colored circle (approval=green, rejection=red, account=coral, marks=blue)
  Title (DM Sans Medium 14px, bold if unread)
  Body (DM Sans 13px muted)
  Trailing: relative time (intl package)
  Unread: light coral row background

On tap: mark as read (UPDATE notifications SET is_read=true)
AppBar action: "Mark all read" TextButton
```

---

# ═══════════════════════════════════════════
# PART 2: REACT WEB DASHBOARD (Faculty)
# ═══════════════════════════════════════════

---

## Prompt W1 — Project Setup

```
Create a new React + TypeScript + Vite project named "mycsit-faculty".

INSTALL:
  @supabase/supabase-js
  react-router-dom@6
  tailwindcss postcss autoprefixer
  @radix-ui/react-dialog @radix-ui/react-tabs @radix-ui/react-select
  @radix-ui/react-checkbox @radix-ui/react-dropdown-menu
  @tanstack/react-table
  recharts
  react-hook-form zod @hookform/resolvers
  zustand
  date-fns
  lucide-react
  xlsx                  ← SheetJS for Excel parsing
  clsx tailwind-merge   ← utility

TAILWIND CONFIG (tailwind.config.ts):
  extend.colors:
    primary: { DEFAULT:'#FF6B35', light:'#FFF3EE', dark:'#E8521A' }
    accent: '#FF9F1C'
    surface: '#FFFFFF'
    muted: '#F7F8FA'
  extend.fontFamily:
    display: ['Poppins','sans-serif']
    body: ['DM Sans','sans-serif']
  Add Google Fonts in index.html: Poppins 400,600,700 + DM Sans 400,500

FOLDER STRUCTURE:
src/
  components/
    layout/   → AppShell.tsx, Sidebar.tsx, TopBar.tsx
    ui/       → Button.tsx, Badge.tsx, Card.tsx, Input.tsx, Modal.tsx, Table.tsx, Skeleton.tsx
    charts/   → ScoreBar.tsx, LeaderboardChart.tsx, DonutChart.tsx, HistogramChart.tsx
    uploads/  → ExcelUploader.tsx, UploadPreviewTable.tsx, ColumnMapper.tsx
  features/
    auth/     → LoginPage.tsx, useAuth.ts
    students/ → StudentDirectory.tsx, StudentDetail.tsx, ScoreBreakdown.tsx
    approvals/→ ApprovalQueue.tsx, ApprovalCard.tsx
    marks/    → MarksPage.tsx, SubjectTable.tsx
    attendance/→ AttendancePage.tsx
    leaderboard/→ LeaderboardPage.tsx, Podium.tsx, LeaderboardTable.tsx
    analytics/→ AnalyticsPage.tsx
    uploads/  → UploadsPage.tsx
  lib/
    supabase.ts
    database.types.ts   ← generated
  hooks/     → useStudents.ts, useApprovals.ts, useLeaderboard.ts
  stores/    → authStore.ts, filterStore.ts
  types/     → index.ts

REACT ROUTER:
  / → redirect to /login
  /login → LoginPage
  /dashboard → AppShell (protected)
    /dashboard/overview → Overview
    /dashboard/students → StudentDirectory
    /dashboard/students/:id → StudentDetail
    /dashboard/approvals → ApprovalQueue
    /dashboard/marks → MarksPage
    /dashboard/attendance → AttendancePage
    /dashboard/leaderboard → LeaderboardPage  ← NEW
    /dashboard/analytics → AnalyticsPage
    /dashboard/uploads → UploadsPage
  Auth guard: if no session or role not in [class_teacher, hod] → /login
```

---

## Prompt W2 — AppShell + Sidebar + Auth

```
Build the AppShell layout and auth for MyCSIT faculty dashboard.

── LoginPage (/login) ──────────────────────────────────────────────
Centered card (white, radius 20px, shadow):
  "MyCSIT Faculty" Poppins Bold 28px + coral underline
  "Department Intelligence Dashboard" muted 14px
  Gap 32px
  Email input + Password input (react-hook-form + zod validation)
  "Login" coral pill button (full width)
  Error message display

On submit: supabase.auth.signInWithPassword({ email, password })
  → fetch users.role
  → if not class_teacher or hod: show "Access restricted to faculty"
  → else: navigate to /dashboard/overview

── AppShell ────────────────────────────────────────────────────────
flex h-screen:
  <Sidebar /> fixed left, 240px
  <main> flex-1 overflow-y-auto
    <TopBar /> sticky top
    <Outlet /> (page content)

── Sidebar ─────────────────────────────────────────────────────────
White bg, border-r border-[#EEEEEE]

Logo (top, 20px padding): "My" span coral + "CSIT" dark, Poppins Bold 22px

NavItem component:
  Props: icon, label, to, badgeCount?
  Active detection: useMatch(to)
  Active styles: bg-primary-light text-primary border-l-[3px] border-primary
  Hover: bg-muted
  Icon size: 18px, mr-3
  Badge: red circle top-right of icon

Nav items:
  LayoutDashboard  Overview
  Users            Students
  ClipboardCheck   Approvals    ← badge: count of pending registrations + activities
  BookOpen         Marks
  CalendarCheck    Attendance
  Trophy           Leaderboard  ← NEW (Trophy icon, lucide)
  BarChart2        Analytics
  Upload           Bulk Uploads

Pending badge count:
  useEffect: query count of users where status='pending' 
           + count of activities where status='pending' and is_deleted=false
  Sum displayed on Approvals nav item

Bottom: faculty name (Poppins Medium 14px) + role chip + LogOut button

── TopBar ──────────────────────────────────────────────────────────
h-16 white border-b border-[#EEEEEE] flex items-center justify-between px-6:
  Left: page title (from route) Poppins SemiBold 20px
        + scope chip: "CSIT1 – Year 2" for class teacher, "All Classes" for HOD
  Right: search input (global student search) + Bell icon (notification count badge)

── Auth Store (Zustand) ─────────────────────────────────────────────
interface AuthStore {
  user: User | null
  profile: UserProfile | null  // from users table
  isHOD: boolean
  assignedClasses: { class: string, year: number }[]
  setUser, setProfile, signOut
}
```

---

## Prompt W3 — Student Directory

```
Build the Student Directory page for MyCSIT faculty dashboard.

FILTER PANEL (left, 280px, collapsible):
  All sections with Radix UI components:
  "Class" — CheckboxGroup: CSIT1, CSIT2, CY
  "Year" — CheckboxGroup: 1st, 2nd, 3rd, 4th
  "CGPA Range" — two number inputs (0–10)
  "Score Range" — two number inputs (0–100)
  "Activity" — Toggle switches: "Has Activities", "Has Coding Entries"
  Apply Filters button (coral, full width)
  Clear All text button (muted)

DATA FETCHING (useStudents hook):
  Query: users + score_cache + latest academic_records (joined)
  Apply class/year filter in Supabase query
  Apply CGPA/score/activity filters client-side
  Return: { students, isLoading, error }

TANSTACK TABLE:
  Columns:
    - select (checkbox)
    - name (avatar initials circle + full_name, clickable → student detail)
    - roll_number
    - class + year (combined "CSIT1 – Y2")
    - cgpa (sortable, numeric)
    - total_score (sortable; render as: progress bar + score number)
      bar: coral fill, proportional to 100, width: 80px
    - activity_count (number badge, coral if >0, grey if 0)
    - actions (Eye icon → navigate to /dashboard/students/:id)
  
  Styling:
    thead: bg-muted, text-muted-foreground, DM Sans Medium 13px
    tbody tr hover: bg-[#FFF8F5]
    No outer border; tr separator: border-b border-[#F3F4F6]
  
  Sorting: click column header → toggle asc/desc, show sort icon

TOP ACTION BAR:
  "[N] students" count (DM Sans Medium)
  Right: Search input (by name or roll number) + "Export CSV" button
  
  CSV Export:
    Uses client-side data (already fetched)
    Generates: Name, Roll No, Class, Year, CGPA, Total Score, Hackathon, Projects, Coding
    Triggers download via Blob + URL.createObjectURL

PAGINATION: 20 rows/page, prev/next, page indicator
LOADING: skeleton rows (shimmer effect) while fetching
```

---

## Prompt W4 — Student Detail

```
Build the Student Detail page (/dashboard/students/:id).

LAYOUT: two-column, lg:grid-cols-[280px_1fr] gap-6

LEFT PANEL (Card, sticky):
  CircleAvatar (64px) or profile photo (from signed URL)
  full_name Poppins Bold 20px
  roll_number, class, year, muted DM Sans 13px
  
  Score Summary Card (coral gradient):
    total_score JetBrains Mono Bold 32px white
    "Total Score" label white opacity-70
    4 sub-score pills (white bg with 20% opacity):
      🏆 [hackathon_score] | 💼 [project_score] | 🎓 [academic_score] | 💻 [coding_score]
  
  Social Links:
    "Online Presence" label
    Each linked platform: icon chip (platform color) + username, clickable → new tab
    Unlinked: muted "—"

RIGHT PANEL (Tabs, Radix UI):
  Tab 1: Overview
    Horizontal score bars (4 rows):
      Label | Weight pill | Bar (coral, proportional) | Score value
    Quick stats row: Total activities | Approved | Pending | CGPA
  
  Tab 2: Activities
    Status filter tabs: All/Pending/Approved/Rejected
    Table: Type | Title | Date | Status | Proof | Actions
      Proof: "View" button → createSignedUrl → window.open
      Actions (pending only): Approve (green) / Reject (red, opens modal with reason input)
      Faculty soft-delete on approved entries: trash icon → confirm dialog
    On approve: update + calculate_score RPC + insert notification
  
  Tab 3: Coding
    Accordion grouped by platform
    Each platform section: list of coding entries with same approve/reject UI
  
  Tab 4: Academics
    Per-semester Accordion (shadcn/Radix)
    Subject marks table (inline editable: marks input + max marks)
    CGPA field: number input + "Save" button → upsert + calculate_score
    Attendance row: total | attended | % (color-coded)
    "Save All Changes" button at bottom of each semester
  
  Tab 5: Score Breakdown
    Detailed computation display:
    "Hackathon Score (35%)"
    → Approved entries: [list with type weights]
    → Raw: X.X / 6.6 × 100 = [hackathon_score]
    Same for each component.
    Total formula shown at bottom with actual values.
```

---

## Prompt W5 — Approval Queue

```
Build the Approval Queue page for MyCSIT faculty dashboard.

3 tabs (Radix TabsList, coral active indicator underline):
  "Student Registrations" + count badge
  "Activity Entries" + count badge  
  "Coding Entries" + count badge

── Tab: Student Registrations ──────────────────────────────────────
Query: users where status='pending', ordered by created_at asc
ApprovalCard (white, radius 16px, shadow):
  Left: initials CircleAvatar (coral bg)
  Name Poppins SemiBold 15px
  Roll No | Class | Year  DM Sans 13px muted
  Submitted: relative time (date-fns formatDistanceToNow)
  Right: 
    "Approve" button (green, small pill)
    "Reject" button (red outlined, small pill) → RejectModal

RejectModal (Radix Dialog):
  "Reject [Name]'s Registration?" heading
  Optional reason Textarea
  Cancel + Confirm Reject buttons

On Approve:
  UPDATE users SET status='active', approved_by, approved_at
  INSERT notification for student
  INSERT audit_log

── Tab: Activity Entries ────────────────────────────────────────────
Query: activities where status='pending' AND is_deleted=false, order by created_at asc
ApprovalEntryCard:
  Student name (linked → student detail) + roll no
  Type badge (colored) + Title + Activity date
  "View Proof" button (opens signed URL)
  Approve / Reject buttons
  Checkbox on left for bulk select

On Reject: modal requires reason text (not optional for activities)

BULK ACTION BAR (appears when ≥1 selected):
  Fixed bottom, white card with shadow:
  "[N] entries selected"
  "Approve All" green button | "Reject All" red button → bulk reason modal

── Tab: Coding Entries ──────────────────────────────────────────────
Same pattern as Activity Entries, queries coding_activities

EMPTY STATES:
  Each tab: green checkmark icon + "All caught up! No pending [type]." 

After any approval/rejection: refresh counts in Sidebar badge
```

---

## Prompt W6 — Leaderboard Page (Full Feature)

```
Build the Leaderboard page for MyCSIT faculty dashboard.
This is the most important faculty-facing feature.

STICKY FILTER BAR (top, white, border-b, z-10):
  4 dropdowns (Radix Select, coral active border):
    [Class: All ▾]  CSIT1 / CSIT2 / CY / All
    [Year: All ▾]   1st / 2nd / 3rd / 4th / All
    [Period: All-time ▾]  All-time / This Semester / This Month / This Week
    [Rank By: Total Score ▾]  Total / Hackathons / Projects / Academic / Coding

  (HOD sees all classes; class teacher's Class dropdown pre-filtered to their assignments)

DATA: useLeaderboard hook
  Calls supabase.rpc('leaderboard_period', { p_class, p_year, p_days })
  Sorts client-side by selected rankBy metric
  Returns: { leaderboard: LeaderboardRow[], isLoading, total }

PODIUM (top 3, when result has ≥3 entries):
  Flex row: 2nd (left) | 1st (center, elevated) | 3rd (right)
  
  1st place card (140×180px, coral gradient bg, accent-glow shadow):
    Crown icon (amber, 24px) above avatar
    CircleAvatar (64px, white border)
    Name Poppins SemiBold 14px white
    "CSIT1 – Y2" muted white 12px
    "#1" JetBrains Mono Bold 32px white
    Score white 14px

  2nd place card (120×160px, silver gradient #E8E8E8→#C0C0C0):
    "#2" + name + score

  3rd place card (120×160px, bronze gradient #E8C88A→#CD7F32):
    "#3" + name + score

LEADERBOARD TABLE (rank 4 onwards):
  Columns:
    Rank (#, coral for top 10, black otherwise)
    Student (avatar initials + name + class/year chip)
    [Selected metric] score bar (proportional, coral fill)
    Hackathon | Projects | Academic | Coding (all 4 component scores shown as numbers)
    Total Score (JetBrains Mono, bold)
    Action (eye → student detail)
  
  Top 10 rows: bg-primary-light (#FFF3EE) subtle highlight
  Row hover: slightly darker
  
  Sort: clicking any score column header sorts by that column (highlights that column header in coral)

CLASS COMPARISON PANEL (HOD only, shown as right sidebar 280px):
  "Class Average Comparison" heading
  Horizontal BarChart (Recharts):
    Y axis: CSIT1, CSIT2, CY
    X axis: avg score (0–100)
    Bars: coral fill, per-class avg from leaderboard data
  
  Below: component breakdown mini table:
    Class | Hackathon avg | Projects avg | CGPA avg | Coding avg
  
  (Hide this panel for class teachers)

EXPORT:
  "Export CSV" button top-right → downloads leaderboard data as CSV
  Columns: Rank, Name, Roll No, Class, Year, Total, Hackathon, Projects, Academic, Coding
```

---

## Prompt W7 — Marks, Attendance + Excel Uploads

```
Build Marks, Attendance, and the Bulk Uploads page.

── MarksPage ───────────────────────────────────────────────────────
Left: student search combobox (Radix Select with search)
Right panel on selection:

Semester accordion (1–8):
  Each semester: subject table
    Columns: Subject Name (editable text) | Marks (number input) | Max Marks (number input) | % (auto-computed)
  CGPA field (number input, 0–10)
  "Save Semester" button → upsert academic_records + subject_marks → calculate_score RPC

Excel Upload section (below accordion):
  ExcelUploader component (see below)
  Format guide: expandable "Expected format" section with column list

── AttendancePage ──────────────────────────────────────────────────
Class + Year filter selects at top
Table: Roll No | Name | Total Classes | Attended | Attendance %
  Total + Attended: inline number inputs (update on blur)
  %: auto-computed, color classes:
    < 75%:  text-red-600 bg-red-50
    75–85%: text-amber-600 bg-amber-50
    > 85%:  text-green-600 bg-green-50
"Set Total Classes for All" input + "Apply" → bulk updates totalClasses for visible rows
"Save All" button → batch upsert attendance table

Excel Upload section (same pattern)

── UploadsPage ─────────────────────────────────────────────────────
Tabs: Roster | Marks | Attendance | Activities

Per tab:
  1. ExcelUploader component
  2. Format guide (expandable Card)
  3. Upload history table (from upload_log): File | Date | Rows | Errors | Uploaded By | Download Error Report

── ExcelUploader Component ──────────────────────────────────────────
Props: uploadType, onComplete

DRAG + DROP ZONE:
  Border-dashed border-2 border-primary/40, radius-xl, p-12
  Upload cloud icon (coral, 48px)
  "Drag & drop your Excel or CSV file, or click to browse"
  Accepted: .xlsx, .xls, .csv
  Max size: 20MB

On file selected:
  1. Parse with SheetJS: XLSX.read(buffer, { type:'array', cellDates:true })
  2. sheet_to_json → normalize headers (trim+lowercase+underscores)
  3. Validate each row per uploadType rules
  4. Separate into valid[] and invalid[]

COLUMN MAPPER (shown when headers don't auto-match):
  Display: "We couldn't match all columns automatically"
  Table: Expected Column | Your Column (Select dropdown with file's headers)
  Each row: required indicator + description
  "Continue with Mapping" button

PREVIEW TABLE:
  Show all rows in a table
  Valid rows: white bg + green dot in first column
  Invalid rows: red-50 bg + red dot + error message in last column "Reason" column
  Count summary: "X valid, Y invalid"

IMPORT BUTTON: "Import X Valid Rows"
  On click: batch commit valid rows + insert upload_log
  Show progress (for large files: process in chunks of 50)
  On complete: "✓ X rows imported. Y rows skipped." toast + download error report link
```

---

## Prompt W8 — Analytics + Final Polish

```
Build the Analytics page and apply final polish across the dashboard.

── AnalyticsPage ────────────────────────────────────────────────────
All data fetched from Supabase, aggregated client-side.
All charts use Recharts with coral (#FF6B35) + amber (#FF9F1C) palette.
White chart backgrounds, gridlines #F3F4F6, no border.

STAT CARDS ROW (4 cards):
  Each card: white, radius 16px, shadow
  Left: icon in coral rounded square (40px)
  Right: value (Poppins Bold 28px) + label (DM Sans 14px muted)
  Values: Total Active Students | Pending Approvals | Avg CGPA | Avg Total Score

CHART 1: CGPA Distribution (BarChart)
  X: buckets 0–4, 4–5, 5–6, 6–7, 7–8, 8–9, 9–10
  Y: student count
  Bar fill: coral, hover: darker coral
  Tooltip: "{count} students"

CHART 2: Activity Type Breakdown (GroupedBarChart)
  X: activity types (hackathon, project, internship...)
  Y: count of approved entries
  Each bar: type-specific color (see UI_design.md type colors)
  
CHART 3: Coding Platform Distribution (PieChart/Donut)
  Segments: LeetCode, Codeforces, CodeChef, Other
  Colors: #FFA116, #1F8ACB, #6B40B6, #6B7280
  Inner label: total coding entries

CHART 4: Top 10 Leaderboard (Horizontal BarChart)
  Y: student names (truncated to 15 chars)
  X: total_score
  Bars: coral gradient
  Clickable bars → navigate to student detail

AT-RISK PANEL:
  "Students Needing Attention" heading (amber left-border card)
  Sub-tabs: Zero Activities | Low Attendance (<75%) | Low CGPA (<5.0)
  Per sub-tab: table with Name | Roll | Class | Year | Value | "View" link

── Global Polish ────────────────────────────────────────────────────
1. Error boundaries on all route-level components:
   Fallback UI: coral icon + "Something went wrong" + "Try Again" button

2. Loading skeletons:
   StudentDirectory: 5 skeleton table rows (shimmer animation)
   StudentDetail: skeleton for left panel + tab content
   Leaderboard: skeleton podium + 10 skeleton rows
   Charts: skeleton rectangles

3. Empty states (consistent pattern):
   Icon (coral, 48px) + heading + subtext + optional CTA button

4. Toast notifications (top-right):
   Success: green bg, white text, check icon
   Error: red bg
   Duration: 3 seconds auto-dismiss
   Use: after every approve/reject/save/import action

5. Confirmation dialogs for destructive actions:
   - Soft-delete entry
   - Reject student registration
   - Bulk reject
   All use Radix Dialog with red confirm button

6. Responsive: dashboard collapses sidebar to icon-only at lg breakpoint
```

---

## Prompt W9 — Supabase Schema Execution + Seed Script

```
Create the following setup scripts for MyCSIT:

1. supabase/seed.sql — seed initial faculty accounts and class assignments:

-- HOD account (create via Supabase Auth first, then insert)
INSERT INTO users (id, full_name, role, status)
VALUES ('<hod-auth-uid>', 'Dr. HOD Name', 'hod', 'active');

-- Class teachers (one per class+year combination, at minimum)
INSERT INTO users (id, full_name, role, status) VALUES
  ('<uid-1>', 'Prof. Teacher 1', 'class_teacher', 'active'),
  ('<uid-2>', 'Prof. Teacher 2', 'class_teacher', 'active');

INSERT INTO faculty_assignments (faculty_id, class, year) VALUES
  ('<uid-1>', 'CSIT1', 1),
  ('<uid-1>', 'CSIT1', 2),
  ('<uid-2>', 'CSIT2', 1);

2. scripts/create_faculty.ts — CLI script to create faculty auth accounts:
   Input: name, email, password, role, class assignments
   Uses supabase.auth.admin.createUser (service role key required)
   Then inserts into users + faculty_assignments

3. scripts/import_roster.ts — CLI script for initial roster import from CSV:
   Input: CSV file path
   Parses with Papa Parse
   Validates each row
   Batch inserts into roster table

4. .env.example:
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key  # for admin scripts only

5. README.md with setup steps:
   1. Create Supabase project
   2. Run schema.sql
   3. Create Storage buckets: proofs (private), avatars (public), excel-uploads (private)
   4. Run seed.sql
   5. Copy .env.example to .env and fill values
   6. npm install && npm run dev (web)
   7. flutter run (mobile)
```

---

*All prompts are sequenced. Each assumes the previous is complete.*
*Mobile (M1–M8) and Web (W1–W9) can be developed in parallel after M1 and W1 are done.*
