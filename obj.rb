File.open("1.obj", "w") do |big1|
File.open("2.obj", "w") do |big2|
  targets = [big1, big2].map{ |_| Struct.new(:file, :shift).new _, 0 }
  Dir.glob("l10u_bunker.objs/*").tap{ |rooms| puts "#{rooms.size} rooms" }.sort_by{ |_| File.basename(_).to_i }.each do |room|
    text = File.read(room).gsub "\r\n", "\n"
    col = text.scan(/^v \S+ (\S+) \S+/).map{ |_,| _.to_i }
    target = col.inject(:+).fdiv(col.size) < -12 ? targets[0] : targets[1]
    room_shift = 0
    text[/\A(?:.*\n){2}((?:g \d+\nusemtl [a-zA-Z_0-9-]+\n(?:[^g].+\n)+)+)\z/,1].scan(/^g.+\n.+ (.+)\n((?:[^g].+\n)+)/).
        tap{ |groups| puts "room #{room} :: #{`wc -l #{room}`.split.first} lines :: #{groups.size} groups" }.each do |name, data|
      data.scan(/((\S+) (.+))/).tap do |lines|
        # puts "group '#{name}' :: #{data.size} bytes :: #{lines.size} lines"
      end.each do |all, keyword, string|
        case keyword
        when "v" ; target.file.puts all ; room_shift += 1
        when "f" ; target.file.puts "f #{all.scan(/ \d+/).map{ |_| _.to_i + target.shift }.join " "}"
        when "vt", "vn", "vg", "vb"
        else ; fail keyword
        end
      end
    end
    target.shift += room_shift
  end
end
end

__END__

require "unicode_plot"
t = Dir.glob("l10u_bunker.objs/*").flat_map do |room|
  File.read(room).gsub("\r\n", "\n").scan(/^v (\S+) (\S+) (\S+)/).map{ |_| _.map &:to_i }
end
t.transpose.each{ |_| UnicodePlot.histogram(_, nbins: 20).render }
