import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, x-request-id",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (
  status: number,
  body: Record<string, unknown>,
  requestId: string,
) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
      "X-Request-Id": requestId,
    },
  });

const asRecord = (value: unknown): Record<string, unknown> | null => {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
};

Deno.serve(async (req) => {
  const requestId = req.headers.get("x-request-id") ?? crypto.randomUUID();

  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        ...corsHeaders,
        "X-Request-Id": requestId,
      },
    });
  }

  if (req.method !== "POST") {
    return json(
      405,
      {
        ok: false,
        step: "request",
        message: "Method not allowed.",
        requestId,
      },
      requestId,
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error(`[delete-account][${requestId}][env] Missing required environment variables.`);
    return json(
      500,
      {
        ok: false,
        step: "env",
        message: "Missing SUPABASE_SERVICE_ROLE_KEY.",
        requestId,
      },
      requestId,
    );
  }

  const authHeader = req.headers.get("Authorization") ??
    req.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return json(
      401,
      {
        ok: false,
        step: "auth",
        message: "Not authenticated.",
        requestId,
      },
      requestId,
    );
  }

  try {
    const accessToken = authHeader.substring("Bearer ".length).trim();
    if (!accessToken) {
      return json(
        401,
        {
          ok: false,
          step: "auth",
          message: "Not authenticated.",
          requestId,
        },
        requestId,
      );
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const {
      data: { user },
      error: userError,
    } = await adminClient.auth.getUser(accessToken);

    if (userError || !user) {
      console.warn(
        `[delete-account][${requestId}][auth] Invalid caller JWT`,
        userError,
      );
      return json(
        401,
        {
          ok: false,
          step: "auth",
          message: "Not authenticated.",
          requestId,
        },
        requestId,
      );
    }

    console.log(`[delete-account][${requestId}][start] uid=${user.id}`);

    const { data: cleanupData, error: cleanupError } = await adminClient.rpc(
      "delete_account_data",
      { p_user_id: user.id },
    );

    if (cleanupError) {
      console.error(
        `[delete-account][${requestId}][delete_user_data] cleanup RPC failed`,
        cleanupError,
      );
      return json(
        500,
        {
          ok: false,
          step: "delete_user_data",
          message: "Failed to delete account data.",
          requestId,
        },
        requestId,
      );
    }

    const cleanupResult = asRecord(cleanupData);
    if (cleanupResult && cleanupResult.ok !== true) {
      const step = typeof cleanupResult.step === "string"
        ? cleanupResult.step
        : "delete_user_data";
      const message = typeof cleanupResult.message === "string"
        ? cleanupResult.message
        : "Failed to delete account data.";

      console.error(
        `[delete-account][${requestId}][${step}] cleanup returned failure`,
        cleanupResult,
      );
      return json(500, { ok: false, step, message, requestId }, requestId);
    }

    console.log(`[delete-account][${requestId}][delete_user_data] completed`);

    const { error: deleteAuthError } = await adminClient.auth.admin.deleteUser(
      user.id,
    );

    if (deleteAuthError) {
      console.error(
        `[delete-account][${requestId}][delete_auth_user] auth admin delete failed`,
        deleteAuthError,
      );
      return json(
        500,
        {
          ok: false,
          step: "delete_auth_user",
          message: "Failed to delete auth user.",
          requestId,
        },
        requestId,
      );
    }

    console.log(`[delete-account][${requestId}][success] uid=${user.id}`);
    return json(200, { ok: true, requestId }, requestId);
  } catch (error) {
    console.error(`[delete-account][${requestId}][unhandled]`, error);
    return json(
      500,
      {
        ok: false,
        step: "unhandled",
        message: "Unexpected server error. Please try again.",
        requestId,
      },
      requestId,
    );
  }
});
