extends PanelContainer
class_name EffectsToolbar

# Trouve l’overlay via le groupe ajouté dans EffectsOverlay._ready()
var _overlay: EffectsOverlay

@onready var btn_toggle: Button = $Root/Buttons/CarteOnOff
@onready var btn_all:    Button = $Root/Buttons/Tout
@onready var btn_o2:     Button = $Root/Buttons/Oxygène
@onready var btn_light:  Button = $Root/Buttons/Lumière
@onready var btn_heat:   Button = $Root/Buttons/Chaleur
@onready var btn_grav:   Button = $Root/Buttons/Gravité

@onready var legend: Control = $Root/Legend

func _ready() -> void:
    # Ne pas intercepter la souris en dehors des boutons
    mouse_filter = Control.MOUSE_FILTER_STOP
    $Root/Legend.mouse_filter = Control.MOUSE_FILTER_IGNORE

    _resolve_overlay()
    _init_legend()

    # Boutons (inchangé si tu avais déjà branché)
    btn_toggle.pressed.connect(func():
           if _overlay:
              var new_vis := not _overlay.overlay_visible
              _overlay.set_overlay_visible(new_vis)
              # on synchronise la barre avec l'overlay
              self.visible = new_vis
    )
    btn_all.pressed.connect(func(): _ensure_overlay_and_call(func(): _overlay.set_mode_all()))
    btn_o2.pressed.connect(func(): _ensure_overlay_and_call(func(): _overlay.set_mode_single(EffectMaps.EffectType.OXYGEN)))
    btn_light.pressed.connect(func(): _ensure_overlay_and_call(func(): _overlay.set_mode_single(EffectMaps.EffectType.LIGHT)))
    btn_heat.pressed.connect(func(): _ensure_overlay_and_call(func(): _overlay.set_mode_single(EffectMaps.EffectType.HEAT)))
    btn_grav.pressed.connect(func(): _ensure_overlay_and_call(func(): _overlay.set_mode_single(EffectMaps.EffectType.GRAVITY)))


    # Si l’overlay arrive une frame plus tard (ordre d’instanciation)
    if _overlay == null:
        await get_tree().process_frame
        _resolve_overlay()



func _resolve_overlay() -> void:
    _overlay = get_tree().get_first_node_in_group("effects_overlay") as EffectsOverlay

func _ensure_overlay_and_call(f: Callable) -> void:
    if _overlay == null:
        _resolve_overlay()
    if _overlay:
        if not _overlay.overlay_visible:
            _overlay.set_overlay_visible(true)
        f.call()

# -------- Légende --------
func _init_legend() -> void:
    if legend == null:
        return

    var cols: Array[Color] = EffectsOverlay.COLORS
    var names: Array[String] = ["Oxygène", "Lumière", "Chaleur", "Gravité"]

    var cr: Array[ColorRect] = []
    var lb: Array[Label] = []
    for child in legend.get_children():
        if child is ColorRect:
            cr.append(child as ColorRect)
        elif child is Label:
            lb.append(child as Label)

    var n: int = mini(cr.size(), names.size())  # <-- typé 👈
    for i in range(n):
        cr[i].color = cols[i]
        if i < lb.size():
            lb[i].text = names[i]
