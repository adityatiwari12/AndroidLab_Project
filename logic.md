# MyCSIT — Logic Documentation (v2)

## 1. Authentication & Account Lifecycle

### Student Registration
```
1. Student enters roll number
2. Query: SELECT * FROM roster WHERE roll_number = ? AND is_registered = false
   → Not found:          error "Roll number not recognized. Contact your faculty coordinator."
   → Already registered: error "This roll number is already associated with an account."
   → Found:              pre-fill name, class, year from roster row; show confirmation chip

3. Student completes name, password → submit
4. supabase.auth.signUp({ email: rollNo@mycsit.aitr.ac.in, password })
5. INSERT INTO users: { id, roll_number, full_name, class, year, role:'student', status:'pending' }
6. UPDATE roster SET is_registered = true WHERE roll_number = ?
7. INSERT INTO notifications for all HOD/class_teacher of that class: "New registration: [name]"
8. Student → Pending Approval screen
```

### Pending State Polling
- Flutter app polls `SELECT status FROM users WHERE id = auth.uid()` every 30 seconds
- On status = 'active': force token refresh → navigate to Home
- No Realtime subscription needed; polling is simpler and sufficient for this flow

### Faculty Approval
```
Faculty clicks Approve:
  UPDATE users SET status='active', approved_by=faculty_id, approved_at=now()
  INSERT INTO audit_log: { action:'account_approved', target_type:'user', target_id:student_id, performed_by:faculty_id }
  INSERT INTO notifications (student_id): "Your account has been approved! Welcome to MyCSIT."
  INSERT INTO score_cache (user_id, all scores = 0)  ← initialize row

Faculty clicks Reject:
  UPDATE users SET status='rejected', rejected_reason=reason
  INSERT INTO notifications (student_id): "Your registration was not approved. Reason: [reason]"
```

### HOD vs Class Teacher Access (enforced by RLS)
```
Class teacher can only approve students WHERE class IN (their faculty_assignments)
HOD: no restriction (can_access_student always returns true for role = 'hod')
```

---

## 2. Activity Entry Logic

### Submission Validations
```
client-side:
  - title: 3–150 chars
  - activity_date <= today
  - proof file: MIME = image/jpeg | image/png | application/pdf, size <= 10MB
  - total entries for user: count(*) from activities where user_id = me → block if >= 30

server-side (DB constraint):
  - activity_date <= current_date (CHECK constraint)
  - title length (CHECK constraint)
```

### Duplicate Warning (not a hard block)
```
Before submit, query:
  SELECT id FROM activities
  WHERE user_id = me
    AND type = selected_type
    AND title ILIKE '%' || entered_title || '%'
    AND activity_date >= now() - interval '30 days'
  LIMIT 1

If found → show amber warning banner: "A similar entry exists recently. Continue anyway?"
```

### Approval → Score Recomputation
```
Faculty approves activity:
  UPDATE activities SET status='approved', reviewed_by=faculty_id, reviewed_at=now()
  INSERT INTO audit_log
  INSERT INTO notifications (student)
  SELECT calculate_score(student_id)   ← PostgreSQL function call via Supabase RPC
```

### Resubmission of Rejected Entry
```
Allowed only if: status = 'rejected'
Student can edit: title, description, activity_date, proof_path
On update:
  UPDATE activities SET status='pending', rejection_reason=null, updated_at=now()
Faculty re-enters approval queue
```

### Soft Delete by Faculty
```
UPDATE activities SET is_deleted=true, deleted_by=faculty_id
INSERT INTO audit_log: { action:'entry_deleted', ... }
SELECT calculate_score(student_id)  ← score drops if this entry was contributing
```

---

## 3. Coding Activity Logic

### Entry Type Validations
| Type             | Required Fields                        | Constraints                     |
|------------------|----------------------------------------|---------------------------------|
| milestone        | platform, value                        | value > 0, integer              |
| contest          | platform, contest_name, value (rank)   | value >= 1                      |
| notable_problem  | platform, title, difficulty            | difficulty in (easy,medium,hard)|

### Milestone Deduplication in Scoring
```
The calculate_score() function uses:
  SELECT platform, MAX(value) as max_val
  FROM coding_activities
  WHERE user_id = p_user_id AND type = 'milestone' AND status = 'approved'
  GROUP BY platform

So if a student has: LeetCode 100 (approved) and LeetCode 200 (approved)
→ only 200 is used. Score never double-counts.

Implication: student should submit a new milestone (200) not edit the old one (100).
Old one stays approved for audit trail; new one supercedes it in scoring.
```

### Contest Count Cap
```
Approved contests across all platforms, capped at 10 in the scoring formula.
11th contest is stored and approved but doesn't increase coding score further.
Faculty can still approve it (for student's profile display purposes).
```

---

## 4. Scoring System

### Formula
```
total_score = (hackathon_score × 0.35)
            + (project_score   × 0.25)
            + (academic_score  × 0.25)
            + (coding_score    × 0.15)

All component scores: 0.00 – 100.00
total_score: 0.00 – 100.00 (rounded to 2 decimal places)
```

### Hackathon Score (35% weight)
```
Eligible types: hackathon (1.0), achievement (0.7), certification (0.5)
Per type: top 3 approved entries by activity_date desc
raw = sum(type_weight × min(count, 3) for each eligible type)
max_raw = 3 × 1.0 + 3 × 0.7 + 3 × 0.5 = 6.6   ← NOT 9 (corrected)
hackathon_score = LEAST((raw / 6.6) × 100, 100)
```

### Project Score (25% weight)
```
Eligible types: internship (1.0), research (0.9), project (0.8)
Per type: top 3 approved entries
raw = sum(type_weight × min(count, 3) for each eligible type)
max_raw = 3 × 1.0 + 3 × 0.9 + 3 × 0.8 = 8.1
project_score = LEAST((raw / 8.1) × 100, 100)
```

> Note: The schema.sql uses simplified max values for the initial implementation.
> Update the constants in calculate_score() to 6.6 and 8.1 for precision.

### Academic Score (25% weight)
```
cgpa = most recent academic_records row for this student (highest semester, latest updated_at)
academic_score = (cgpa / 10.0) × 100
If no record: academic_score = 0 (displayed as "Not entered" in UI)
```

### Coding Score (15% weight)
```
milestone_avg = avg(MAX(value) per platform) / 500.0   → capped at 1.0
contest_ratio = count(approved contests) / 10.0        → capped at 1.0
coding_score  = (milestone_avg × 50) + (contest_ratio × 50)

Example:
  LeetCode best milestone: 300 → 300/500 = 0.6
  Codeforces best: 150 → 150/500 = 0.3
  avg = (0.6 + 0.3) / 2 = 0.45 → milestone contribution = 0.45 × 50 = 22.5
  Contests: 6 → 6/10 = 0.6 → contest contribution = 0.6 × 50 = 30
  coding_score = 22.5 + 30 = 52.5
```

### When calculate_score() Is Called
```
Via Supabase RPC (supabase.rpc('calculate_score', { p_user_id: id })):
  - After faculty approves or rejects any activity entry
  - After faculty approves or rejects any coding entry
  - After faculty enters or updates CGPA
  - After faculty soft-deletes an approved entry
  - On bulk approval (called once per student after batch commit)
```

### Score Anti-Manipulation Rules
```
- score_cache has no RLS INSERT/UPDATE policy for students or class_teacher role
- calculate_score() runs as security definer (postgres role)
- Only approved entries (status = 'approved' AND is_deleted = false) count
- Per-type caps (top 3) prevent farming of a single category
- Coding milestone deduplication prevents re-submitting milestones for inflation
```

---

## 5. Leaderboard Logic

### Timeframe Definitions
```
All-time:       use score_cache as-is (reflects all ever-approved entries)
This semester:  filter by academic_year + current semester (scope = cohort, not score period)
This month:     filter score_cache WHERE last_computed >= now() - interval '30 days'
This week:      filter score_cache WHERE last_computed >= now() - interval '7 days'
```

> Limitation: weekly/monthly in MVP reflects when the score was last recalculated,
> not when activities were done. True period-based scoring (score from entries approved
> in the last 7 days only) is a v2 feature and requires per-period score recomputation.

### Scope Filtering
```
Full department: no class/year filter
Single class:   WHERE u.class = 'CSIT1'
Single year:    WHERE u.year = 2
Both:           WHERE u.class = 'CSIT1' AND u.year = 2
```

### Rank By Options
```
The ORDER BY and displayed column changes based on selection:
  Total Score    → ORDER BY sc.total_score DESC
  Hackathon      → ORDER BY sc.hackathon_score DESC
  Projects       → ORDER BY sc.project_score DESC
  Academic       → ORDER BY sc.academic_score DESC
  Coding         → ORDER BY sc.coding_score DESC
```

### Class Teacher Leaderboard Access
```
Class teacher sees leaderboard filtered to their assigned classes only.
If assigned to CSIT1-Year2 and CSIT2-Year2, they see both but not CY-Year2.
HOD sees the global leaderboard with all classes.
```

---

## 6. Excel Upload Logic

### Processing Pipeline (all upload types)
```
1. User selects .xlsx / .xls / .csv file
2. Client-side parse with SheetJS (xlsx library)
3. Normalize headers: trim whitespace, lowercase, remove special chars
4. Column mapping: auto-map known header names; show manual mapper if ambiguous
5. Row-by-row validation:
   - Required fields present
   - Enum values match allowed list
   - Numeric ranges valid
   - Dates parseable and not future (for activities)
   - Roll numbers exist in roster (for marks/attendance)
6. Show preview table:
   - Valid rows: white background, green dot
   - Invalid rows: red background, error message in last column
7. Faculty clicks "Import [N] valid rows"
8. Batch INSERT using Supabase client (.from('table').insert([...]))
9. INSERT INTO upload_log: { file_name, total_rows, successful_rows, failed_rows, error_report }
10. Show summary toast: "180 rows imported, 4 skipped. Download error report?"
```

### Roster Upload Column Mapping
```
Required: RollNumber, FullName, Class, Year, Semester, AcademicYear
Class values accepted: CSIT1, CSIT2, CY (case-insensitive)
Year values accepted: 1, 2, 3, 4 (or "1st", "2nd" etc. — normalize in parser)
On conflict (roll_number exists): UPDATE non-key fields (upsert)
```

### Marks Upload Column Mapping
```
Required: RollNumber, Semester, AcademicYear, SubjectName, MarksObtained, MaxMarks
Optional: CGPA (if present per row, upserts academic_records.cgpa)
Validation: MarksObtained <= MaxMarks, MaxMarks > 0
Unknown roll number → error row
After commit: call calculate_score() for each unique student in the upload
```

### Attendance Upload Column Mapping
```
Required: RollNumber, Semester, AcademicYear, TotalClasses, Attended
Validation: Attended <= TotalClasses, TotalClasses > 0
Percentage auto-computed by generated column
```

### Activity Bulk Upload Column Mapping
```
Required: RollNumber, Type, Title, Date
Optional: Description
Type must match enum; Date must be parseable (DD/MM/YYYY or YYYY-MM-DD)
All imported activities → status: 'pending' (still need faculty approval)
Proof cannot be bulk uploaded — student must add individually
```

---

## 7. Role & Permission Matrix

| Action                          | Student  | Class Teacher | HOD     |
|---------------------------------|----------|---------------|---------|
| Register account                | ✓ (self) | —             | —       |
| Approve student registration    | —        | Own class     | All     |
| View student profiles           | Own only | Own classes   | All     |
| Log activities                  | ✓ (self) | —             | —       |
| Approve/reject activities       | —        | Own classes   | All     |
| Soft-delete approved entries    | —        | Own classes   | All     |
| Enter marks/CGPA                | —        | Own classes   | All     |
| Enter attendance                | —        | Own classes   | All     |
| Upload Excel (any type)         | —        | ✓             | ✓       |
| View leaderboard                | Own rank | Own classes   | All     |
| View analytics                  | —        | Own classes   | All     |
| View audit log                  | —        | —             | ✓       |

---

## 8. Edge Cases Reference

| Scenario | Behavior |
|---|---|
| Student submits roll number not in roster | Blocked with clear error message |
| Faculty tries to approve student outside their class | Blocked by RLS (403) |
| CGPA entered as 11 (out of range) | DB CHECK constraint rejects; UI shows validation error |
| Excel uploaded with merged cells | SheetJS unmerges; affected rows flagged in preview |
| Excel headers don't match expected names | Column mapping UI shown; user drags to match |
| Activity proof is a .docx file | Rejected at client (MIME validation) and server (Storage policy) |
| Student submits same milestone twice (e.g., 200 again) | Both can be approved; scoring uses MAX(value) — no inflation |
| Faculty bulk approves 20 items | calculate_score() called once per unique student (batched) |
| HOD edits a class teacher's entry | Allowed — HOD override is by design |
| Student sees score_cache directly via Supabase client | RLS blocks SELECT if role is student for other students' rows |
| Score recomputed while user is viewing leaderboard | Page shows stale data until next refresh (no Realtime in MVP) |
| Roster uploaded with a student already registered | Upsert updates name/class/year but does NOT reset is_registered |
| Contest rank = 0 submitted | DB CHECK constraint rejects (value >= 1 for contests) |
| Attendance: attended > total_classes in Excel | Flagged as invalid row; not imported |
| Faculty deletes own account | Admin role only via Supabase dashboard; no UI for this |
