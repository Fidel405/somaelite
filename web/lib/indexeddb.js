import { openDB } from 'idb'

const DB_NAME = 'schoolos'
const DB_VERSION = 1
const LESSON_STORE = 'lessons'
const VIDEO_STORE = 'videos'

export async function getDB() {
  return openDB(DB_NAME, DB_VERSION, {
    upgrade(db) {
      if (!db.objectStoreNames.contains(LESSON_STORE)) db.createObjectStore(LESSON_STORE, { keyPath: 'id' })
      if (!db.objectStoreNames.contains(VIDEO_STORE)) db.createObjectStore(VIDEO_STORE)
    }
  })
}

export async function cacheLesson(lesson) {
  const db = await getDB(); await db.put(LESSON_STORE, lesson)
}
export async function getLesson(id) { const db = await getDB(); return db.get(LESSON_STORE, id) }
export async function cacheVideo(key, blob) { const db = await getDB(); await db.put(VIDEO_STORE, blob, key) }
export async function getVideo(key) { const db = await getDB(); return db.get(VIDEO_STORE, key) }
