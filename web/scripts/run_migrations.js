const fs = require('fs')
const path = require('path')
const { Client } = require('pg')

async function run() {
  const sqlPath = path.resolve(__dirname, '..', '..', 'db', 'migrations', '001_create_schema.sql')
  const sql = fs.readFileSync(sqlPath, 'utf8')
  const dbUrl = process.env.DATABASE_URL
  if (!dbUrl) {
    console.error('Set DATABASE_URL environment variable to your Supabase/Postgres connection string.')
    process.exit(1)
  }
  const client = new Client({ connectionString: dbUrl, ssl: { rejectUnauthorized: false } })
  await client.connect()
  console.log('Applying migration...')
  try {
    await client.query(sql)
    console.log('Migration applied successfully')
  } catch (err) {
    console.error('Migration failed:', err)
    process.exit(1)
  } finally {
    await client.end()
  }
}

run().catch(e => { console.error(e); process.exit(1) })
