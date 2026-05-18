import type { Student, ScoreCache, StudentWithScore, Activity, CodingActivity, AcademicRecord, LeaderboardRow } from '../types'

// ── Students ─────────────────────────────────────────────────────────────────

export const students: Student[] = [
  { id: 'user-09', rollNumber: '0191CS009', fullName: 'Aditya Tiwari', classGroup: 'CSIT1', year: 2, status: 'active', email: '0191CS009@mycsit.aitr.ac.in', registeredAt: '2024-07-01' },
  { id: 'user-12', rollNumber: '0191CS012', fullName: 'Akshay Khanna', classGroup: 'CSIT1', year: 2, status: 'active', email: '0191CS012@mycsit.aitr.ac.in', registeredAt: '2024-07-05' },
  { id: 'user-23', rollNumber: '0191CS023', fullName: 'Anvesh Trivedi', classGroup: 'CSIT1', year: 2, status: 'active', email: '0191CS023@mycsit.aitr.ac.in', registeredAt: '2024-07-02' },
  { id: 'user-24', rollNumber: '0191CS024', fullName: 'Aryan Singh Bhadoria', classGroup: 'CSIT1', year: 2, status: 'active', email: '0191CS024@mycsit.aitr.ac.in', registeredAt: '2024-06-30' },
]

export const pendingStudents: Student[] = [
  { id: 'user-pending-1', rollNumber: '0191CS015', fullName: 'Ravi Sharma', classGroup: 'CSIT1', year: 2, status: 'pending', email: '0191CS015@mycsit.aitr.ac.in', registeredAt: '2025-05-10' },
  { id: 'user-pending-2', rollNumber: '0191CS031', fullName: 'Priya Gupta', classGroup: 'CSIT2', year: 2, status: 'pending', email: '0191CS031@mycsit.aitr.ac.in', registeredAt: '2025-05-12' },
]

// ── Scores ────────────────────────────────────────────────────────────────────

export const scores: ScoreCache[] = [
  { userId: 'user-09', totalScore: 65.25, hackathonScore: 67.5, projectScore: 50.0, academicScore: 85.0, codingScore: 52.5 },
  { userId: 'user-12', totalScore: 55.88, hackathonScore: 55.0, projectScore: 45.0, academicScore: 77.5, codingScore: 40.0 },
  { userId: 'user-23', totalScore: 72.50, hackathonScore: 72.5, projectScore: 65.0, academicScore: 87.5, codingScore: 60.0 },
  { userId: 'user-24', totalScore: 79.63, hackathonScore: 85.0, projectScore: 75.0, academicScore: 82.5, codingScore: 70.0 },
]

// ── Activities ────────────────────────────────────────────────────────────────

export const activities: Activity[] = [
  // Aditya
  { id: 'act-09-1', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', type: 'hackathon', title: 'Smart India Hackathon 2024', description: 'Built an AI-powered crop disease detection app for farmers.', activityDate: '2024-08-15', proofPath: 'proof.pdf', status: 'approved', createdAt: '2024-08-16' },
  { id: 'act-09-2', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', type: 'certification', title: 'Python for Data Science (Coursera)', description: 'IBM Python certification.', activityDate: '2024-07-20', proofPath: 'coursera_cert.pdf', status: 'approved', createdAt: '2024-07-22' },
  { id: 'act-09-3', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', type: 'achievement', title: 'AITR Tech Fest 2024 – 1st Place', description: 'Won first prize in Project Exhibition.', activityDate: '2024-10-05', proofPath: 'prize.jpg', status: 'approved', createdAt: '2024-10-06' },
  { id: 'act-09-4', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', type: 'project', title: 'Personal Portfolio Website', description: 'Full-stack portfolio with React.', activityDate: '2025-01-15', proofPath: 'screenshot.png', status: 'pending', createdAt: '2025-01-16' },
  { id: 'act-09-5', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', type: 'research', title: 'Blockchain in Healthcare – Research Paper', description: 'Survey on blockchain in medical records.', activityDate: '2025-02-10', proofPath: 'paper.pdf', status: 'rejected', rejectionReason: 'Provide DOI or published journal link.', createdAt: '2025-02-11' },
  { id: 'act-09-6', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', type: 'certification', title: 'AWS Cloud Practitioner Essentials', description: 'AWS cloud cert.', activityDate: '2025-03-01', proofPath: 'aws.pdf', status: 'pending', createdAt: '2025-03-02' },
  // Akshay
  { id: 'act-12-1', userId: 'user-12', studentName: 'Akshay Khanna', rollNumber: '0191CS012', type: 'certification', title: 'Java Programming – NPTEL', description: 'NPTEL 12-week Java cert.', activityDate: '2024-11-30', proofPath: 'nptel.pdf', status: 'approved', createdAt: '2024-12-01' },
  { id: 'act-12-2', userId: 'user-12', studentName: 'Akshay Khanna', rollNumber: '0191CS012', type: 'project', title: 'Library Management System', description: 'C++ desktop app.', activityDate: '2025-01-10', proofPath: 'lms.zip', status: 'pending', createdAt: '2025-01-11' },
  // Anvesh
  { id: 'act-23-1', userId: 'user-23', studentName: 'Anvesh Trivedi', rollNumber: '0191CS023', type: 'hackathon', title: 'Flipkart Grid 6.0', description: 'Qualified Level 2.', activityDate: '2024-09-20', proofPath: 'grid.pdf', status: 'approved', createdAt: '2024-09-21' },
  { id: 'act-23-2', userId: 'user-23', studentName: 'Anvesh Trivedi', rollNumber: '0191CS023', type: 'internship', title: 'Web Development Intern – TechCorp', description: '2-month internship building React dashboards.', activityDate: '2024-06-01', proofPath: 'internship.pdf', status: 'approved', createdAt: '2024-08-05' },
  { id: 'act-23-3', userId: 'user-23', studentName: 'Anvesh Trivedi', rollNumber: '0191CS023', type: 'achievement', title: 'Google DSC Core Team Member', description: 'Selected for GDSC AITR.', activityDate: '2024-08-10', proofPath: 'gdsc.pdf', status: 'approved', createdAt: '2024-08-11' },
  // Aryan
  { id: 'act-24-1', userId: 'user-24', studentName: 'Aryan Singh Bhadoria', rollNumber: '0191CS024', type: 'hackathon', title: 'HackWithInfy 2024', description: 'Reached semi-finals.', activityDate: '2024-07-05', proofPath: 'infosys.pdf', status: 'approved', createdAt: '2024-07-06' },
  { id: 'act-24-2', userId: 'user-24', studentName: 'Aryan Singh Bhadoria', rollNumber: '0191CS024', type: 'internship', title: 'ML Intern – AIIMS Bhopal', description: 'Medical image segmentation research.', activityDate: '2024-05-15', proofPath: 'aiims.pdf', status: 'approved', createdAt: '2024-08-01' },
  { id: 'act-24-3', userId: 'user-24', studentName: 'Aryan Singh Bhadoria', rollNumber: '0191CS024', type: 'achievement', title: 'GATE 2025 Qualified', description: 'Score 612.', activityDate: '2025-02-20', proofPath: 'gate.pdf', status: 'approved', createdAt: '2025-03-05' },
]

// ── Coding Activities ─────────────────────────────────────────────────────────

export const codingActivities: CodingActivity[] = [
  { id: 'cod-09-1', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', platform: 'leetcode', type: 'milestone', value: 250, status: 'approved', createdAt: '2024-11-10' },
  { id: 'cod-09-2', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', platform: 'codeforces', type: 'milestone', value: 100, status: 'approved', createdAt: '2024-12-05' },
  { id: 'cod-09-3', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', platform: 'leetcode', type: 'contest', title: 'Biweekly Contest 128', value: 1502, status: 'approved', createdAt: '2024-12-21' },
  { id: 'cod-09-4', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', platform: 'leetcode', type: 'contest', title: 'Weekly Contest 394', value: 890, status: 'pending', createdAt: '2025-04-06' },
  { id: 'cod-09-5', userId: 'user-09', studentName: 'Aditya Tiwari', rollNumber: '0191CS009', platform: 'leetcode', type: 'notableProblem', title: 'Merge K Sorted Lists', difficulty: 'hard', status: 'approved', createdAt: '2025-01-12' },
  { id: 'cod-12-1', userId: 'user-12', studentName: 'Akshay Khanna', rollNumber: '0191CS012', platform: 'leetcode', type: 'milestone', value: 80, status: 'approved', createdAt: '2025-01-05' },
  { id: 'cod-23-1', userId: 'user-23', studentName: 'Anvesh Trivedi', rollNumber: '0191CS023', platform: 'leetcode', type: 'milestone', value: 320, status: 'approved', createdAt: '2024-10-15' },
  { id: 'cod-23-2', userId: 'user-23', studentName: 'Anvesh Trivedi', rollNumber: '0191CS023', platform: 'codeforces', type: 'contest', title: 'Div 2 Round 949', value: 312, status: 'approved', createdAt: '2024-11-20' },
  { id: 'cod-23-3', userId: 'user-23', studentName: 'Anvesh Trivedi', rollNumber: '0191CS023', platform: 'codechef', type: 'milestone', value: 150, status: 'approved', createdAt: '2025-02-01' },
  { id: 'cod-24-1', userId: 'user-24', studentName: 'Aryan Singh Bhadoria', rollNumber: '0191CS024', platform: 'leetcode', type: 'milestone', value: 450, status: 'approved', createdAt: '2024-09-10' },
  { id: 'cod-24-2', userId: 'user-24', studentName: 'Aryan Singh Bhadoria', rollNumber: '0191CS024', platform: 'codeforces', type: 'milestone', value: 200, status: 'approved', createdAt: '2024-10-20' },
  { id: 'cod-24-3', userId: 'user-24', studentName: 'Aryan Singh Bhadoria', rollNumber: '0191CS024', platform: 'codeforces', type: 'contest', title: 'Div 1 Round 947', value: 156, status: 'approved', createdAt: '2025-01-08' },
]

// ── Academic Records ──────────────────────────────────────────────────────────

export const academicRecords: AcademicRecord[] = [
  { id: 'ar-09-1', userId: 'user-09', semester: 1, cgpa: 8.0, totalClasses: 120, attended: 98, subjects: [{ subjectName: 'Data Structures & Algorithms', marksObtained: 82, maxMarks: 100 }, { subjectName: 'Mathematics – I', marksObtained: 79, maxMarks: 100 }, { subjectName: 'Engineering Physics', marksObtained: 70, maxMarks: 100 }, { subjectName: 'EVS', marksObtained: 88, maxMarks: 100 }, { subjectName: 'English Communication', marksObtained: 75, maxMarks: 100 }] },
  { id: 'ar-09-2', userId: 'user-09', semester: 2, cgpa: 8.5, totalClasses: 110, attended: 102, subjects: [{ subjectName: 'OOP (Java)', marksObtained: 88, maxMarks: 100 }, { subjectName: 'Mathematics – II', marksObtained: 82, maxMarks: 100 }, { subjectName: 'Statistics', marksObtained: 80, maxMarks: 100 }, { subjectName: 'Digital Logic', marksObtained: 82, maxMarks: 100 }, { subjectName: 'Python Programming', marksObtained: 92, maxMarks: 100 }] },
  { id: 'ar-12-1', userId: 'user-12', semester: 1, cgpa: 7.5, totalClasses: 120, attended: 85, subjects: [{ subjectName: 'Data Structures', marksObtained: 71, maxMarks: 100 }, { subjectName: 'Mathematics – I', marksObtained: 74, maxMarks: 100 }, { subjectName: 'Physics', marksObtained: 68, maxMarks: 100 }] },
  { id: 'ar-12-2', userId: 'user-12', semester: 2, cgpa: 8.0, totalClasses: 110, attended: 90, subjects: [{ subjectName: 'OOP (Java)', marksObtained: 80, maxMarks: 100 }, { subjectName: 'Mathematics – II', marksObtained: 78, maxMarks: 100 }] },
  { id: 'ar-23-1', userId: 'user-23', semester: 1, cgpa: 8.7, totalClasses: 120, attended: 108, subjects: [{ subjectName: 'Data Structures', marksObtained: 90, maxMarks: 100 }, { subjectName: 'Mathematics – I', marksObtained: 85, maxMarks: 100 }, { subjectName: 'Physics', marksObtained: 78, maxMarks: 100 }] },
  { id: 'ar-23-2', userId: 'user-23', semester: 2, cgpa: 8.8, totalClasses: 110, attended: 105, subjects: [{ subjectName: 'OOP (Java)', marksObtained: 92, maxMarks: 100 }, { subjectName: 'Statistics', marksObtained: 84, maxMarks: 100 }] },
  { id: 'ar-24-1', userId: 'user-24', semester: 1, cgpa: 8.2, totalClasses: 120, attended: 115, subjects: [{ subjectName: 'Data Structures', marksObtained: 84, maxMarks: 100 }, { subjectName: 'Mathematics – I', marksObtained: 80, maxMarks: 100 }] },
  { id: 'ar-24-2', userId: 'user-24', semester: 2, cgpa: 8.3, totalClasses: 110, attended: 108, subjects: [{ subjectName: 'OOP (Java)', marksObtained: 86, maxMarks: 100 }, { subjectName: 'ML Fundamentals', marksObtained: 89, maxMarks: 100 }] },
]

// ── Derived collections (declared after raw data to avoid TDZ) ────────────────

export const studentsWithScores: StudentWithScore[] = students.map(s => {
  const score = scores.find(sc => sc.userId === s.id)!
  const academic = academicRecords.filter(r => r.userId === s.id)
  const lastCgpa = academic.length > 0 ? academic[academic.length - 1].cgpa : 0
  const actCount = activities.filter(a => a.userId === s.id).length
  const codCount = codingActivities.filter(c => c.userId === s.id).length
  return { ...s, score, activityCount: actCount, codingCount: codCount, cgpa: lastCgpa }
})

export const leaderboard: LeaderboardRow[] = [
  { rank: 1, userId: 'user-24', fullName: 'Aryan Singh Bhadoria', rollNumber: '0191CS024', classGroup: 'CSIT1', year: 2, totalScore: 79.63, hackathonScore: 85.0, projectScore: 75.0, academicScore: 82.5, codingScore: 70.0 },
  { rank: 2, userId: 'user-23', fullName: 'Anvesh Trivedi', rollNumber: '0191CS023', classGroup: 'CSIT1', year: 2, totalScore: 72.50, hackathonScore: 72.5, projectScore: 65.0, academicScore: 87.5, codingScore: 60.0 },
  { rank: 3, userId: 'user-09', fullName: 'Aditya Tiwari', rollNumber: '0191CS009', classGroup: 'CSIT1', year: 2, totalScore: 65.25, hackathonScore: 67.5, projectScore: 50.0, academicScore: 85.0, codingScore: 52.5 },
  { rank: 4, userId: 'user-12', fullName: 'Akshay Khanna', rollNumber: '0191CS012', classGroup: 'CSIT1', year: 2, totalScore: 55.88, hackathonScore: 55.0, projectScore: 45.0, academicScore: 77.5, codingScore: 40.0 },
]

export const pendingActivities = activities.filter(a => a.status === 'pending')
export const pendingCoding = codingActivities.filter(c => c.status === 'pending')

// ── Helpers ───────────────────────────────────────────────────────────────────

export function getStudentById(id: string) {
  return studentsWithScores.find(s => s.id === id)
}

export function getActivitiesForStudent(id: string) {
  return activities.filter(a => a.userId === id)
}

export function getCodingForStudent(id: string) {
  return codingActivities.filter(c => c.userId === id)
}

export function getAcademicsForStudent(id: string) {
  return academicRecords.filter(r => r.userId === id)
}

export const typeColors: Record<string, string> = {
  hackathon: '#8B5CF6',
  achievement: '#EF4444',
  certification: '#3B82F6',
  project: '#10B981',
  internship: '#F59E0B',
  research: '#EC4899',
  milestone: '#06B6D4',
  contest: '#FF6B35',
}
