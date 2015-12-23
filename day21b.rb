MY_HIT_POINTS = 100

# Puzzle input
BOSS_HIT_POINTS = 109
BOSS_DAMAGE = 8
BOSS_ARMOR = 2

Gear = Struct.new(:name, :cost, :damage, :armor) do
  def <=>(other)
    name <=> other.name
  end
end

# Parse gear data.

weapons, armor, rings = DATA.read.split("\n\n").map { |raw|
  data_lines = raw.lines[1..-1]
  data_lines.map { |line|
    name, cost, damage, armor = line.strip.split(/\s\s+/)
    Gear.new(name, cost.to_i, damage.to_i, armor.to_i)
  }
}

# Gear combos.
# * Must buy exactly 1 weapon
# * May buy 0-1 armor
# * May buy 0-2 rings (not the same)

ring_combos = rings.product(rings).
  map { |x, y| x == y ? [ x ] : [ x, y ] }.  # Can't pair with yourself.
  uniq(&:sort)  # [ a, b ] and [ b, a ] are the same pair.

combos = weapons.
  product([nil, *armor]).
  product([nil, *ring_combos])

combos = combos.map { |combo| combo.flatten.compact }
sorted_combos = combos.sort_by { |combo| combo.map(&:cost).inject(:+) }.reverse

Fighter = Struct.new(:name, :hit_points, :damage, :armor) do
  def use_gear(gear)
    self.damage += gear.map(&:damage).inject(:+)
    self.armor += gear.map(&:armor).inject(:+)
  end

  def receive_damage(other)
    damage = [ other.damage - armor, 1 ].max
    self.hit_points -= damage
    alive?
  end

  def alive?
    hit_points > 0
  end
end

def do_i_win?(me, boss)
  loop do
    boss.receive_damage(me) || break
    me.receive_damage(boss) || break
  end

  me.alive?
end

sorted_combos.each do |gear_combo|
  me = Fighter.new("Me", MY_HIT_POINTS, 0, 0)
  me.use_gear(gear_combo)

  boss = Fighter.new("Boss", BOSS_HIT_POINTS, BOSS_DAMAGE, BOSS_ARMOR)

  unless do_i_win?(me, boss)
    puts "I finally lost! It cost me #{gear_combo.map(&:cost).inject(:+)}."
    p gear_combo
    break
  end
end

__END__
Weapons:    Cost  Damage  Armor
Dagger        8     4       0
Shortsword   10     5       0
Warhammer    25     6       0
Longsword    40     7       0
Greataxe     74     8       0

Armor:      Cost  Damage  Armor
Leather      13     0       1
Chainmail    31     0       2
Splintmail   53     0       3
Bandedmail   75     0       4
Platemail   102     0       5

Rings:      Cost  Damage  Armor
Damage +1    25     1       0
Damage +2    50     2       0
Damage +3   100     3       0
Defense +1   20     0       1
Defense +2   40     0       2
Defense +3   80     0       3
