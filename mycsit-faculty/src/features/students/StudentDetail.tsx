import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { ArrowLeft, CheckCircle, XCircle, Clock, Award, Code2, BookOpen, BarChart3 } from 'lucide-react'
import { getStudentById, getActivitiesForStudent, getCodingForStudent, getAcademicsForStudent, typeColors } from '../../lib/mockData'

const TABS = ['Overview', 'Activities', 'Coding', 'Academics', 'Score Breakdown'] as const
type Tab = typeof TABS[number]

function StatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    approved: 'bg-emerald-100 text-emerald-700',
    pending: 'bg-amber-100 text-amber-700',
    rejected: 'bg-red-100 text-red-700',
  }
  return (
    <span className={`text-xs px-2 py-0.5 rounded-full font-body font-medium ${map[status] ?? 'bg-gray-100 text-gray-600'}`}>
      {status.charAt(0).toUpperCase() + status.slice(1)}
    </span>
  )
}

export default function StudentDetail() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const [tab, setTab] = useState<Tab>('Overview')

  const student = id ? getStudentById(id) : null
  if (!student) return (
    <div className="flex items-center justify-center h-64 text-gray-400 font-body">Student not found.</div>
  )

  const activities = getActivitiesForStudent(student.id)
  const coding = getCodingForStudent(student.id)
  const academics = getAcademicsForStudent(student.id)
  const approvedActs = activities.filter(a => a.status === 'approved')
  const score = student.score

  const scoreBreakdown = [
    { label: 'Hackathons', weight: '35%', value: score.hackathonScore, color: '#8B5CF6' },
    { label: 'Projects', weight: '25%', value: score.projectScore, color: '#3B82F6' },
    { label: 'Academic', weight: '25%', value: score.academicScore, color: '#10B981' },
    { label: 'Coding', weight: '15%', value: score.codingScore, color: '#F59E0B' },
  ]

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="bg-white rounded-2xl shadow-card p-6">
        <button onClick={() => navigate(-1)} className="flex items-center gap-2 text-sm text-gray-500 font-body hover:text-gray-800 mb-4 transition-colors">
          <ArrowLeft size={16} /> Back to Directory
        </button>
        <div className="flex items-center gap-5">
          <div className="w-16 h-16 rounded-2xl bg-primary-light flex items-center justify-center flex-shrink-0">
            <span className="text-primary font-bold text-xl font-display">
              {student.fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
            </span>
          </div>
          <div className="flex-1">
            <h2 className="text-xl font-bold font-display text-gray-900">{student.fullName}</h2>
            <p className="text-sm text-gray-500 font-body mt-0.5">{student.rollNumber} · {student.classGroup} · Year {student.year}</p>
            <p className="text-xs text-gray-400 font-body">{student.email}</p>
          </div>
          <div className="text-right">
            <p className="text-3xl font-bold font-display text-primary">{score.totalScore.toFixed(1)}</p>
            <p className="text-xs text-gray-500 font-body">Total Score</p>
            <p className="text-sm font-semibold font-display text-gray-700 mt-1">CGPA: {student.cgpa.toFixed(2)}</p>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 bg-white rounded-2xl shadow-card p-1.5">
        {TABS.map(t => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`flex-1 py-2 text-sm rounded-xl font-body transition-all ${tab === t ? 'bg-primary text-white font-semibold shadow-accent-glow' : 'text-gray-500 hover:text-gray-800 hover:bg-gray-50'}`}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Tab content */}
      {tab === 'Overview' && (
        <div className="grid grid-cols-3 gap-4">
          {[
            { label: 'Activities Submitted', value: activities.length, icon: Award, color: 'text-purple-500', bg: 'bg-purple-50' },
            { label: 'Approved', value: approvedActs.length, icon: CheckCircle, color: 'text-emerald-500', bg: 'bg-emerald-50' },
            { label: 'Coding Entries', value: coding.length, icon: Code2, color: 'text-blue-500', bg: 'bg-blue-50' },
          ].map(({ label, value, icon: Icon, color, bg }) => (
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
          <div className="col-span-3 bg-white rounded-2xl shadow-card p-5">
            <h4 className="font-semibold font-display text-gray-900 mb-3">Recent Activity</h4>
            <div className="space-y-2">
              {activities.slice(0, 5).map(a => (
                <div key={a.id} className="flex items-center gap-3 p-3 bg-[#F7F8FA] rounded-xl">
                  <span className="text-xs px-2 py-1 rounded-lg font-body font-medium"
                    style={{ background: (typeColors[a.type] ?? '#8B5CF6') + '20', color: typeColors[a.type] ?? '#8B5CF6' }}>
                    {a.type}
                  </span>
                  <span className="flex-1 text-sm font-body text-gray-700 truncate">{a.title}</span>
                  <StatusBadge status={a.status} />
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {tab === 'Activities' && (
        <div className="bg-white rounded-2xl shadow-card overflow-hidden">
          <div className="px-5 py-4 border-b border-[#EEEEEE]">
            <span className="font-semibold font-display text-gray-900">{activities.length} Activities</span>
          </div>
          <div className="divide-y divide-[#EEEEEE]">
            {activities.map(a => (
              <div key={a.id} className="px-5 py-4 flex items-start gap-4">
                <div className="w-1 h-full min-h-[40px] rounded-full flex-shrink-0" style={{ background: typeColors[a.type] ?? '#8B5CF6' }} />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-sm font-semibold font-display text-gray-900 truncate">{a.title}</span>
                    <StatusBadge status={a.status} />
                  </div>
                  <p className="text-xs text-gray-500 font-body">{a.type} · {new Date(a.activityDate).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}</p>
                  {a.description && <p className="text-xs text-gray-500 font-body mt-1 line-clamp-2">{a.description}</p>}
                  {a.rejectionReason && <p className="text-xs text-red-600 font-body mt-1">Rejection: {a.rejectionReason}</p>}
                </div>
              </div>
            ))}
            {activities.length === 0 && <p className="px-5 py-8 text-center text-sm text-gray-400 font-body">No activities yet.</p>}
          </div>
        </div>
      )}

      {tab === 'Coding' && (
        <div className="bg-white rounded-2xl shadow-card overflow-hidden">
          <div className="px-5 py-4 border-b border-[#EEEEEE]">
            <span className="font-semibold font-display text-gray-900">{coding.length} Coding Entries</span>
          </div>
          <div className="divide-y divide-[#EEEEEE]">
            {coding.map(c => (
              <div key={c.id} className="px-5 py-4 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center flex-shrink-0">
                  <Code2 size={18} className="text-blue-500" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-semibold font-display text-gray-900 truncate">{c.title}</span>
                    <StatusBadge status={c.status} />
                  </div>
                  <p className="text-xs text-gray-500 font-body">{c.platform} · {c.type}</p>
                </div>
              </div>
            ))}
            {coding.length === 0 && <p className="px-5 py-8 text-center text-sm text-gray-400 font-body">No coding entries yet.</p>}
          </div>
        </div>
      )}

      {tab === 'Academics' && (
        <div className="space-y-4">
          {academics.map(record => (
            <div key={record.id} className="bg-white rounded-2xl shadow-card overflow-hidden">
              <div className="px-5 py-4 border-b border-[#EEEEEE] flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookOpen size={18} className="text-primary" />
                  <span className="font-semibold font-display text-gray-900">Semester {record.semester}</span>
                </div>
                <div className="flex items-center gap-4">
                  <div className="text-right">
                    <p className="text-lg font-bold font-display text-gray-900">{record.cgpa.toFixed(2)}</p>
                    <p className="text-xs text-gray-400 font-body">SGPA</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-bold font-display text-gray-700">{Math.round((record.attended / record.totalClasses) * 100)}%</p>
                    <p className="text-xs text-gray-400 font-body">Attendance</p>
                  </div>
                </div>
              </div>
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-[#F7F8FA] border-b border-[#EEEEEE]">
                    <th className="text-left px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">Subject</th>
                    <th className="text-center px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">Marks</th>
                    <th className="text-center px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">%</th>
                    <th className="text-center px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">Grade</th>
                  </tr>
                </thead>
                <tbody>
                  {record.subjects.map(sub => {
                    const pct = (sub.marksObtained / sub.maxMarks) * 100
                    return (
                      <tr key={sub.subjectName} className="border-b border-[#EEEEEE] last:border-0">
                        <td className="px-5 py-3 font-body text-gray-700">{sub.subjectName}</td>
                        <td className="px-5 py-3 text-center font-body text-gray-700">{sub.marksObtained}/{sub.maxMarks}</td>
                        <td className="px-5 py-3 text-center">
                          <span className={`text-xs font-bold font-display ${pct >= 75 ? 'text-emerald-600' : pct >= 60 ? 'text-blue-600' : 'text-red-600'}`}>
                            {pct.toFixed(1)}%
                          </span>
                        </td>
                        <td className="px-5 py-3 text-center font-body text-gray-600">
                          {pct >= 90 ? 'A+' : pct >= 80 ? 'A' : pct >= 70 ? 'B+' : pct >= 60 ? 'B' : 'C'}
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          ))}
        </div>
      )}

      {tab === 'Score Breakdown' && (
        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2 bg-white rounded-2xl shadow-card p-6">
            <h3 className="font-semibold font-display text-gray-900 mb-5">Composite Score: {score.totalScore.toFixed(2)} / 100</h3>
            <div className="space-y-4">
              {scoreBreakdown.map(({ label, weight, value, color }) => (
                <div key={label}>
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="text-sm font-body text-gray-700">{label} <span className="text-gray-400">({weight})</span></span>
                    <span className="text-sm font-bold font-display text-gray-900">{value.toFixed(1)}</span>
                  </div>
                  <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
                    <div className="h-full rounded-full transition-all" style={{ width: `${value}%`, background: color }} />
                  </div>
                </div>
              ))}
            </div>
          </div>
          {scoreBreakdown.map(({ label, value, color }) => (
            <div key={label} className="bg-white rounded-2xl shadow-card p-5">
              <div className="flex items-center gap-2 mb-2">
                <span className="w-3 h-3 rounded-full" style={{ background: color }} />
                <span className="text-sm font-body text-gray-600">{label}</span>
              </div>
              <p className="text-3xl font-bold font-display text-gray-900">{value.toFixed(1)}</p>
              <div className="mt-2 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                <div className="h-full rounded-full" style={{ width: `${value}%`, background: color }} />
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
