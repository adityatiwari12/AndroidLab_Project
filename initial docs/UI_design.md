# MyCSIT — UI Design Specification (v2)

## Design Language

**Aesthetic:** Clean, card-based, warm-white surfaces with coral/orange accent.
Directly mirrors the reference ed-tech app image provided.
Feels like a modern consumer product, not an enterprise admin panel.

---

## Design Tokens

### Colors
```
Primary:           #FF6B35   (coral-orange)
Primary Light:     #FFF3EE   (peach tint — card backgrounds, active states)
Primary Dark:      #E8521A   (hover, pressed)
Accent:            #FF9F1C   (warm amber — gradient partner)

Success:           #22C55E
Success Light:     #DCFCE7
Warning:           #F59E0B
Warning Light:     #FEF3C7
Error:             #EF4444
Error Light:       #FEE2E2
Info:              #3B82F6
Info Light:        #DBEAFE

Background:        #F7F8FA   (off-white body)
Surface:           #FFFFFF
Border:            #EEEEEE
Divider:           #F3F4F6

Text Primary:      #111827
Text Secondary:    #6B7280
Text Muted:        #9CA3AF
Text Inverse:      #FFFFFF
```

### Activity Type Colors
```
hackathon:    #8B5CF6  (purple)
achievement:  #EF4444  (red)
certification:#3B82F6  (blue)
project:      #10B981  (emerald)
internship:   #F59E0B  (amber)
research:     #EC4899  (pink)
milestone:    #06B6D4  (cyan)
contest:      #FF6B35  (coral)
```

### Typography
```
Display/Headings:  Poppins  (700 Bold, 600 SemiBold)
Body:              DM Sans  (400 Regular, 500 Medium)
Numbers/Scores:    JetBrains Mono (monospace for score displays)
```

### Spacing (8pt grid)
```
4 / 8 / 12 / 16 / 24 / 32 / 48 / 64
```

### Border Radii
```
sm: 8px   md: 12px   lg: 16px   xl: 24px   pill: 9999px
```

### Shadows
```
card:        0 2px 12px rgba(0,0,0,0.06)
elevated:    0 4px 24px rgba(0,0,0,0.10)
accent-glow: 0 4px 20px rgba(255,107,53,0.28)
```

---

## Status Badge System

| Status   | Text Color | Background |
|----------|------------|------------|
| pending  | #F59E0B    | #FEF3C7    |
| approved | #22C55E    | #DCFCE7    |
| rejected | #EF4444    | #FEE2E2    |

---

## Mobile App (Flutter) — All Screens

### 1. Splash
- White bg, centered "MyCSIT" wordmark in Poppins Bold
- Coral underline animates in (400ms ease-out)
- Auto-navigate based on Supabase session state

### 2. Login
- Large "Welcome Back 👋" (Poppins Bold 28px)
- Muted subtext: "Log in with your college credentials"
- Roll number field (outlined, radius 12px, coral focus ring)
- Password field (show/hide toggle)
- Coral pill CTA: "Login" (full width, 52px)
- Bottom link: "New here? Register" (coral text)

### 3. Register
- Back arrow
- "Create Account" heading
- Fields: Full Name, Roll Number, Password, Confirm Password
- Class and Year auto-filled from roster lookup after roll number blur
- Show: "[Name] found — CSIT1, Year 2" confirmation chip in coral before submit
- Submit CTA: "Register"
- On unrecognised roll number: inline red error "Roll number not in our records"

### 4. Pending Approval
- Centered layout
- Hourglass icon (coral, 72px)
- "Awaiting Approval" (Poppins SemiBold 22px)
- Subtext: "Your account is under review by faculty."
- Polls Supabase every 30 seconds; auto-navigates to Home on status → active
- "Logout" outlined button (coral)

### 5. Home / Dashboard Tab
- **AppBar:** Avatar + "Hi, [First Name] 👋" + bell icon
- **Score Card** (coral gradient, radius 20px, accent-glow shadow):
  - Circular progress ring (profile completeness %)
  - Total score in JetBrains Mono Bold 36px white
  - 3 sub-score pills: Hackathon | Projects | Coding
- **Quick Actions** (horizontal row of icon cards, white, 64×64px):
  Add Activity / Add Coding / Timeline / Academics
- **Recent Entries** section: last 3 with type color bar + status badge
- **Marks Snapshot**: horizontal scroll, one card per semester

### 6. Profile Tab
- Coral header (100px), overlapping avatar (80px, white border, edit overlay)
- Name, roll number, year, class — read-only fields (greyed)
- Linear progress bar (coral, 8px, rounded): profile completeness
- Missing field chips: "Add GitHub +", "Add LeetCode +" etc.
- **Online Presence grid** (2 columns, platform tiles):
  - Linked: platform icon + username + coral check badge
  - Unlinked: "Add" in muted, tap → URL input bottom sheet
- Logout tile (red text, bottom)

### 7. Activity Log (Timeline Tab)
- Filter chips row: All | Hackathon | Certification | Research | Project | Internship | Achievement
- Status segmented control: All / Pending / Approved / Rejected
- Entry cards:
  - Left: 4px type-colored vertical bar
  - Type pill + title + date
  - Right: status badge
- Tap → Activity Detail

### 8. Add Activity (Bottom Sheet, 3 steps)
- Step 1: Type grid (6 icon tiles, coral border on selected)
- Step 2: Title + Date picker (no future) + Description
- Step 3: Proof upload zone (dashed coral border, tap to pick, shows filename on select)
- Submit: optimistic insert, pending badge shown immediately

### 9. Add Coding (Bottom Sheet, 4 steps)
- Step 1: Type (Milestone / Contest / Notable Problem)
- Step 2: Platform (LeetCode / Codeforces / CodeChef / Other)
- Step 3: Details by type (see logic.md)
- Step 4: Proof upload (same as activity)

### 10. Coding Tab
- 3 sub-tabs: Milestones | Contests | Problems
- Cards: platform logo circle + title + value + status
- FAB (coral, +)

### 11. Academics (read-only)
- Per-semester accordion (Sem 1 → Sem 8)
- Subjects table: name | marks | max | %
- CGPA chip at top of each accordion
- Circular attendance gauge (coral): percentage, color-coded

### 12. My Rank Screen (accessible from Score Card tap)
- "Your Rank in [CSIT1 - Year 2]" heading
- Large rank number: "#12 / 58" in JetBrains Mono
- Score breakdown horizontal bars:
  - Hackathons (35%) — filled bar + score
  - Projects (25%) — filled bar + score
  Academic (25%) — filled bar + score
  - Coding (15%) — filled bar + score
- Note: "Overall department rank visible to faculty"

### 13. Notifications
- List: icon (colored by type) + title + body + relative time
- Tap to mark as read
- "Mark all read" button in AppBar

---

## Faculty Web Dashboard — All Pages

### Layout Shell
- **Sidebar** (240px, fixed, white):
  - Logo top
  - Nav items with active: coral bg (#FFF3EE), coral left border (3px), coral icon+text
  - Items: Dashboard | Students | Approvals (badge) | Marks | Attendance | **Leaderboard** | Analytics | Uploads
  - Bottom: faculty name + role chip + logout
- **Top bar** (64px, white, bottom border):
  - Page title (Poppins SemiBold 20px)
  - Class scope indicator ("Viewing: CSIT1 - Year 2" for class teacher, "All Classes" for HOD)
  - Search + notification bell

### 1. Dashboard Overview
- 4 stat cards (coral icon, white card, radius 16px):
  Total Students | Pending Approvals | Avg CGPA | Avg Total Score
- Score distribution bar chart (Recharts)
- Activity participation donut
- At-risk panel: students with 0 approved activities

### 2. Student Directory
- Left filter panel (collapsible, 280px):
  Year checkboxes | Class checkboxes | CGPA range | Score range | Has Activities | Has Coding
- TanStack Table:
  Cols: Name+Avatar | Roll No | Class | Year | CGPA | Total Score (progress bar) | Activities | Actions
- Row click → Student Detail
- Top bar: count + Search + Export CSV

### 3. Student Detail (5 tabs)
- Left panel: avatar, name, roll, class/year, social links
- **Tab: Overview** — score breakdown bars + quick stats
- **Tab: Activities** — full list + inline approve/reject for pending
- **Tab: Coding** — grouped by platform accordion + inline approvals
- **Tab: Academics** — semester accordion, editable CGPA, subject marks, attendance
- **Tab: Score Breakdown** — detailed formula display with actual values

### 4. Approval Queue (3 tabs)
- **Student Registrations**: name, roll, class, year, submitted time → Approve / Reject
- **Activity Entries**: student, type, title, proof link → Approve / Reject + reason
- **Coding Entries**: same pattern
- Bulk select (checkbox) + floating action bar: "Approve X selected"
- Empty state per tab: "All caught up ✓"

### 5. Marks Management
- Student search/select combobox
- Semester accordion → subject marks table (inline editable)
- CGPA override field → Save → triggers `calculate_score()` call
- **Excel Upload panel**:
  - Drag-drop zone or file picker (.xlsx, .xls, .csv)
  - Preview table after parse: valid rows (white), invalid rows (red highlight)
  - Column mapping UI: drag columns to match expected fields if headers differ
  - "Import X valid rows" button → commit + show upload summary

### 6. Attendance Management
- Year + Class filter
- Inline editable table: Roll No | Name | Total | Attended | % (auto, color-coded)
- "Set Total Classes for All" bulk field
- Excel upload (same pattern as marks)

### 7. Leaderboard ⭐ (New Page)

This is the crown feature of the faculty dashboard.

**Top Filter Bar** (always visible, sticky):
```
[ Class: All ▾ ]  [ Year: All ▾ ]  [ Period: All-time ▾ ]  [ Rank By: Total Score ▾ ]
```

- **Class:** All / CSIT1 / CSIT2 / CY
- **Year:** All / 1st / 2nd / 3rd / 4th
- **Period:** All-time / This Semester / This Month / This Week
- **Rank By:** Total Score / Hackathon Score / Project Score / Academic Score / Coding Score

**Podium Section** (top 3 students, when not filtered too narrowly):
- Visual podium: 2nd (silver, left), 1st (coral/gold, center elevated), 3rd (bronze, right)
- Each: avatar circle, name, rank number, score
- Coral glow on 1st place card

**Leaderboard Table** (rank 4 onwards):
- Cols: Rank # | Name | Class | Year | Total Score | Hackathon | Projects | CGPA | Coding
- Rank change indicator: ↑ ↓ = (compared to previous period — Phase 2 feature, show "—" in MVP)
- Row click → Student Detail
- Score cells: colored bars (coral to white, proportional)
- Highlight top 10 rows with light coral row background

**Class Comparison Panel** (HOD only, sidebar chart):
- Horizontal bar chart: avg score per class (CSIT1 / CSIT2 / CY)
- Toggle between total score and per-component

### 8. Analytics
- CGPA histogram (Recharts BarChart)
- Top 10 students chart (clickable → Student Detail)
- Activity type breakdown grouped bar
- Coding platform donut
- At-risk list (0 approved activities)

### 9. Uploads (Bulk Data Management)
- Single page for all Excel imports
- Tabs: Roster | Marks | Attendance | Activities
- Per tab: upload zone + format guide (expandable) + recent upload history
- Upload history table: file name | date | rows processed | errors | uploaded by
- Download error report button per upload

---

## Shared Component Patterns

### Primary Button
```
bg: #FF6B35 | text: white | radius: 9999px | padding: 14px 28px
hover: #E8521A + scale(1.01) | shadow: accent-glow
```

### Input Field
```
border: 1px solid #EEEEEE | radius: 12px | bg: #F7F8FA
focus-border: #FF6B35 | padding: 12px 16px | DM Sans 14px
```

### Card
```
bg: white | radius: 16px | shadow: card | padding: 24px (web), 16px (mobile)
```

### Accent Gradient Card
```
bg: linear-gradient(135deg, #FF6B35 0%, #FF9F1C 100%)
radius: 20px | shadow: accent-glow | text: white
```

### Data Table (Web)
```
header bg: #F7F8FA | header text: muted | border: none
row separator: 1px solid #F3F4F6 | row hover: #FFF8F5
active sort column: coral header text
```
