-- Crystal Estates Hub — shared database setup
-- Paste this whole file into Supabase: SQL Editor -> New query -> Run

create table if not exists ce_units (
  id text primary key,
  property text not null,
  unit_no text not null,
  type text default 'Room',
  tenant text default '',
  phone text default '',
  monthly_rent text default '',
  due_day int default 1,
  status text default 'Occupied',
  notes text default '',
  start_date text default '',
  updated_at timestamptz default now()
);

alter table ce_units add column if not exists start_date text default '';

create table if not exists ce_rent_payments (
  id text primary key,
  unit_id text default '',
  property text default '',
  month_for text default '',
  paid_date text default '',
  amount text default '',
  method text default '',
  notes text default '',
  updated_at timestamptz default now()
);

create table if not exists ce_carwash (
  id text primary key,
  date text default '',
  wash_type text default 'Manual',
  amount text default '',
  notes text default '',
  updated_at timestamptz default now()
);

create table if not exists ce_expenses (
  id text primary key,
  date text default '',
  property text default 'General',
  category text default 'Other',
  description text default '',
  amount text default '',
  method text default '',
  notes text default '',
  recurring_id text default '',
  updated_at timestamptz default now()
);

create table if not exists ce_recurring (
  id text primary key,
  name text not null,
  property text default 'General',
  category text default 'Other',
  amount text default '',
  due_day int default 1,
  active boolean default true,
  notes text default '',
  updated_at timestamptz default now()
);

alter table ce_expenses add column if not exists recurring_id text default '';

-- Rent invoices: file metadata (the files themselves live in the private 'invoices' Storage bucket)
create table if not exists ce_invoices (
  id text primary key,
  unit_id text default '',
  month_for text default '',
  file_path text default '',
  file_name text default '',
  notes text default '',
  updated_at timestamptz default now()
);

insert into storage.buckets (id, name, public) values ('invoices','invoices', false)
  on conflict (id) do nothing;

-- Security: only signed-in team members can read or write
alter table ce_units enable row level security;
alter table ce_rent_payments enable row level security;
alter table ce_carwash enable row level security;
alter table ce_expenses enable row level security;
alter table ce_recurring enable row level security;
alter table ce_invoices enable row level security;

drop policy if exists "team can do everything" on ce_units;
drop policy if exists "team can do everything" on ce_rent_payments;
drop policy if exists "team can do everything" on ce_carwash;
drop policy if exists "team can do everything" on ce_expenses;
drop policy if exists "team can do everything" on ce_recurring;
drop policy if exists "team can do everything" on ce_invoices;

create policy "team can do everything" on ce_units for all to authenticated using (true) with check (true);
create policy "team can do everything" on ce_rent_payments for all to authenticated using (true) with check (true);
create policy "team can do everything" on ce_carwash for all to authenticated using (true) with check (true);
create policy "team can do everything" on ce_expenses for all to authenticated using (true) with check (true);
create policy "team can do everything" on ce_recurring for all to authenticated using (true) with check (true);
create policy "team can do everything" on ce_invoices for all to authenticated using (true) with check (true);

-- Storage access for the invoices bucket: signed-in team members only
drop policy if exists "team invoices read" on storage.objects;
drop policy if exists "team invoices write" on storage.objects;
drop policy if exists "team invoices update" on storage.objects;
drop policy if exists "team invoices delete" on storage.objects;
create policy "team invoices read" on storage.objects for select to authenticated using (bucket_id = 'invoices');
create policy "team invoices write" on storage.objects for insert to authenticated with check (bucket_id = 'invoices');
create policy "team invoices update" on storage.objects for update to authenticated using (bucket_id = 'invoices') with check (bucket_id = 'invoices');
create policy "team invoices delete" on storage.objects for delete to authenticated using (bucket_id = 'invoices');

-- Live sync: broadcast changes to all connected devices
do $$
begin
  begin
    alter publication supabase_realtime add table ce_units;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table ce_rent_payments;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table ce_carwash;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table ce_expenses;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table ce_recurring;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table ce_invoices;
  exception when duplicate_object then null;
  end;
end $$;
