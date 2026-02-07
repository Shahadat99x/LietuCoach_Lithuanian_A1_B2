import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseAnonKey || !serviceRoleKey) {
    console.error("delete-account: Missing required environment variables.");
    return json(500, { ok: false, error: "Server configuration error." });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return json(401, { ok: false, error: "Unauthorized." });
  }

  try {
    const callerClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const {
      data: { user },
      error: userError,
    } = await callerClient.auth.getUser();

    if (userError || !user) {
      console.warn("delete-account: Invalid caller JWT", userError);
      return json(401, { ok: false, error: "Unauthorized." });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { error: cleanupError } = await adminClient.rpc("delete_account_data", {
      p_user_id: user.id,
    });

    if (cleanupError) {
      console.error("delete-account: cleanup RPC failed", cleanupError);
      return json(500, {
        ok: false,
        error: "Failed to delete account data. Please try again.",
      });
    }

    const { error: deleteAuthError } = await adminClient.auth.admin.deleteUser(user.id);

    if (deleteAuthError) {
      console.error("delete-account: auth admin delete failed", deleteAuthError);
      return json(500, {
        ok: false,
        error: "Failed to delete account. Please contact support.",
      });
    }

    return json(200, { ok: true });
  } catch (error) {
    console.error("delete-account: unhandled error", error);
    return json(500, {
      ok: false,
      error: "Unexpected server error. Please try again.",
    });
  }
});
