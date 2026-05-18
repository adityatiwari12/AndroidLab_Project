import { useState } from 'react'
import { ChevronDown, ChevronUp, BookOpen, TrendingUp } from 'lucide-react'
import { studentsWithScores, getAcademicsForStudent } from '../../lib/mockData'

export default function MarksPage() {
  const [selectedId, setSelectedId] = useState(studentsWithScores[0]?.id ?? '')
  const [openSem, setOpenSem] = useState<number | null>(1)

  const student = studentsWithScores.find(s => s.id === selectedId)
  const academics = selectedId ? getAcademicsForStudent(selectedId) : []
  const cgpa = academics.length
    ? (academics.reduce((s, r) => s + r.cgpa, 0) / academics.length).toFixed(2)
    : '—'

  return (
    <div className="space-y-5">
      {/* Student selector */}
      <div className="bg-white rounded-2xl shadow-card p-5">
        <div className="flex items-center gap-4">
          <div className="flex-1">
            <label className="block text-xs font-semibold text-gray-500 font-body mb-1.5 uppercase tracking-wide">Select Student</label>
            <div className="relative">
              <select
                value={selectedId}
                onChange={e => { setSelectedId(e.target.value); setOpenSem(1) }}
                className="w-full px-4 py-3 text-sm bg-[#F7F8FA] border border-[#EEEEEE] rounded-xl outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 font-body appearance-none cursor-pointer"
              >
                {studentsWithScores.map(s => (
                  <option key={s.id} value={s.id}>{s.fullName} — {s.rollNumber}</option>
                ))}
              </select>
              <ChevronDown size={15} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
            </div>
          </div>

          {student && (
            <div className="flex gap-4">
              <div className="bg-[#F7F8FA] rounded-xl p-4 text-center min-w-[100px]">
                <p className="text-2xl font-bold font-display text-gray-900">{cgpa}</p>
                <p className="text-xs text-gray-500 font-body mt-0.5">Cumulative GPA</p>
              </div>
              <div className="bg-[#F7F8FA] rounded-xl p-4 text-center min-w-[100px]">
                <p className="text-2xl font-bold font-display text-primary">{academics.length}</p>
                <p className="text-xs text-gray-500 font-body mt-0.5">Semesters</p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* CGPA trend */}
      {academics.length > 0 && (
        <div className="bg-white rounded-2xl shadow-card p-5">
          <div className="flex items-center gap-2 mb-4">
            <TrendingUp size={18} className="text-primary" />
            <h3 className="font-semibold font-display text-gray-900">SGPA Trend</h3>
          </div>
          <div className="flex items-end gap-3 h-24">
            {academics.map(r => {
              const pct = (r.cgpa / 10) * 100
              return (
                <div key={r.id} className="flex-1 flex flex-col items-center gap-1">
                  <span className="text-xs font-bold font-display text-gray-700">{r.cgpa.toFixed(1)}</span>
                  <div className="w-full bg-gray-100 rounded-t-lg overflow-hidden" style={{ height: 64 }}>
                    <div
                      className="w-full rounded-t-lg transition-all"
                      style={{ height: `${pct}%`, background: r.cgpa >= 8 ? '#10B981' : r.cgpa >= 7 ? '#3B82F6' : '#F59E0B', marginTop: `${100 - pct}%` }}
                    />
                  </div>
                  <span className="text-xs text-gray-400 font-body">Sem {r.semester}</span>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Semester accordion */}
      <div className="space-y-3">
        {academics.map(record => (
          <div key={record.id} className="bg-white rounded-2xl shadow-card overflow-hidden">
            <button
              onClick={() => setOpenSem(openSem === record.semester ? null : record.semester)}
              className="w-full px-5 py-4 flex items-center gap-3 hover:bg-[#F7F8FA] transition-colors text-left"
            >
              <div className="w-10 h-10 rounded-xl bg-primary-light flex items-center justify-center flex-shrink-0">
                <BookOpen size={18} className="text-primary" />
              </div>
              <div className="flex-1">
                <p className="font-semibold font-display text-gray-900">Semester {record.semester}</p>
                <p className="text-xs text-gray-500 font-body">{record.subjects.length} subjects · {Math.round((record.attended / record.totalClasses) * 100)}% attendance</p>
              </div>
              <div className="flex items-center gap-4">
                <div className="text-right">
                  <p className={`text-lg font-bold font-display ${record.cgpa >= 8 ? 'text-emerald-600' : record.cgpa >= 7 ? 'text-blue-600' : 'text-orange-600'}`}>
                    {record.cgpa.toFixed(2)}
                  </p>
                  <p className="text-xs text-gray-400 font-body">SGPA</p>
                </div>
                {openSem === record.semester ? <ChevronUp size={16} className="text-gray-400" /> : <ChevronDown size={16} className="text-gray-400" />}
              </div>
            </button>

            {openSem === record.semester && (
              <>
                <div className="border-t border-[#EEEEEE]" />
                <div className="px-5 py-3">
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-xs font-body text-gray-500">Attendance:</span>
                    <div className="flex-1 h-1.5 bg-gray-100 rounded-full overflow-hidden max-w-[200px]">
                      <div
                        className="h-full rounded-full"
                        style={{
                          width: `${Math.round((record.attended / record.totalClasses) * 100)}%`,
                          background: Math.round((record.attended / record.totalClasses) * 100) >= 85 ? '#10B981' : Math.round((record.attended / record.totalClasses) * 100) >= 75 ? '#F59E0B' : '#EF4444',
                        }}
                      />
                    </div>
                    <span className={`text-xs font-bold font-display ${Math.round((record.attended / record.totalClasses) * 100) >= 85 ? 'text-emerald-600' : Math.round((record.attended / record.totalClasses) * 100) >= 75 ? 'text-amber-600' : 'text-red-600'}`}>
                      {Math.round((record.attended / record.totalClasses) * 100)}%
                    </span>
                  </div>
                </div>
                <table className="w-full text-sm border-t border-[#EEEEEE]">
                  <thead>
                    <tr className="bg-[#F7F8FA]">
                      <th className="text-left px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">Subject</th>
                      <th className="text-center px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">Obtained</th>
                      <th className="text-center px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">Total</th>
                      <th className="text-center px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">%</th>
                      <th className="text-center px-5 py-2.5 text-xs font-semibold text-gray-500 font-body">Grade</th>
                    </tr>
                  </thead>
                  <tbody>
                    {record.subjects.map(sub => {
                      const pct = (sub.marksObtained / sub.maxMarks) * 100
                      const grade = pct >= 90 ? 'A+' : pct >= 80 ? 'A' : pct >= 70 ? 'B+' : pct >= 60 ? 'B' : 'C'
                      return (
                        <tr key={sub.subjectName} className="border-t border-[#EEEEEE] hover:bg-[#F7F8FA] transition-colors">
                          <td className="px-5 py-3 font-body text-gray-700">{sub.subjectName}</td>
                          <td className="px-5 py-3 text-center font-body text-gray-900 font-semibold">{sub.marksObtained}</td>
                          <td className="px-5 py-3 text-center font-body text-gray-500">{sub.maxMarks}</td>
                          <td className="px-5 py-3 text-center">
                            <span className={`text-xs font-bold font-display px-2 py-0.5 rounded-full ${pct >= 75 ? 'bg-emerald-100 text-emerald-700' : pct >= 60 ? 'bg-blue-100 text-blue-700' : 'bg-red-100 text-red-700'}`}>
                              {pct.toFixed(1)}%
                            </span>
                          </td>
                          <td className="px-5 py-3 text-center font-body text-gray-600">{grade}</td>
                        </tr>
                      )
                    })}
                  </tbody>
                  <tfoot>
                    <tr className="bg-primary-light">
                      <td colSpan={4} className="px-5 py-3 text-sm font-semibold font-display text-primary text-right">SGPA</td>
                      <td className="px-5 py-3 text-center text-sm font-bold font-display text-primary">{record.cgpa.toFixed(2)}</td>
                    </tr>
                  </tfoot>
                </table>
              </>
            )}
          </div>
        ))}
        {academics.length === 0 && (
          <div className="bg-white rounded-2xl shadow-card p-10 text-center text-sm text-gray-400 font-body">
            No academic records found for this student.
          </div>
        )}
      </div>
    </div>
  )
}
