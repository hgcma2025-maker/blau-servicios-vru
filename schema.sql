-- ════════════════════════════════════════════════════════════════
--  BLAU CYT · Reportes de Servicio VRU
--  Ejecutar completo en Supabase → SQL Editor → New query → Run
-- ════════════════════════════════════════════════════════════════

-- 1) Tabla de servicios (reporte + ATS + parte de mantenimiento)
create table if not exists public.servicios (
  id              text primary key,
  estado          text not null check (estado in ('borrador', 'finalizado')),
  creado          timestamptz not null default now(),
  modificado      timestamptz not null default now(),
  finalizado      timestamptz,
  -- columnas de consulta rápida (copiadas del reporte)
  fecha           date,
  tipo            text,
  empresa         text,
  yacimiento      text,
  equipo          text,
  tecnico         text,
  parte_numero    text,
  creado_por      text,
  modificado_por  text,
  -- contenido completo
  reporte         jsonb not null default '{}'::jsonb,
  ats             jsonb not null default '{}'::jsonb,
  parte           jsonb not null default '{}'::jsonb
);

create index if not exists servicios_fecha_idx   on public.servicios (fecha desc);
create index if not exists servicios_estado_idx  on public.servicios (estado);
create index if not exists servicios_empresa_idx on public.servicios (empresa);

-- 2) Seguridad: solo usuarios con sesión iniciada
alter table public.servicios enable row level security;

drop policy if exists "servicios_leer"      on public.servicios;
drop policy if exists "servicios_crear"     on public.servicios;
drop policy if exists "servicios_modificar" on public.servicios;
drop policy if exists "servicios_eliminar"  on public.servicios;

create policy "servicios_leer"      on public.servicios for select to authenticated using (true);
create policy "servicios_crear"     on public.servicios for insert to authenticated with check (true);
create policy "servicios_modificar" on public.servicios for update to authenticated using (true) with check (true);
create policy "servicios_eliminar"  on public.servicios for delete to authenticated using (true);

-- 3) Fotos del Anexo 1 (bucket privado)
insert into storage.buckets (id, name, public)
values ('fotos-servicios', 'fotos-servicios', false)
on conflict (id) do nothing;

drop policy if exists "fotos_leer"      on storage.objects;
drop policy if exists "fotos_subir"     on storage.objects;
drop policy if exists "fotos_modificar" on storage.objects;
drop policy if exists "fotos_eliminar"  on storage.objects;

create policy "fotos_leer"      on storage.objects for select to authenticated using (bucket_id = 'fotos-servicios');
create policy "fotos_subir"     on storage.objects for insert to authenticated with check (bucket_id = 'fotos-servicios');
create policy "fotos_modificar" on storage.objects for update to authenticated using (bucket_id = 'fotos-servicios');
create policy "fotos_eliminar"  on storage.objects for delete to authenticated using (bucket_id = 'fotos-servicios');
