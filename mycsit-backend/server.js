const express = require('express')
const cors = require('cors')
const fs = require('fs')
const path = require('path')
const multer = require('multer')
const XLSX = require('xlsx')
const { v4: uuidv4 } = require('uuid')

const app = express()
const PORT = 3001

app.use(cors())
app.use(express.json())
app.use('/uploads', express.static(path.join(__dirname, 'uploads')))

// ── DB helpers ────────────────────────────────────────────────────────────────

const DB_FILE = path.join(__dirname, 'data', 'db.json')

function readDB() {
  return JSON.parse(fs.readFileSync(DB_FILE, 'utf-8'))
}

function writeDB(data) {
  fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2))
}

// ── File upload storage ───────────────────────────────────────────────────────

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, 'uploads', req.params.type || 'misc')
    fs.mkdirSync(dir, { recursive: true })
    cb(null, dir)
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname)
    cb(null, `${Date.now()}-${uuidv4().slice(0, 8)}${ext}`)
  },
})
const upload = multer({ storage, limits: { fileSize: 20 * 1024 * 1024 } })

// ── Routes: Students ──────────────────────────────────────────────────────────

app.get('/api/students', (req, res) => {
  const db = readDB()
  const { status, year, classGroup } = req.query
  let list = [...db.students, ...db.pendingStudents]
  if (status) list = list.filter(s => s.status === status)
  if (year) list = list.filter(s => s.year === Number(year))
  if (classGroup) list = list.filter(s => s.classGroup === classGroup)
  res.json(list)
})

app.get('/api/students/:id', (req, res) => {
  const db = readDB()
  const student = [...db.students, ...db.pendingStudents].find(s => s.id === req.params.id)
  if (!student) return res.status(404).json({ error: 'Student not found' })
  const score = db.scores.find(sc => sc.userId === student.id) || null
  const activities = db.activities.filter(a => a.userId === student.id)
  const coding = db.codingActivities.filter(c => c.userId === student.id)
  const academics = db.academicRecords.filter(r => r.userId === student.id)
  res.json({ ...student, score, activities, coding, academics })
})

app.post('/api/students', (req, res) => {
  const db = readDB()
  const student = { id: `user-${uuidv4().slice(0, 8)}`, status: 'pending', registeredAt: new Date().toISOString().split('T')[0], ...req.body }
  db.pendingStudents.push(student)
  writeDB(db)
  res.status(201).json(student)
})

app.put('/api/students/:id/status', (req, res) => {
  const db = readDB()
  const { status } = req.body
  const idx = db.pendingStudents.findIndex(s => s.id === req.params.id)
  if (idx === -1) return res.status(404).json({ error: 'Student not found' })
  const student = db.pendingStudents[idx]
  student.status = status
  if (status === 'active') {
    db.students.push(student)
    db.pendingStudents.splice(idx, 1)
  } else {
    db.pendingStudents[idx] = student
  }
  writeDB(db)
  res.json(student)
})

// ── Routes: Activities ────────────────────────────────────────────────────────

app.get('/api/activities', (req, res) => {
  const db = readDB()
  const { status, userId, type } = req.query
  let list = db.activities
  if (status) list = list.filter(a => a.status === status)
  if (userId) list = list.filter(a => a.userId === userId)
  if (type) list = list.filter(a => a.type === type)
  res.json(list)
})

app.get('/api/activities/student/:userId', (req, res) => {
  const db = readDB()
  res.json(db.activities.filter(a => a.userId === req.params.userId))
})

app.post('/api/activities', (req, res) => {
  const db = readDB()
  const activity = { id: `act-${uuidv4().slice(0, 8)}`, status: 'pending', createdAt: new Date().toISOString().split('T')[0], ...req.body }
  db.activities.push(activity)
  writeDB(db)
  res.status(201).json(activity)
})

app.put('/api/activities/:id/status', (req, res) => {
  const db = readDB()
  const { status, rejectionReason } = req.body
  const activity = db.activities.find(a => a.id === req.params.id)
  if (!activity) return res.status(404).json({ error: 'Activity not found' })
  activity.status = status
  if (rejectionReason) activity.rejectionReason = rejectionReason
  writeDB(db)
  res.json(activity)
})

// ── Routes: Coding ────────────────────────────────────────────────────────────

app.get('/api/coding', (req, res) => {
  const db = readDB()
  const { status, userId } = req.query
  let list = db.codingActivities
  if (status) list = list.filter(c => c.status === status)
  if (userId) list = list.filter(c => c.userId === userId)
  res.json(list)
})

app.get('/api/coding/student/:userId', (req, res) => {
  const db = readDB()
  res.json(db.codingActivities.filter(c => c.userId === req.params.userId))
})

app.post('/api/coding', (req, res) => {
  const db = readDB()
  const entry = { id: `cod-${uuidv4().slice(0, 8)}`, status: 'pending', createdAt: new Date().toISOString().split('T')[0], ...req.body }
  db.codingActivities.push(entry)
  writeDB(db)
  res.status(201).json(entry)
})

app.put('/api/coding/:id/status', (req, res) => {
  const db = readDB()
  const { status, rejectionReason } = req.body
  const entry = db.codingActivities.find(c => c.id === req.params.id)
  if (!entry) return res.status(404).json({ error: 'Entry not found' })
  entry.status = status
  if (rejectionReason) entry.rejectionReason = rejectionReason
  writeDB(db)
  res.json(entry)
})

// ── Routes: Academics ─────────────────────────────────────────────────────────

app.get('/api/academics/student/:userId', (req, res) => {
  const db = readDB()
  res.json(db.academicRecords.filter(r => r.userId === req.params.userId))
})

// ── Routes: Leaderboard ───────────────────────────────────────────────────────

app.get('/api/leaderboard', (req, res) => {
  const db = readDB()
  const rows = db.students.map((s, i) => {
    const score = db.scores.find(sc => sc.userId === s.id)
    return score ? { rank: 0, userId: s.id, fullName: s.fullName, rollNumber: s.rollNumber, classGroup: s.classGroup, year: s.year, ...score } : null
  }).filter(Boolean)
  rows.sort((a, b) => b.totalScore - a.totalScore)
  rows.forEach((r, i) => { r.rank = i + 1 })
  res.json(rows)
})

// ── Routes: Stats (overview) ──────────────────────────────────────────────────

app.get('/api/stats/overview', (req, res) => {
  const db = readDB()
  const pendingCount = db.pendingStudents.length + db.activities.filter(a => a.status === 'pending').length + db.codingActivities.filter(c => c.status === 'pending').length
  const avgScore = db.scores.reduce((s, sc) => s + sc.totalScore, 0) / db.scores.length
  const avgCgpa = db.academicRecords.reduce((s, r) => s + r.cgpa, 0) / db.academicRecords.length
  res.json({ totalStudents: db.students.length, pendingApprovals: pendingCount, avgScore: avgScore.toFixed(2), avgCgpa: avgCgpa.toFixed(2) })
})

// ── Routes: File upload (proof) ───────────────────────────────────────────────

app.post('/api/upload/:type', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' })
  const url = `/uploads/${req.params.type}/${req.file.filename}`
  res.json({ url, filename: req.file.originalname, size: req.file.size })
})

// ── Routes: Excel roster import ───────────────────────────────────────────────

app.post('/api/upload/roster/excel', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' })
  try {
    const workbook = XLSX.readFile(req.file.path)
    const sheet = workbook.Sheets[workbook.SheetNames[0]]
    const rows = XLSX.utils.sheet_to_json(sheet)
    const db = readDB()
    const imported = []
    const errors = []
    rows.forEach((row, i) => {
      const rollNumber = String(row['roll_number'] || row['Roll Number'] || row['RollNumber'] || '').trim()
      const fullName = String(row['full_name'] || row['Full Name'] || row['Name'] || '').trim()
      const email = String(row['email'] || row['Email'] || '').trim()
      const year = Number(row['year'] || row['Year'] || 1)
      const classGroup = String(row['class_group'] || row['Class'] || row['ClassGroup'] || 'CSIT1').trim()
      if (!rollNumber || !fullName) { errors.push(`Row ${i + 2}: missing roll_number or full_name`); return }
      if (db.students.find(s => s.rollNumber === rollNumber) || db.pendingStudents.find(s => s.rollNumber === rollNumber)) {
        errors.push(`Row ${i + 2}: ${rollNumber} already exists`)
        return
      }
      const student = { id: `user-${uuidv4().slice(0, 8)}`, rollNumber, fullName, email: email || `${rollNumber}@mycsit.aitr.ac.in`, year, classGroup, status: 'pending', registeredAt: new Date().toISOString().split('T')[0] }
      db.pendingStudents.push(student)
      imported.push(student)
    })
    writeDB(db)
    res.json({ imported: imported.length, errors, students: imported })
  } catch (err) {
    res.status(500).json({ error: `Failed to parse Excel: ${err.message}` })
  }
})

// ── Routes: Excel marks import ────────────────────────────────────────────────

app.post('/api/upload/marks/excel', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' })
  try {
    const workbook = XLSX.readFile(req.file.path)
    const sheet = workbook.Sheets[workbook.SheetNames[0]]
    const rows = XLSX.utils.sheet_to_json(sheet)
    const db = readDB()
    let updated = 0
    const errors = []
    rows.forEach((row, i) => {
      const rollNumber = String(row['roll_number'] || row['Roll Number'] || '').trim()
      const semester = Number(row['semester'] || row['Semester'] || 0)
      const subjectName = String(row['subject_name'] || row['Subject'] || '').trim()
      const obtained = Number(row['obtained'] || row['Marks'] || 0)
      const total = Number(row['total'] || row['Total'] || 100)
      if (!rollNumber || !semester || !subjectName) { errors.push(`Row ${i + 2}: missing fields`); return }
      const student = db.students.find(s => s.rollNumber === rollNumber)
      if (!student) { errors.push(`Row ${i + 2}: student ${rollNumber} not found`); return }
      let record = db.academicRecords.find(r => r.userId === student.id && r.semester === semester)
      if (!record) {
        record = { id: `ar-${uuidv4().slice(0, 8)}`, userId: student.id, semester, cgpa: 0, totalClasses: 60, attended: 48, subjects: [] }
        db.academicRecords.push(record)
      }
      const existing = record.subjects.find(s => s.subjectName === subjectName)
      if (existing) { existing.marksObtained = obtained; existing.maxMarks = total }
      else record.subjects.push({ subjectName, marksObtained: obtained, maxMarks: total })
      updated++
    })
    writeDB(db)
    res.json({ updated, errors })
  } catch (err) {
    res.status(500).json({ error: `Failed to parse Excel: ${err.message}` })
  }
})

// ── Start ─────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`MyCSIT Backend running at http://localhost:${PORT}`)
  console.log(`API endpoints: http://localhost:${PORT}/api/students`)
})
