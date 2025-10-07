import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import serviceAccount from '../service_account.json' assert { type: 'json' };
interface Message {
  message: string;
  username: string;
  toUser: string;
  
}

interface WebhookPayload {
  type: "insert";
  table: string;
  record: Message;
  old_record: null | Message;
}

const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json();
  const { data } = await supabase
    .from("profiles")
    .select("token")
    .eq("user_id", payload.record.toUser)
    .single();

  // const { default: serviceAccount } = await import("../service_account.json", {
  //   with: { type: "json" },
  // });

  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  });

  const fcm_token = data.token as string;

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: fcm_token,
          notification: {
            title: "New message",
            body: `${payload.record.username}\nMessage: ${payload.record.message}`,
          },
        },
      }),
    }
  );

  const resData = await res.json();
  if (res.status < 200 || res.status > 299) {
    throw resData;
  }

  return new Response(JSON.stringify(resData), {
    headers: { "Content-Type": "application/json" },
  });
});

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string;
  privateKey: string;
}): Promise<string> =>
  new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });
    jwtClient.authorize((err, token) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(token?.access_token!);
    });
  });