# Boat Eye Mode

Der "Boat Eye"-Modus ist ein spezieller Minecraft-Speedrun-Modus, bei dem das Sichtfeld extrem vertikal gestreckt wird, um beim Boot-Fahren möglichst viel zu sehen. Damit das Setup den Regeln von speedrun.com entspricht, muss das Boat-Eye-Bild in der Aufnahme als separates Overlay eingeblendet und ausgeblendet werden können.

## OBS-Konfiguration

Siehe [OBS Setup](./013-obs-setup.md) für die allgemeine Einrichtung.  
Für Boat Eye empfiehlt sich ein eigenes OBS-Szenen-Setup:

1. **Erstelle eine neue Szene** in OBS, z.B. "BoatEyeScene".
2. **Füge eine eigene Game Capture-Quelle** hinzu, die Minecraft aufnimmt.
3. **Passe die Quelle an:**
   - **Position:** zentriert
   - **Größe:** Setze die Bounding Box auf **halbe Breite und halbe Höhe** deiner Monitorauflösung (z.B. 960x540 bei 1920x1080).
   - **Ausrichtung:** zentriert
4. **Projiziere** diese Szene auf einen zweiten Monitor, falls gewünscht.

## Automatisches Ein-/Ausblenden mit obs-cli

Um das Boat-Eye-Overlay regelkonform nur bei Bedarf einzublenden, kannst du [obs-cli](https://github.com/pschmitt/obs-cli) verwenden.  
Beispiel-Konfiguration in deinem Profil (`example.default.profile.json`):

```json
// Ausschnitt aus "modeSwitch" in example.default.profile.json
"boat-eye": {
  "size": "384x16384",
  "sensitivity": "-0.9375",
  "onEnter": [
    "# ~/.local/bin/razer-cli --dpi 100",
    "~/.local/bin/obs-cli item show --scene BoatEyeScene GameCapture"
  ],
  "onExit": [
    "# ~/.local/bin/razer-cli --dpi 1800",
    "~/.local/bin/obs-cli item hide --scene BoatEyeScene GameCapture"
  ]
}
```
- Beim Aktivieren von Boat Eye wird das Overlay eingeblendet, beim Verlassen wieder ausgeblendet.
- Passe ggf. Pfade und Szenennamen an deine Umgebung an.

## Maus-Sensitivität für Boat Eye

Für präzises Spielen im Boat-Eye-Modus ist die richtige Zeigergeschwindigkeit wichtig.  
Ein Video, das die Einstellungen erklärt:  
[Boat Eye Sensitivity Guide (YouTube)](https://www.youtube.com/watch?v=QwQwQwQwQwQ) <!-- Ersetze ggf. durch den richtigen Link -->

**Berechnung der optimalen Zeigergeschwindigkeit:**  
Nutze das Tool: [Pixel-Perfect-Tools/calc](https://priffin.github.io/Pixel-Perfect-Tools/calc.html)  
Beachte: Das Tool arbeitet mit der Windows-Zeigergeschwindigkeit.

### Umrechnungstabelle: Windows → Linux

| Windows |   1 |   2 |   3 |   4 |   5 |   6 |   7 |   8 |   9 |  10 |  11 |  12 |  13 |  14 |
|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| xinput  | 0.03125 | 0.0625 | 0.125 | 0.25 | 0.375 | 0.5 | 0.625 | 0.75 | 0.875 | 1 | 1.25 | 1.5 | 1.75 | 2 |
| libinput| -0.96875 | -0.9375 | -0.875 | -0.75 | -0.625 | -0.5 | -0.375 | -0.25 | -0.125 | 0 | 0.25 | 0.5 | 0.75 | 1 |

- Für hyprmcsr kannst du den Wert direkt als `"sensitivity"` in deinem Profil eintragen (libinput-Wert empfohlen).

---

> Zurück zu [OBS Setup](./013-obs-setup.md)
