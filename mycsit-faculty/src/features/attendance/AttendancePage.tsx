import { useState } from 'react'
import { Save, AlertTriangle } from 'lucide-react'
import { studentsWithScores, getAcademicsForStudent } from '../../lib/mockData'

type AttRow = { id: string; name: string; rollNumber: string; attended: number; total: number }

function buildAttendance(year: number, sem: number): AttRow[] {
  return studentsWithScores
    .filter(s => s.year === year)
    .map(s => {
      const rec = getAcademicsForStudent(s.id).find(r => r.semester === sem)
      const pct = rec ? Math.round((rec.attended / rec.totalClasses) * 100) : 80
      const total = 60
      return { id: s.id, name: s.fullName, rollNumber: s.rollNumber, attended: Math.round((pct / 100) * total), total }
    })
}

function AttPill({ pct }: { pct: number }) {
  const cls = pct >= 85 ? 'bg-emerald-100 text-emerald-700' : pct >= 75 ? 'bg-amber-100 text-amber-700' : 'bg-red-100 text-red-700'
  return <span className={`text-xs font-bold px-2 py-0.5 rounded-full font-display ${cls}`}>{pct.toFixed(1)}%</span>
}

export default function AttendancePage() {
  const [year, setYear] = useState(3)
  const [sem, setSem] = useState(5)
  const [rows, setRows] = useState<AttRow[]>(() => buildAttendance(3, 5))
  const [saved, setSaved] = useState(false)

  function handleYearSemChange(y: number, s: number) {
    setYear(y); setSem(s)
    setRows(buildAttendance(y, s))
    setSaved(false)
  }

  function updateAttended(id: string, val: string) {
    const n = Math.max(0, Math.min(parseInt(val) || 0, rows.find(r => r.id === id)?.total ?? 60))
    setRows(r => r.map(row => row.id === id ? { ...row, attended: n } : row))
    setSaved(false)
  }

  function updateTotal(id: string, val: string) {
    const n = Math.max(1, parseInt(val) || 1)
    setRows(r => r.map(row => row.id === id ? { ...row, total: n } : row))
    setSaved(false)
  }

  function handleSave() {
    setSaved(true)
    setTimeout(() => setSaved(false), 2500)
  }

  const atRisk = rows.filter(r => (r.attended / r.total) * 100 < 75)

  return (
    <div className="space-y-5">
      {/* Filters */}
      <div className="bg-white rounded-2xl shadow-card p-5 flex items-center gap-6 flex-wrap">
        <div>
          <label className="block text-xs font-semibold text-gray-500 font-body mb-1.5 uppercase tracking-wide">Year</label>
          <div className="flex gap-2">
            {[1, 2, 3, 4].map(y => (
              <button
                key={y}
                onClick={() => handleYearSemChange(y, y * 2 - 1)}
                className={`px-4 py-2 text-sm rounded-xl font-body transition-colors ${year === y ? 'bg-primary text-white font-semibold' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
              >
                Year {y}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="block text-xs font-semibold text-gray-500 font-body mb-1.5 uppercase tracking-wide">Semester</label>
          <div className="flex gap-2">
            {[year * 2 - 1, year * 2].map(s => (
              <button
                key={s}
                onClick={() => handleYearSemChange(year, s)}
                className={`px-4 py-2 text-sm rounded-xl font-body transition-colors ${sem === s ? 'bg-primary text-white font-semibold' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
              >
                Sem {s}
              </button>
            ))}
          </div>
        </div>

        <button
          onClick={handleSave}
          className={`ml-auto flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-xl transition-all font-body ${saved ? 'bg-emerald-500 text-white' : 'bg-primary text-white hover:bg-primary-dark'}`}
        >
          <Save size={15} />
          {saved ? 'Saved!' : 'Save Changes'}
        </button>
      </div>

      {/* At-risk banner */}
      {atRisk.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-2xl px-5 py-3 flex items-center gap-3">
          <AlertTriangle size={16} className="text-red-500 flex-shrink-0" />
          <p className="text-sm text-red-700 font-body">
            <span className="font-semibold">{atRisk.length}</span> student{atRisk.length !== 1 ? 's' : ''} below 75% attendance:{' '}
            {atRisk.map(r => r.name.split(' ')[0]).join(', ')}
          </p>
        </div>
      )}

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <div className="px-5 py-4 border-b border-[#EEEEEE] flex items-center justify-between">
          <span className="font-semibold font-display text-gray-900">Year {year} · Semester {sem}</span>
          <span className="text-sm text-gray-500 font-body">{rows.length} student{rows.length !== 1 ? 's' : ''}</span>
        </div>
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-[#F7F8FA] border-b border-[#EEEEEE]">
              <th className="text-left px-5 py-3 text-xs font-semibold text-gray-500 font-body">Student</th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-gray-500 font-body">Roll No.</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Attended</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Total Classes</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">%</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Status</th>
            </tr>
          </thead>
          <tbody>
            {rows.map(r => {
              const pct = (r.attended / r.total) * 100
              return (
                <tr key={r.id} className={`border-b border-[#EEEEEE] hover:bg-[#F7F8FA] transition-colors ${pct < 75 ? 'bg-red-50/30' : ''}`}>
                  <td className="px-5 py-3">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-primary-light flex items-center justify-center flex-shrink-0">
                        <span className="text-primary font-bold text-xs font-display">
                          {r.name.split(' ').map(p => p[0]).join('').slice(0, 2)}
                        </span>
                      </div>
                      <span className="font-semibold font-display text-gray-900">{r.name}</span>
                    </div>
                  </td>
                  <td className="px-5 py-3 text-gray-600 font-body">{r.rollNumber}</td>
                  <td className="px-5 py-3 text-center">
                    <input
                      type="number"
                      value={r.attended}
                      onChange={e => updateAttended(r.id, e.target.value)}
                      min={0}
                      max={r.total}
                      className="w-16 text-center px-2 py-1.5 text-sm border border-[#EEEEEE] rounded-lg bg-[#F7F8FA] outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 font-body"
                    />
                  </td>
                  <td className="px-5 py-3 text-center">
                    <input
                      type="number"
                      value={r.total}
                      onChange={e => updateTotal(r.id, e.target.value)}
                      min={1}
                      className="w-16 text-center px-2 py-1.5 text-sm border border-[#EEEEEE] rounded-lg bg-[#F7F8FA] outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 font-body"
                    />
                  </td>
                  <td className="px-5 py-3 text-center">
                    <AttPill pct={pct} />
                  </td>
                  <td className="px-5 py-3 text-center">
                    {pct < 75 ? (
                      <span className="text-xs text-red-600 font-semibold font-body flex items-center justify-center gap-1">
                        <AlertTriangle size={12} /> At Risk
                      </span>
                    ) : pct < 85 ? (
                      <span className="text-xs text-amber-600 font-body">Acceptable</span>
                    ) : (
                      <span className="text-xs text-emerald-600 font-body">Good</span>
                    )}
                  </td>
                </tr>
              )
            })}
            {rows.length === 0 && (
              <tr>
                <td colSpan={6} className="px-5 py-10 text-center text-sm text-gray-400 font-body">
                  No students found for Year {year}.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Summary */}
      {rows.length > 0 && (
        <div className="grid grid-cols-3 gap-4">
          {[
            { label: 'Average Attendance', value: `${(rows.reduce((s, r) => s + (r.attended / r.total) * 100, 0) / rows.length).toFixed(1)}%`, color: 'text-blue-600' },
            { label: 'Below 75%', value: atRisk.length.toString(), color: 'text-red-600' },
            { label: 'Above 85%', value: rows.filter(r => (r.attended / r.total) * 100 >= 85).length.toString(), color: 'text-emerald-600' },
          ].map(({ label, value, color }) => (
            <div key={label} className="bg-white rounded-2xl shadow-card p-5 text-center">
              <p className={`text-2xl font-bold font-display ${color}`}>{value}</p>
              <p className="text-xs text-gray-500 font-body mt-1">{label}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
