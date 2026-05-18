import { useLocation } from 'react-router-dom'
import { Bell, Search } from 'lucide-react'
import { pendingActivities, pendingCoding, pendingStudents } from '../../lib/mockData'

const pageTitles: Record<string, string> = {
  '/overview': 'Dashboard',
  '/students': 'Student Directory',
  '/approvals': 'Approval Queue',
  '/marks': 'Marks Management',
  '/attendance': 'Attendance',
  '/leaderboard': 'Leaderboard',
  '/analytics': 'Analytics',
  '/uploads': 'Bulk Uploads',
}

const unread = pendingStudents.length + pendingActivities.length + pendingCoding.length

export default function TopBar() {
  const { pathname } = useLocation()
  const base = '/' + pathname.split('/')[1]
  const title = pageTitles[base] ?? 'MyCSIT'

  return (
    <header className="h-16 bg-white border-b border-[#EEEEEE] flex items-center justify-between px-6 sticky top-0 z-20">
      <div className="flex items-center gap-3">
        <h1 className="font-display font-semibold text-[18px] text-gray-900">{title}</h1>
        <span className="bg-primary-light text-primary text-xs px-3 py-1 rounded-full font-body">
          All Classes · HOD View
        </span>
      </div>
      <div className="flex items-center gap-3">
        <div className="relative">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search students..."
            className="pl-9 pr-4 py-2 text-sm bg-[#F7F8FA] border border-[#EEEEEE] rounded-xl outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 w-56 font-body"
          />
        </div>
        <button className="relative p-2 rounded-xl hover:bg-gray-100 transition-colors">
          <Bell size={18} className="text-gray-500" />
          {unread > 0 && (
            <span className="absolute top-1 right-1 w-4 h-4 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
              {unread}
            </span>
          )}
        </button>
      </div>
    </header>
  )
}
