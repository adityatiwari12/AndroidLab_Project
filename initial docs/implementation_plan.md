# MyCSIT — Implementation Plan (v2)

## Tech Stack

| Layer             | Choice                                      |
|-------------------|---------------------------------------------|
| Mobile App        | Flutter 3.x + Dart                          |
| Web Dashboard     | React 18 + TypeScript + Vite                |
| Auth              | Supabase Auth (email+password, JWT roles)   |
| Database          | Supabase PostgreSQL (with RLS)              |
| File Storage      | Supabase Storage (3 buckets)                |
| State — Mobile    | Riverpod                                    |
| State — Web       | Zustand                                     |
| UI — Web          | Tailwind CSS + shadcn/ui                    |
| Excel Parsing     | SheetJS (xlsx) on web; dart_excel on mobile |
| Routing — Mobile  | go_router                                   |
| Routing — Web     | React Router v6                             |
| Tables — Web      | TanStack Table v8                           |
| Charts — Web      | Recharts                                    |
| Forms — Web       | React Hook Form + Zod                       |

---

## Supabase Setup Checklist

- [ ] Create project in Supabase dashboard
- [ ] Run `schema.sql` in SQL Editor (top to bottom)
- [ ] Create Storage buckets: `proofs`, `avatars`, `excel-uploads`
- [ ] Set Storage RLS policies per bucket (see schema.sql comments)
- [ ] Seed initial faculty accounts + class assignments via SQL
- [ ] Import first student roster via Excel upload feature (Phase 1)
- [ ] Generate and store `SUPABASE_URL` + `SUPABASE_ANON_KEY` in `.env`

---

## Phase 1 — Foundation: Auth, Roles, Roster Import

**Duration: 1.5 weeks**

### Goals
- Supabase project live, schema deployed
- Student registration against pre-seeded roster
- Pending → Active flow via faculty approval
- Faculty role-based login
- Excel roster upload for admin/HOD

### Student Registration Logic
```
1. Student enters roll number + password
2. App queries roster WHERE roll_number = input AND is_registered = false
   → If not found: "Roll number not recognized. Contact your faculty."
   → If already registered: "This roll number is already in use."
3. On valid: create Supabase auth user (email = rollNumber@mycsit.aitr.ac.in)
4. Insert into users table: { roll_number, full_name, class, year from roster, status: 'pending' }
5. Update roster.is_registered = true
6. Student sees Pending Approval screen
7. Faculty approves → update users.status = 'active', users.approved_by, approved_at
8. Notify student (insert into notifications)
```

### Excel Roster Import
- Accepted format: `.xlsx` with columns: `RollNumber`, `FullName`, `Class`, `Year`, `Semester`, `AcademicYear`
- Parse client-side with SheetJS
- Validate: roll number format, class enum, year 1–4, semester 1–8
- Show preview table with row-level validation badges
- On confirm: batch upsert into `roster` table (upsert on roll_number)
- Log to `upload_log`

### Edge Cases
- Duplicate roll number in Excel → skip with error: "Already exists in roster"
- Student changes device → Supabase persistent session handles it
- Faculty approves wrong student → rejection must remain possible after approval (status toggleable)
- Student registers before roster is imported → blocked at step 2

---

## Phase 2 — Student Profile + Social Links

**Duration: 1 week**

### Goals
- Profile screen with completeness computation
- Social links CRUD
- Avatar upload to Supabase Storage `avatars` bucket

### Profile Completeness Formula
```
score = 0
if (full_name)        score += 10
if (profile_photo)    score += 10
if (linkedin linked)  score += 10
if (github linked)    score += 15
if (leetcode linked)  score += 10
if (codeforces linked) score += 10
if (codechef linked)  score += 10
if (portfolio linked) score += 5
if (has ≥1 activity)  score += 10
if (has ≥1 coding)    score += 10
Total: 100
```

Stored as a derived value — computed on client, not persisted.

### Edge Cases
- Avatar > 2MB → compress client-side (flutter_image_compress) before upload
- URL validation: platform-specific regex (linkedin.com, github.com, etc.)
- Social link removal: DELETE from social_links; completeness updates reactively

---

## Phase 3 — Activity System

**Duration: 1.5 weeks**

### Goals
- Full activity CRUD for students
- Proof upload to `proofs` bucket
- Faculty approval queue with inline approve/reject
- Score recomputation after each approval

### Entry Lifecycle
```
student submits → status: 'pending'
faculty approves → status: 'approved' → call calculate_score(user_id)
faculty rejects → status: 'rejected' + reason
student edits rejected entry → status back to 'pending', reason cleared
faculty soft-deletes approved entry → is_deleted: true → calculate_score(user_id)
```

### Validation Rules
- `activity_date` cannot be in the future (enforced in DB + UI)
- Proof file: image/jpeg, image/png, application/pdf, max 10MB
- Per-student hard cap: 30 total activity entries (UI disables Add beyond this)
- Warn (not block) on duplicate: same title + type within 30 days

### Activity Bulk Upload (Excel)
- Accepted columns: `Title`, `Type`, `Date`, `Description`
  (Proof cannot be bulk-uploaded — still requires individual upload per entry)
- Type must match enum: hackathon/achievement/certification/project/internship/research
- All bulk-imported activities start with `status: 'pending'`
- Validation report shown before commit

---

## Phase 4 — Coding Activity System

**Duration: 1 week**

### Goals
- Structured coding entry forms (milestone, contest, notable problem)
- Per-platform deduplication in scoring (handled in `calculate_score()`)
- Faculty approval flow same as activities

### Scoring Deduplication
The `calculate_score()` function already handles this:
- For milestones: `max(value)` per platform — only highest approved count used
- Adding a new lower milestone doesn't reduce score
- If a higher milestone gets approved later, it replaces the lower one in score

### Validation
- Milestone value: integer > 0; warn if not a round number (50, 100, 200…)
- Contest rank: integer ≥ 1
- Notable problem: difficulty required
- Platform: must be one of the enum values

---

## Phase 5 — Academic Data + Attendance + Excel Imports

**Duration: 1.5 weeks**

### Goals
- Faculty enters marks/CGPA per student per semester
- Attendance tracking with auto-computed percentage
- Excel bulk upload for marks AND attendance
- Score updates after CGPA entry

### Marks Excel Format
```
Expected columns: RollNumber, Semester, AcademicYear, SubjectName, MarksObtained, MaxMarks, CGPA
- CGPA: optional per row; if present, upserts academic_records
- MarksObtained ≤ MaxMarks enforced in validation
- Unknown roll numbers flagged as errors (not inserted)
```

### Attendance Excel Format
```
Expected columns: RollNumber, Semester, AcademicYear, TotalClasses, Attended
- Attended ≤ TotalClasses enforced
- Percentage is a generated column (no need to include in upload)
```

### Edge Cases
- Faculty uploads marks for a student outside their assigned class → RLS blocks the insert
- CGPA entry triggers `calculate_score()` — run after batch commit, not per row
- Missing CGPA for a student: academic_score = 0, shown as "Not entered" in UI
- Excel has merged cells → SheetJS unmerges; validation flags affected rows

---

## Phase 6 — Leaderboard + Analytics

**Duration: 1.5 weeks**

### Goals
- Leaderboard page with all filter dimensions
- Analytics charts for HOD/faculty
- Score snapshot queries optimized

### Leaderboard Query Strategy

Timeframe filtering is based on `score_cache.last_computed`:
- **All-time**: no date filter on score_cache; use as-is
- **Semester-wise**: filter activities/coding by academic_year; recompute on-the-fly for display
  (or store a snapshot per semester — simpler for MVP: use all-time score, semester filter = cohort filter)
- **Weekly/Monthly**: filter activities WHERE `reviewed_at >= now() - interval '7 days'`
  and recompute a temporary score for display (not persisted — computed in a SQL view)

```sql
-- Leaderboard view example (all-time, full dept)
create or replace view leaderboard_full as
select
  u.id,
  u.full_name,
  u.class,
  u.year,
  u.roll_number,
  sc.total_score,
  sc.hackathon_score,
  sc.project_score,
  sc.academic_score,
  sc.coding_score,
  rank() over (order by sc.total_score desc) as overall_rank,
  rank() over (partition by u.class, u.year order by sc.total_score desc) as class_rank
from users u
join score_cache sc on sc.user_id = u.id
where u.role = 'student'
  and u.status = 'active'
order by sc.total_score desc;
```

For weekly/monthly — parameterized function:
```sql
create or replace function leaderboard_period(
  p_class    class_name default null,
  p_year     int        default null,
  p_days     int        default null   -- null = all-time
)
returns table (
  user_id        uuid,
  full_name      text,
  class          class_name,
  year           int,
  total_score    numeric,
  hackathon_score numeric,
  project_score  numeric,
  academic_score numeric,
  coding_score   numeric,
  rank           bigint
)
language sql security definer as $$
  -- For MVP: use score_cache filtered by class/year
  -- Period-specific scoring deferred to v2 (requires activity date filtering per score component)
  select
    u.id, u.full_name, u.class, u.year,
    sc.total_score, sc.hackathon_score, sc.project_score,
    sc.academic_score, sc.coding_score,
    rank() over (order by sc.total_score desc)
  from users u
  join score_cache sc on sc.user_id = u.id
  where u.role = 'student'
    and u.status = 'active'
    and (p_class is null or u.class = p_class)
    and (p_year  is null or u.year  = p_year)
    and (p_days  is null or sc.last_computed >= now() - (p_days || ' days')::interval)
  order by sc.total_score desc;
$$;
```

---

## Phase 7 — Polish, Security Audit, Deployment

**Duration: 1 week**

### Goals
- RLS audit: test all role combinations with Supabase RLS simulator
- Input sanitization pass on all forms
- Proof file signed URL generation (never expose raw storage paths to clients)
- Loading states + error boundaries on all screens
- Flutter APK build + release signing
- React app deployed to Vercel or Supabase Hosting

### Security Checklist
- [ ] RLS tested: student cannot read other student's activities
- [ ] RLS tested: class teacher cannot access unassigned class students
- [ ] `score_cache` has no INSERT/UPDATE policy for authenticated users
- [ ] `calculate_score()` is `security definer` — runs as postgres, not caller
- [ ] Storage signed URLs expire in 1 hour (set in Supabase dashboard)
- [ ] Audit log is insert-only (no UPDATE/DELETE policy)
- [ ] Excel upload validates MIME type server-side (not just extension)

---

## Database Indexes (Beyond Schema Defaults)

Already in schema.sql. Additional composite indexes for leaderboard queries:

```sql
create index idx_score_total   on score_cache(total_score desc);
create index idx_score_class   on users(class, year) where role = 'student' and status = 'active';
create index idx_act_reviewed  on activities(reviewed_at desc) where status = 'approved';
```
