import { useState } from 'react'
import { CheckCircle, XCircle, Eye, User, Award, Code2 } from 'lucide-react'
import { pendingStudents, pendingActivities, pendingCoding } from '../../lib/mockData'
import type { Activity, CodingActivity } from '../../types'

type Tab = 'registrations' | 'activities' | 'coding'

function ActionButtons({ onApprove, onReject }: { onApprove: () => void; onReject: () => void }) {
  return (
    <div className="flex gap-2">
      <button
        onClick={onApprove}
        className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 text-emerald-700 text-xs font-semibold rounded-lg hover:bg-emerald-100 transition-colors font-body"
      >
        <CheckCircle size={13} /> Approve
      </button>
      <button
        onClick={onReject}
        className="flex items-center gap-1.5 px-3 py-1.5 bg-red-50 text-red-600 text-xs font-semibold rounded-lg hover:bg-red-100 transition-colors font-body"
      >
        <XCircle size={13} /> Reject
      </button>
    </div>
  )
}

export default function ApprovalQueue() {
  const [tab, setTab] = useState<Tab>('registrations')
  const [students, setStudents] = useState(pendingStudents)
  const [acts, setActs] = useState<Activity[]>(pendingActivities)
  const [coding, setCoding] = useState<CodingActivity[]>(pendingCoding)
  const [rejectModal, setRejectModal] = useState<{ type: Tab; id: string } | null>(null)
  const [rejectReason, setRejectReason] = useState('')
  const [toast, setToast] = useState<string | null>(null)

  function showToast(msg: string) {
    setToast(msg)
    setTimeout(() => setToast(null), 2500)
  }

  function approveStudent(id: string) {
    setStudents(s => s.filter(x => x.id !== id))
    showToast('Student registration approved.')
  }
  function rejectStudent(id: string, reason: string) {
    setStudents(s => s.filter(x => x.id !== id))
    console.log('Reject reason:', reason)
    showToast('Student registration rejected.')
  }

  function approveAct(id: string) {
    setActs(a => a.filter(x => x.id !== id))
    showToast('Activity approved.')
  }
  function rejectAct(id: string, reason: string) {
    setActs(a => a.filter(x => x.id !== id))
    console.log('Reject reason:', reason)
    showToast('Activity rejected.')
  }

  function approveCoding(id: string) {
    setCoding(c => c.filter(x => x.id !== id))
    showToast('Coding entry approved.')
  }
  function rejectCoding(id: string, reason: string) {
    setCoding(c => c.filter(x => x.id !== id))
    console.log('Reject reason:', reason)
    showToast('Coding entry rejected.')
  }

  function handleBulkApprove() {
    if (tab === 'registrations') { setStudents([]); showToast(`${students.length} registrations approved.`) }
    if (tab === 'activities') { setActs([]); showToast(`${acts.length} activities approved.`) }
    if (tab === 'coding') { setCoding([]); showToast(`${coding.length} coding entries approved.`) }
  }

  function handleRejectConfirm() {
    if (!rejectModal) return
    if (rejectModal.type === 'registrations') rejectStudent(rejectModal.id, rejectReason)
    if (rejectModal.type === 'activities') rejectAct(rejectModal.id, rejectReason)
    if (rejectModal.type === 'coding') rejectCoding(rejectModal.id, rejectReason)
    setRejectModal(null)
    setRejectReason('')
  }

  const tabCounts = { registrations: students.length, activities: acts.length, coding: coding.length }
  const tabs: { key: Tab; label: string; icon: typeof User }[] = [
    { key: 'registrations', label: 'Student Registrations', icon: User },
    { key: 'activities', label: 'Activity Entries', icon: Award },
    { key: 'coding', label: 'Coding Entries', icon: Code2 },
  ]

  return (
    <div className="space-y-4">
      {/* Toast */}
      {toast && (
        <div className="fixed bottom-6 right-6 z-50 bg-gray-900 text-white text-sm px-4 py-3 rounded-xl shadow-elevated font-body animate-bounce">
          {toast}
        </div>
      )}

      {/* Reject Modal */}
      {rejectModal && (
        <div className="fixed inset-0 z-50 bg-black/40 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-elevated p-6 w-full max-w-md">
            <h3 className="font-bold font-display text-gray-900 mb-2">Rejection Reason</h3>
            <p className="text-sm text-gray-500 font-body mb-4">Provide a reason so the student can resubmit with corrections.</p>
            <textarea
              value={rejectReason}
              onChange={e => setRejectReason(e.target.value)}
              placeholder="e.g. Please provide a valid certificate with issuer name and date..."
              rows={3}
              className="w-full px-4 py-3 text-sm border border-[#EEEEEE] rounded-xl bg-[#F7F8FA] outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 font-body resize-none"
            />
            <div className="flex gap-3 mt-4">
              <button onClick={() => setRejectModal(null)} className="flex-1 py-2.5 text-sm border border-[#EEEEEE] rounded-xl text-gray-600 font-body hover:bg-gray-50 transition-colors">Cancel</button>
              <button onClick={handleRejectConfirm} className="flex-1 py-2.5 text-sm bg-red-500 text-white rounded-xl font-semibold font-body hover:bg-red-600 transition-colors">Confirm Reject</button>
            </div>
          </div>
        </div>
      )}

      {/* Tabs */}
      <div className="bg-white rounded-2xl shadow-card p-1.5 flex gap-1">
        {tabs.map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`flex-1 flex items-center justify-center gap-2 py-2.5 text-sm rounded-xl font-body transition-all ${tab === key ? 'bg-primary text-white font-semibold' : 'text-gray-500 hover:text-gray-800 hover:bg-gray-50'}`}
          >
            <Icon size={14} />
            {label}
            {tabCounts[key] > 0 && (
              <span className={`text-xs font-bold px-1.5 py-0.5 rounded-full min-w-[20px] text-center ${tab === key ? 'bg-white/30' : 'bg-red-500 text-white'}`}>
                {tabCounts[key]}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Bulk actions */}
      {((tab === 'registrations' && students.length > 0) || (tab === 'activities' && acts.length > 0) || (tab === 'coding' && coding.length > 0)) && (
        <div className="bg-amber-50 border border-amber-200 rounded-2xl px-5 py-3 flex items-center justify-between">
          <p className="text-sm text-amber-800 font-body">
            <span className="font-semibold">{tabCounts[tab]}</span> item{tabCounts[tab] !== 1 ? 's' : ''} pending review
          </p>
          <button
            onClick={handleBulkApprove}
            className="flex items-center gap-1.5 px-4 py-2 bg-emerald-500 text-white text-sm font-semibold rounded-xl hover:bg-emerald-600 transition-colors font-body"
          >
            <CheckCircle size={14} /> Approve All
          </button>
        </div>
      )}

      {/* Student Registrations */}
      {tab === 'registrations' && (
        <div className="bg-white rounded-2xl shadow-card overflow-hidden">
          {students.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-gray-400">
              <CheckCircle size={40} className="text-emerald-400 mb-3" />
              <p className="text-sm font-body">All registrations reviewed</p>
            </div>
          ) : (
            <div className="divide-y divide-[#EEEEEE]">
              {students.map(s => (
                <div key={s.id} className="px-5 py-4 flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0">
                    <span className="text-blue-600 font-bold text-sm font-display">
                      {s.fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold font-display text-gray-900 text-sm">{s.fullName}</p>
                    <p className="text-xs text-gray-500 font-body">{s.rollNumber} · {s.classGroup} · Year {s.year}</p>
                    <p className="text-xs text-gray-400 font-body">{s.email}</p>
                  </div>
                  <ActionButtons
                    onApprove={() => approveStudent(s.id)}
                    onReject={() => setRejectModal({ type: 'registrations', id: s.id })}
                  />
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Activity Entries */}
      {tab === 'activities' && (
        <div className="bg-white rounded-2xl shadow-card overflow-hidden">
          {acts.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-gray-400">
              <CheckCircle size={40} className="text-emerald-400 mb-3" />
              <p className="text-sm font-body">All activities reviewed</p>
            </div>
          ) : (
            <div className="divide-y divide-[#EEEEEE]">
              {acts.map(a => (
                <div key={a.id} className="px-5 py-4 flex items-start gap-4">
                  <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center flex-shrink-0">
                    <Award size={18} className="text-purple-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-0.5">
                      <span className="text-sm font-semibold font-display text-gray-900 truncate">{a.title}</span>
                      <span className="text-xs bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full font-body">{a.type}</span>
                    </div>
                    <p className="text-xs text-gray-500 font-body">{a.studentName} · {new Date(a.activityDate).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}</p>
                    {a.description && <p className="text-xs text-gray-500 font-body mt-1 line-clamp-2">{a.description}</p>}
                  </div>
                  <div className="flex items-center gap-2">
                    <button className="p-1.5 rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors">
                      <Eye size={14} className="text-gray-500" />
                    </button>
                    <ActionButtons
                      onApprove={() => approveAct(a.id)}
                      onReject={() => setRejectModal({ type: 'activities', id: a.id })}
                    />
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Coding Entries */}
      {tab === 'coding' && (
        <div className="bg-white rounded-2xl shadow-card overflow-hidden">
          {coding.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-gray-400">
              <CheckCircle size={40} className="text-emerald-400 mb-3" />
              <p className="text-sm font-body">All coding entries reviewed</p>
            </div>
          ) : (
            <div className="divide-y divide-[#EEEEEE]">
              {coding.map(c => (
                <div key={c.id} className="px-5 py-4 flex items-center gap-4">
                  <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center flex-shrink-0">
                    <Code2 size={18} className="text-blue-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-0.5">
                      <span className="text-sm font-semibold font-display text-gray-900 truncate">{c.title ?? c.type}</span>
                      <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full font-body">{c.type}</span>
                    </div>
                    <p className="text-xs text-gray-500 font-body">{c.studentName} · {c.platform}</p>
                  </div>
                  <ActionButtons
                    onApprove={() => approveCoding(c.id)}
                    onReject={() => setRejectModal({ type: 'coding', id: c.id })}
                  />
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
