import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Search, Filter, Download, ChevronUp, ChevronDown } from 'lucide-react'
import { studentsWithScores } from '../../lib/mockData'

type SortKey = 'fullName' | 'rollNumber' | 'cgpa' | 'score' | 'activityCount'
type SortDir = 'asc' | 'desc'

export default function StudentDirectory() {
  const navigate = useNavigate()
  const [search, setSearch] = useState('')
  const [yearFilter, setYearFilter] = useState<number | 'all'>('all')
  const [classFilter, setClassFilter] = useState<string>('all')
  const [sortKey, setSortKey] = useState<SortKey>('rollNumber')
  const [sortDir, setSortDir] = useState<SortDir>('asc')

  const years = [1, 2, 3, 4]
  const classes = ['all', ...Array.from(new Set(studentsWithScores.map(s => s.classGroup)))]

  const filtered = studentsWithScores
    .filter(s => {
      const q = search.toLowerCase()
      const matchSearch = !q || s.fullName.toLowerCase().includes(q) || s.rollNumber.toLowerCase().includes(q)
      const matchYear = yearFilter === 'all' || s.year === yearFilter
      const matchClass = classFilter === 'all' || s.classGroup === classFilter
      return matchSearch && matchYear && matchClass
    })
    .sort((a, b) => {
      let av: string | number = a[sortKey] as string | number
      let bv: string | number = b[sortKey] as string | number
      if (typeof av === 'string') av = av.toLowerCase()
      if (typeof bv === 'string') bv = bv.toLowerCase()
      if (av < bv) return sortDir === 'asc' ? -1 : 1
      if (av > bv) return sortDir === 'asc' ? 1 : -1
      return 0
    })

  function toggleSort(key: SortKey) {
    if (sortKey === key) setSortDir(d => d === 'asc' ? 'desc' : 'asc')
    else { setSortKey(key); setSortDir('asc') }
  }

  function exportCSV() {
    const header = 'Name,Roll Number,Class,Year,CGPA,Total Score,Activities'
    const rows = filtered.map(s =>
      `"${s.fullName}",${s.rollNumber},${s.classGroup},${s.year},${s.cgpa},${s.score.totalScore},${s.activityCount}`
    )
    const blob = new Blob([[header, ...rows].join('\n')], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a'); a.href = url; a.download = 'students.csv'; a.click()
    URL.revokeObjectURL(url)
  }

  function SortIcon({ col }: { col: SortKey }) {
    if (sortKey !== col) return <ChevronUp size={13} className="text-gray-300 ml-1" />
    return sortDir === 'asc'
      ? <ChevronUp size={13} className="text-primary ml-1" />
      : <ChevronDown size={13} className="text-primary ml-1" />
  }

  function ScorePill({ score }: { score: number }) {
    const color = score >= 75 ? 'bg-emerald-100 text-emerald-700' : score >= 60 ? 'bg-blue-100 text-blue-700' : 'bg-orange-100 text-orange-700'
    return <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${color}`}>{score.toFixed(1)}</span>
  }

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="bg-white rounded-2xl shadow-card p-4 flex items-center gap-3 flex-wrap">
        <div className="relative flex-1 min-w-[200px]">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search by name or roll number..."
            className="w-full pl-9 pr-4 py-2 text-sm bg-[#F7F8FA] border border-[#EEEEEE] rounded-xl outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 font-body"
          />
        </div>

        <div className="flex items-center gap-2">
          <Filter size={14} className="text-gray-400" />
          <span className="text-xs text-gray-500 font-body">Year:</span>
          {(['all', ...years] as const).map(y => (
            <button
              key={y}
              onClick={() => setYearFilter(y as number | 'all')}
              className={`px-3 py-1.5 text-xs rounded-lg font-body transition-colors ${yearFilter === y ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
            >
              {y === 'all' ? 'All' : `Y${y}`}
            </button>
          ))}
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-gray-500 font-body">Class:</span>
          {classes.map(c => (
            <button
              key={c}
              onClick={() => setClassFilter(c)}
              className={`px-3 py-1.5 text-xs rounded-lg font-body transition-colors ${classFilter === c ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
            >
              {c === 'all' ? 'All' : c}
            </button>
          ))}
        </div>

        <button
          onClick={exportCSV}
          className="flex items-center gap-1.5 px-4 py-2 text-sm bg-primary text-white rounded-xl font-body hover:bg-primary-dark transition-colors ml-auto"
        >
          <Download size={14} />
          Export CSV
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <div className="px-5 py-4 border-b border-[#EEEEEE] flex items-center justify-between">
          <span className="font-semibold font-display text-gray-900">Students</span>
          <span className="text-sm text-gray-500 font-body">{filtered.length} result{filtered.length !== 1 ? 's' : ''}</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-[#EEEEEE] bg-[#F7F8FA]">
                {[
                  { key: 'fullName', label: 'Student' },
                  { key: 'rollNumber', label: 'Roll No.' },
                  { key: 'classGroup', label: 'Class' },
                  { key: 'cgpa', label: 'CGPA' },
                  { key: 'score', label: 'Total Score' },
                  { key: 'activityCount', label: 'Activities' },
                ].map(({ key, label }) => (
                  <th
                    key={key}
                    onClick={() => key !== 'classGroup' && toggleSort(key as SortKey)}
                    className={`text-left px-5 py-3 text-xs font-semibold text-gray-500 font-body uppercase tracking-wide select-none ${key !== 'classGroup' ? 'cursor-pointer hover:text-gray-800' : ''}`}
                  >
                    <span className="flex items-center">
                      {label}
                      {key !== 'classGroup' && <SortIcon col={key as SortKey} />}
                    </span>
                  </th>
                ))}
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody>
              {filtered.map(s => (
                <tr
                  key={s.id}
                  className="border-b border-[#EEEEEE] hover:bg-[#F7F8FA] cursor-pointer transition-colors"
                  onClick={() => navigate(`/students/${s.id}`)}
                >
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-primary-light flex items-center justify-center flex-shrink-0">
                        <span className="text-primary font-bold text-xs font-display">
                          {s.fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
                        </span>
                      </div>
                      <span className="font-semibold font-display text-gray-900">{s.fullName}</span>
                    </div>
                  </td>
                  <td className="px-5 py-4 text-gray-600 font-body">{s.rollNumber}</td>
                  <td className="px-5 py-4">
                    <span className="bg-gray-100 text-gray-600 text-xs px-2 py-1 rounded-lg font-body">{s.classGroup}</span>
                  </td>
                  <td className="px-5 py-4">
                    <span className={`text-sm font-bold font-display ${s.cgpa >= 8 ? 'text-emerald-600' : s.cgpa >= 7 ? 'text-blue-600' : 'text-orange-600'}`}>
                      {s.cgpa.toFixed(2)}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    <ScorePill score={s.score.totalScore} />
                  </td>
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-2">
                      <div className="w-16 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                        <div className="h-full bg-primary rounded-full" style={{ width: `${Math.min(100, (s.activityCount / 6) * 100)}%` }} />
                      </div>
                      <span className="text-xs font-body text-gray-600">{s.activityCount}</span>
                    </div>
                  </td>
                  <td className="px-5 py-4 text-right">
                    <span className="text-xs text-primary font-body hover:underline">View →</span>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-5 py-10 text-center text-sm text-gray-400 font-body">
                    No students match the current filters.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
