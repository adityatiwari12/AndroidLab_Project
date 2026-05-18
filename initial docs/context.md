# MyCSIT — Product Context (v2)

## What Is MyCSIT?

MyCSIT is a **department-level student intelligence platform** for the CSIT department at
Acropolis Institute of Technology and Research (AITR), Indore (RGPV). It consists of:

- A **Flutter mobile app** for students
- A **React + TypeScript web dashboard** for faculty
- A **Supabase backend** — PostgreSQL + Auth + Storage (no Edge Functions, no Realtime in MVP)

The system converts fragmented student data — academic records, hackathons, projects, coding
activity — into a verified, scored, and queryable intelligence layer that faculty can act on.

---

## Department Structure

| Class  | Branch              | Years Available |
|--------|---------------------|-----------------|
| CSIT1  | CS & IT (Section 1) | 1, 2, 3, 4      |
| CSIT2  | CS & IT (Section 2) | 1, 2, 3, 4      |
| CY     | Cyber Security      | 1, 2, 3, 4      |

- 3 classes × 4 years = **12 cohorts**
- ~60 students per class → ~180/year → **~720 total students**
- All three classes share the same scoring system and feature set

---

## User Roles

### Student
- Can only register if their roll number exists in the admin-seeded roster
- Account stays `pending` until a faculty member approves it
- Once `active`: logs activities, coding entries, views own score + profile
- Cannot see other students' data

### Class Teacher
- Assigned to one or more specific class+year combinations (e.g., CSIT1-Year2)
- Sees and manages only students in their assigned classes
- Can approve/reject student registrations and activity entries for their classes
- Enters marks and attendance for their classes
- Can upload Excel sheets for batch data entry

### HOD (Head of Department)
- Unrestricted access across all classes, all years
- Sees global leaderboard and cross-class analytics
- Can override approvals in any class
- Receives all pending approval notifications

### System Admin (implicit, no UI)
- Seeds faculty accounts and class assignments via Supabase dashboard or script
- Imports student roster CSV at semester start
- Not a user-facing role in MVP

---

## Core Design Principles

1. **Roster-Anchored Registration** — Students cannot register unless their roll number is
   pre-seeded. This eliminates fake accounts at the source.
2. **Proof-Gated Entries** — Every activity and coding entry requires a proof file upload.
   No proof = form does not submit.
3. **Separation of Trust** — Students generate data, faculty validate it, the DB computes
   scores from approved entries only.
4. **Role-Scoped Visibility** — Class teachers see their classes; HOD sees everything.
   Enforced at the PostgreSQL Row Level Security (RLS) layer, not just the UI.
5. **Signal over Noise** — Activities are categorized and capped per type to prevent
   score farming. Quality beats quantity.
6. **Excel-First Bulk Input** — Faculty already maintain Excel sheets. The system must
   accept those sheets directly instead of forcing re-entry.

---

## Scoring Model

Faculty priority ranking:

| Component              | Weight | Entry Types Included                          |
|------------------------|--------|-----------------------------------------------|
| Hackathons & Events    | 35%    | hackathon, achievement, certification         |
| Projects & Internships | 25%    | project, internship, research                 |
| Academic (CGPA)        | 25%    | Faculty-entered CGPA, normalized 0–10 → 0–100 |
| Coding Activity        | 15%    | Milestones + contests across platforms        |

Each component scores 0–100. Total score = weighted sum = 0–100.
Score is **computed on the server (PostgreSQL function)**, never client-side.
Only **approved** entries count toward score.

---

## Leaderboard Dimensions

| Axis      | Options                                                     |
|-----------|-------------------------------------------------------------|
| Timeframe | Weekly / Monthly / Semester-wise / All-time                 |
| Scope     | Single class / Single year / Full department                |
| Metric    | Total score / Hackathon score / Project score / CGPA score / Coding score |

Leaderboards are visible to faculty and HOD only. Students see only their own rank
(e.g., "You are ranked #12 in CSIT1-Year2").

---

## Excel Upload Scope

Faculty can upload Excel (.xlsx) sheets for:

| Sheet Type         | What It Populates              | Validation Required                        |
|--------------------|--------------------------------|--------------------------------------------|
| Student Roster     | `roster` table                 | Roll number format, class, year            |
| Marks Sheet        | `academic_records` table       | Subject names, marks range 0–max           |
| Attendance Sheet   | `attendance` table             | Total ≥ attended, percentage auto-computed |
| Activity Bulk      | `activities` table (pending)   | Type enum, date format, mandatory fields   |

All uploads show a **preview + validation report** before committing. Invalid rows are
highlighted and skipped; valid rows are committed. Faculty gets a row-level error log.

---

## Success Criteria

- Faculty shortlists top 10 students for an opportunity in under 90 seconds
- Zero unverified entries affect any student's score
- Leaderboard reflects latest approvals within one page refresh
- Excel upload handles 200-row sheet in under 5 seconds
- RLS enforced: class teacher cannot query students outside their assignment
