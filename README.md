# Мой заработок

Личное приложение учёта доходов, расходов и семейного бюджета.

- `site/` — само приложение (GitHub Pages: https://grach31.github.io/earnings-app/)
- `supabase/setup.sql` — таблицы и правила доступа; `supabase/functions/scan-receipt` — распознавание чеков (ключ Anthropic хранится в секретах Supabase)
- Данные лежат в Supabase, вход по e-mail и паролю. Личные данные (`seed.sql`) в репозиторий не кладём.
