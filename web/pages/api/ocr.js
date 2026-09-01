export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' })

  // This is a lightweight stub. To enable server-side OCR enqueueing:
  // 1) Create a Supabase service role key and set it as SUPABASE_SERVICE_ROLE_KEY in your deployment.
  // 2) Use Supabase Admin REST or a direct DB connection to insert into ocr_jobs and return job id.

  // Accepts: { image_url: string, school_id: uuid, exam_id: uuid }
  const { image_url, school_id, exam_id } = req.body || {}
  if (!image_url) return res.status(400).json({ error: 'image_url required' })

  // Return accepted and instructions to run autograde worker separately.
  return res.status(202).json({ status: 'accepted', message: 'OCR job accepted. Configure a worker or function to pull from ocr_jobs and run OCR/auto-marking.' })
}
