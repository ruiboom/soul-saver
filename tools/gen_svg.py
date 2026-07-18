#!/usr/bin/env python3
"""All Soul Saver sprite art, authored as SVG. Palette: 'Illuminated Inferno'.
Demons: charcoal + ember. Holy things: gold + halo-white. Nothing else gets gold."""
import os

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets")

# shared gradient defs
DEMON_DEFS = """
<linearGradient id="body" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#3a2c31"/><stop offset="0.55" stop-color="#221c24"/><stop offset="1" stop-color="#14101a"/>
</linearGradient>
<radialGradient id="ember" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#ffd9a0"/><stop offset="0.35" stop-color="#ff9d4d"/><stop offset="1" stop-color="#ff6b2b" stop-opacity="0"/>
</radialGradient>
<linearGradient id="rust" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#7a3524"/><stop offset="1" stop-color="#3d1b16"/>
</linearGradient>
"""

GOLD_DEFS = """
<linearGradient id="gold" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#fff3d6"/><stop offset="0.45" stop-color="#e8b64c"/><stop offset="1" stop-color="#a97b23"/>
</linearGradient>
<linearGradient id="goldv" x1="0" y1="0" x2="1" y2="0">
 <stop offset="0" stop-color="#a97b23"/><stop offset="0.5" stop-color="#ffe9b0"/><stop offset="1" stop-color="#a97b23"/>
</linearGradient>
<radialGradient id="haloG" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#fff3d6" stop-opacity="0.95"/><stop offset="0.6" stop-color="#ffe9b0" stop-opacity="0.35"/><stop offset="1" stop-color="#ffe9b0" stop-opacity="0"/>
</radialGradient>
"""

S = {}

def svg(w, h, defs, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs>{defs}</defs>{body}</svg>'

# ============================================================ PLAYER
S["sprites/player_priest"] = svg(256, 256, GOLD_DEFS + """
<linearGradient id="cassock" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#332b3a"/><stop offset="0.5" stop-color="#221d2b"/><stop offset="1" stop-color="#120f18"/>
</linearGradient>
<linearGradient id="stole" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#8a5fb8"/><stop offset="1" stop-color="#4a3070"/>
</linearGradient>
""", """
<!-- halo -->
<ellipse cx="128" cy="52" rx="46" ry="14" fill="none" stroke="#ffe9b0" stroke-width="7" opacity="0.28"/>
<ellipse cx="128" cy="52" rx="46" ry="14" fill="none" stroke="#fff3d6" stroke-width="3" opacity="0.85"/>
<!-- cassock body, slight forward lean walking right -->
<path d="M96 96 Q88 150 78 226 L112 232 Q116 180 120 160 Q126 185 128 232 L178 226 Q166 150 160 98 Q140 84 96 96 Z" fill="url(#cassock)"/>
<!-- hem shadow -->
<path d="M78 226 L112 232 L128 232 L178 226 L174 214 Q128 226 82 214 Z" fill="#0a080e"/>
<!-- shoulder cape -->
<path d="M92 96 Q128 78 164 96 L170 130 Q128 144 86 130 Z" fill="#1a1622"/>
<path d="M92 96 Q128 78 164 96 L166 108 Q128 120 90 108 Z" fill="#3a3346"/>
<!-- violet stole -->
<path d="M112 100 L106 210 L122 212 L124 102 Z" fill="url(#stole)"/>
<path d="M144 102 L146 212 L162 210 L152 100 Z" fill="url(#stole)"/>
<rect x="104" y="196" width="20" height="14" fill="url(#gold)"/>
<rect x="145" y="196" width="19" height="14" fill="url(#gold)"/>
<!-- cincture -->
<path d="M96 148 Q128 158 162 148 L162 158 Q128 168 96 158 Z" fill="url(#goldv)" opacity="0.9"/>
<!-- pectoral cross -->
<rect x="125" y="118" width="6" height="22" fill="url(#gold)"/><rect x="117" y="124" width="22" height="6" fill="url(#gold)"/>
<!-- head facing right -->
<circle cx="130" cy="62" r="24" fill="#d8b393"/>
<path d="M108 58 Q106 40 130 38 Q154 40 152 58 Q142 48 128 48 Q114 50 108 58 Z" fill="#8d8d94"/>
<!-- beard -->
<path d="M112 64 Q112 92 130 96 Q150 92 150 64 Q150 80 130 84 Q112 80 112 64 Z" fill="#a8a8b0"/>
<path d="M114 66 Q116 86 130 90 Q146 86 148 66 Q144 78 130 80 Q116 78 114 66 Z" fill="#c9c9d2"/>
<!-- eyes closed in prayer-calm, facing right -->
<path d="M132 60 q5 3 9 0" stroke="#3a2c22" stroke-width="2.5" fill="none"/>
<path d="M116 60 q4 3 8 0" stroke="#3a2c22" stroke-width="2.5" fill="none"/>
<!-- right arm folded, holding the censer chain against the chest -->
<path d="M156 104 Q172 114 172 136 Q168 150 156 148 Q148 132 146 118 Z" fill="#2b2534"/>
<circle cx="160" cy="142" r="7" fill="#c6a381"/>
"""
)

# ============================================================ SWARM DEMONS
S["sprites/enemy_ashimp"] = svg(128, 128, DEMON_DEFS, """
<!-- hunched cinder imp -->
<path d="M28 96 Q18 66 42 46 Q60 28 86 38 Q112 50 106 82 Q102 104 78 108 Q46 112 28 96 Z" fill="url(#body)"/>
<!-- back spikes -->
<path d="M40 48 L34 30 L50 40 Z M56 38 L56 18 L70 34 Z M76 36 L84 20 L90 40 Z" fill="#14101a"/>
<!-- ember cracks -->
<path d="M44 78 q10 -8 6 -20 M62 96 q4 -14 16 -16 M84 60 q-8 6 -6 18" stroke="#ff6b2b" stroke-width="3" fill="none" opacity="0.9"/>
<path d="M44 78 q10 -8 6 -20" stroke="#ffd9a0" stroke-width="1.2" fill="none"/>
<!-- arms -->
<path d="M30 84 Q14 88 10 102 L22 106 Q26 94 36 92 Z" fill="url(#body)"/>
<path d="M100 78 Q116 84 118 98 L106 102 Q102 90 94 88 Z" fill="url(#body)"/>
<!-- eyes -->
<circle cx="62" cy="60" r="12" fill="url(#ember)"/><circle cx="84" cy="64" r="10" fill="url(#ember)"/>
<circle cx="62" cy="60" r="4" fill="#ffd9a0"/><circle cx="84" cy="64" r="3.2" fill="#ffd9a0"/>
<!-- maw -->
<path d="M56 84 Q70 94 88 84 Q80 98 68 98 Q60 96 56 84 Z" fill="#0c0910"/>
<path d="M60 86 l4 6 M70 90 l3 6 M80 87 l-2 7" stroke="#c9bfa8" stroke-width="2.4"/>
"""
)

S["sprites/enemy_gnasher"] = svg(128, 128, DEMON_DEFS, """
<!-- lean hound, running right -->
<path d="M14 78 Q10 60 30 58 Q52 50 78 54 Q102 56 114 70 Q120 80 108 84 Q88 78 66 82 Q40 88 28 92 Q16 90 14 78 Z" fill="url(#body)"/>
<!-- spine ridge -->
<path d="M34 58 L38 46 L46 56 M52 53 L58 42 L66 53 M72 53 L80 44 L86 56" stroke="#14101a" stroke-width="5" fill="none"/>
<!-- head + jaw -->
<path d="M100 62 Q124 60 126 74 Q126 82 112 82 Q104 80 100 74 Z" fill="url(#body)"/>
<path d="M104 80 Q120 84 126 94 Q112 96 102 88 Z" fill="#14101a"/>
<path d="M108 80 l3 6 M114 82 l3 6 M120 84 l2 6 M107 74 l4 4 M114 75 l4 4" stroke="#c9bfa8" stroke-width="2.2"/>
<circle cx="108" cy="68" r="6" fill="url(#ember)"/><circle cx="108" cy="68" r="2" fill="#ffd9a0"/>
<!-- legs mid-stride -->
<path d="M30 88 L20 112 L28 114 L38 92 Z M58 86 L54 112 L62 113 L68 88 Z M84 82 L90 108 L98 106 L92 80 Z M104 82 L116 104 L122 100 L112 80 Z" fill="#1a141d"/>
<!-- ember rake on flank -->
<path d="M44 68 q8 6 20 4" stroke="#ff6b2b" stroke-width="2.5" fill="none" opacity="0.85"/>
<!-- tail -->
<path d="M16 72 Q2 66 4 52 L10 54 Q10 64 20 68 Z" fill="url(#body)"/>
"""
)

S["sprites/enemy_bloatgrub"] = svg(128, 128, DEMON_DEFS + """
<linearGradient id="grub" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#d6cbb2"/><stop offset="0.6" stop-color="#a89a80"/><stop offset="1" stop-color="#6e6353"/>
</linearGradient>
<radialGradient id="sick" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#c8e87a"/><stop offset="0.5" stop-color="#7fae3e"/><stop offset="1" stop-color="#7fae3e" stop-opacity="0"/>
</radialGradient>
""", """
<!-- fat larva, segments -->
<ellipse cx="64" cy="78" rx="52" ry="34" fill="url(#grub)"/>
<path d="M20 70 Q30 56 44 52 M34 96 Q30 84 32 70 M56 108 Q50 92 52 62 M80 108 Q76 90 78 60 M100 98 Q98 84 98 68" stroke="#5c5142" stroke-width="4" fill="none" opacity="0.7"/>
<!-- sickly boils -->
<circle cx="46" cy="66" r="10" fill="url(#sick)"/><circle cx="76" cy="88" r="12" fill="url(#sick)"/><circle cx="94" cy="62" r="8" fill="url(#sick)"/>
<circle cx="46" cy="66" r="3.4" fill="#e2f5a8"/><circle cx="76" cy="88" r="4" fill="#e2f5a8"/><circle cx="94" cy="62" r="2.6" fill="#e2f5a8"/>
<!-- face end -->
<circle cx="112" cy="76" r="14" fill="url(#grub)"/>
<circle cx="112" cy="70" r="4" fill="#3d1b16"/><circle cx="118" cy="78" r="3" fill="#3d1b16"/>
<path d="M104 84 q8 6 16 0" stroke="#3d1b16" stroke-width="3" fill="none"/>
<!-- stub legs -->
<path d="M28 106 l-4 10 M46 112 l-2 10 M66 114 l0 10 M86 112 l2 10 M102 106 l4 10" stroke="#6e6353" stroke-width="6"/>
"""
)

S["sprites/enemy_wailer"] = svg(128, 128, DEMON_DEFS + """
<linearGradient id="shroud" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#6b5a80"/><stop offset="0.55" stop-color="#43364f"/><stop offset="1" stop-color="#43364f" stop-opacity="0"/>
</linearGradient>
<radialGradient id="cold" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#e8f2ff"/><stop offset="0.4" stop-color="#9fc4e8"/><stop offset="1" stop-color="#9fc4e8" stop-opacity="0"/>
</radialGradient>
""", """
<!-- drifting shrouded wraith -->
<path d="M40 30 Q64 8 88 30 Q100 44 96 70 Q104 96 92 118 L84 100 L78 122 L70 102 L62 124 L54 100 L46 118 Q34 94 36 68 Q28 44 40 30 Z" fill="url(#shroud)" opacity="0.92"/>
<!-- hood void -->
<path d="M50 38 Q64 26 78 38 Q84 48 80 62 Q64 70 48 62 Q44 48 50 38 Z" fill="#0c0910"/>
<!-- cold eyes + open wail -->
<circle cx="58" cy="48" r="6" fill="url(#cold)"/><circle cx="72" cy="48" r="6" fill="url(#cold)"/>
<ellipse cx="65" cy="62" rx="5" ry="8" fill="url(#cold)" opacity="0.7"/>
<!-- trailing wisps -->
<path d="M42 80 q-14 8 -12 22 M90 78 q14 10 10 24" stroke="#6b5a80" stroke-width="4" fill="none" opacity="0.5"/>
"""
)

S["sprites/enemy_chainbrute"] = svg(192, 192, DEMON_DEFS + """
<linearGradient id="iron" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#8a8f9a"/><stop offset="1" stop-color="#4a4e58"/>
</linearGradient>
""", """
<!-- hulking damned brute -->
<path d="M46 74 Q42 40 96 36 Q152 40 148 76 Q156 120 140 152 L118 158 L120 130 Q98 138 76 130 L78 158 L54 152 Q38 118 46 74 Z" fill="url(#body)"/>
<!-- small head sunken -->
<path d="M82 40 Q96 26 112 40 Q114 54 96 58 Q80 54 82 40 Z" fill="#1a141d"/>
<circle cx="90" cy="44" r="5" fill="url(#ember)"/><circle cx="104" cy="44" r="5" fill="url(#ember)"/>
<!-- massive fists -->
<path d="M40 76 Q18 84 14 112 Q12 132 30 136 Q46 134 48 116 Q50 94 52 84 Z" fill="url(#body)"/>
<path d="M152 78 Q176 86 180 114 Q182 134 164 138 Q148 136 146 118 Q144 96 142 86 Z" fill="url(#body)"/>
<!-- crossed chains -->
<g stroke="url(#iron)" stroke-width="9" fill="none" opacity="0.95">
<path d="M52 60 L148 140"/><path d="M148 60 L52 140"/>
</g>
<g stroke="#2b2e35" stroke-width="3" fill="none">
<path d="M52 60 L148 140"/><path d="M148 60 L52 140"/>
</g>
<circle cx="100" cy="100" r="10" fill="url(#iron)"/><circle cx="100" cy="100" r="4" fill="#2b2e35"/>
<!-- ember wounds -->
<path d="M66 96 q6 10 2 20 M132 92 q-6 12 -2 22" stroke="#ff6b2b" stroke-width="3.4" fill="none" opacity="0.9"/>
"""
)

S["sprites/enemy_fury"] = svg(128, 128, DEMON_DEFS + """
<linearGradient id="wing" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#6b2433"/><stop offset="1" stop-color="#31121c"/>
</linearGradient>
""", """
<!-- winged shrike, wings spread -->
<path d="M64 58 Q40 30 8 34 Q22 44 26 56 Q14 58 4 68 Q22 70 32 78 Q24 88 24 98 Q44 88 60 74 Z" fill="url(#wing)"/>
<path d="M64 58 Q88 30 120 34 Q106 44 102 56 Q114 58 124 68 Q106 70 96 78 Q104 88 104 98 Q84 88 68 74 Z" fill="url(#wing)"/>
<!-- wing bones -->
<path d="M62 62 Q40 44 16 40 M62 66 Q36 62 10 66 M66 62 Q88 44 112 40 M66 66 Q92 62 118 66" stroke="#14101a" stroke-width="3" fill="none" opacity="0.8"/>
<!-- body -->
<path d="M56 54 Q64 44 72 54 Q78 74 70 96 L64 116 L58 96 Q50 74 56 54 Z" fill="url(#body)"/>
<!-- head -->
<circle cx="64" cy="52" r="11" fill="url(#body)"/>
<circle cx="60" cy="50" r="4" fill="url(#ember)"/><circle cx="69" cy="50" r="4" fill="url(#ember)"/>
<path d="M58 60 q6 5 12 0 l-6 6 Z" fill="#0c0910"/>
<!-- claws tail -->
<path d="M64 112 l-6 12 M64 112 l6 12" stroke="#1a141d" stroke-width="4"/>
"""
)

S["sprites/enemy_pyrewight"] = svg(128, 128, DEMON_DEFS + """
<linearGradient id="flameV" x1="0" y1="1" x2="0" y2="0">
 <stop offset="0" stop-color="#8a2f1d"/><stop offset="0.45" stop-color="#ff6b2b"/><stop offset="0.8" stop-color="#ffb46b"/><stop offset="1" stop-color="#ffe9b0"/>
</linearGradient>
""", """
<!-- burning revenant -->
<path d="M64 6 Q76 26 70 38 Q86 32 88 16 Q98 40 88 56 Q104 52 108 40 Q112 68 96 82 Q100 100 86 112 L78 100 L74 118 L64 104 L54 118 L50 100 L42 112 Q28 100 32 82 Q16 68 20 40 Q24 52 40 56 Q30 40 40 16 Q42 32 58 38 Q52 26 64 6 Z" fill="url(#flameV)" opacity="0.95"/>
<!-- charred core skeleton -->
<path d="M56 44 Q64 38 72 44 Q76 60 72 76 L66 96 L62 96 L56 76 Q52 60 56 44 Z" fill="#1a0e12" opacity="0.85"/>
<circle cx="60" cy="50" r="4" fill="#ffe9b0"/><circle cx="69" cy="50" r="4" fill="#ffe9b0"/>
<path d="M58 62 q7 4 13 0" stroke="#ffe9b0" stroke-width="2.4" fill="none"/>
<path d="M52 70 l-10 8 M76 70 l10 8" stroke="#1a0e12" stroke-width="5"/>
"""
)

S["sprites/enemy_scribe"] = svg(128, 128, DEMON_DEFS + """
<linearGradient id="ink" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#2c3242"/><stop offset="1" stop-color="#141824"/>
</linearGradient>
""", """
<!-- ledger-scribe: hunched clerk demon -->
<path d="M36 58 Q40 30 68 28 Q96 30 98 60 Q106 92 92 112 L44 112 Q28 90 36 58 Z" fill="url(#ink)"/>
<!-- beaked plague-clerk mask -->
<path d="M58 40 Q70 30 82 40 Q88 48 84 56 L104 66 L82 62 Q70 68 60 60 Q54 50 58 40 Z" fill="#1a1420"/>
<circle cx="68" cy="46" r="5" fill="url(#ember)"/><circle cx="68" cy="46" r="1.8" fill="#ffd9a0"/>
<!-- clutched ledger (bone-white) -->
<rect x="42" y="70" width="44" height="32" rx="3" fill="#c9bfa8" transform="rotate(-8 64 86)"/>
<rect x="44" y="72" width="19" height="28" fill="#b3a890" transform="rotate(-8 64 86)"/>
<path d="M48 78 h12 M48 84 h12 M48 90 h10 M68 78 h12 M68 84 h12 M68 90 h9" stroke="#5c5142" stroke-width="1.8" transform="rotate(-8 64 86)"/>
<!-- quill -->
<path d="M92 60 Q104 44 116 40 Q108 56 98 66 Z" fill="#8d8d94"/>
<!-- grasping fingers over ledger -->
<path d="M40 74 q-8 6 -6 14 M88 70 q10 4 10 12" stroke="#141824" stroke-width="6" fill="none"/>
"""
)

# ============================================================ ELITES / BOSS
S["sprites/elite_keeper"] = svg(384, 384, DEMON_DEFS + """
<linearGradient id="kbody" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#57454c"/><stop offset="0.5" stop-color="#372b33"/><stop offset="1" stop-color="#1c1520"/>
</linearGradient>
""", """
<!-- shrinekeeper: horned colossus (grey-ish base for per-keeper tinting) -->
<path d="M96 160 Q88 92 192 84 Q296 92 288 162 Q304 250 272 306 L228 316 L232 262 Q192 276 152 262 L156 316 L112 306 Q80 248 96 160 Z" fill="url(#kbody)"/>
<!-- great curved horns -->
<path d="M136 96 Q92 76 78 30 Q116 44 140 66 Q148 80 136 96 Z" fill="#1c1520"/>
<path d="M248 96 Q292 76 306 30 Q268 44 244 66 Q236 80 248 96 Z" fill="#1c1520"/>
<path d="M132 90 Q100 72 88 42 M252 90 Q284 72 296 42" stroke="#57454c" stroke-width="5" fill="none"/>
<!-- skull face plate -->
<path d="M152 100 Q192 82 232 100 Q244 128 232 152 Q192 168 152 152 Q140 128 152 100 Z" fill="#c9bfa8"/>
<path d="M162 118 a12 14 0 1 0 24 0 a12 14 0 1 0 -24 0 M198 118 a12 14 0 1 0 24 0 a12 14 0 1 0 -24 0" fill="#14101a"/>
<circle cx="174" cy="120" r="6" fill="url(#ember)"/><circle cx="210" cy="120" r="6" fill="url(#ember)"/>
<path d="M178 148 l6 12 M192 152 l0 12 M206 148 l-6 12" stroke="#c9bfa8" stroke-width="7"/>
<!-- arms with cleaver fists -->
<path d="M92 168 Q44 184 36 244 Q34 286 72 290 Q104 286 104 244 Q104 200 108 180 Z" fill="url(#kbody)"/>
<path d="M292 168 Q340 184 348 244 Q350 286 312 290 Q280 286 280 244 Q280 200 276 180 Z" fill="url(#kbody)"/>
<!-- ember furnace lines -->
<path d="M150 200 q14 22 6 46 M234 196 q-14 24 -6 50 M192 190 q0 26 0 44" stroke="#ff6b2b" stroke-width="6" fill="none" opacity="0.9"/>
<path d="M150 200 q14 22 6 46 M234 196 q-14 24 -6 50" stroke="#ffd9a0" stroke-width="2" fill="none"/>
"""
)

S["sprites/boss_warden"] = svg(512, 640, DEMON_DEFS + """
<linearGradient id="wiron" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#5a5f6b"/><stop offset="0.5" stop-color="#3a3e48"/><stop offset="1" stop-color="#1e2128"/>
</linearGradient>
<linearGradient id="furnace" x1="0" y1="1" x2="0" y2="0">
 <stop offset="0" stop-color="#8a2f1d"/><stop offset="0.5" stop-color="#ff6b2b"/><stop offset="1" stop-color="#ffd9a0"/>
</linearGradient>
""", """
<!-- THE WARDEN: blind furnace jailer -->
<!-- ragged iron skirt -->
<path d="M136 380 Q120 500 108 600 L172 576 L196 616 L236 584 L276 616 L300 576 L364 600 Q352 500 336 380 Z" fill="url(#wiron)"/>
<path d="M150 420 L164 560 M236 420 L236 580 M322 420 L308 560" stroke="#1e2128" stroke-width="10"/>
<!-- torso with furnace ribcage -->
<path d="M120 180 Q112 100 236 92 Q360 100 352 182 Q368 300 336 392 L136 392 Q104 298 120 180 Z" fill="url(#wiron)"/>
<!-- furnace slits -->
<g fill="url(#furnace)">
<path d="M180 220 q10 40 0 84 l-22 -6 q-8 -40 0 -74 Z"/>
<path d="M258 214 q12 44 0 96 l-24 0 q-12 -52 0 -96 Z"/>
<path d="M314 220 q8 34 0 74 l-22 6 q-10 -44 0 -84 Z"/>
</g>
<path d="M168 306 q68 26 156 -2" stroke="#1e2128" stroke-width="14" fill="none"/>
<path d="M164 258 q72 22 164 -2" stroke="#1e2128" stroke-width="14" fill="none"/>
<!-- blind riveted helm, no eyes -->
<path d="M182 96 Q178 30 236 26 Q294 30 290 96 Q294 132 236 138 Q178 132 182 96 Z" fill="url(#wiron)"/>
<path d="M198 60 L274 60 M190 88 L282 88" stroke="#1e2128" stroke-width="8"/>
<circle cx="204" cy="74" r="5" fill="#14161b"/><circle cx="236" cy="74" r="5" fill="#14161b"/><circle cx="268" cy="74" r="5" fill="#14161b"/>
<!-- weeping heat seam where eyes should be -->
<path d="M200 104 q36 14 72 0" stroke="#ff6b2b" stroke-width="5" fill="none" opacity="0.9"/>
<!-- colossal arms -->
<path d="M116 190 Q40 214 30 320 Q26 384 84 392 Q136 386 132 322 Q130 250 136 214 Z" fill="url(#wiron)"/>
<path d="M356 190 Q432 214 442 320 Q446 384 388 392 Q336 386 340 322 Q342 250 336 214 Z" fill="url(#wiron)"/>
<!-- knuckle rivets -->
<circle cx="62" cy="352" r="9" fill="#1e2128"/><circle cx="92" cy="360" r="9" fill="#1e2128"/>
<circle cx="410" cy="352" r="9" fill="#1e2128"/><circle cx="380" cy="360" r="9" fill="#1e2128"/>
<!-- hanging chains with hooks -->
<g stroke="#5a5f6b" stroke-width="8" fill="none">
<path d="M84 396 Q80 452 96 500"/><path d="M388 396 Q392 452 376 500"/>
</g>
<path d="M96 500 q14 6 8 20 q-16 2 -14 -12 M376 500 q-14 6 -8 20 q16 2 14 -12" fill="#5a5f6b"/>
<!-- shoulder braziers -->
<path d="M120 172 q24 -20 48 -6 l-8 22 q-20 -10 -34 2 Z" fill="#1e2128"/>
<path d="M352 172 q-24 -20 -48 -6 l8 22 q20 -10 34 2 Z" fill="#1e2128"/>
"""
)

S["sprites/lucia_wisp"] = svg(96, 96, """
<radialGradient id="wispG" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#ffffff"/><stop offset="0.3" stop-color="#e6f0ff"/><stop offset="0.7" stop-color="#cfe6ff" stop-opacity="0.5"/><stop offset="1" stop-color="#cfe6ff" stop-opacity="0"/>
</radialGradient>
""", """
<circle cx="48" cy="42" r="34" fill="url(#wispG)"/>
<circle cx="48" cy="42" r="12" fill="#ffffff"/>
<path d="M48 60 Q44 76 48 90 Q52 76 48 60 Z" fill="#e6f0ff" opacity="0.8"/>
<circle cx="30" cy="58" r="4" fill="#ffffff" opacity="0.7"/><circle cx="66" cy="56" r="3" fill="#ffffff" opacity="0.6"/>
"""
)

# ============================================================ ENVIRONMENT
S["env/shrine"] = svg(384, 512, DEMON_DEFS + """
<linearGradient id="basalt" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#332e3d"/><stop offset="0.5" stop-color="#201c28"/><stop offset="1" stop-color="#121017"/>
</linearGradient>
<radialGradient id="sickG" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#c8e87a"/><stop offset="0.4" stop-color="#7fae3e" stop-opacity="0.7"/><stop offset="1" stop-color="#7fae3e" stop-opacity="0"/>
</radialGradient>
""", """
<!-- profane shrine: inverted chapel of black basalt -->
<!-- base slab -->
<path d="M32 452 L352 452 L332 496 L52 496 Z" fill="#121017"/>
<!-- main inverted-arch mass: wide at top, tapering down -->
<path d="M48 92 L336 92 L312 400 Q292 452 192 456 Q92 452 72 400 Z" fill="url(#basalt)"/>
<!-- top spikes pointing DOWN (inversion) hanging over the facade -->
<path d="M64 92 L88 150 L108 92 Z M118 92 L142 172 L164 92 Z M172 92 L192 200 L212 92 Z M220 92 L244 172 L266 92 Z M276 92 L300 150 L320 92 Z" fill="#0c0a10"/>
<!-- crown battlements above -->
<path d="M48 92 L48 44 L86 44 L86 68 L122 68 L122 30 L166 30 L166 56 L218 56 L218 30 L262 30 L262 68 L298 68 L298 44 L336 44 L336 92 Z" fill="#201c28"/>
<!-- inverted cross finial -->
<rect x="186" y="8" width="12" height="44" fill="#0c0a10"/><rect x="172" y="36" width="40" height="12" fill="#0c0a10"/>
<!-- niche with void -->
<path d="M136 200 Q192 156 248 200 L248 340 Q192 372 136 340 Z" fill="#050408"/>
<path d="M136 200 Q192 156 248 200" stroke="#57454c" stroke-width="6" fill="none"/>
<!-- sickly candles -->
<circle cx="110" cy="380" r="26" fill="url(#sickG)"/><circle cx="274" cy="380" r="26" fill="url(#sickG)"/>
<rect x="105" y="374" width="10" height="26" fill="#c9bfa8"/><rect x="269" y="374" width="10" height="26" fill="#c9bfa8"/>
<path d="M110 366 q6 8 0 14 q-6 -6 0 -14 M274 366 q6 8 0 14 q-6 -6 0 -14" fill="#c8e87a"/>
<!-- carved demon glyphs -->
<path d="M84 240 q14 10 0 24 M84 300 q14 10 0 24 M300 240 q-14 10 0 24 M300 300 q-14 10 0 24" stroke="#57454c" stroke-width="4" fill="none"/>
"""
)

S["env/gate"] = svg(768, 640, GOLD_DEFS + """
<linearGradient id="stone" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#f2ede2"/><stop offset="0.6" stop-color="#d8d0c0"/><stop offset="1" stop-color="#b3a890"/>
</linearGradient>
""", """
<!-- GATE OF DAWN: the one clean thing in Hell -->
<!-- steps -->
<path d="M104 560 L664 560 L704 620 L64 620 Z" fill="#b3a890"/>
<path d="M136 520 L632 520 L664 560 L104 560 Z" fill="#cfc7b8"/>
<!-- pillars -->
<path d="M148 120 L236 120 L228 520 L156 520 Z" fill="url(#stone)"/>
<path d="M532 120 L620 120 L612 520 L540 520 Z" fill="url(#stone)"/>
<path d="M160 140 L168 500 M224 140 L218 500 M544 140 L550 500 M608 140 L600 500" stroke="#b3a890" stroke-width="6"/>
<!-- arch -->
<path d="M148 200 Q384 -60 620 200 L620 120 L532 120 Q384 20 236 120 L148 120 Z" fill="url(#stone)"/>
<path d="M188 170 Q384 -20 580 170" stroke="#b3a890" stroke-width="8" fill="none"/>
<!-- capstone cross -->
<rect x="374" y="18" width="20" height="64" fill="url(#gold)"/><rect x="352" y="38" width="64" height="20" fill="url(#gold)"/>
<!-- sealed doors -->
<path d="M236 520 L236 190 Q384 80 532 190 L532 520 Z" fill="#e6e0d2"/>
<path d="M384 128 L384 520" stroke="#b3a890" stroke-width="10"/>
<!-- great gold seal -->
<circle cx="384" cy="330" r="86" fill="none" stroke="url(#goldv)" stroke-width="14"/>
<circle cx="384" cy="330" r="60" fill="none" stroke="url(#goldv)" stroke-width="6"/>
<rect x="376" y="270" width="16" height="120" fill="url(#gold)"/><rect x="324" y="310" width="120" height="16" fill="url(#gold)"/>
<!-- seven small vestige sockets around the seal -->
<g fill="#b3a890">
<circle cx="384" cy="222" r="10"/><circle cx="470" cy="260" r="10"/><circle cx="492" cy="348" r="10"/><circle cx="440" cy="416" r="10"/><circle cx="328" cy="416" r="10"/><circle cx="276" cy="348" r="10"/><circle cx="298" cy="260" r="10"/>
</g>
"""
)

S["env/bonepile"] = svg(192, 144, DEMON_DEFS + """
<linearGradient id="bone" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#d6cbb2"/><stop offset="1" stop-color="#8a7f68"/>
</linearGradient>
""", """
<path d="M16 120 Q30 84 64 80 Q60 56 88 52 Q120 50 122 76 Q158 74 172 100 Q184 116 176 128 L20 130 Z" fill="url(#bone)"/>
<!-- skull -->
<circle cx="88" cy="84" r="24" fill="#e2d8c0"/>
<path d="M74 80 a7 9 0 1 0 14 0 a7 9 0 1 0 -14 0 M94 80 a7 9 0 1 0 14 0 a7 9 0 1 0 -14 0" fill="#221c24"/>
<path d="M80 100 l4 8 M88 102 l0 8 M96 100 l-4 8" stroke="#e2d8c0" stroke-width="4"/>
<!-- ribs & long bones -->
<path d="M30 108 q20 -12 44 -6 M124 88 q22 0 36 18" stroke="#b3a890" stroke-width="7" fill="none"/>
<path d="M140 70 l24 -18 M140 70 q-4 -10 4 -14 M164 52 q10 -2 8 8" stroke="#d6cbb2" stroke-width="8" fill="none"/>
<path d="M40 90 q-2 -18 14 -24" stroke="#d6cbb2" stroke-width="8" fill="none"/>
"""
)

S["env/gibbet"] = svg(256, 384, DEMON_DEFS + """
<linearGradient id="giron" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#4a4e58"/><stop offset="1" stop-color="#22242b"/>
</linearGradient>
""", """
<!-- iron gibbet tree -->
<path d="M116 368 L108 80 Q106 48 132 46 L196 50 L196 66 L140 64 Q124 66 126 84 L136 368 Z" fill="url(#giron)"/>
<path d="M84 368 L168 368 L160 344 L94 344 Z" fill="#22242b"/>
<!-- chain -->
<path d="M188 66 L188 118" stroke="#4a4e58" stroke-width="7"/>
<circle cx="188" cy="80" r="6" fill="none" stroke="#22242b" stroke-width="3"/>
<circle cx="188" cy="96" r="6" fill="none" stroke="#22242b" stroke-width="3"/>
<!-- hanging cage -->
<path d="M156 118 Q188 106 220 118 L214 218 Q188 236 162 218 Z" fill="none" stroke="url(#giron)" stroke-width="8"/>
<path d="M168 116 L170 224 M188 112 L188 230 M208 116 L206 224" stroke="url(#giron)" stroke-width="5"/>
<path d="M156 150 h64 M158 184 h60" stroke="url(#giron)" stroke-width="5"/>
<!-- poor soul's remains -->
<circle cx="188" cy="166" r="12" fill="#8a7f68"/>
<path d="M182 180 q6 16 12 0" stroke="#8a7f68" stroke-width="6" fill="none"/>
"""
)

S["env/rock"] = svg(256, 224, DEMON_DEFS + """
<linearGradient id="bslt" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0" stop-color="#3d3846"/><stop offset="0.6" stop-color="#262230"/><stop offset="1" stop-color="#15121c"/>
</linearGradient>
""", """
<path d="M20 200 L48 96 L92 120 L120 30 L168 84 L200 60 L236 180 L220 208 L36 208 Z" fill="url(#bslt)"/>
<path d="M120 30 L138 96 L92 120 M168 84 L158 150 M48 96 L84 170" stroke="#15121c" stroke-width="5" fill="none"/>
<path d="M120 30 L168 84 L200 60 L236 180" stroke="#57536b" stroke-width="4" fill="none" opacity="0.6"/>
<!-- faint ember vein -->
<path d="M60 180 q30 -20 60 -8 q30 10 70 -6" stroke="#8a2f1d" stroke-width="4" fill="none" opacity="0.7"/>
"""
)

# ============================================================ WEAPON ICONS (128) — gold on transparent
def icon(body, extra_defs=""):
    return svg(128, 128, GOLD_DEFS + extra_defs, body)

S["icons/weap_thurible"] = icon("""
<path d="M64 8 L64 30" stroke="url(#goldv)" stroke-width="4"/>
<circle cx="64" cy="14" r="5" fill="none" stroke="url(#goldv)" stroke-width="3"/>
<path d="M50 34 L78 34 L74 44 L54 44 Z" fill="url(#gold)"/>
<path d="M40 48 Q64 36 88 48 Q96 72 82 88 Q64 98 46 88 Q32 72 40 48 Z" fill="url(#gold)"/>
<path d="M44 60 h40 M42 72 h44" stroke="#7a5518" stroke-width="4"/>
<circle cx="52" cy="54" r="3" fill="#3d2c10"/><circle cx="64" cy="52" r="3" fill="#3d2c10"/><circle cx="76" cy="54" r="3" fill="#3d2c10"/>
<path d="M58 96 L70 96 L66 110 L62 110 Z" fill="url(#gold)"/><ellipse cx="64" cy="114" rx="12" ry="5" fill="url(#gold)"/>
<path d="M34 40 Q20 28 26 12 M94 40 Q108 28 102 12" stroke="#cfe6ff" stroke-width="3" fill="none" opacity="0.8"/>
""")

S["icons/weap_holywater"] = icon("""
<path d="M50 34 L78 34 L76 22 L52 22 Z" fill="#8a7f68"/>
<rect x="54" y="10" width="20" height="14" rx="3" fill="#a89a80"/>
<path d="M46 40 Q36 62 40 88 Q44 112 64 112 Q84 112 88 88 Q92 62 82 40 Z" fill="#cfe6ff" opacity="0.45"/>
<path d="M46 62 Q42 76 44 90 Q48 108 64 108 Q80 108 84 90 Q86 76 82 62 Q64 70 46 62 Z" fill="#7ab8e8" opacity="0.85"/>
<path d="M60 70 h8 v8 h8 v8 h-8 v12 h-8 v-12 h-8 v-8 h8 Z" fill="#fff3d6"/>
<path d="M50 44 Q54 56 50 66" stroke="#ffffff" stroke-width="3" fill="none" opacity="0.7"/>
""", "")

S["icons/weap_rosary"] = icon("""
<circle cx="64" cy="52" r="34" fill="none" stroke="#7a5518" stroke-width="2"/>
<g fill="url(#gold)">
<circle cx="64" cy="18" r="6"/><circle cx="88" cy="28" r="6"/><circle cx="98" cy="52" r="6"/><circle cx="88" cy="76" r="6"/><circle cx="64" cy="86" r="6"/><circle cx="40" cy="76" r="6"/><circle cx="30" cy="52" r="6"/><circle cx="40" cy="28" r="6"/>
</g>
<circle cx="64" cy="86" r="4" fill="#5b3a7e"/>
<rect x="60" y="92" width="8" height="24" fill="url(#gold)"/><rect x="52" y="100" width="24" height="8" fill="url(#gold)"/>
""")

S["icons/weap_psalter"] = icon("""
<path d="M14 40 Q40 26 62 40 L62 104 Q40 92 14 102 Z" fill="#e2d8c0"/>
<path d="M114 40 Q88 26 66 40 L66 104 Q88 92 114 102 Z" fill="#e2d8c0"/>
<path d="M14 40 Q40 26 62 40 M114 40 Q88 26 66 40" stroke="#8a5b2c" stroke-width="5" fill="none"/>
<path d="M24 52 q18 -6 32 2 M24 64 q18 -6 32 2 M24 76 q18 -6 32 2 M104 52 q-18 -6 -32 2 M104 64 q-18 -6 -32 2 M104 76 q-18 -6 -32 2" stroke="#e8b64c" stroke-width="3.4" fill="none"/>
<path d="M60 20 Q64 10 68 20 L68 40 L60 40 Z" fill="url(#gold)"/>
""")

S["icons/weap_paten"] = icon("""
<ellipse cx="64" cy="64" rx="48" ry="44" fill="url(#gold)"/>
<ellipse cx="64" cy="64" rx="34" ry="31" fill="#ffe9b0"/>
<ellipse cx="64" cy="64" rx="34" ry="31" fill="none" stroke="#a97b23" stroke-width="3"/>
<rect x="60" y="42" width="8" height="44" fill="#a97b23"/><rect x="44" y="58" width="40" height="8" fill="#a97b23"/>
<path d="M28 40 Q46 24 74 26" stroke="#fff3d6" stroke-width="5" fill="none" opacity="0.9"/>
""")

S["icons/weap_bell"] = icon("""
<path d="M60 12 Q64 6 68 12 L68 20 L60 20 Z" fill="url(#gold)"/>
<path d="M36 78 Q34 34 64 30 Q94 34 92 78 Q98 84 100 92 L28 92 Q30 84 36 78 Z" fill="url(#gold)"/>
<path d="M40 76 Q40 42 64 38" stroke="#fff3d6" stroke-width="4" fill="none" opacity="0.9"/>
<path d="M28 92 L100 92" stroke="#7a5518" stroke-width="4"/>
<circle cx="64" cy="102" r="8" fill="url(#gold)"/>
<path d="M18 60 Q10 72 16 86 M110 60 Q118 72 112 86" stroke="#ffe9b0" stroke-width="4" fill="none" opacity="0.8"/>
""")

S["icons/weap_pillar"] = icon("""
<path d="M34 16 Q64 4 94 16 L86 26 Q64 18 42 26 Z" fill="#cfe6ff"/>
<path d="M46 26 L82 26 L74 108 L54 108 Z" fill="url(#goldv)" opacity="0.9"/>
<path d="M52 30 L58 104 M76 30 L70 104" stroke="#fff3d6" stroke-width="3" opacity="0.8"/>
<ellipse cx="64" cy="112" rx="28" ry="8" fill="#ffe9b0" opacity="0.8"/>
<path d="M30 60 l-8 4 M98 60 l8 4 M34 84 l-10 2 M94 84 l10 2" stroke="#cfe6ff" stroke-width="3"/>
""")

S["icons/weap_crown"] = icon("""
<ellipse cx="64" cy="70" rx="44" ry="26" fill="none" stroke="#5c4a2c" stroke-width="12"/>
<ellipse cx="64" cy="70" rx="44" ry="26" fill="none" stroke="#7a6238" stroke-width="6"/>
<g stroke="#3d2f1a" stroke-width="4" fill="none">
<path d="M28 58 l-8 -10 M46 50 l-4 -12 M68 46 l2 -12 M90 52 l8 -10 M102 66 l12 -4 M96 82 l10 8 M74 92 l4 12 M50 92 l-6 10 M28 80 l-12 6"/>
</g>
<circle cx="40" cy="56" r="3.4" fill="#a82a2a"/><circle cx="76" cy="48" r="3.4" fill="#a82a2a"/><circle cx="100" cy="74" r="3.4" fill="#a82a2a"/>
<ellipse cx="64" cy="70" rx="52" ry="32" fill="none" stroke="#ffe9b0" stroke-width="3" opacity="0.5"/>
""")

S["icons/weap_sword"] = icon("""
<path d="M64 4 L74 22 L70 78 L58 78 L54 22 Z" fill="#ffffff"/>
<path d="M64 8 L64 76" stroke="#cfe6ff" stroke-width="4"/>
<path d="M54 30 Q44 40 48 54 Q40 44 46 30 Z M74 34 Q84 44 80 58 Q88 48 82 34 Z" fill="#ffe9b0" opacity="0.85"/>
<rect x="40" y="78" width="48" height="10" rx="4" fill="url(#gold)"/>
<rect x="59" y="88" width="10" height="26" fill="url(#gold)"/>
<circle cx="64" cy="120" r="7" fill="url(#gold)"/>
""")

# passives
S["icons/pass_coal"] = icon("""
<path d="M30 84 L44 52 L70 40 L96 56 L100 84 L78 102 L46 102 Z" fill="#221c24"/>
<path d="M46 78 q10 -12 26 -10 M60 96 q2 -12 16 -18" stroke="#ff6b2b" stroke-width="5" fill="none"/>
<path d="M46 78 q10 -12 26 -10" stroke="#ffd9a0" stroke-width="2" fill="none"/>
<path d="M58 30 q6 -12 0 -20 q12 8 8 22 Z" fill="#ff9d4d" opacity="0.9"/>
""", DEMON_DEFS.replace('id="body"', 'id="bodyx"'))
S["icons/pass_chalice"] = icon("""
<path d="M34 20 L94 20 Q92 56 64 64 Q36 56 34 20 Z" fill="url(#gold)"/>
<path d="M42 26 Q44 48 64 56" stroke="#fff3d6" stroke-width="4" fill="none"/>
<path d="M40 24 Q64 34 88 24" stroke="#6b1a2a" stroke-width="8" fill="none"/>
<rect x="60" y="62" width="8" height="28" fill="url(#gold)"/>
<path d="M40 104 Q64 88 88 104 L88 110 L40 110 Z" fill="url(#gold)"/>
""")
S["icons/pass_stole"] = icon("""
<path d="M40 10 Q64 24 88 10 L96 24 Q64 42 32 24 Z" fill="#5b3a7e"/>
<path d="M36 22 L28 104 L52 106 L54 34 Q44 30 36 22 Z" fill="#7a55a0"/>
<path d="M92 22 L100 104 L76 106 L74 34 Q84 30 92 22 Z" fill="#7a55a0"/>
<rect x="28" y="92" width="24" height="12" fill="url(#gold)"/><rect x="76" y="92" width="24" height="12" fill="url(#gold)"/>
<path d="M36 56 h16 M76 56 h16" stroke="#e8b64c" stroke-width="4"/>
""")
S["icons/pass_medal"] = icon("""
<path d="M48 8 L80 8 L72 34 L56 34 Z" fill="#a82a2a"/>
<circle cx="64" cy="70" r="38" fill="url(#gold)"/>
<circle cx="64" cy="70" r="30" fill="#ffe9b0"/>
<circle cx="64" cy="70" r="30" fill="none" stroke="#a97b23" stroke-width="3"/>
<!-- tiny traveller figure -->
<circle cx="60" cy="58" r="6" fill="#a97b23"/>
<path d="M60 64 Q56 76 58 88 M60 68 L48 80 M60 68 L72 74 M52 92 L58 88 L66 92" stroke="#a97b23" stroke-width="5" fill="none"/>
<path d="M74 54 L74 90" stroke="#a97b23" stroke-width="4"/>
""")
S["icons/pass_candle"] = icon("""
<path d="M64 10 q10 14 0 24 q-10 -10 0 -24 Z" fill="#ffb46b"/>
<path d="M64 16 q5 8 0 14 q-5 -6 0 -14 Z" fill="#fff3d6"/>
<rect x="52" y="38" width="24" height="58" rx="4" fill="#e2d8c0"/>
<path d="M56 42 q-4 20 2 30" stroke="#fff" stroke-width="3" fill="none" opacity="0.6"/>
<path d="M52 46 q-6 12 -2 18 l4 0 Z" fill="#e2d8c0"/>
<ellipse cx="64" cy="102" rx="26" ry="8" fill="url(#gold)"/>
<path d="M42 102 Q40 92 50 90" stroke="url(#gold)" stroke-width="5" fill="none"/>
""")
S["icons/pass_manuscript"] = icon("""
<path d="M22 24 L94 24 Q106 24 106 36 L106 92 L34 92 Q22 92 22 80 Z" fill="#e2d8c0"/>
<path d="M106 36 Q106 46 96 46 L96 100 Q84 96 34 100 Q22 100 22 88" fill="none" stroke="#b3a890" stroke-width="4"/>
<rect x="30" y="34" width="22" height="26" fill="#a82a2a"/>
<path d="M34 40 h14 M34 46 h14 M34 52 h10" stroke="#ffe9b0" stroke-width="2"/>
<path d="M60 36 h36 M60 44 h36 M60 52 h30 M30 68 h64 M30 76 h64 M30 84 h50" stroke="#5c5142" stroke-width="3"/>
<path d="M60 36 h12" stroke="#e8b64c" stroke-width="3"/>
""")
S["icons/pass_palm"] = icon("""
<path d="M64 116 L64 52" stroke="#6b8a3e" stroke-width="7"/>
<g fill="#8fae5a">
<path d="M64 56 Q40 44 30 18 Q56 26 66 48 Z"/>
<path d="M64 56 Q88 44 98 18 Q72 26 62 48 Z"/>
<path d="M64 44 Q48 26 48 6 Q66 18 66 40 Z"/>
<path d="M64 44 Q80 26 80 6 Q62 18 62 40 Z"/>
<path d="M64 72 Q44 68 34 52 Q56 54 64 64 Z"/>
<path d="M64 72 Q84 68 94 52 Q72 54 64 64 Z"/>
</g>
<path d="M64 56 Q40 44 30 18 M64 56 Q88 44 98 18 M64 44 Q48 26 48 6 M64 44 Q80 26 80 6" stroke="#55702c" stroke-width="2" fill="none"/>
<path d="M50 108 Q64 98 78 108" stroke="url(#goldv)" stroke-width="5" fill="none"/>
""")
S["icons/pass_ring"] = icon("""
<circle cx="64" cy="72" r="34" fill="none" stroke="url(#goldv)" stroke-width="14"/>
<path d="M48 36 L64 16 L80 36 L72 44 L56 44 Z" fill="url(#gold)"/>
<path d="M56 24 L64 16 L72 24 L64 34 Z" fill="#8a5fb8"/>
<path d="M58 26 L64 20" stroke="#cfa8ff" stroke-width="3"/>
""")

# pickups
S["icons/pick_bread"] = icon("""
<ellipse cx="64" cy="72" rx="44" ry="28" fill="#c9945a"/>
<ellipse cx="64" cy="66" rx="44" ry="26" fill="#e0b070"/>
<path d="M40 56 q8 14 -2 24 M62 52 q8 14 -2 26 M86 56 q6 12 -2 22" stroke="#a8743c" stroke-width="5" fill="none"/>
<path d="M30 52 Q64 36 98 52" stroke="#f2d4a0" stroke-width="4" fill="none"/>
""")
S["icons/pick_chrism"] = icon("""
<rect x="56" y="8" width="16" height="12" rx="3" fill="#a97b23"/>
<path d="M50 22 L78 22 L84 40 Q90 74 78 100 Q64 110 50 100 Q38 74 44 40 Z" fill="#ffe9b0" opacity="0.55"/>
<path d="M48 56 Q44 80 52 96 Q64 104 76 96 Q84 80 80 56 Q64 64 48 56 Z" fill="url(#gold)" opacity="0.95"/>
<path d="M52 30 Q56 44 52 52" stroke="#fff" stroke-width="3" fill="none" opacity="0.8"/>
""")
S["icons/pick_wrath"] = icon("""
<circle cx="64" cy="64" r="20" fill="#fff3d6"/>
<g stroke="url(#goldv)" stroke-width="7" fill="none">
<path d="M64 10 L64 40 M64 88 L64 118 M10 64 L40 64 M88 64 L118 64"/>
<path d="M28 28 L46 46 M100 28 L82 46 M28 100 L46 82 M100 100 L82 82" stroke-width="5"/>
</g>
<circle cx="64" cy="64" r="27" fill="none" stroke="#ffe9b0" stroke-width="4" opacity="0.8"/>
""")
S["icons/pick_mark"] = icon("""
<path d="M40 20 Q64 8 88 20 L92 56 Q90 96 64 112 Q38 96 36 56 Z" fill="#8a7f68"/>
<path d="M44 26 Q64 16 84 26 L87 56 Q85 90 64 104 Q43 90 41 56 Z" fill="#c9bfa8"/>
<path d="M58 40 a6 8 0 1 0 12 0 a6 8 0 1 0 -12 0" fill="#221c24"/>
<path d="M56 64 h16 M52 74 h24 M56 84 h16" stroke="#5c5142" stroke-width="4"/>
""")

# projectiles / in-world weapon visuals
S["proj/bead"] = svg(32, 32, GOLD_DEFS, """
<circle cx="16" cy="16" r="12" fill="url(#gold)"/><circle cx="12" cy="11" r="4" fill="#fff3d6"/>
""")
S["proj/verse"] = svg(64, 24, GOLD_DEFS, """
<path d="M2 12 L26 3 L62 12 L26 21 Z" fill="#ffe9b0" opacity="0.9"/>
<path d="M8 12 L60 12" stroke="#fff3d6" stroke-width="4"/>
<path d="M30 8 h8 M42 8 h6 M30 16 h6 M40 16 h8" stroke="#a97b23" stroke-width="2"/>
""")
S["proj/vial"] = svg(32, 40, "", """
<rect x="12" y="2" width="8" height="6" fill="#a89a80"/>
<path d="M10 8 L22 8 L26 20 Q26 36 16 36 Q6 36 6 20 Z" fill="#cfe6ff" opacity="0.6"/>
<path d="M8 20 Q8 32 16 32 Q24 32 24 20 Q16 26 8 20 Z" fill="#7ab8e8"/>
""")
S["proj/paten"] = svg(48, 48, GOLD_DEFS, """
<circle cx="24" cy="24" r="20" fill="url(#gold)"/><circle cx="24" cy="24" r="13" fill="#ffe9b0"/>
<rect x="21" y="12" width="6" height="24" fill="#a97b23"/><rect x="12" y="21" width="24" height="6" fill="#a97b23"/>
""")
S["proj/censer"] = svg(48, 64, GOLD_DEFS, """
<path d="M24 0 L24 18" stroke="url(#goldv)" stroke-width="3"/>
<path d="M16 18 L32 18 L30 24 L18 24 Z" fill="url(#gold)"/>
<path d="M10 26 Q24 20 38 26 Q42 40 34 48 Q24 54 14 48 Q6 40 10 26 Z" fill="url(#gold)"/>
<path d="M12 32 h24 M11 40 h26" stroke="#7a5518" stroke-width="3"/>
<circle cx="18" cy="29" r="2" fill="#ff9d4d"/><circle cx="24" cy="28" r="2" fill="#ff9d4d"/><circle cx="30" cy="29" r="2" fill="#ff9d4d"/>
<path d="M20 52 L28 52 L26 58 L22 58 Z" fill="url(#gold)"/>
""")
S["proj/sword"] = svg(48, 160, GOLD_DEFS, """
<path d="M24 2 L32 20 L29 104 L19 104 L16 20 Z" fill="#ffffff"/>
<path d="M24 6 L24 102" stroke="#cfe6ff" stroke-width="3"/>
<path d="M16 30 Q8 44 12 62 Q4 48 8 30 Z M32 36 Q40 50 36 68 Q44 54 40 36 Z" fill="#ffe9b0" opacity="0.8"/>
<rect x="8" y="104" width="32" height="8" rx="3" fill="url(#gold)"/>
<rect x="20" y="112" width="8" height="20" fill="url(#gold)"/>
<circle cx="24" cy="136" r="6" fill="url(#gold)"/>
""")
S["proj/ember"] = svg(24, 24, """
<radialGradient id="gr" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#ffffff"/><stop offset="0.35" stop-color="#cfe6ff"/><stop offset="1" stop-color="#7ab8e8" stop-opacity="0"/>
</radialGradient>
""", """
<circle cx="12" cy="12" r="11" fill="url(#gr)"/><circle cx="12" cy="12" r="4" fill="#ffffff"/>
""")
S["proj/spit"] = svg(24, 24, """
<radialGradient id="sp" cx="0.5" cy="0.5" r="0.5">
 <stop offset="0" stop-color="#c8e87a"/><stop offset="0.5" stop-color="#7fae3e"/><stop offset="1" stop-color="#4a6a20" stop-opacity="0"/>
</radialGradient>
""", """
<circle cx="12" cy="12" r="11" fill="url(#sp)"/>
""")

def main():
    n = 0
    for rel, content in S.items():
        path = os.path.join(ROOT, rel + ".svg")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write(content)
        n += 1
    print(f"wrote {n} svgs under {ROOT}")

if __name__ == "__main__":
    main()
