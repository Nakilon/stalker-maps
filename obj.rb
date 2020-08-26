File.open("big.obj", "w") do |big|
  shift = 0
  Dir.glob("l10u_bunker.objs/*").tap{ |rooms| puts "#{rooms.size} rooms" }.sort_by{ |_| File.basename(_).to_i }.each do |room|
    room_shift = 0
    File.read(room).gsub("\r\n", "\n")[/\A(?:.*\n){2}((?:g \d+\nusemtl [a-zA-Z_0-9-]+\n(?:[^g].+\n)+)+)\z/,1].
                                                  scan(/^g.+\n.+ (.+)\n((?:[^g].+\n)+)/).
        tap{ |groups| puts "room #{room} :: #{`wc -l #{room}`.split.first} lines :: #{groups.size} groups" }.each do |name, data|
      data.scan(/((\S+) (.+))/).tap do |lines|
        # puts "group '#{name}' :: #{data.size} bytes :: #{lines.size} lines"
      end.each do |all, keyword, string|
        case keyword
        when "v" ; big.puts all ; room_shift += 1
        when "f" ; big.puts "f #{all.scan(/ \d+/).map{ |_| _.to_i + shift }.join " "}"
        when "vt", "vn", "vg", "vb"
        else ; fail keyword
        end
      end
    end
    shift += room_shift
  end
end

