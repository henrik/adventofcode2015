defmodule AoC do
  defmodule Spell do
    defstruct [name: "Unnamed", cost: nil, turns: 0, instantly: [], effect_start: [], effect_each: [], effect_end: []]

    def all do
      [
        %Spell{name: "Magic Missile", cost: 53, turns: 0, instantly: [damage: 4]},
        %Spell{name: "Drain", cost: 73, turns: 0, instantly: [damage: 2, heal: 2]},
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
    @known_bad 9999

    def run do
      start_agent
      unstarted_fight = Fight.new

      costs = for next_spell <- Spell.all, do: run(next_spell, unstarted_fight)
      IO.inspect cost: Enum.min(costs)
    end

    def run(this_spell, fight) do
      fight_result = Fight.run(this_spell, fight)

      known_min = get_min

      case fight_result do
        %Fight{cost: cost} when cost >= known_min ->
          known_min
        %Fight{state: :invalid} ->
          @known_bad
        %Fight{state: :ongoing} ->
          costs = for next_spell <- Spell.all, do: run(next_spell, fight_result)
          new_min = Enum.min(costs)

          set_min min(new_min, known_min)

          new_min
        %Fight{state: :won} = fight ->
          fight.cost
        %Fight{state: :lost} ->
          @known_bad
      end
    end

    defp start_agent, do: Agent.start_link(fn -> @known_bad end, name: __MODULE__)
    defp set_min(value), do: Agent.update(__MODULE__, fn _ -> value end)
    defp get_min, do: Agent.get(__MODULE__, &(&1))
  end

  def run do
    Runner.run
  end
end

AoC.run
