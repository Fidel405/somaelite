import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { getLesson as getCachedLesson, getVideo, cacheVideo } from '../../lib/indexeddb'
import { supabase } from '../../lib/supabaseClient'

export default function LessonPage() {
  const router = useRouter()
  const { id } = router.query
  const [lesson, setLesson] = useState(null)
  const [videoUrl, setVideoUrl] = useState(null)

  useEffect(() => {
    if (!id) return
    ;(async () => {
      const cached = await getCachedLesson(id)
      if (cached) {
        setLesson(cached)
        const v = await getVideo(cached.video_r2_key || cached.video_url)
        if (v) { setVideoUrl(URL.createObjectURL(v)); return }
      }

      const { data, error } = await supabase.from('lessons').select('*').eq('id', id).single()
      if (error) {
        console.error(error)
        return
      }
      if (data) {
        setLesson(data)
        try {
          const resp = await fetch(data.video_url)
          const blob = await resp.blob()
          await cacheVideo(data.video_r2_key || data.video_url, blob)
          setVideoUrl(URL.createObjectURL(blob))
        } catch (e) {
          console.error(e)
          setVideoUrl(data.video_url)
        }
      }
    })()
  }, [id])

  if (!lesson) return <div className="p-4">Loading...</div>
  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold">{lesson.topic}</h1>
      <p className="text-sm text-gray-600">Difficulty: {lesson.difficulty}</p>
      {videoUrl ? <video controls src={videoUrl} className="w-full mt-4" /> : <p>Loading video...</p>}
    </div>
  )
}
