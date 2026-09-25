# Reportes de Servicio VRU — BLAU CYT

App web para cargar reportes de servicio de VRU. Cada servicio incluye el reporte, el ATS y el parte de servicio de mantenimiento con fotos. Los datos se comparten entre todos los equipos a través de Supabase, y la app sigue funcionando sin señal: guarda en el equipo y envía a la nube cuando vuelve la conexión.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `index.html` | La aplicación completa |
| `config.js` | URL y clave pública de Supabase (se completa una sola vez) |
| `schema.sql` | Crea la tabla, las reglas de seguridad y el espacio para fotos |
| `sw.js`, `manifest.json`, `icon-192.png`, `icon-512.png` | Permiten instalarla en el celular y abrirla sin señal |
| `vercel.json` | Evita que Vercel guarde en caché versiones viejas de `sw.js` y `config.js` |

## 1. Supabase

1. Crear un proyecto nuevo en <https://supabase.com> (conviene uno separado del de TECPE). Región sugerida: **South America (São Paulo)**.
2. **SQL Editor → New query**: pegar todo `schema.sql` y tocar **Run**. Tiene que terminar en "Success".
3. **Authentication → Sign In / Providers**: desactivar **Allow new users to sign up**, así solo entra quien vos des de alta.
4. **Authentication → Users → Add user → Create new user**: cargar correo y contraseña de cada técnico, con **Auto Confirm User** marcado.
5. **Project Settings → API** (o **API Keys**): copiar la **Project URL** y la clave **anon public** (o **publishable**).

## 2. Completar `config.js`

```js
window.BLAU_CONFIG = {
  supabaseUrl: 'https://xxxxxxxx.supabase.co',
  supabaseAnonKey: 'eyJ... o sb_publishable_...',
  bucket: 'fotos-servicios'
};
```

La clave pública puede quedar en el repositorio: sin usuario y contraseña no se puede leer ni escribir nada, porque la base tiene reglas de seguridad (RLS).

**Nunca** pegues en este archivo la clave `service_role` ni la `secret`.

## 3. GitHub

1. Crear un repositorio nuevo (por ejemplo `blau-servicios-vru`).
2. **Add file → Upload files**: arrastrar **todo el contenido** de esta carpeta. `index.html` tiene que quedar en la raíz del repositorio, no dentro de otra carpeta.
3. **Commit changes**.

## 4. Vercel

1. **Add New → Project** → importar el repositorio.
2. **Framework Preset: Other**, **Root Directory: `./`**, sin comando de build.
3. **Deploy**. Cada cambio que subas a GitHub se publica solo.

## 5. Pasar los datos de la versión anterior

1. En el HTML anterior: solapa **Historial → Respaldo completo**.
2. En la app nueva, con sesión iniciada: **Historial → Restaurar respaldo** con ese archivo. Los reportes se suben a la nube.

## Uso en campo

- El primer ingreso en cada equipo necesita señal. Después la sesión queda abierta.
- Sin señal se puede cargar, guardar y finalizar normalmente. El indicador muestra "Sin conexión · N pendientes", y los pendientes se envían solos al recuperar señal. También se puede tocar el indicador para forzar el envío.
- Instalar en el celular: abrir la dirección de Vercel en Chrome → menú ⋮ → **Agregar a la pantalla principal**.
- Si dos personas editan el mismo reporte, queda la última versión guardada.
