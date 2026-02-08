-- Account deletion cleanup for authenticated user data
-- Called only by server-side Edge Function using service role.

create or replace function public.delete_account_data(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Explicit deletes for tables that are not guaranteed to cascade.
  delete from public.practice_stats where user_id = p_user_id;
  delete from public.certificates where user_id = p_user_id;

  -- These currently cascade from auth.users, but we delete explicitly for safety.
  delete from public.lesson_progress where user_id = p_user_id;
  delete from public.unit_progress where user_id = p_user_id;
  delete from public.srs_cards where user_id = p_user_id;
  delete from public.profiles where id = p_user_id;
end;
$$;

revoke all on function public.delete_account_data(uuid) from public;
grant execute on function public.delete_account_data(uuid) to service_role;
