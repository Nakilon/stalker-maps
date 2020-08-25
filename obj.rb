require "pp"
File.open("big.obj", "w") do |big|
  Dir.glob("l10u_bunker.objs/*").tap{ |rooms| puts "#{rooms.size} rooms" }.sort.each do |room|
    File.read(room).gsub("\r\n", "\n")[/\A(?:.*\n){2}((?:g \d+\nusemtl [a-zA-Z_0-9-]+\n(?:[^g].+\n)+)+)\z/,1].
                                                  scan(/^g.+\n.+ (.+)\n((?:[^g].+\n)+)/).
        tap{ |groups| puts "room #{room} :: #{`wc -l #{room}`.split.first} lines :: #{groups.size} groups" }.each do |name, data|
      data.scan(/(\S+) (.+)/).tap{ |lines| puts "group '#{name}' :: #{data.size} bytes :: #{lines.size} lines" }.each do |keyword, string|
        p [keyword, string]
        abort
      end
      abort
    end
    abort
  end
end

