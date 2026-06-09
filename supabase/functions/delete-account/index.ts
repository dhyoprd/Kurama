import { createClient } from 'jsr:@supabase/supabase-js@2'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } })
}

Deno.serve(async (req: Request) => {
  try {
    const authHeader = req.headers.get('Authorization') ?? ''
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const authClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } })
    const { data: { user }, error: userErr } = await authClient.auth.getUser()
    if (userErr || !user) return json({ error: 'unauthorized' }, 401)

    // Service role deletes the auth user; profiles (and all child rows) cascade via FK.
    const admin = createClient(supabaseUrl, serviceKey)
    const { error } = await admin.auth.admin.deleteUser(user.id)
    if (error) return json({ error: error.message }, 500)
    return json({ ok: true })
  } catch (e) {
    return json({ error: String(e) }, 500)
  }
})
