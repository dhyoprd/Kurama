import { createClient } from 'jsr:@supabase/supabase-js@2'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req: Request) => {
  try {
    const authHeader = req.headers.get('Authorization') ?? ''
    const { prompt } = await req.json().catch(() => ({ prompt: undefined }))
    if (!prompt || typeof prompt !== 'string') return json({ error: 'missing prompt' }, 400)

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const replicateToken = Deno.env.get('REPLICATE_API_TOKEN')
    if (!replicateToken) return json({ error: 'REPLICATE_API_TOKEN not set' }, 500)
    const model = Deno.env.get('REPLICATE_MODEL') ?? 'black-forest-labs/flux-schnell'

    // Identify the caller from their JWT.
    const authClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })
    const { data: { user }, error: userErr } = await authClient.auth.getUser()
    if (userErr || !user) return json({ error: 'unauthorized' }, 401)

    // Generate the image via Replicate (create-by-model endpoint, wait for result).
    const predRes = await fetch(`https://api.replicate.com/v1/models/${model}/predictions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${replicateToken}`,
        'Content-Type': 'application/json',
        Prefer: 'wait',
      },
      body: JSON.stringify({ input: { prompt } }),
    })
    const pred = await predRes.json()
    if (!predRes.ok) return json({ error: 'replicate error', detail: pred }, 502)
    const out = pred.output
    const imageUrl = Array.isArray(out) ? out[0] : out
    if (!imageUrl || typeof imageUrl !== 'string') return json({ error: 'no image in output', detail: pred }, 502)

    // Download the generated image.
    const imgRes = await fetch(imageUrl)
    if (!imgRes.ok) return json({ error: 'failed to download image' }, 502)
    const bytes = new Uint8Array(await imgRes.arrayBuffer())

    // Upload to the public avatars bucket and persist on the profile (service role).
    const admin = createClient(supabaseUrl, serviceKey)
    const path = `${user.id}.png`
    const up = await admin.storage.from('avatars').upload(path, bytes, {
      contentType: 'image/png',
      upsert: true,
    })
    if (up.error) return json({ error: 'upload failed', detail: up.error.message }, 500)

    const { data: pub } = admin.storage.from('avatars').getPublicUrl(path)
    const avatarUrl = pub.publicUrl

    const { error: updErr } = await admin.from('profiles').update({ avatar_url: avatarUrl }).eq('id', user.id)
    if (updErr) return json({ error: 'profile update failed', detail: updErr.message }, 500)

    return json({ avatarUrl })
  } catch (e) {
    return json({ error: String(e) }, 500)
  }
})
