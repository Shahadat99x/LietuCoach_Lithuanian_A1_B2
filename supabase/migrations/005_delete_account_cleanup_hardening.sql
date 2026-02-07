-- Harden account deletion cleanup with step-aware transactional result payload.
-- This function is called by the delete-account Edge Function using service role.

create or replace function public.delete_account_data(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  _step text := 'validate_user';
begin
  if p_user_id is null then
    return jsonb_build_object(
      'ok', false,
      'step', _step,
      'message', 'Missing user id.'
    );
  end if;

  begin
    -- Explicit deletes for tables that are not guaranteed to cascade.
    _step := 'practice_stats';
    delete from public.practice_stats where user_id = p_user_id;

    _step := 'certificates';
    delete from public.certificates where user_id = p_user_id;

    -- Delete remaining user-owned rows.
    _step := 'lesson_progress';
    delete from public.lesson_progress where user_id = p_user_id;

    _step := 'unit_progress';
    delete from public.unit_progress where user_id = p_user_id;

    _step := 'srs_cards';
    delete from public.srs_cards where user_id = p_user_id;

    _step := 'profiles';
    delete from public.profiles where id = p_user_id;
  exception
    when others then
      -- Plpgsql exception blocks run in a subtransaction, so partial deletes
      -- inside this block are rolled back before returning.
      return jsonb_build_object(
        'ok', false,
        'step', _step,
        'message', 'Database cleanup failed.',
        'detail', sqlerrm
      );
  end;

  return jsonb_build_object('ok', true);
end;
$$;

revoke all on function public.delete_account_data(uuid) from public;
grant execute on function public.delete_account_data(uuid) to service_role;
