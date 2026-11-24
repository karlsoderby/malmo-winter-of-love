# Malmö Winter of Love

A shared, psychedelic-Christmas map of Malmö's bars, sights and weird spots. Visitors pick a name, drop pins, suggest activities and vote for where to go. Hosted on GitHub Pages and backed by Supabase.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app (Leaflet map plus Supabase client) |
| `malmo.json` | Base map drawn from OpenStreetMap data: sea, parks, canals, streets |
| `config.js` | Your Supabase project URL and anon key |
| `supabase/schema.sql` | Tables, access rules, realtime |
| `supabase/seed.sql` | The places and activities from the original map |

## Set up Supabase (one time)

1. Create a project at supabase.com (the free plan is enough).
2. **Authentication → Sign In / Providers → Allow anonymous sign-ins**: turn it on. Visitors get an invisible anonymous account, which is what lets each person vote once and remove only their own pins.
3. **SQL Editor**: paste and run `supabase/schema.sql`, then `supabase/seed.sql`.
4. **Project Settings → API**: copy the Project URL and the `anon` public key into `config.js`.

## Who can do what

- Anyone with the link can see everything.
- Anyone can add pins and activities, and vote (one vote per person per item; tap again to take it back).
- People can remove only the pins and activities they added themselves.
- To remove anything else, including the seeded places, delete the row in Supabase's Table Editor.

Anonymous accounts are tied to the browser. Someone who clears their browser data or switches device becomes a new visitor and can vote again.

## Run it locally

```sh
python3 -m http.server 8000
```

Then open http://localhost:8000. Opening the file directly won't work, because the page fetches `malmo.json`.
