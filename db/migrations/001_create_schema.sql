-- Migration: create core schema for School OS MVP

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- schools
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  county TEXT,
  address TEXT,
  created_at timestamptz DEFAULT now()
);

-- users (teachers/admins/parents)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE,
  name TEXT,
  role TEXT CHECK (role IN ('teacher','admin','parent','student')) DEFAULT 'teacher',
  password_hash TEXT,
  phone TEXT,
  created_at timestamptz DEFAULT now()
);

-- students
CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  class_level TEXT, -- e.g., Grade 1 .. Grade 10, Form 2, etc.
  parent_phone TEXT,
  school_id UUID REFERENCES schools(id),
  created_at timestamptz DEFAULT now()
);

-- curricula (CBC, Cambridge, etc.)
CREATE TABLE curricula (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT NOT NULL, -- e.g., "CBC-8.4.4", "CAMBRIDGE-IGCSE"
  name TEXT NOT NULL,
  notes TEXT
);

-- subjects
CREATE TABLE subjects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  curriculum_id UUID REFERENCES curricula(id),
  code TEXT,
  name TEXT NOT NULL
);

-- curriculum_subjects: mapping for which subject applies to which grade/level
CREATE TABLE curriculum_subjects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
  class_level TEXT NOT NULL, -- e.g., "Grade 3", "Grade 10"
  extra JSONB
);

-- learning outcomes
CREATE TABLE learning_outcomes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
  class_level TEXT,
  outcome_text TEXT NOT NULL,
  code TEXT
);

-- lessons (videos + metadata)
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic TEXT NOT NULL,
  subject_id UUID REFERENCES subjects(id),
  curriculum_id UUID REFERENCES curricula(id),
  class_level TEXT,
  difficulty TEXT,
  video_url TEXT,
  video_r2_key TEXT,
  duration_seconds INT,
  compressed_bytes BIGINT,
  cached BOOLEAN DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- exams
CREATE TABLE exams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  curriculum_id UUID REFERENCES curricula(id),
  subject_id UUID REFERENCES subjects(id),
  title TEXT,
  term TEXT,
  date date,
  created_at timestamptz DEFAULT now()
);

-- marks
CREATE TABLE marks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  score NUMERIC,
  grader_id UUID REFERENCES users(id),
  graded_at timestamptz DEFAULT now()
);

-- payments
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES students(id),
  amount_cents INT NOT NULL,
  currency TEXT DEFAULT 'KES',
  provider TEXT,
  provider_ref TEXT,
  status TEXT,
  paid_at timestamptz
);

-- OCR jobs
CREATE TABLE ocr_jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  image_url TEXT,
  school_id UUID REFERENCES schools(id),
  status TEXT,
  result_json JSONB,
  created_at timestamptz DEFAULT now()
);

-- AI autograde results
CREATE TABLE autograde_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ocr_job_id UUID REFERENCES ocr_jobs(id) ON DELETE CASCADE,
  exam_id UUID REFERENCES exams(id),
  results_json JSONB,
  created_at timestamptz DEFAULT now()
);

-- lesson <> learning outcome link
CREATE TABLE lesson_outcomes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
  learning_outcome_id UUID REFERENCES learning_outcomes(id) ON DELETE CASCADE
);

-- indexes for common queries
CREATE INDEX idx_students_school ON students(school_id);
CREATE INDEX idx_lessons_curriculum ON lessons(curriculum_id);
CREATE INDEX idx_exams_curriculum ON exams(curriculum_id);
CREATE INDEX idx_marks_student ON marks(student_id);

-- sample curricula seeds (CBC and Cambridge)
INSERT INTO curricula (code, name, notes) VALUES
('CBC-8.4.4','Kenya CBC 8.4.4','Competency-Based Curriculum snapshot 8.4.4'),
('CAMBRIDGE-IGCSE','Cambridge IGCSE','Cambridge IGCSE curriculum');

-- end of migration
