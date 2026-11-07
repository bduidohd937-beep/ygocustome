// DUELMIND Isobar V1 — WindBot Ignite deck executor.
// Copyright (c) custom archetype authors. Standalone source to integrate
// into the AGPL-3.0-or-later WindBot Ignite project.
using WindBot.Game;
using WindBot.Game.AI;
using YGOSharp.OCGWrapper.Enums;

namespace WindBot.Game.AI.Decks
{
    [Deck("DuelmindIsobar", "AI_DuelmindIsobar")]
    public class DuelmindIsobarExecutor : DefaultExecutor
    {
        private static class C
        {
            public const int Argen = 210000201;
            public const int Rain = 210000202;
            public const int Bolt = 210000203;
            public const int Sol = 210000204;
            public const int Nova = 210000205;
            public const int Zephyr = 210000206;
            public const int Hawk = 210000207;
            public const int Bastion = 210000208;
            public const int Tempest = 210000209;
            public const int Observatory = 210000210;
            public const int Front = 210000211;
            public const int Journal = 210000212;
            public const int Alert = 210000213;

            public const int AshBlossom = 14558127;
            public const int EffectVeiler = 97268402;
            public const int BookOfMoon = 14087893;
            public const int InfiniteImpermanence = 10045474;
            public const int TornadoDragon = 6983839;
            public const int AbyssDweller = 21044178;
        }

        public DuelmindIsobarExecutor(GameAI ai, Duel duel) : base(ai, duel)
        {
            // WindBot filters against the duel engine's legally offered actions.
            // No card moves are fabricated outside the duel protocol.

            // Reactive controls. These outrank main-phase development.
            AddExecutor(ExecutorType.Activate, C.Bastion, BastionNegate);
            AddExecutor(ExecutorType.Activate, C.Alert, EnemyHasCards);
            AddExecutor(ExecutorType.Activate, C.InfiniteImpermanence, DefaultInfiniteImpermanence);
            AddExecutor(ExecutorType.Activate, C.AshBlossom, DefaultAshBlossomAndJoyousSpring);
            AddExecutor(ExecutorType.Activate, C.EffectVeiler, DefaultEffectVeiler);
            AddExecutor(ExecutorType.Activate, C.BookOfMoon);
            AddExecutor(ExecutorType.Activate, C.Front, HasWeatherStation);

            // Establish the weather station, then develop Rank 4 material.
            AddExecutor(ExecutorType.Activate, C.Observatory);
            AddExecutor(ExecutorType.Activate, C.Journal);
            AddExecutor(ExecutorType.Summon, C.Argen);
            AddExecutor(ExecutorType.Activate, C.Argen);
            AddExecutor(ExecutorType.SpSummon, C.Nova);
            AddExecutor(ExecutorType.SpSummon, C.Rain);
            AddExecutor(ExecutorType.Activate, C.Zephyr);
            AddExecutor(ExecutorType.SpSummon, C.Zephyr);
            AddExecutor(ExecutorType.Summon, C.Zephyr);
            AddExecutor(ExecutorType.Activate, C.Sol);
            AddExecutor(ExecutorType.Activate, C.Nova);
            AddExecutor(ExecutorType.Activate, C.Rain);
            AddExecutor(ExecutorType.Activate, C.Bolt);

            // Rank-4 priorities: defense first when opponent has no monsters;
            // otherwise bounce threats, then build more resources.
            AddExecutor(ExecutorType.SpSummon, C.Bastion, PreferBastion);
            AddExecutor(ExecutorType.SpSummon, C.Tempest, PreferTempest);
            AddExecutor(ExecutorType.SpSummon, C.Hawk);
            AddExecutor(ExecutorType.Activate, C.Tempest, EnemyHasCards);
            AddExecutor(ExecutorType.Activate, C.Hawk);
            AddExecutor(ExecutorType.Activate, C.Observatory, HasWeatherStation);

            // Backup deck engine actions and conventional fallback.
            AddExecutor(ExecutorType.Summon, C.Bolt);
            AddExecutor(ExecutorType.Summon, C.Sol);
            AddExecutor(ExecutorType.Summon, C.Nova);
            AddExecutor(ExecutorType.Summon, C.Rain);
            AddExecutor(ExecutorType.SpSummon, C.Argen);
            AddExecutor(ExecutorType.SpSummon, C.TornadoDragon);
            AddExecutor(ExecutorType.SpSummon, C.AbyssDweller);
            AddExecutor(ExecutorType.SpellSet, C.Alert);
            AddExecutor(ExecutorType.SpellSet, C.InfiniteImpermanence);
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
            AddExecutor(ExecutorType.SpellSet);
        }

        private bool HasWeatherStation()
        {
            return Bot.HasInSpellZone(C.Observatory, true);
        }

        private bool EnemyHasCards()
        {
            return Enemy.GetMonsterCount() > 0;
        }

        private bool BastionNegate()
        {
            return HasWeatherStation() && !DefaultCheckWhetherCardIsNegated(Card);
        }

        private bool PreferBastion()
        {
            return HasWeatherStation() && Enemy.GetMonsterCount() == 0;
        }

        private bool PreferTempest()
        {
            return Enemy.GetMonsterCount() > 0;
        }
    }
}
