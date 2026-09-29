# ODD — mindplay-mockup-ui

## Objective
Implementar la UI fiel al mockup de 8 pantallas sobre la lógica actual (SceneRouter, GameSession, QuestionManager).

## Problem
La lógica funciona pero la UI es default sin estilo: no hay vidas, progreso x/10, cards de categorías, feedback verde/rojo, rango, toggles de opciones ni pantalla de instrucciones.

## Why
El usuario autorizó ("Sí, implementar UI") replicar el mockup manteniendo la lógica actual.

## Scope (autorizado 2026-09-28, rev2: flujo con QuizSetup + banco PDF)
- Flujo: MainMenu → CategorySelection → QuizSetup → Quiz → Results. (Options/Instrucciones del mockup quedan fuera de este flujo.)
- Partida v1 = exactamente las preguntas de la combinación category+audience+difficulty (3 según PDF). NO mezclar niveles/públicos, NO expandir a 10, NO inventar preguntas.
- Schema por pregunta: id, category, audience, difficulty, question, answers[4], correct_index, feedback_correct, feedback_incorrect. Fuente única: MINDPLAY_Preguntas.pdf (72). questions.json se reescribe entero (aún NO tocar).
- Cambios: QuestionBank (schema+filtrado), GameSession (staging+start triple), SceneRouter (+1 ruta), QuizSetup nuevo (tscn+gd), CategorySelection (staging+4 cards), Quiz (feedback dual), Results (info combo+incorrectas).
- T1 MainMenu ya hecho. Vidas/rango/puntos mockup siguen pendientes y separados.

## Constraints
- Godot 4.7.2, GL Compatibility, Control root + anchors/containers, sin offsets fijos en hijos de containers.
- Foco visible + Tab/direccional + Enter/Escape en cada pantalla; restaurar foco al volver.
- Contraste legible sobre fondo oscuro #12132E aprox.; no usar solo color como señal.
- Delegación por Task no disponible en este runtime (free tier): se implementa inline por tareas, una pantalla por vez.
- Repo git raíz es C:\Users\luis2 (home, sin commits): NO hacer commits ni branches; evidencia vía archivos + screenshots + Engram.
- NO inventar preguntas ni modificar questions.json hasta autorizar la transcripción.
- total_questions siempre derivado del banco, nunca hardcodeado (v1 da 3 por combinación).

## TDD / Checks
- TDD: off (sin runner ni tests en repo). Fuente: inspección 2026-09-28.
- Checks por tarea: `get_parse_errors` del .gd tocado + `get_scene_tree` + `get_viewport_screenshot` tras cambio visual. Cierre: headless run si runtime disponible.

## Tasks (rev2: banco PDF + QuizSetup; T2–T7 originales invalidados por cambio de categorías/schema)
- [x] T1 — MainMenu fiel (hecho, ver Progress)
- [x] T2 — QuestionBank: schema nuevo + get_questions_filtered + validación de valores — evidencia: --check-only limpio; smoke funcional x2 (acumulación, completitud 23/24, probe 0, filtro vacío 0). Rerun de inmutabilidad colgado (transitorio); inmutabilidad verificada por readback (duplicate(true) + shuffle sobre copias).
- [x] T3 — questions.json: transcripción 72 desde PDF + QA — evidencia: QA_VALID:true sin errores; TOTAL 72; 24 combos x3; ids únicos; DIST 18/18/18/18; spots 12/12 (py) + 6/6 (GDScript); POOL_DJF:3. Headless intermitente (2 editores abiertos suspected), reintento OK.
- [x] T3.5 — revisión editorial del banco (ritmo quiz rápido) — evidencia: 68/72 reformuladas, 207 opciones, 0 feedbacks; brecha máx/media 75/33.2 → 17/9.4; índices idénticos 72/72; QA engine todo verde.
- [x] T4 — GameSession: staging de categoría + start_new_game triple + results con combo e incorrectas — evidencia: check-only limpio; funcional DJF (pool 3, total 3, 100pts/streak1, wrong 0/streak0, staging sin arranque, empty-pool rechazado sin crash); boot 120 frames sin errores.
- [x] T5 — SceneRouter (+ruta quiz_setup) + CategorySelection (staging + 4 cards Diseño/Tecnología/Videojuegos/Cultura Digital) + QuizSetup.tscn/gd nuevo — evidencia: E2E headless 21/21 (staging sin arranque, defaults Jóvenes/Fácil, cambio a Adultos/Difícil, start→pool 3→Quiz, backs OK); error category_selection.gd:43 eliminado; scaffolding t5_e2e.* removido.
- [x] T6 — Quiz: feedback_correct/feedback_incorrect + label de combo en HUD — evidencia: E2E headless 23/23 (Q1 correcta 100pts/racha1 + feedback + Continuar, doble-respuesta bloqueada, Q2 incorrecta 0pts/racha0 + correcta marcada ✔, Q3→Results, foco inicial OK); boot sin errores; scaffolding t6_e2e.* removido.
- [x] T7 — Results: muestra combo + correctas/incorrectas + botones — evidencia: E2E 10/10 (partida DJF 200pts 2/3+1/3, foco, Jugar→Category, 2da partida→Menú); scaffolding t7_e2e.* removido.
- [x] T8 — Verificación integral (parse, headless, flujo ejemplo Diseño+Jóvenes+Fácil, screenshots, foco)
- [x] T9 (cierre) — A1/A2 anillos de foco + V1 flow con breakpoint + V2 Results con scroll — evidencia: E2E 31/31 en 1280x720 y 800x600 (límites, anillos, filas, toggles, flujo); scaffolding removido.
- [x] T9 — Settings autoload (prefs+persistencia) + música procedural + click SFX — evidencia: check-only limpio; boot headless 120 frames sin SCRIPT ERROR (Settings genera loop 16s, conecta scene_changed, GameSession carga banco 72).
- [x] T10 — Options visual mockup + cableado funcional + fila Cómo jugar — evidencia: LOAD_OK + 5/5 unique names.
- [x] T11 — Instructions (4 pasos, Comenzar) + ruta instructions — evidencia: LOAD_OK + 2/2 unique names.
- Visual mockup fino (cards con color, grilla 2x2, feedback verde/rojo, toggles, Instructions) sigue pendiente tras T8, a propósito: primero estructura, después pintura, para no estilar dos veces.

## Acceptance
- Las 8 pantallas se ven como el mockup (layout, colores, textos ES) a 1280x720 y no rompen a 800x600.
- Flujo MainMenu → Category → Quiz → Feedback → Results funciona; Opciones e Instrucciones navegan y vuelven.
- Foco inicial + Tab + Enter/Esc en cada pantalla; sin errores de parse ni en headless.

## Progress
- 2026-09-28: creado doc + mirror. Mapa: 5 tscn básicos confirmados, brechas de vidas/rango/categorías/ruta instructions. Delegación Task falló (free tier) → inline. Git no seguro → sin commits.
- Next: T10 completo. No iniciar T11, ni documento final, ni screencast sin tu aprobación.
- T10 2026-09-28: export_presets.cfg (Windows Desktop) + build/windows/MINDPLAY.exe (104MB + pck 0.3MB, Godot 4.7.2). Auto-test temporal en build de prueba: E2E 0 fails en headless ×2 tamaños y оконный con EXIT:0 vía Salir; scaffolding eliminado y build final limpio con boot sin errores. Audio audible: no verificable en este entorno (driver dummy).
- Nota: "T9/T10/T11" listados arriba fueron side-track post-T3 (Settings/Options/Instructions); "T9 (cierre)" es la tarea oficial de a11y/responsive.
- T9 (cierre) 2026-09-28: anillos de foco (docs Godot confirman overlay), V1 HFlowContainer+breakpoint, V2 Results con scroll. Hallazgo honesto: con canvas_items/expand el canvas siempre ≥ base, así que a 800x600 todo escala sin recorte (verificado) y el 2x2 es red de seguridad.
- T7 2026-09-28: scenes/quiz/Results.tscn (score héroe + X/3 + combo + 2 botones) + results.gd (solo get_results(), sin persistencia). Headless volvió a trabarse pre-banner 2 veces (contienda editor) y salió a la 3ra tras pausas+limpieza.
- Post-T8 (pedido usuario): Instructions.tscn rediseñado (hoja blanca con sombra, badges lila 1-4, Comenzar héroe, ¡Tú puedes!) sin tocar script; verificado LOAD_OK + badges 4/4 + foco.
- Bugfix cards (reporte usuario: "Cultura Digital" ilegible en hover): category_selection.gd ahora fija font_* en los 5 estados; verificado runtime 4/4 dark navy.
- Bugfix respuestas Quiz (mismo síntoma en hover): Quiz.tscn fija font_*×5 en los 4 botones; verificado runtime 4/4 dark navy.
- Hover visible global (pedido usuario): Quiz/QuizSetup/Options/Results/Instructions con hover+focus distintos del normal (MainMenu y cards ya tenían); verificado runtime 32/32 (16 botones × hover/focus). De paso corrige A1/A2 de la auditoría.
- T6 2026-09-28: scenes/quiz/Quiz.tscn (tema oscuro + tarjeta dominante + HUD combo/progreso/score/racha) + quiz.gd (feedback dual, +puntos, ✔/✖ no solo color, Continuar, submit con pregunta+índice). QuestionManager sin cambios (no hizo falta). Headless se pone lento bajo contienda con el editor: --version responde, esperar y reintentar funciona; matar solo zombies propios por CommandLine.
- T5 2026-09-28: scenes/quiz/category_selection.gd + CategorySelection.tscn (cards) + QuizSetup.tscn + quiz_setup.gd (nuevos) + route quiz_setup. Fallo inicial: defaults tscn no pegaban (button_pressed antes de toggle_mode/button_group) → defaults en _ready. E2E necesitó driver persistente (dummy current_scene) y limpieza de zombies propios.
- T4 2026-09-28: autoload/game_session.gd + shim eliminado de scripts/question_bank.gd. category_selection.gd:43 queda pendiente (llama firma vieja de 1 arg) → se arregla en T5. Sin señales en GameSession (nada que preservar).
- T9-T11 2026-09-28 (redirect del usuario, antes que T4): Settings+música procedural+Options funcional+Instructions. Simplificaciones honestas: sin iconos emoji (fuente default), números de pasos como texto lila, toggles ON/OFF en vez de switches iOS, idioma solo Español visual, sin buses custom (mute vía players), _ready de Options/Instructions verificado en T8/editor (solo parse+estructura por ahora).
- T3 2026-09-28: data/questions.json reescrito (72 desde PDF, barajado pos. correcta = índice global mod 4). Corregido error propio tec-adultos-facil-02 (pregunta USB). Solo data/questions.json modificado.
- Rev2 2026-09-28: banco PDF (72: 4 cat × 2 púb × 3 niv × 3) + flujo con QuizSetup + partidas de 3 sin mezclar. T2–T7 originales invalidados (pedían inventar preguntas y usaban categorías viejas). Propuesta actualizada, sin implementar.
- T2 2026-09-28: solo scripts/question_bank.gd. Estado intermedio: questions.json actual (schema viejo) ahora FAILA validación — esperado hasta T3.
- T1 2026-09-28: MainMenu.tscn reescrito (fondo #12132B, MIND blanco + PLAY lila, 3 botones pill). Reload ok, tree verificado.
- Rev2 2026-09-28: banco PDF (72: 4 cat × 2 púb × 3 niv × 3) + flujo con QuizSetup + partidas de 3 sin mezclar. T2–T7 originales invalidados (pedían inventar preguntas y usaban categorías viejas). Propuesta actualizada, sin implementar.
- T1 2026-09-28: MainMenu.tscn reescrito (fondo #12132B, MIND blanco + PLAY lila, 3 botones pill). Reload ok, tree verificado.

## Route declaration
- Ruta: delegated direct intentada → inline por fallo de runtime (Task free-tier). Trigger evidencia: 5 tscn + 7 gd + data = 4+ archivos (mapping) y 2+ archivos por tarea (writer), pero sin subagentes disponibles.
