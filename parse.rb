require "pp"

require "base64"
read = File.read(ARGV[0], encoding: "CP1251").encode "utf-8", "cp1251"
magic = ([*?a..?z].product([*?a..?z]) - read.chars.each_cons(2).to_a).first.join
all = read.gsub("\r\n", "\n").gsub(/<<END\n(.*?)\nEND/m){ |_| magic + Base64.strict_encode64(_) }.split(/^\[.*/).drop(1).map do |item|
  item.scan(/.+/).map do |line|
    case line # parsing with no errors
    when /\A; \S/, /\A;{67}\z/
    when "section_name = smart_terrain" ; break []
    when "section_name = actor" ; break []
    when "section_name = lights_hanging_lamp" ; break []
    when "section_name = device_torch" ; break []
    when "section_name = harmonica_a" ; break []
    when "section_name = explosive_barrel" ; break []
    when "section_name = zone_flame_small" ; break []
    when "section_name = level_changer" ; break []
    when "section_name = helicopter" ; break []
    when "section_name = device_pda" ; break []
    when "visual_name = physics\\decor\\vedro_01" ; break []
    when "visual_name = physics\\large_trash\\poddon" ; break []
    when "visual_name = physics\\balon\\bochka_close_1" ; break []
    when "visual_name = physics\\decor\\prt\\bottle_bar_1_prt0" ; break []
    when "visual_name = physics\\decor\\ventilator_01" ; break []
    when "visual_name = physics\\decor\\priemnik_gorizont" ; break []
    when "name = esc_matugalnik" ; break []
    when /\Aname = trader_physic_object\d+\z/ ; break []
    when /\Aname = meshes\\brkbl#\d+\.ogf\z/ ; break []
    when /\Aname = clmbl#\d\d?\z/ ; break []
    when "s_gameid = 0x1"
    when /\Abone_\d\d?:[a-z_]+ = \S/
    when /\Ashape_\d:[a-z_]+ = \S/
    when /\Ajob_\d\d?:[a-z_]+ = \S/
    when /\Aupd:ammo_ids =( 0, 0)?\z/
    when /\AstateBegin = [\d:]+\z/
    when /\Ainfo_\d\d?:[A-Za-z_]+ = [\d:]+\z/
    when /\A(name) = ([a-z_\d\.]+)\z/ ; [$1, $2]
    when /\A(visual_name) = ([A-Za-z_\d\\-]+)\z/ ; [$1, $2.downcase]
    when /\A(specific_character) = ([a-z_\d]+)\z/ ; [$1, $2]
    when /\A(character_name) = ([А-Яа-яё ]+)\z/ ; [$1, $2]
    when /\A(section_name) = ([a-z_\d\.]+)\z/ ; [$1, $2]
    when /\A(dest_level_name) = ([A-Za-z_\d]+)\z/ ; [$1, $2.downcase]
    when /\A(custom_data) = (cond = 0\.2)\z/ ; [$1, $2]
    when /\A(custom_data) = (\[dont_spawn_character_supplies\])\z/
    when /\Asquad_id = \S/
    when /\Avisual_flags = 0x1\z/
    when /\Aspawned_obj = (\d+(, \d+)*)?\z/
    when "upd:quaternion = -1, -1, 1, -1"
    when /\A[a-z_:]+ = ?\z/
    when /\A([a-z_:]+) = (\S.*)/
      next if %w{
        s_flags object_flags light_flags
        bones_mask bbox_min bbox_max upd:timestamp s_gameid physic_type fixed_bones main_color_animator glow_texture ambient_texture
        equipment_preferences main_weapon_preferences
        s_rp upd:num_items upd:creature_flags artefact_position_offset dest_graph_point
        duration_end motion_name engine_sound main_color
      }.include? $1 # not interesting?
      [$1, case v = $2
      when /\A\d+\z/ ; v.to_i
      when /\A-?\d+\.\d+\z/ ; v.to_f
      when /\A[a-z_]+\z/ ; v
      when /\A(-?\d+(?:\.\d+(?:e-\d+)?)?), (-?\d+(?:\.\d+(?:e[-+]\d+)?)?), (-?\d+(\.\d+(e-\d+)?)?)\z/ ; [$1.to_f, $2.to_f, $3.to_f]
      when /\A#{magic}/
        data = Base64.strict_decode64(v[2..-1])
        break [] if [
          "<<END\n[collide]\nignore_static\nEND",
          "<<END\n[collide]\nignore_static\n\n[logic]\ncfg = scripts\\door_metal_small.ltx\nEND",
          "<<END\n[collide]\nignore_static\n\n[logic]\ncfg = scripts\\door_metal_small_unlocked.ltx\nEND",
        ].include? data
        data[6..-4].scan(/\[([^\]]*)\]\n(.*?)\n(?=\[|\z)/m).map do |name, data|
          [name, data.split(?\n)]
        end
      else ; fail line.inspect
      end ]
    else ; fail line.inspect
    end
  end.compact.to_h.reject do |k,| # rejecting parsed but not interesting data
    %w{
      condition
      version script_version
      distance shapes restrictor_type direction mass
      game_vertex_id level_vertex_id
      offline_interactive_radius skeleton_flags root_bone bones_count
      spawn_id upd:torch_flags max_power artefact_spawn_count
      g_team g_group g_squad
      ammo_current ammo_elapsed ammo_left
      character_profile specific_character
      enabled_time disabled_time start_time_shift
      reputation money rank
      smart_terrain_id smart_terrain_task_active job_online
      spawned_obj trader_flags
      base_out_restrictors weapon_state
    }.include? k or /\Aupd:/ =~ k && k != "upd:health"
  end
end - [{}]

require "yaml"
puts YAML.dump all

require "mll"
PP.pp MLL::tally[all.flat_map &:keys].sort_by(&:last).first(15), STDERR

STDERR.puts "OK"
