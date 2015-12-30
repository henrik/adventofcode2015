defmodule AoC do
  defmodule Spell do
    defstruct [name: "Unnamed", cost: nil, turns: 0, instantly: [], effect_start: [], effect_each: [], effect_end: []]

    def all do
      [
        %Spell{name: "Magic Missile", cost: 53, turns: 0, instantly: [damage: 4]},
        # Commented this out after realizing it's probably never a good choice (since the net result is that the boss does you more net damage.)
        #%Spell{name: "Drain", cost: 73, turns: 0, instantly: [damage: 2, heal: 2]},
        %Spell{name: "Shield", cost: 113, turns: 6, effect_start: [armor: 7], effect_end: [armor: -7]},
        %Spell{name: "Poison", cost: 173, turns: 6, effect_each: [damage: 3]},
        %Spell{name: "Recharge", cost: 229, turns: 5, effect_each: [mana: 101]},
      ]
    end
  end

  defmodule Player do
    defstruct [name: "Unnamed", hp: 0, damage: 0, mana: 0, armor: 0]

    def me, do: %Player{name: "Me", hp: 50, mana: 500}
    def boss, do: %Player{name: "Boss", hp: 51, damage: 9}

    def do_damage(recipient, 0), do: recipient
    def do_damage(recipient, damage) do
      actual_damage = max(1, damage - recipient.armor)
      new_hp = recipient.hp - actual_damage
      %Player{recipient|hp: new_hp}
    end

    def heal(recipient, amount) do
      %Player{recipient|hp: recipient.hp + amount}
    end
  end

  defmodule Fight do
    defstruct [me: nil, boss: nil, effects: [], state: :unknown, cost: 0]

    def new do
      %Fight{me: Player.me, boss: Player.boss}
    end

    def run(spell, previous_state) do
      %Fight{me: me, boss: boss, cost: cost, effects: effects} = previous_state

      # Player's turn.

      {me, boss, effects} = apply_effects(me, boss, effects)
      invalid_spell? = Enum.any?(effects, &(&1.name == spell.name))
      {me, boss, effects} = cast_spell(me, boss, effects, spell)

      # Boss's turn.

      {me, boss, effects} = apply_effects(me, boss, effects)
      me = Player.do_damage(me, boss.damage)

      # Now calculate some other stuff.

      new_cost = cost + spell.cost

      new_state =
        cond do
          invalid_spell? ->
            :invalid
          me.mana < 0 ->
            :invalid
          boss.hp <= 0 ->
            :won
          me.hp <= 0 ->
            :lost
          me.mana == 0 ->
            :lost
          true ->
            :ongoing
        end

      fight = %Fight{me: me, boss: boss, state: new_state, effects: effects, cost: new_cost}
      #IO.inspect spell: spell, fight_ends_as: fight
      fight
    end

    defp cast_spell(me, boss, effects, spell) do
      # Instant effects.
      instant_damage = Dict.get spell.instantly, :damage, 0
      instant_healing = Dict.get spell.instantly, :heal, 0
      boss = Player.do_damage(boss, instant_damage)
      me = Player.heal(me, instant_healing)

      # Apply effects.
      effect_armor = Dict.get spell.effect_start, :armor, 0
      me = %Player{me|armor: me.armor + effect_armor}
      effects = if spell.turns > 0, do: [spell|effects], else: effects

      # Cost of spell.
      me = %Player{me|mana: me.mana - spell.cost}

      {me, boss, effects}
    end

    defp apply_effects(me, boss, effects) do
      # Run any effect_each.
      {me, boss} = Enum.reduce effects, {me, boss}, fn(spell, {me, boss}) ->
        mana = Dict.get spell.effect_each, :mana, 0
        damage = Dict.get spell.effect_each, :damage, 0

        me = %Player{me|mana: me.mana + mana}
        boss = Player.do_damage(boss, damage)

        {me, boss}
      end

      # Decrement counts.
      effects = Enum.map effects, fn(s) -> %Spell{s|turns: s.turns - 1} end

      # Remove any expired effects (and run effect_end).
      {expired_effects, remaining_effects} = Enum.partition(effects, fn(s) -> s.turns == 0 end)
      me = Enum.reduce expired_effects, me, fn(spell, me) ->
        armor = Dict.get spell.effect_end, :armor, 0
        %Player{me|armor: me.armor + armor}
      end

      {me, boss, remaining_effects}
    end
  end

  defmodule Runner do
    def run do
      all_spells = Spell.all
      unstarted_fight = Fight.new

      for next_spell <- all_spells, do: run_async(all_spells, next_spell, unstarted_fight)
    end

    def run(all_spells, this_spell, fight) do
      fight_result = Fight.run(this_spell, fight)

      case fight_result do
        %Fight{state: :invalid} ->
          :noop
          #IO.write [IO.ANSI.yellow, "x", IO.ANSI.reset]
        %Fight{state: :ongoing} = fight_state ->
          #IO.puts "go on"
          for next_spell <- all_spells, do: run_async(all_spells, next_spell, fight_state)
        %Fight{state: :won} = fight ->
          IO.puts [IO.ANSI.green, "won! ", IO.ANSI.reset, " ", inspect(fight)]
          IO.puts "won?!"
        %Fight{state: :lost} ->
          #IO.write [IO.ANSI.red, ".", IO.ANSI.reset]
          :noop
          #IO.puts [IO.ANSI.red, "lose", IO.ANSI.reset]
      end
    end

    def run_async(all_spells, this_spell, fight_state) do
      # Temp for debug
      # TODO: sleep makes it return an answer sooner. because of depth vs breadth?
      :timer.sleep 500
      Task.async(fn -> Runner.run(all_spells, this_spell, fight_state) end)
    end
  end

  def run do
    IO.puts "Running infinitely. Ctrl+C when happy…"
    Runner.run
    :timer.sleep :infinity
  end
end

AoC.run
