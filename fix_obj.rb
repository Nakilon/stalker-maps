puts "#{`grep "^o " #{ARGV[0]} | wc -l`.strip} objects to parse"
vertices = []
shift = 0

object_count = 0
group_count = 0
mtl_count = 0
File.open(ARGV[1], "w") do |obj|
  File.open(ARGV[0]).each do |line|
    fail unless line[" "]
    /\A(?<all>(?<keyword>\S+) (?<string>.+))\n\z/ =~ line
    fail unless $&
    case keyword
    when "#", "vt", "vn"
    when "mtllib"
      fail unless "mtllib ogfmodel.mtl" == all
    when "o"
      object_count += 1
      puts "#{object_count} objects parsed so far..." if (object_count % 1000).zero?
      shift = vertices.size
      fail string unless string[/\A[a-zA-Z0-9-]+\z/]
    when "g"
      group_count += 1
    when "usemtl"
      mtl_count += 1
    when "v"
      x, z, y = string.split.map(&:to_f)
      vertices.push [-x, z, y]
      obj.puts "v #{(-x).round 3} #{z.round 3} #{y.round 3}"
    when "f"
      vs = all.scan(/(?<= )(\d+)\S+/).map{ |_,| _.to_i + shift }
      fail unless 3 == vs.size
      if false  # just a check
        (x1, z1, y1), (x2, z2, y2), (x3, z3, y3) = vs.map{ |_| vertices[_ - 1] }
        a1, a2, a3, b1, b2, b3, c1, c2, c3 = x2-x1, y2-y1, z2-z1, x3-x1, y3-y1, z3-z1, x3-x2, y3-y2, z3-z2
        s1, s2, s3 = a2*b3 - a3*b2, a3*b1 - a1*b3, a1*b2 - a2*b1
        fail if s1.zero? && s2.zero? && s3.zero?
      end
      obj.puts "f #{vs.reverse.join " "}"
    else
      fail keyword
    end
  end
end
puts "groups: #{group_count}"
puts "objects: #{object_count}"
puts "materials: #{mtl_count}"
fail unless group_count == object_count
fail unless group_count == mtl_count

puts "vertices: #{vertices.size}"
puts "faces: #{`grep "^f " #{ARGV[1]} | wc -l`.strip}"
