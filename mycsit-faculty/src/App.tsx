import { Routes, Route, Navigate } from 'react-router-dom'
import { useState } from 'react'
import AppShell from './components/layout/AppShell'
import LoginPage from './features/auth/LoginPage'
import OverviewPage from './features/overview/OverviewPage'
import StudentDirectory from './features/students/StudentDirectory'
import StudentDetail from './features/students/StudentDetail'
import ApprovalQueue from './features/approvals/ApprovalQueue'
import MarksPage from './features/marks/MarksPage'
import AttendancePage from './features/attendance/AttendancePage'
import LeaderboardPage from './features/leaderboard/LeaderboardPage'
import AnalyticsPage from './features/analytics/AnalyticsPage'
import UploadsPage from './features/uploads/UploadsPage'

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false)

  if (!isLoggedIn) {
    return <LoginPage onLogin={() => setIsLoggedIn(true)} />
  }

  return (
    <Routes>
      <Route path="/" element={<AppShell />}>
        <Route index element={<Navigate to="/overview" replace />} />
        <Route path="overview" element={<OverviewPage />} />
        <Route path="students" element={<StudentDirectory />} />
        <Route path="students/:id" element={<StudentDetail />} />
        <Route path="approvals" element={<ApprovalQueue />} />
        <Route path="marks" element={<MarksPage />} />
        <Route path="attendance" element={<AttendancePage />} />
        <Route path="leaderboard" element={<LeaderboardPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="uploads" element={<UploadsPage />} />
        <Route path="*" element={<Navigate to="/overview" replace />} />
      </Route>
    </Routes>
  )
}
