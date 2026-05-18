import { Users, ClipboardCheck, BookOpen, TrendingUp } from 'lucide-react'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import { studentsWithScores, pendingActivities, pendingCoding, pendingStudents, activities } from '../../lib/mockData'

const totalPending = pendingStudents.length + pendingActivities.length + pendingCoding.length
const avgCgpa = (studentsWithScores.reduce((s, st) => s + st.cgpa, 0) / studentsWithScores.length).toFixed(2)
const avgScore = (studentsWithScores.reduce((s, st) => s + st.score.totalScore, 0) / studentsWithScores.length).toFixed(1)

const scoreData = studentsWithScores.map(s => ({
  name: s.fullName.split(' ')[0],
  score: s.score.totalScore,
}))

const typeBreakdown = ['hackathon', 'certification', 'project', 'internship', 'achievement', 'research'].map(t => ({
  type: t.charAt(0).toUpperCase() + t.slice(1),
  count: activities.filter(a => a.type === t && a.status === 'approved').length,
}))

const COLORS = ['#8B5CF6', '#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#EC4899']

export default function OverviewPage() {
  return (
    <div className="space-y-6">
      {/* Stat cards */}
      <div className="grid grid-cols-4 gap-4">
        {[
          { icon: Users, label: 'Total Active Students', value: studentsWithScores.length.toString(), color: 'text-blue-500', bg: 'bg-blue-50' },
          { icon: ClipboardCheck, label: 'Pending Approvals', value: totalPending.toString(), color: 'text-orange-500', bg: 'bg-orange-50' },
          { icon: BookOpen, label: 'Avg CGPA', value: avgCgpa, color: 'text-emerald-500', bg: 'bg-emerald-50' },
          { icon: TrendingUp, label: 'Avg Total Score', value: avgScore, color: 'text-primary', bg: 'bg-primary-light' },
        ].map(({ icon: Icon, label, value, color, bg }) => (
          <div key={label} className="bg-white rounded-2xl shadow-card p-5 flex items-center gap-4">
            <div className={`${bg} w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0`}>
              <Icon size={22} className={color} />
            </div>
            <div>
              <p className="text-2xl font-bold font-display text-gray-900">{value}</p>
              <p className="text-xs text-gray-500 font-body">{label}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-6">
        {/* Score distribution */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4">Student Scores</h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={scoreData} barSize={40}>
              <XAxis dataKey="name" tick={{ fontSize: 12, fontFamily: 'DM Sans' }} axisLine={false} tickLine={false} />
              <YAxis domain={[0, 100]} tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip formatter={(v: number) => [v.toFixed(2), 'Score']} contentStyle={{ borderRadius: 10, border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.1)' }} />
              <Bar dataKey="score" fill="#FF6B35" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Activity breakdown */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4">Approved Activities by Type</h3>
          <div className="flex items-center gap-4">
            <ResponsiveContainer width="50%" height={180}>
              <PieChart>
                <Pie data={typeBreakdown} dataKey="count" nameKey="type" cx="50%" cy="50%" outerRadius={70} innerRadius={40}>
                  {typeBreakdown.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 10, border: 'none' }} />
              </PieChart>
            </ResponsiveContainer>
            <div className="flex-1 space-y-2">
              {typeBreakdown.map(({ type, count }, i) => (
                <div key={type} className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ background: COLORS[i] }} />
                  <span className="text-xs font-body text-gray-600 flex-1">{type}</span>
                  <span className="text-xs font-bold font-display text-gray-900">{count}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* At-risk panel */}
      <div className="bg-white rounded-2xl shadow-card p-6">
        <div className="flex items-center gap-2 mb-4">
          <div className="w-1 h-5 bg-amber-400 rounded-full" />
          <h3 className="font-semibold font-display text-gray-900">Students Needing Attention</h3>
        </div>
        <div className="space-y-2">
          {studentsWithScores.filter(s => s.activityCount < 2).map(s => (
            <div key={s.id} className="flex items-center gap-4 p-3 bg-amber-50 rounded-xl">
              <div className="w-8 h-8 rounded-full bg-amber-100 flex items-center justify-center text-sm font-bold text-amber-700 font-display">
                {s.fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
              </div>
              <div className="flex-1">
                <p className="text-sm font-semibold font-display text-gray-900">{s.fullName}</p>
                <p className="text-xs text-gray-500 font-body">{s.classGroup} · Year {s.year}</p>
              </div>
              <span className="text-xs bg-amber-100 text-amber-700 px-2 py-1 rounded-full font-body">
                {s.activityCount} activities
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
