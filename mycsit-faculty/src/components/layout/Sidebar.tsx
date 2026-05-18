import { NavLink } from 'react-router-dom'
import {
  LayoutDashboard, Users, ClipboardCheck, BookOpen,
  CalendarCheck, Trophy, BarChart2, Upload, LogOut
} from 'lucide-react'
import { pendingActivities, pendingCoding, pendingStudents } from '../../lib/mockData'

const totalPending = pendingStudents.length + pendingActivities.length + pendingCoding.length

const navItems = [
  { to: '/overview', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/students', icon: Users, label: 'Students' },
  { to: '/approvals', icon: ClipboardCheck, label: 'Approvals', badge: totalPending },
  { to: '/marks', icon: BookOpen, label: 'Marks' },
  { to: '/attendance', icon: CalendarCheck, label: 'Attendance' },
  { to: '/leaderboard', icon: Trophy, label: 'Leaderboard' },
  { to: '/analytics', icon: BarChart2, label: 'Analytics' },
  { to: '/uploads', icon: Upload, label: 'Bulk Uploads' },
]

export default function Sidebar() {
  return (
    <aside className="w-60 h-screen bg-white border-r border-[#EEEEEE] flex flex-col fixed left-0 top-0 z-30">
      {/* Logo */}
      <div className="px-6 py-5 border-b border-[#EEEEEE]">
        <span className="font-display font-bold text-xl">
          <span className="text-primary">My</span>
          <span className="text-gray-900">CSIT</span>
        </span>
        <p className="text-xs text-gray-400 mt-0.5 font-body">Faculty Dashboard</p>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-4 px-3">
        {navItems.map(({ to, icon: Icon, label, badge }) => (
          <NavLink
            key={to}
            to={to}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-xl mb-1 text-sm font-body transition-all group ${
                isActive
                  ? 'bg-primary-light text-primary font-semibold border-l-[3px] border-primary rounded-l-none'
                  : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'
              }`
            }
          >
            {({ isActive }) => (
              <>
                <Icon size={18} className={isActive ? 'text-primary' : 'text-gray-400 group-hover:text-gray-600'} />
                <span className="flex-1">{label}</span>
                {badge != null && badge > 0 && (
                  <span className="bg-red-500 text-white text-xs font-bold px-1.5 py-0.5 rounded-full min-w-[18px] text-center">
                    {badge}
                  </span>
                )}
              </>
            )}
          </NavLink>
        ))}
      </nav>

      {/* Faculty info */}
      <div className="border-t border-[#EEEEEE] px-4 py-4">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-primary-light flex items-center justify-center">
            <span className="text-primary font-bold text-sm font-display">PS</span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold font-display text-gray-900 truncate">Prof. P. Sharma</p>
            <span className="inline-block bg-primary-light text-primary text-xs px-2 py-0.5 rounded-full font-body">HOD</span>
          </div>
          <button className="text-gray-400 hover:text-red-500 transition-colors">
            <LogOut size={16} />
          </button>
        </div>
      </div>
    </aside>
  )
}
