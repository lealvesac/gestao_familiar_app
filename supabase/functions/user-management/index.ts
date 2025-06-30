// ARQUIVO: supabase/functions/user-management/index.ts

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  // Lida com a requisição preflight do CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Pega o corpo da requisição
    const { targetUserId, houseId, action } = await req.json();

    // Cria um cliente Supabase com privilégios de administrador
    const supabaseAdmin = createClient(
      Deno.env.get("https://ddiztapmnmwdaisqgsvw.supabase.co") ?? "",
      Deno.env.get(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkaXp0YXBtbm13ZGFpc3Fnc3Z3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NjczOTYsImV4cCI6MjA2NTE0MzM5Nn0.gHoSY7h0c-Olct3p3bswHOIzM8ri1weELDdrQxF3yC8"
      ) ?? ""
    );

    // Pega o ID do usuário que está fazendo a chamada
    const authHeader = req.headers.get("Authorization")!;
    const {
      data: { user },
    } = await supabaseAdmin.auth.getUser(authHeader.replace("Bearer ", ""));

    if (!user) {
      throw new Error("Usuário não autenticado.");
    }

    // --- VERIFICAÇÃO DE PERMISSÕES ---
    const { data: callerMembership, error: callerError } = await supabaseAdmin
      .from("house_members")
      .select("role, houses(owner_id)")
      .eq("profile_id", user.id)
      .eq("house_id", houseId)
      .single();

    if (callerError || !callerMembership) {
      throw new Error("Você não é membro desta casa.");
    }

    if (callerMembership.role !== "administrador") {
      throw new Error("Apenas administradores podem executar esta ação.");
    }

    // Um admin não pode modificar o dono da casa (super admin)
    // ATENÇÃO: O erro estava aqui. 'houses' é um objeto. Acesso correto é callerMembership.houses.owner_id
    if (targetUserId === callerMembership.houses.owner_id) {
      throw new Error("Você não pode modificar o dono da casa.");
    }

    // --- EXECUÇÃO DAS AÇÕES ---
    if (action === "reset-password") {
      const { data: targetUser, error: getUserError } =
        await supabaseAdmin.auth.admin.getUserById(targetUserId);
      if (getUserError) throw getUserError;

      const { data, error } = await supabaseAdmin.auth.admin.generateLink({
        type: "recovery",
        email: targetUser.user.email,
      });
      if (error) throw error;
      // A API do Supabase envia o e-mail automaticamente
      return new Response(
        JSON.stringify({
          message: "Link de recuperação de senha enviado para o usuário.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    // if (action === 'deactivate-user') {
    //   // TODO: Implementar a lógica de desativação
    // }

    return new Response(JSON.stringify({ message: "Ação não reconhecida." }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
