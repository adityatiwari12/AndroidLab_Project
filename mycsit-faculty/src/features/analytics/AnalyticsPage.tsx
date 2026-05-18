import { TrendingUp, Users, Award, Code2, AlertTriangle } from 'lucide-react'
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, LineChart, Line, CartesianGrid, Legend,
} from 'recharts'
import { studentsWithScores, activities, codingActivities, typeColors } from '../../lib/mockData'

const COLORS = ['#8B5CF6', '#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#EC4899']

const cgpaData = studentsWithScores.map(s => ({ name: s.fullName.split(' ')[0], cgpa: s.cgpa }))

const actTypeData = ['hackathon', 'certification', 'project', 'internship', 'achievement', 'research'].map(t => ({
  type: t.charAt(0).toUpperCase() + t.slice(1),
  count: activities.filter(a => a.type === t).length,
  approved: activities.filter(a => a.type === t && a.status === 'approved').length,
}))

const platformData = (() => {
  const counts: Record<string, number> = {}
  codingActivities.forEach(c => { counts[c.platform] = (counts[c.platform] ?? 0) + 1 })
  return Object.entries(counts).map(([platform, count]) => ({ platform, count }))
})()

const scoreData = studentsWithScores.map(s => ({
  name: s.fullName.split(' ')[0],
  hackathon: s.score.hackathonScore,
  project: s.score.projectScore,
  academic: s.score.academicScore,
  coding: s.score.codingScore,
}))

const atRisk = studentsWithScores.filter(s => s.activityCount < 2 || s.cgpa < 7.0)

export default function AnalyticsPage() {
  return (
    <div className="space-y-6">
      {/* Summary KPIs */}
      <div className="grid grid-cols-4 gap-4">
        {[
          { icon: Users, label: 'Active Students', value: studentsWithScores.length.toString(), color: 'text-blue-500', bg: 'bg-blue-50' },
          { icon: Award, label: 'Total Activities', value: activities.length.toString(), color: 'text-purple-500', bg: 'bg-purple-50' },
          { icon: Code2, label: 'Coding Entries', value: codingActivities.length.toString(), color: 'text-emerald-500', bg: 'bg-emerald-50' },
          { icon: TrendingUp, label: 'Approval Rate', value: `${Math.round((activities.filter(a => a.status === 'approved').length / activities.length) * 100)}%`, color: 'text-primary', bg: 'bg-primary-light' },
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
        {/* CGPA distribution */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4">CGPA by Student</h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={cgpaData} barSize={48}>
              <XAxis dataKey="name" tick={{ fontSize: 12, fontFamily: 'DM Sans' }} axisLine={false} tickLine={false} />
              <YAxis domain={[0, 10]} tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip
                formatter={(v: number) => [v.toFixed(2), 'CGPA']}
                contentStyle={{ borderRadius: 10, border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.1)' }}
              />
              <Bar dataKey="cgpa" radius={[6, 6, 0, 0]}>
                {cgpaData.map((d, i) => (
                  <Cell key={i} fill={d.cgpa >= 8 ? '#10B981' : d.cgpa >= 7 ? '#3B82F6' : '#F59E0B'} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Activity type donut */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4">Activities by Type</h3>
          <div className="flex items-center gap-4">
            <ResponsiveContainer width="50%" height={180}>
              <PieChart>
                <Pie data={actTypeData} dataKey="count" nameKey="type" cx="50%" cy="50%" outerRadius={70} innerRadius={40}>
                  {actTypeData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 10, border: 'none' }} />
              </PieChart>
            </ResponsiveContainer>
            <div className="flex-1 space-y-1.5">
              {actTypeData.map(({ type, count, approved }, i) => (
                <div key={type} className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ background: COLORS[i] }} />
                  <span className="text-xs font-body text-gray-600 flex-1">{type}</span>
                  <span className="text-xs text-gray-400 font-body">{approved}/{count}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Coding platform distribution */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4">Coding Platform Distribution</h3>
          <div className="flex items-center gap-4">
            <ResponsiveContainer width="50%" height={180}>
              <PieChart>
                <Pie data={platformData} dataKey="count" nameKey="platform" cx="50%" cy="50%" outerRadius={70} innerRadius={40}>
                  {platformData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 10, border: 'none' }} />
              </PieChart>
            </ResponsiveContainer>
            <div className="flex-1 space-y-2">
              {platformData.map(({ platform, count }, i) => (
                <div key={platform} className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ background: COLORS[i] }} />
                  <span className="text-xs font-body text-gray-600 flex-1">{platform}</span>
                  <span className="text-xs font-bold font-display text-gray-900">{count}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Score breakdown stacked bar */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4">Score Components</h3>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={scoreData} barSize={36}>
              <XAxis dataKey="name" tick={{ fontSize: 12, fontFamily: 'DM Sans' }} axisLine={false} tickLine={false} />
              <YAxis domain={[0, 100]} tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ borderRadius: 10, border: 'none' }} />
              <Legend wrapperStyle={{ fontSize: 11, fontFamily: 'DM Sans' }} />
              <Bar dataKey="hackathon" name="Hackathon" stackId="a" fill="#8B5CF6" />
              <Bar dataKey="project" name="Project" stackId="a" fill="#3B82F6" />
              <Bar dataKey="academic" name="Academic" stackId="a" fill="#10B981" />
              <Bar dataKey="coding" name="Coding" stackId="a" fill="#F59E0B" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Activity approval trend (simulated) */}
      <div className="bg-white rounded-2xl shadow-card p-6">
        <h3 className="font-semibold font-display text-gray-900 mb-4">Monthly Submission Trend (Simulated)</h3>
        <ResponsiveContainer width="100%" height={180}>
          <LineChart data={[
            { month: 'Jan', submitted: 2, approved: 1 },
            { month: 'Feb', submitted: 3, approved: 2 },
            { month: 'Mar', submitted: 5, approved: 4 },
            { month: 'Apr', submitted: 4, approved: 3 },
            { month: 'May', submitted: 7, approved: 5 },
            { month: 'Jun', submitted: 6, approved: 6 },
          ]}>
            <CartesianGrid stroke="#EEEEEE" strokeDasharray="3 3" />
            <XAxis dataKey="month" tick={{ fontSize: 12, fontFamily: 'DM Sans' }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
            <Tooltip contentStyle={{ borderRadius: 10, border: 'none' }} />
            <Legend wrapperStyle={{ fontSize: 11, fontFamily: 'DM Sans' }} />
            <Line type="monotone" dataKey="submitted" name="Submitted" stroke="#FF6B35" strokeWidth={2} dot={{ r: 4 }} />
            <Line type="monotone" dataKey="approved" name="Approved" stroke="#10B981" strokeWidth={2} dot={{ r: 4 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* At-risk panel */}
      {atRisk.length > 0 && (
        <div className="bg-white rounded-2xl shadow-card p-6">
          <div className="flex items-center gap-2 mb-4">
            <AlertTriangle size={18} className="text-amber-500" />
            <h3 className="font-semibold font-display text-gray-900">Students Needing Attention</h3>
            <span className="bg-amber-100 text-amber-700 text-xs px-2 py-0.5 rounded-full font-body">{atRisk.length}</span>
          </div>
          <div className="space-y-2">
            {atRisk.map(s => (
              <div key={s.id} className="flex items-center gap-4 p-3 bg-amber-50 rounded-xl">
                <div className="w-9 h-9 rounded-full bg-amber-100 flex items-center justify-center flex-shrink-0">
                  <span className="text-amber-700 font-bold text-sm font-display">
                    {s.fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
                  </span>
                </div>
                <div className="flex-1">
                  <p className="text-sm font-semibold font-display text-gray-900">{s.fullName}</p>
                  <p className="text-xs text-gray-500 font-body">{s.classGroup} · CGPA {s.cgpa.toFixed(2)}</p>
                </div>
                <div className="flex gap-2">
                  {s.activityCount < 2 && (
                    <span className="text-xs bg-amber-100 text-amber-700 px-2 py-1 rounded-full font-body">Low activity ({s.activityCount})</span>
                  )}
                  {s.cgpa < 7.0 && (
                    <span className="text-xs bg-red-100 text-red-700 px-2 py-1 rounded-full font-body">Low CGPA</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
