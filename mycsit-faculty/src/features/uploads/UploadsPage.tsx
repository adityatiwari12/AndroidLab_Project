import { useState, useRef } from 'react'
import * as XLSX from 'xlsx'
import { Upload, FileText, CheckCircle, AlertCircle, X, Download, Eye } from 'lucide-react'

type Tab = 'roster' | 'marks' | 'attendance' | 'activities'

interface UploadRecord {
  id: string; tab: Tab; filename: string; rows: number; status: 'success' | 'error'; time: string; errors?: string[]; preview?: Record<string, unknown>[]
}

const TAB_CONFIG: Record<Tab, { label: string; columns: string[]; required: string[]; example: string[][] }> = {
  roster: {
    label: 'Student Roster',
    columns: ['roll_number', 'full_name', 'email', 'year', 'class_group'],
    required: ['roll_number', 'full_name'],
    example: [
      ['0191CS040', 'Rohan Verma', 'rohan@aitr.ac.in', '3', 'CS-A'],
      ['0191CS041', 'Sneha Patel', 'sneha@aitr.ac.in', '2', 'CS-B'],
    ],
  },
  marks: {
    label: 'Marks Data',
    columns: ['roll_number', 'semester', 'subject_name', 'obtained', 'total', 'grade'],
    required: ['roll_number', 'semester', 'subject_name', 'obtained', 'total'],
    example: [
      ['0191CS009', '5', 'Data Structures', '85', '100', 'A'],
      ['0191CS009', '5', 'DBMS', '78', '100', 'B+'],
    ],
  },
  attendance: {
    label: 'Attendance',
    columns: ['roll_number', 'semester', 'attended', 'total_classes'],
    required: ['roll_number', 'semester', 'attended', 'total_classes'],
    example: [
      ['0191CS009', '5', '52', '60'],
      ['0191CS012', '5', '48', '60'],
    ],
  },
  activities: {
    label: 'Activities',
    columns: ['roll_number', 'type', 'title', 'date', 'status'],
    required: ['roll_number', 'type', 'title'],
    example: [
      ['0191CS009', 'hackathon', 'Smart India Hackathon', '2024-08-15', 'approved'],
      ['0191CS023', 'certification', 'AWS Cloud Practitioner', '2024-07-20', 'approved'],
    ],
  },
}

function parseFile(file: File): Promise<Record<string, unknown>[]> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target!.result as ArrayBuffer)
        const workbook = XLSX.read(data, { type: 'array' })
        const sheet = workbook.Sheets[workbook.SheetNames[0]]
        const rows = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet, { defval: '' })
        resolve(rows)
      } catch (err) {
        reject(err)
      }
    }
    reader.onerror = reject
    reader.readAsArrayBuffer(file)
  })
}

function validateRows(rows: Record<string, unknown>[], required: string[]): string[] {
  const errors: string[] = []
  rows.forEach((row, i) => {
    required.forEach(col => {
      if (!row[col] && row[col] !== 0) {
        errors.push(`Row ${i + 2}: missing required field "${col}"`)
      }
    })
  })
  return errors.slice(0, 5)
}

function DropZone({ onFile, loading }: { onFile: (file: File) => void; loading: boolean }) {
  const ref = useRef<HTMLInputElement>(null)
  const [drag, setDrag] = useState(false)

  function handleDrop(e: React.DragEvent) {
    e.preventDefault(); setDrag(false)
    const f = e.dataTransfer.files[0]
    if (f) onFile(f)
  }

  return (
    <div
      onDragOver={e => { e.preventDefault(); setDrag(true) }}
      onDragLeave={() => setDrag(false)}
      onDrop={handleDrop}
      onClick={() => !loading && ref.current?.click()}
      className={`border-2 border-dashed rounded-2xl p-10 flex flex-col items-center justify-center gap-3 transition-all ${loading ? 'opacity-50 cursor-wait' : 'cursor-pointer'} ${drag ? 'border-primary bg-primary-light' : 'border-[#EEEEEE] bg-[#F7F8FA] hover:border-primary/50 hover:bg-primary-light/50'}`}
    >
      <input ref={ref} type="file" accept=".csv,.xlsx,.xls" className="hidden" onChange={e => { const f = e.target.files?.[0]; if (f) onFile(f) }} />
      {loading
        ? <div className="w-8 h-8 border-3 border-primary border-t-transparent rounded-full animate-spin" />
        : <Upload size={36} className={drag ? 'text-primary' : 'text-gray-300'} />
      }
      <p className="text-sm font-semibold font-display text-gray-700">
        {loading ? 'Parsing file…' : 'Drop CSV/Excel here or click to browse'}
      </p>
      <p className="text-xs text-gray-400 font-body">Supported: .csv, .xlsx, .xls · Max 10MB</p>
    </div>
  )
}

export default function UploadsPage() {
  const [tab, setTab] = useState<Tab>('roster')
  const [loading, setLoading] = useState(false)
  const [previewRecord, setPreviewRecord] = useState<UploadRecord | null>(null)
  const [history, setHistory] = useState<UploadRecord[]>([
    { id: '1', tab: 'roster', filename: 'students_batch_2024.csv', rows: 45, status: 'success', time: '10/01/2025, 14:32' },
    { id: '2', tab: 'marks', filename: 'sem5_marks.xlsx', rows: 180, status: 'success', time: '08/01/2025, 09:15' },
    { id: '3', tab: 'attendance', filename: 'oct_attendance.csv', rows: 47, status: 'error', time: '06/01/2025, 16:45', errors: ['Row 23: missing required field "roll_number"', 'Row 41: missing required field "total_classes"'] },
  ])

  async function handleFile(file: File) {
    setLoading(true)
    try {
      const rows = await parseFile(file)
      const cfg = TAB_CONFIG[tab]
      const errors = validateRows(rows, cfg.required)
      const record: UploadRecord = {
        id: Date.now().toString(),
        tab,
        filename: file.name,
        rows: rows.length,
        status: errors.length === 0 ? 'success' : 'error',
        time: new Date().toLocaleString('en-IN', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }),
        errors: errors.length > 0 ? errors : undefined,
        preview: rows.slice(0, 5),
      }
      setHistory(h => [record, ...h])
    } catch {
      const record: UploadRecord = {
        id: Date.now().toString(), tab, filename: file.name, rows: 0, status: 'error',
        time: new Date().toLocaleString('en-IN', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }),
        errors: ['Could not parse file. Ensure it is a valid CSV or Excel file.'],
      }
      setHistory(h => [record, ...h])
    } finally {
      setLoading(false)
    }
  }

  function downloadTemplate(t: Tab) {
    const cfg = TAB_CONFIG[t]
    const rows = [cfg.columns.join(','), ...cfg.example.map(r => r.join(','))].join('\n')
    const blob = new Blob([rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a'); a.href = url; a.download = `template_${t}.csv`; a.click()
    URL.revokeObjectURL(url)
  }

  const cfg = TAB_CONFIG[tab]
  const tabHistory = history.filter(h => h.tab === tab)

  const tabs: { key: Tab; label: string }[] = [
    { key: 'roster', label: 'Student Roster' },
    { key: 'marks', label: 'Marks' },
    { key: 'attendance', label: 'Attendance' },
    { key: 'activities', label: 'Activities' },
  ]

  return (
    <div className="space-y-5">
      {/* Tabs */}
      <div className="bg-white rounded-2xl shadow-card p-1.5 flex gap-1">
        {tabs.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`flex-1 py-2.5 text-sm rounded-xl font-body transition-all ${tab === key ? 'bg-primary text-white font-semibold' : 'text-gray-500 hover:text-gray-800 hover:bg-gray-50'}`}
          >
            {label}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-3 gap-6">
        {/* Upload area */}
        <div className="col-span-2 space-y-4">
          <div className="bg-white rounded-2xl shadow-card p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold font-display text-gray-900">Upload {cfg.label}</h3>
              <button
                onClick={() => downloadTemplate(tab)}
                className="flex items-center gap-1.5 text-xs text-primary font-body hover:underline"
              >
                <Download size={13} /> Download template
              </button>
            </div>
            <DropZone onFile={handleFile} loading={loading} />
          </div>

          {/* Preview modal */}
          {previewRecord?.preview && (
            <div className="bg-white rounded-2xl shadow-card overflow-hidden">
              <div className="px-5 py-4 border-b border-[#EEEEEE] flex items-center justify-between">
                <span className="font-semibold font-display text-gray-900">Preview — {previewRecord.filename}</span>
                <button onClick={() => setPreviewRecord(null)} className="text-gray-400 hover:text-gray-700">
                  <X size={16} />
                </button>
              </div>
              <div className="overflow-x-auto p-4">
                <table className="text-xs w-full border-collapse">
                  <thead>
                    <tr>
                      {Object.keys(previewRecord.preview[0] ?? {}).map(k => (
                        <th key={k} className="text-left px-3 py-2 bg-gray-50 border border-gray-200 font-semibold text-gray-600 whitespace-nowrap">{k}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {previewRecord.preview.map((row, i) => (
                      <tr key={i} className="hover:bg-gray-50">
                        {Object.values(row).map((cell, j) => (
                          <td key={j} className="px-3 py-2 border border-gray-100 text-gray-700 whitespace-nowrap">{String(cell)}</td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
                {previewRecord.rows > 5 && (
                  <p className="text-xs text-gray-400 font-body mt-2">Showing 5 of {previewRecord.rows} rows</p>
                )}
              </div>
            </div>
          )}

          {/* Upload history */}
          {tabHistory.length > 0 && (
            <div className="bg-white rounded-2xl shadow-card overflow-hidden">
              <div className="px-5 py-4 border-b border-[#EEEEEE]">
                <span className="font-semibold font-display text-gray-900">Upload History</span>
              </div>
              <div className="divide-y divide-[#EEEEEE]">
                {tabHistory.map(r => (
                  <div key={r.id} className="px-5 py-4">
                    <div className="flex items-start gap-3">
                      {r.status === 'success'
                        ? <CheckCircle size={18} className="text-emerald-500 flex-shrink-0 mt-0.5" />
                        : <AlertCircle size={18} className="text-red-500 flex-shrink-0 mt-0.5" />
                      }
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 flex-wrap">
                          <FileText size={14} className="text-gray-400" />
                          <span className="text-sm font-semibold font-display text-gray-900 truncate">{r.filename}</span>
                          <span className={`text-xs px-2 py-0.5 rounded-full font-body ${r.status === 'success' ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'}`}>
                            {r.status === 'success' ? `${r.rows} rows parsed` : 'Failed'}
                          </span>
                          {r.preview && (
                            <button
                              onClick={() => setPreviewRecord(previewRecord?.id === r.id ? null : r)}
                              className="flex items-center gap-1 text-xs text-primary font-body hover:underline"
                            >
                              <Eye size={11} /> Preview
                            </button>
                          )}
                        </div>
                        <p className="text-xs text-gray-400 font-body mt-0.5">{r.time}</p>
                        {r.errors && (
                          <div className="mt-2 space-y-1">
                            {r.errors.map((err, i) => (
                              <p key={i} className="text-xs text-red-600 font-body flex items-center gap-1">
                                <X size={11} /> {err}
                              </p>
                            ))}
                            {r.errors.length === 5 && <p className="text-xs text-gray-400 font-body">…more errors not shown</p>}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Format guide */}
        <div className="bg-white rounded-2xl shadow-card p-5 h-fit">
          <h4 className="font-semibold font-display text-gray-900 mb-3">Format Guide</h4>
          <p className="text-xs text-gray-500 font-body mb-3">Required columns in order:</p>
          <div className="space-y-1.5 mb-4">
            {cfg.columns.map((col, i) => (
              <div key={col} className="flex items-center gap-2">
                <span className="w-5 h-5 rounded bg-primary-light text-primary text-xs font-bold font-display flex items-center justify-center flex-shrink-0">
                  {i + 1}
                </span>
                <code className={`text-xs font-mono px-2 py-0.5 rounded ${cfg.required.includes(col) ? 'bg-amber-50 text-amber-700' : 'text-gray-700 bg-[#F7F8FA]'}`}>{col}</code>
                {cfg.required.includes(col) && <span className="text-xs text-amber-600 font-body">required</span>}
              </div>
            ))}
          </div>
          <div className="border-t border-[#EEEEEE] pt-3">
            <p className="text-xs font-semibold text-gray-600 font-body mb-2">Example rows:</p>
            <div className="bg-[#F7F8FA] rounded-xl p-3 overflow-x-auto">
              <table className="text-xs font-mono text-gray-600 w-full">
                <thead>
                  <tr>
                    {cfg.columns.map(c => (
                      <th key={c} className="text-left pb-1 pr-3 font-semibold text-gray-400 whitespace-nowrap">{c}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {cfg.example.map((row, i) => (
                    <tr key={i}>
                      {row.map((cell, j) => (
                        <td key={j} className="pr-3 py-0.5 whitespace-nowrap text-gray-700">{cell}</td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          <div className="border-t border-[#EEEEEE] mt-3 pt-3 space-y-1.5">
            <p className="text-xs font-semibold text-gray-600 font-body">Rules:</p>
            <p className="text-xs text-gray-500 font-body">• First row must be the header</p>
            <p className="text-xs text-gray-500 font-body">• Roll numbers must match existing students</p>
            <p className="text-xs text-gray-500 font-body">• Dates in YYYY-MM-DD format</p>
            <p className="text-xs text-gray-500 font-body">• UTF-8 encoding for CSV files</p>
            <p className="text-xs text-gray-500 font-body">• <span className="text-amber-600">Amber</span> = required column</p>
          </div>
        </div>
      </div>
    </div>
  )
}
