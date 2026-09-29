# MINDPLAY

Quiz educativo rápido en **Godot 4.7** (GDScript): elegí categoría, público y nivel, respondé 3 preguntas con feedback inmediato y descubrí tu resultado.

## Jugar (Windows)

1. Descargá `MINDPLAY.exe` y `MINDPLAY.pck` desde la pestaña **Releases** de este repositorio.
2. Ponelos en la misma carpeta y ejecutá `MINDPLAY.exe`.
3. Requiere Windows 10/11 de 64 bits.

> El ejecutable es solo para Windows x86_64. Para otras plataformas, abrí el proyecto en Godot y exportalo desde ahí.

## Flujo del juego

MainMenu → CategorySelection → QuizSetup → Quiz → Results (más Options e Instructions).

- **4 categorías:** Diseño, Tecnología, Videojuegos, Cultura Digital.
- **Públicos:** Jóvenes, Adultos. **Niveles:** Fácil, Normal, Difícil.
- **Partida:** 3 preguntas de la combinación elegida (72 en total, sin mezclar).
- **Puntos:** 100 base × racha (x1.0 → x1.5 → x2.0 → x2.5); el fallo da 0 y reinicia la racha.
- **Feedback:** cada respuesta trae su explicación (correcta e incorrecta).

## Abrir el proyecto

1. Godot 4.7.2 (render GL Compatibility).
2. Abrir `project.godot` desde el Editor.
3. Escena principal: `res://scenes/main/MainMenu.tscn`.
4. Opciones → Música/Sonido con persistencia local; Cómo jugar incluido.

## Estructura

- `autoload/` — `SceneRouter` (navegación), `GameSession` (estado de partida), `Settings` (preferencias + audio procedural).
- `data/questions.json` — banco validado (fuente: `MINDPLAY_Preguntas.pdf`).
- `scripts/` — `QuestionBank` (carga/validación/filtrado inmutable), `QuestionManager` (secuencia).
- `scenes/` — pantallas del flujo + Options + Instructions.
- `odd/tasks/mindplay-mockup-ui.md` — decisiones y trazabilidad del desarrollo.
- `build/windows/` — ejecutable Windows (seguido con Git LFS).
- `export_presets.cfg` — preset "Windows Desktop".

## Controles

Mouse/touch o teclado: Tab para moverse, Enter/Espacio para activar, Esc para volver. Sin dependencias externas: audio y contenido generados/incluidos.
