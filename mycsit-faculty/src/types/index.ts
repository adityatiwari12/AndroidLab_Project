export type EntryStatus = 'pending' | 'approved' | 'rejected'
export type ActivityType = 'hackathon' | 'achievement' | 'certification' | 'project' | 'internship' | 'research'
export type CodingType = 'milestone' | 'contest' | 'notableProblem'
export type CodingPlatform = 'leetcode' | 'codeforces' | 'codechef' | 'other'

export interface Student {
  id: string
  rollNumber: string
  fullName: string
  classGroup: string
  year: number
  status: 'active' | 'pending' | 'rejected'
  email: string
  registeredAt: string
}

export interface ScoreCache {
  userId: string
  totalScore: number
  hackathonScore: number
  projectScore: number
  academicScore: number
  codingScore: number
}

export interface StudentWithScore extends Student {
  score: ScoreCache
  activityCount: number
  codingCount: number
  cgpa: number
}

export interface Activity {
  id: string
  userId: string
  studentName: string
  rollNumber: string
  type: ActivityType
  title: string
  description: string
  activityDate: string
  proofPath: string
  status: EntryStatus
  rejectionReason?: string
  createdAt: string
}

export interface CodingActivity {
  id: string
  userId: string
  studentName: string
  rollNumber: string
  platform: CodingPlatform
  type: CodingType
  title?: string
  value?: number
  difficulty?: 'easy' | 'medium' | 'hard'
  status: EntryStatus
  rejectionReason?: string
  createdAt: string
}

export interface AcademicRecord {
  id: string
  userId: string
  semester: number
  cgpa: number
  subjects: SubjectMark[]
  totalClasses: number
  attended: number
}

export interface SubjectMark {
  subjectName: string
  marksObtained: number
  maxMarks: number
}

export interface LeaderboardRow {
  rank: number
  userId: string
  fullName: string
  rollNumber: string
  classGroup: string
  year: number
  totalScore: number
  hackathonScore: number
  projectScore: number
  academicScore: number
  codingScore: number
}
