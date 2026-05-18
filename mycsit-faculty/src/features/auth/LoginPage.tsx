import { useState } from 'react'

interface Props { onLogin: () => void }

export default function LoginPage({ onLogin }: Props) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    await new Promise(r => setTimeout(r, 600))
    setLoading(false)
    onLogin()
  }

  return (
    <div className="min-h-screen bg-[#F7F8FA] flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-elevated p-10 w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <h1 className="font-display font-bold text-3xl">
            <span className="text-primary">My</span>
            <span className="text-gray-900">CSIT</span>
          </h1>
          <div className="h-1 w-16 bg-primary rounded-full mx-auto mt-2 mb-3" />
          <p className="text-sm text-gray-500 font-body">Department Intelligence Dashboard</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 font-body mb-1">Faculty Email</label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="faculty@aitr.ac.in"
              className="w-full px-4 py-3 border border-[#EEEEEE] rounded-xl bg-[#F7F8FA] text-sm font-body outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 font-body mb-1">Password</label>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="••••••••"
              className="w-full px-4 py-3 border border-[#EEEEEE] rounded-xl bg-[#F7F8FA] text-sm font-body outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
            />
          </div>
          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-primary hover:bg-primary-dark text-white font-semibold rounded-full transition-colors font-display text-[15px] disabled:opacity-60 shadow-accent-glow"
          >
            {loading ? 'Signing in…' : 'Login'}
          </button>
        </form>

        <div className="mt-6 p-4 bg-primary-light rounded-xl border border-primary/20">
          <p className="text-xs font-semibold text-primary font-display mb-1">🎓 Demo — any credentials work</p>
          <p className="text-xs text-primary/80 font-body">Logged in as: Prof. P. Sharma (HOD) · All Classes</p>
        </div>
      </div>
    </div>
  )
}
