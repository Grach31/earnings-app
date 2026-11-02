-- Выполнить один раз в Supabase: SQL Editor -> New query -> вставить всё -> Run.
-- Версия 3.0. Ирина (гость) видит и меняет только расходы и банк. Доходы, приёмы и остальное база от неё закрывает.
--   читать:  владелец — всё; гость — расходы (expenses), банк (savings) и настройки (app)
--   писать:  владелец — везде; гость — только расходы и банк (добавлять, менять, удалять любые)
-- Таблицу members гость изменить не может.

create or replace function public.member_role() returns text
language sql stable security definer set search_path = public as $$
  select role from public.members where email = lower(auth.jwt() ->> 'email');
$$;

-- функция атомарного обновления записи (если её ещё нет)
create or replace function public.docs_merge(p_collection text, p_id text, p_patch jsonb)
returns void language sql security invoker set search_path = public as $$
  insert into public.docs (collection, id, data, updated_at)
  values (p_collection, p_id, p_patch, now())
  on conflict (collection, id) do update
    set data = public.docs.data || excluded.data, updated_at = now();
$$;
grant execute on function public.docs_merge(text, text, jsonb) to authenticated;

drop policy if exists "members read docs"   on public.docs;
drop policy if exists "members insert docs" on public.docs;
drop policy if exists "members update docs" on public.docs;
drop policy if exists "members delete docs" on public.docs;
drop policy if exists "role read docs"   on public.docs;
drop policy if exists "role insert docs" on public.docs;
drop policy if exists "role update docs" on public.docs;
drop policy if exists "role delete docs" on public.docs;

create policy "role read docs" on public.docs for select to authenticated
  using (public.member_role() = 'owner' or (public.member_role() = 'guest' and collection in ('expenses', 'savings', 'app')));
create policy "role insert docs" on public.docs for insert to authenticated
  with check (public.member_role() = 'owner' or (public.member_role() = 'guest' and collection in ('expenses', 'savings')));
create policy "role update docs" on public.docs for update to authenticated
  using      (public.member_role() = 'owner' or (public.member_role() = 'guest' and collection in ('expenses', 'savings')))
  with check (public.member_role() = 'owner' or (public.member_role() = 'guest' and collection in ('expenses', 'savings')));
create policy "role delete docs" on public.docs for delete to authenticated
  using (public.member_role() = 'owner' or (public.member_role() = 'guest' and collection in ('expenses', 'savings')));
