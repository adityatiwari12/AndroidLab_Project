import { Trophy, Medal, Award, TrendingUp } from 'lucide-react'
import { leaderboard, studentsWithScores } from '../../lib/mockData'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts'

const COLORS = ['#FF6B35', '#FF9F1C', '#10B981', '#3B82F6']

function RankIcon({ rank }: { rank: number }) {
  if (rank === 1) return <Trophy size={20} className="text-yellow-500" />
  if (rank === 2) return <Medal size={20} className="text-gray-400" />
  if (rank === 3) return <Award size={20} className="text-amber-600" />
  return <span className="text-sm font-bold font-display text-gray-500">#{rank}</span>
}

function ScoreBar({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div>
      <div className="flex justify-between mb-1">
        <span className="text-xs text-gray-500 font-body">{label}</span>
        <span className="text-xs font-bold font-display text-gray-700">{value.toFixed(1)}</span>
      </div>
      <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
        <div className="h-full rounded-full" style={{ width: `${value}%`, background: color }} />
      </div>
    </div>
  )
}

export default function LeaderboardPage() {
  const top3 = leaderboard.slice(0, 3)

  const chartData = leaderboard.map(s => ({
    name: s.fullName.split(' ')[0],
    score: s.totalScore,
    hackathon: s.hackathonScore,
    project: s.projectScore,
    academic: s.academicScore,
    coding: s.codingScore,
  }))

  const avgScore = (studentsWithScores.reduce((s, st) => s + st.score.totalScore, 0) / studentsWithScores.length).toFixed(1)
  const topScore = leaderboard[0]?.totalScore.toFixed(1) ?? '—'

  return (
    <div className="space-y-6">
      {/* Stat bar */}
      <div className="grid grid-cols-3 gap-4">
        {[
          { label: 'Top Score', value: topScore, color: 'text-yellow-600', bg: 'bg-yellow-50' },
          { label: 'Class Average', value: avgScore, color: 'text-blue-600', bg: 'bg-blue-50' },
          { label: 'Total Students', value: leaderboard.length.toString(), color: 'text-primary', bg: 'bg-primary-light' },
        ].map(({ label, value, color, bg }) => (
          <div key={label} className={`${bg} rounded-2xl p-5 text-center`}>
            <p className={`text-2xl font-bold font-display ${color}`}>{value}</p>
            <p className="text-xs text-gray-500 font-body mt-1">{label}</p>
          </div>
        ))}
      </div>

      {/* Podium */}
      <div className="bg-white rounded-2xl shadow-card p-6">
        <h3 className="font-semibold font-display text-gray-900 mb-6 flex items-center gap-2">
          <Trophy size={18} className="text-yellow-500" /> Top Performers
        </h3>
        <div className="flex items-end justify-center gap-4">
          {/* 2nd */}
          {top3[1] && (
            <div className="flex flex-col items-center gap-2 w-36">
              <div className="w-14 h-14 rounded-full bg-gray-100 flex items-center justify-center">
                <span className="font-bold text-lg font-display text-gray-500">
                  {top3[1].fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
                </span>
              </div>
              <Medal size={20} className="text-gray-400" />
              <p className="text-sm font-semibold font-display text-gray-700 text-center">{top3[1].fullName.split(' ')[0]}</p>
              <p className="text-lg font-bold font-display text-gray-900">{top3[1].totalScore.toFixed(1)}</p>
              <div className="w-full h-16 bg-gray-100 rounded-t-xl flex items-center justify-center">
                <span className="text-2xl font-bold text-gray-400">2</span>
              </div>
            </div>
          )}
          {/* 1st */}
          {top3[0] && (
            <div className="flex flex-col items-center gap-2 w-36">
              <div className="w-16 h-16 rounded-full bg-yellow-50 border-2 border-yellow-300 flex items-center justify-center">
                <span className="font-bold text-xl font-display text-yellow-700">
                  {top3[0].fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
                </span>
              </div>
              <Trophy size={22} className="text-yellow-500" />
              <p className="text-sm font-semibold font-display text-gray-900 text-center">{top3[0].fullName.split(' ')[0]}</p>
              <p className="text-xl font-bold font-display text-primary">{top3[0].totalScore.toFixed(1)}</p>
              <div className="w-full h-24 bg-primary rounded-t-xl flex items-center justify-center">
                <span className="text-3xl font-bold text-white">1</span>
              </div>
            </div>
          )}
          {/* 3rd */}
          {top3[2] && (
            <div className="flex flex-col items-center gap-2 w-36">
              <div className="w-14 h-14 rounded-full bg-amber-50 flex items-center justify-center">
                <span className="font-bold text-lg font-display text-amber-700">
                  {top3[2].fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
                </span>
              </div>
              <Award size={20} className="text-amber-600" />
              <p className="text-sm font-semibold font-display text-gray-700 text-center">{top3[2].fullName.split(' ')[0]}</p>
              <p className="text-lg font-bold font-display text-gray-900">{top3[2].totalScore.toFixed(1)}</p>
              <div className="w-full h-10 bg-amber-200 rounded-t-xl flex items-center justify-center">
                <span className="text-2xl font-bold text-amber-700">3</span>
              </div>
            </div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-6">
        {/* Score comparison chart */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4 flex items-center gap-2">
            <TrendingUp size={18} className="text-primary" /> Score Comparison
          </h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={chartData} barSize={36}>
              <XAxis dataKey="name" tick={{ fontSize: 12, fontFamily: 'DM Sans' }} axisLine={false} tickLine={false} />
              <YAxis domain={[0, 100]} tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip
                formatter={(v: number) => [v.toFixed(2), 'Score']}
                contentStyle={{ borderRadius: 10, border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.1)' }}
              />
              <Bar dataKey="score" radius={[6, 6, 0, 0]}>
                {chartData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Score breakdown per student */}
        <div className="bg-white rounded-2xl shadow-card p-6">
          <h3 className="font-semibold font-display text-gray-900 mb-4">Score Breakdown — #{1} {leaderboard[0]?.fullName}</h3>
          {leaderboard[0] && (
            <div className="space-y-3">
              <ScoreBar label="Hackathons (35%)" value={leaderboard[0].hackathonScore} color="#8B5CF6" />
              <ScoreBar label="Projects (25%)" value={leaderboard[0].projectScore} color="#3B82F6" />
              <ScoreBar label="Academic (25%)" value={leaderboard[0].academicScore} color="#10B981" />
              <ScoreBar label="Coding (15%)" value={leaderboard[0].codingScore} color="#F59E0B" />
              <div className="border-t border-[#EEEEEE] pt-3">
                <div className="flex justify-between">
                  <span className="text-sm font-semibold font-display text-gray-700">Total Score</span>
                  <span className="text-sm font-bold font-display text-primary">{leaderboard[0].totalScore.toFixed(2)}</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Full table */}
      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <div className="px-5 py-4 border-b border-[#EEEEEE]">
          <span className="font-semibold font-display text-gray-900">Full Rankings</span>
        </div>
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-[#F7F8FA] border-b border-[#EEEEEE]">
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body w-16">Rank</th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-gray-500 font-body">Student</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Hackathon</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Project</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Academic</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Coding</th>
              <th className="text-center px-5 py-3 text-xs font-semibold text-gray-500 font-body">Total</th>
            </tr>
          </thead>
          <tbody>
            {leaderboard.map((s, i) => (
              <tr key={s.userId} className={`border-b border-[#EEEEEE] hover:bg-[#F7F8FA] transition-colors ${i === 0 ? 'bg-yellow-50/40' : ''}`}>
                <td className="px-5 py-4 text-center">
                  <div className="flex items-center justify-center">
                    <RankIcon rank={i + 1} />
                  </div>
                </td>
                <td className="px-5 py-4">
                  <div className="flex items-center gap-3">
                    <div className={`w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${i === 0 ? 'bg-yellow-100' : 'bg-primary-light'}`}>
                      <span className={`font-bold text-xs font-display ${i === 0 ? 'text-yellow-700' : 'text-primary'}`}>
                        {s.fullName.split(' ').map(p => p[0]).join('').slice(0, 2)}
                      </span>
                    </div>
                    <div>
                      <p className="font-semibold font-display text-gray-900">{s.fullName}</p>
                      <p className="text-xs text-gray-400 font-body">{s.rollNumber}</p>
                    </div>
                  </div>
                </td>
                <td className="px-5 py-4 text-center text-xs font-body text-gray-600">{s.hackathonScore.toFixed(1)}</td>
                <td className="px-5 py-4 text-center text-xs font-body text-gray-600">{s.projectScore.toFixed(1)}</td>
                <td className="px-5 py-4 text-center text-xs font-body text-gray-600">{s.academicScore.toFixed(1)}</td>
                <td className="px-5 py-4 text-center text-xs font-body text-gray-600">{s.codingScore.toFixed(1)}</td>
                <td className="px-5 py-4 text-center">
                  <span className={`text-sm font-bold font-display ${i === 0 ? 'text-primary' : 'text-gray-900'}`}>
                    {s.totalScore.toFixed(2)}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
