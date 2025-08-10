#plantedcrop.gd
class_name PlantedCrop
extends Node2D
# --------------------------------------------------------------------
@export var plant_data : PlantData
var wetness_overlay    : TileMapLayer        # assignée par le cursor

@export_group("Santé et Stress")
@export var max_health: float = 100.0
var health: float
var is_dead: bool = false # Pour savoir si la plante est morte


# --- AJOUTE CES DEUX VARIABLES AU DÉBUT ---
var fixed_screen_position: Vector2


# --- Références internes (onready) ----------------------------------
@onready var animated_sprite      : AnimatedSprite2D   = $AnimatedSprite2D
@onready var watering_particles   : GPUParticles2D     = $WateringParticles
@onready var flowering_particles  : GPUParticles2D     = $FloweringParticles
@onready var growth_cycle_component : GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component       : HurtComponent      = $HurtComponent
@onready var collectable_component: CollectableComponent = $CollectableComponent
@onready var light_emitter        : PointLight2D       = $LightEmitter

@onready var aura_component: AuraComponent = $AuraComponent

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var status_icons_container: HBoxContainer = $StatusIconsContainer


@onready var flame_particles: GPUParticles2D = $FlameParticles
@onready var water_sphere: Sprite2D = $WaterSphere
@onready var water_burst_particles: GPUParticles2D = $WaterSphere/WaterBurstParticles

var current_gravity_strength: float = 0.0


func _ready() -> void:
    pass

func init(p_data: PlantData, p_wetness_overlay: TileMapLayer) -> void:
    # 1. On assigne les données reçues en premier.
    self.plant_data = p_data
    self.wetness_overlay = p_wetness_overlay
    
    


    # --- Initialisation de la santé ---
    health = max_health
    if health_bar:
        health_bar.max_value = max_health
        health_bar.value = health
        health_bar.visible = false
    
    if status_icons_container:
        status_icons_container.visible = false
        
    # --- Le reste de ton initialisation (copié de ton code) ---
    if aura_component:
        aura_component.init(
            plant_data.heat_effect,
            plant_data.gravity_effect,
            plant_data.oxygen_effect)
        aura_component.name = "%s_Aura" % plant_data.resource_name
    
    var pmat := water_burst_particles.process_material as ParticleProcessMaterial
    if pmat:
        pmat.direction = Vector3(1, 0, 0)
        pmat.spread = 180.0
    
    if plant_data.growth_data:
        growth_cycle_component.total_stages = plant_data.growth_data.sprite_frames.get_animation_names().size() - 1
        animated_sprite.sprite_frames = plant_data.growth_data.sprite_frames
        animated_sprite.offset = plant_data.sprite_offset
        growth_cycle_component.plant_data_ref = plant_data

    animated_sprite.play("stage_0")
    if plant_data.harvest_data:
        collectable_component.item_data = plant_data.harvest_data.harvest_item
    growth_cycle_component.wetness_overlay = self.wetness_overlay

    hurt_component.hurt.connect(on_hurt)
    growth_cycle_component.growth_stage_changed.connect(on_growth_stage_changed)
    growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)
    
    light_emitter.visible = false
    if plant_data.light_effect and plant_data.light_effect.has_light_effect:
        light_emitter.visible = true
        light_emitter.color = plant_data.light_effect.light_color
        light_emitter.energy = plant_data.light_effect.light_emission
        start_shimmer_animation()
    
    if plant_data.water_pulse_effect and plant_data.water_pulse_effect.has_water_pulse_effect:
        water_sphere.visible = true
        var radius = plant_data.water_pulse_effect.pulse_radius
        var diameter_in_tiles = (radius * 2) + 1
        var target_diameter_in_pixels = diameter_in_tiles * 16
        var texture_size = water_sphere.texture.get_size().x
        var required_scale = target_diameter_in_pixels / texture_size
        water_sphere.scale = Vector2(required_scale, required_scale)
        _start_water_sphere_animation()
        
    # --- NOTRE LOGIQUE CORRIGÉE ---
    # La plante elle-même décide si elle doit s'enregistrer pour un effet de gravité.
    if self.plant_data.gravity_effect and self.plant_data.gravity_effect.has_gravity_effect:
        # On s'assure que le manager existe avant de l'appeler.
        if VisualEffectsManager:
            VisualEffectsManager.register_gravity_source(self)
            # On ne démarre la pulsation que si l'effet existe.
            self.current_gravity_strength = plant_data.gravity_effect.gravity_influence
            _start_pulse()


const GROWTH_PART      := 0.50   # 50 % du temps = apparition
const FILL_PART        := 0.40   # 40 % = remplissage
const PAUSE_PART       := 0.10   # 10 % = suspense

func _start_water_sphere_animation() -> void:
    var dur := plant_data.water_pulse_effect.pulse_duration
    var t   := create_tween()

    # 1. Apparition : growth 0 → 1
    t.tween_property(water_sphere.material, "shader_parameter/growth",
        1.0, dur * GROWTH_PART).from(0.0)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    # 2. Remplissage : fill_amount 0 → 1
    t.tween_property(water_sphere.material, "shader_parameter/fill_amount",
        1.0, dur * FILL_PART).from(0.0)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    # 3. Pause dramatique
    t.tween_interval(dur * PAUSE_PART)

    # 4. Explosion
    t.tween_callback(_burst_water_sphere)

func _burst_water_sphere() -> void:
    water_burst_particles.emitting = true

    # Mouille le sol labouré
    if wetness_overlay:
        var c := wetness_overlay.local_to_map(
            wetness_overlay.to_local(global_position))
        SoilManager.add_wet_area(c, plant_data.water_pulse_effect.pulse_radius)

    # Fade‑out synchronisé des deux paramètres
    var t := create_tween()
    t.tween_property(water_sphere.material, "shader_parameter/growth",
        0.0, 0.4).set_trans(Tween.TRANS_SINE)
    t.parallel().tween_property(water_sphere.material, "shader_parameter/fill_amount",
        0.0, 0.4).set_trans(Tween.TRANS_SINE)

    # Quand le fade est fini → mini pause → cycle suivant
    t.tween_callback(func():
        await get_tree().create_timer(0.2).timeout
        _start_water_sphere_animation()
    )









func get_current_gravity_strength() -> float:
    # Si la plante est morte ou l'effet inactif, retourne 0
    if is_dead or not (plant_data.gravity_effect and plant_data.gravity_effect.has_gravity_effect):
        return 0.0
    return current_gravity_strength

# --------------------------------------------------------------------
# 1. Animation pulsante de la gravité (shader overlay)
# --------------------------------------------------------------------
func _start_pulse() -> void:
    var base := plant_data.gravity_effect.gravity_influence
    # On crée un tween qui va boucler. Par défaut, il est séquentiel.
    var tw := create_tween().set_loops()
    
    # Étape 1: La force monte de (base * 0.5) à (base * 1.5) en 2 secondes.
    tw.tween_method(func(s): current_gravity_strength = s, base * 0.5, base * 1.5, 2.0)
    
    # Étape 2: La force redescend de (base * 1.5) à (base * 0.5) en 2 secondes.
    tw.tween_method(func(s): current_gravity_strength = s, base * 1.5, base * 0.5, 2.0)

# --------------------------------------------------------------------
# 2. Halo lumineux « shimmer »
# --------------------------------------------------------------------
func start_shimmer_animation() -> void:
    # On lit les valeurs depuis la sous-ressource
    var base_energy := plant_data.light_effect.light_emission
    var low  := base_energy * plant_data.light_effect.shimmer_min_factor
    var high := base_energy * plant_data.light_effect.shimmer_max_factor
    var dur  := plant_data.light_effect.shimmer_duration

    var t := create_tween().set_loops()
    t.tween_property(light_emitter, "energy", high, dur).from(low).set_trans(Tween.TRANS_SINE)
    t.tween_property(light_emitter, "energy", low,  dur).set_trans(Tween.TRANS_SINE)

# --------------------------------------------------------------------
# 3. Changements de stade de croissance
# --------------------------------------------------------------------
func on_growth_stage_changed(stage: int) -> void:
    var anim := "stage_" + str(stage)
    if animated_sprite.sprite_frames.has_animation(anim):
        animated_sprite.play(anim)

    # Gravité : ne s’active qu’au stade final
    if stage == growth_cycle_component.total_stages - 1:
        flowering_particles.emitting = true
        

       
        

# --------------------------------------------------------------------
# 4. Arrosage (hurt avec outil arrosoir)
# --------------------------------------------------------------------
func on_hurt(item_used : ItemData) -> void:
    if growth_cycle_component.is_watered_today:
        return

    watering_particles.emitting = true
    growth_cycle_component.set_watered_state(true)

    var tile := wetness_overlay.local_to_map(
        wetness_overlay.to_local(global_position)
    )
    SoilManager.add_wet_tile(tile)

    await get_tree().create_timer(1.0).timeout
    watering_particles.emitting = false

# --------------------------------------------------------------------
# 5. Récolte
# --------------------------------------------------------------------
func on_crop_harvesting() -> void:
    # On vérifie si le nœud existe avant de l'utiliser

    
    var anim := "stage_" + str(growth_cycle_component.total_stages)
    if animated_sprite.sprite_frames.has_animation(anim):
        animated_sprite.play(anim)
    collectable_component.monitoring = true
    

# --------------------------------------------------------------------
# 6. Nettoyage quand la plante est supprimée
# --------------------------------------------------------------------
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        

            
        # Si la plante avait un effet de gravité, elle se désenregistre proprement.
        if plant_data and plant_data.gravity_effect and plant_data.gravity_effect.has_gravity_effect:
            if Engine.has_singleton("VisualEffectsManager"):
                VisualEffectsManager.unregister_gravity_source(self)
        
        # On désenregistre aussi du CropManager.
        if wetness_overlay:
            var tile := wetness_overlay.local_to_map(
                wetness_overlay.to_local(global_position)
            )
            CropManager.unregister_crop(tile)


func _process(delta: float) -> void:
    # Si la plante est morte, on ne fait plus aucun calcul
    if is_dead:
        return

    # 1. Obtenir les valeurs actuelles de l'environnement
    var eff = EnvironmentManager.get_local_effects(global_position)
    
    # 2. On initialise nos totaux pour ce 'tick'
    var total_stress_damage: float = 0.0
    var total_growth_bonus: float = 0.0 # On va calculer un bonus, pas un modificateur
    
    # --- NOUVELLE LOGIQUE UNIFIÉE ---

    # Chaleur
    var heat_sensitivity = plant_data.heat_effect.heat_sensitivity
    var heat_impact = eff.heat * heat_sensitivity
    total_stress_damage += max(0, -heat_impact) # Le stress est l'opposé de l'impact négatif
    total_growth_bonus += max(0, heat_impact) # Le bonus est l'impact positif

    # Oxygène
    var oxygen_sensitivity = plant_data.oxygen_effect.oxygen_sensitivity
    var oxygen_impact = eff.oxygen * oxygen_sensitivity
    total_stress_damage += max(0, -oxygen_impact)
    total_growth_bonus += max(0, oxygen_impact)

    # Gravité
    var gravity_sensitivity = plant_data.gravity_effect.gravity_sensitivity
    var gravity_impact = eff.gravity * gravity_sensitivity
    total_stress_damage += max(0, -gravity_impact)
    total_growth_bonus += max(0, gravity_impact)

    # 3. Appliquer le stress et le bonus
    if total_stress_damage > 0:
        health -= total_stress_damage * delta
        print("Santé actuelle de la plante : ", health)
    
    # On met le modificateur de croissance à 1.0 (normal) + le bonus total
    # Le 0.1 est un facteur d'équilibrage que vous pouvez ajuster
    growth_cycle_component.growth_modifier = 1.0 + (total_growth_bonus * 0.1)

    # 4. Mettre à jour l'UI
    update_ui()
    
    # 5. Vérifier la mort
    if health <= 0:
        die()
        
        
func die() -> void:
    print("%s est morte." % plant_data.item_name)
    is_dead = true
    health = 0
    
    # Joue l'animation de la plante morte
    if animated_sprite.sprite_frames.has_animation("stage_dead"):
        animated_sprite.play("stage_dead")
    
    # Désactive la possibilité de la récolter
    collectable_component.monitoring = false
    
    # On cache l'UI
    if health_bar:
        health_bar.visible = false
    if status_icons_container:
        status_icons_container.visible = false

func update_ui() -> void:
    if not health_bar: return

    # Mettre à jour la valeur de la barre
    health_bar.value = health
    
    # Afficher la barre uniquement si la plante a perdu de la vie ET n'est pas morte
    health_bar.visible = (health < max_health and not is_dead)

    # --- Logique pour les icônes de statut (simplifiée) ---
    # Vous aurez besoin d'un ou plusieurs TextureRect dans le HBoxContainer
    # var buff_icon = $StatusIconsContainer/BuffIcon
    # var debuff_icon = $StatusIconsContainer/DebuffIcon
    #
    # if growth_cycle_component.growth_modifier > 1.1: # Si on a un bon bonus
    #     status_icons_container.visible = true
    #     buff_icon.visible = true
    # else:
    #     buff_icon.visible = false
    #
    # if health < max_health: # Si on subit des dégâts
    #     status_icons_container.visible = true
    #     debuff_icon.visible = true
    # else:
    #     debuff_icon.visible = false
