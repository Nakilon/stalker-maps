zs = [nil]
File.open("1.obj", "w") do |obj1| range1 = -5..10
File.open("2.obj", "w") do |obj2| range2 = 11.5..22
  STDIN.each do |line|
    /\A(?<all>(?<keyword>\S+) (?<string>.+))\n\z/ =~ line
    fail unless $&
    case keyword
    when "v"
      obj1.puts line
      obj2.puts line
      _, z, _ = string.split.map(&:to_f)
      zs.push z
    when "f"
      vs = string.scan(/\d+/).map &:to_i
      obj = nil
      obj = obj1 if vs.all?{ |_| range1.include? zs[_] }
      obj = obj2 if vs.all?{ |_| range2.include? zs[_] }
      obj.puts all if obj
    else
      fail keyword
    end
  end
end
end

__END__

require "unicode_plot"
UnicodePlot.histogram(
  STDIN.read.scan(/^v (\S+) (\S+) (\S+)/).map{ |_, z, _| z.to_i }.select{ |_| _ < 40 },
  nbins: 30,
).render
