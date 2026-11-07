// DUELMIND Isobar V1 — WindBot Ignite deck executor.
// Copyright (c) custom archetype authors. Standalone source to integrate
// into the AGPL-3.0-or-later WindBot Ignite project.
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;
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
        // Duelmind IPC bridge (optional): only selects among the exact
        // legally offered choices. If the Python service is down, WindBot's
        // original DefaultExecutor decision logic is used as a fallback.
        [DataContract]
        private sealed class Decision
        {
            [DataMember(Name = "action_id")]
            public string ActionId { get; set; }

            [DataMember(Name = "error")]
            public string Error { get; set; }
        }

        private static bool IsPriorityOwnCard(int id)
        {
            return id == C.Argen || id == C.Observatory ||
                id == C.Journal || id == C.Nova || id == C.Bastion ||
                id == C.Hawk || id == C.Tempest;
        }

        private int AskDuelmind(IList<ClientCard> cards, string kind)
        {
            if (cards == null || cards.Count == 0 || cards.Count > 512)
                return -1;
            var message = new StringBuilder(200 + cards.Count * 135);
            message.Append("{\"protocol\":\"duelmind.v1\",\"public_state\":{");
            message.Append("\"phase\":\"").Append(Duel.Phase.ToString().ToLowerInvariant()).Append("\",");
            message.Append("\"going_first\":").Append(Duel.IsFirst ? "true" : "false").Append(",");
            message.Append("\"own_monster_count\":").Append(Bot.GetMonsterCount()).Append(",");
            message.Append("\"opponent_monster_count\":").Append(Enemy.GetMonsterCount()).Append(",");
            message.Append("\"hand_count\":").Append(Bot.Hand.Count);
            message.Append("},\"legal_actions\":[");
            for (int i = 0; i < cards.Count; i++)
            {
                if (i != 0) message.Append(",");
                var card = cards[i];
                message.Append("{\"action_id\":\"").Append(i).Append("\",");
                message.Append("\"kind\":\"").Append(kind).Append("\",");
                message.Append("\"card_id\":").Append(card.Id).Append(",");
                message.Append("\"target\":{\"high_value\":");
                // Only use visible candidate metadata or own known cards;
                // never disclose opponent hidden deck/hand information.
                bool priority = card.Controller == 0 && IsPriorityOwnCard(card.Id);
                message.Append(priority ? "true" : "false").Append("}}");
            }
            message.Append("]}");
            try
            {
                using (var tcp = new TcpClient())
                {
                    var pending = tcp.BeginConnect("127.0.0.1", 28741, null, null);
                    using (pending.AsyncWaitHandle)
                    {
                        if (!pending.AsyncWaitHandle.WaitOne(150))
                            return -1;
                    }
                    tcp.EndConnect(pending);
                    tcp.ReceiveTimeout = 200;
                    tcp.SendTimeout = 200;
                    using (var stream = tcp.GetStream())
                    {
                        byte[] request = Encoding.UTF8.GetBytes(message.ToString() + "\n");
                        stream.Write(request, 0, request.Length);
                        using (var reader = new StreamReader(stream, Encoding.UTF8, false, 1024, true))
                        {
                            string response = reader.ReadLine();
                            if (response == null || response.Length > 32768)
                                return -1;
                            using (var input = new MemoryStream(Encoding.UTF8.GetBytes(response)))
                            {
                                var serializer = new DataContractJsonSerializer(typeof(Decision));
                                var selected = (Decision)serializer.ReadObject(input);
                                int index;
                                if (selected == null || selected.Error != null ||
                                    !int.TryParse(selected.ActionId, out index) ||
                                    index < 0 || index >= cards.Count)
                                    return -1;
                                return index;
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                // The AI should remain playable even when the local
                // Python server is closed or temporarily unavailable.
                return -1;
            }
        }

        public override IList<ClientCard> OnSelectCard(IList<ClientCard> cards, int min, int max, long hint, bool cancelable)
        {
            if (cards == null || cards.Count == 0 || min != 1 || max != 1)
                return base.OnSelectCard(cards, min, max, hint, cancelable);
            int index = AskDuelmind(cards, "select_card");
            if (index < 0)
                return base.OnSelectCard(cards, min, max, hint, cancelable);
            return new List<ClientCard> { cards[index] };
        }

        public override ClientCard OnSelectAttacker(IList<ClientCard> attackers, IList<ClientCard> defenders)
        {
            if (attackers == null || attackers.Count == 0)
                return base.OnSelectAttacker(attackers, defenders);
            int index = AskDuelmind(attackers, "select_card");
            return index >= 0 ? attackers[index] : base.OnSelectAttacker(attackers, defenders);
        }

    }
}
