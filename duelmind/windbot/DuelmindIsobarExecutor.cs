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
using System.Text.Json;
using WindBot.Game;
using WindBot.Game.AI;
using YGOSharp.OCGWrapper.Enums;

namespace WindBot.Game.AI.Decks
{
    [Deck("DuelmindIsobar", "AI_DuelmindIsobar")]
    public class DuelmindIsobarExecutor : DefaultExecutor
    {
        private static int _traceCount = 0;

        private static void Trace(string detail)
        {
            try
            {
                if (System.Threading.Interlocked.Increment(ref _traceCount) > 300)
                    return;
                File.AppendAllText(
                    Path.Combine(Path.GetTempPath(), "duelmind-windbot.log"),
                    DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ") + " " + detail + Environment.NewLine);
            }
            catch (Exception)
            {
                // Logging must never interrupt a duel.
            }
        }

        private static string CardName(int id)
        {
            switch (id)
            {
                case C.Argen: return "흑철기상청 - 이소바르 아르젠";
                case C.Rain: return "흑철기상청 - 이소바르 레인";
                case C.Bolt: return "흑철기상청 - 이소바르 볼트";
                case C.Sol: return "흑철기상청 - 이소바르 솔";
                case C.Nova: return "흑철기상청 - 이소바르 노바";
                case C.Zephyr: return "흑철기상청 - 이소바르 제피르";
                case C.Hawk: return "흑철기상청 - 이소바르 솔라 호크";
                case C.Bastion: return "흑철기상청 - 이소바르 스톰바스티온";
                case C.Tempest: return "흑철기상청 - 이소바르 템페스트 제로";
                case C.Observatory: return "흑철기상청 - 중앙관측소";
                case C.Front: return "이소바르의 기압전선";
                case C.Journal: return "이소바르의 관측일지";
                case C.Alert: return "이소바르의 긴급경보";
                case C.Cirrus: return "흑철기상청 - 이소바르 시러스";
                case C.Nimbus: return "흑철기상청 - 이소바르 님버스";
                case C.StormBoundary: return "이소바르의 폭풍경계";
                default: return "알 수 없는 카드";
            }
        }

        private void TraceDecision(IList<DuelmindChoice> choices,
            int selected, bool fallback, string reason)
        {
            try
            {
                var candidates = new List<Dictionary<string, object>>();
                if (choices != null)
                {
                    for (int i = 0; i < choices.Count; i++)
                    {
                        var card = choices[i].Card;
                        int id = card == null || (card.Controller != 0 && !card.IsFaceup()) ? 0 : card.Id;
                        candidates.Add(new Dictionary<string, object> {
                            ["action_id"] = i.ToString(),
                            ["kind"] = choices[i].Kind,
                            ["card_id"] = id,
                            ["card_name"] = CardName(id),
                            ["selected"] = i == selected,
                            ["score"] = null,
                        });
                    }
                }
                var record = new Dictionary<string, object> {
                    ["timestamp"] = DateTime.UtcNow.ToString("o"),
                    ["turn"] = Duel.Turn,
                    ["phase"] = Duel.Phase.ToString(),
                    ["fallback"] = fallback,
                    ["fallback_reason"] = reason,
                    ["selected_index"] = selected,
                    ["candidates"] = candidates,
                    ["execution_result"] = selected >= 0 ? "action_returned_to_windbot" : "no_action_returned",
                };
                File.AppendAllText(Path.Combine(Path.GetTempPath(), "duelmind-decisions.jsonl"),
                    JsonSerializer.Serialize(record) + Environment.NewLine);
            }
            catch (Exception)
            {
                // Diagnostics must never interrupt a duel.
            }
        }
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
            public const int Cirrus = 210000214;
            public const int Nimbus = 210000215;
            public const int StormBoundary = 210000216;

            public const int AshBlossom = 14558127;
            public const int EffectVeiler = 97268402;
            public const int BookOfMoon = 14087893;
            public const int InfiniteImpermanence = 10045474;
            public const int TornadoDragon = 6983839;
            public const int AbyssDweller = 21044178;
        }

        public DuelmindIsobarExecutor(GameAI ai, Duel duel) : base(ai, duel)
        {
            Trace("DUELMIND executor activated; native C# bridge loaded");
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
            AddExecutor(ExecutorType.Activate, C.StormBoundary, EnemyHasCards);

            // Establish the weather station, then develop Rank 4 material.
            AddExecutor(ExecutorType.Activate, C.Observatory);
            AddExecutor(ExecutorType.Activate, C.Journal);
            AddExecutor(ExecutorType.Summon, C.Argen);
            AddExecutor(ExecutorType.Activate, C.Argen);
            AddExecutor(ExecutorType.SpSummon, C.Nova);
            AddExecutor(ExecutorType.SpSummon, C.Rain);
            AddExecutor(ExecutorType.SpSummon, C.Cirrus);
            AddExecutor(ExecutorType.SpSummon, C.Nimbus);
            AddExecutor(ExecutorType.Activate, C.Cirrus);
            AddExecutor(ExecutorType.Activate, C.Nimbus);
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
            AddExecutor(ExecutorType.Summon, C.Cirrus);
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
            return Bot.HasInSpellZone(C.Observatory, true, true);
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
                id == C.Hawk || id == C.Tempest || id == C.Cirrus ||
                id == C.Nimbus || id == C.StormBoundary;
        }

        private int AskDuelmind(IList<ClientCard> cards, string kind)
        {
            if (cards == null || cards.Count == 0)
                return -1;
            var options = new List<DuelmindChoice>();
            foreach (var c in cards)
                options.Add(new DuelmindChoice { Card = c, Kind = kind });
            return AskActionChoices(options);
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

        private sealed class DuelmindChoice
        {
            public ClientCard Card;
            public string Kind;
            public MainPhaseAction Action;
            public int ChainIndex;
        }

        private static Dictionary<string, int> VerifiedEvaluation(DuelmindChoice choice)
        {
            if (choice == null || choice.Card == null)
                return null;
            var result = new Dictionary<string, int>();
            switch (choice.Card.Id)
            {
                case C.Observatory:
                    result["immediate_gain"] = 30;
                    result["follow_up"] = 45;
                    result["weather_synergy"] = 35;
                    result["resource_preservation"] = 25;
                    break;
                case C.Argen:
                    result["immediate_gain"] = 25;
                    result["follow_up"] = 45;
                    result["resource_preservation"] = 20;
                    break;
                case C.Journal:
                    result["follow_up"] = 35;
                    result["resource_preservation"] = 30;
                    break;
                case C.Rain:
                case C.Nova:
                case C.Zephyr:
                case C.Cirrus:
                case C.Nimbus:
                    result["follow_up"] = 35;
                    result["resource_preservation"] = 20;
                    break;
                case C.Hawk:
                    result["follow_up"] = 45;
                    result["resource_preservation"] = 25;
                    result["board_persistence"] = 25;
                    break;
                case C.Bastion:
                    result["interaction"] = 45;
                    result["board_persistence"] = 40;
                    break;
                case C.Tempest:
                    result["interaction"] = 50;
                    result["win_contribution"] = 35;
                    break;
                case C.Front:
                case C.StormBoundary:
                    result["interaction"] = 35;
                    result["weather_synergy"] = 35;
                    break;
                case C.Alert:
                    result["interaction"] = 45;
                    result["board_persistence"] = 25;
                    break;
            }
            return result.Count == 0 ? null : result;
        }

        private int AskActionChoices(IList<DuelmindChoice> choices)
        {
            Trace("python decision requested; choices=" + (choices == null ? 0 : choices.Count));
            if (choices == null || choices.Count == 0 || choices.Count > 512)
            {
                TraceDecision(choices, -1, true, "invalid_or_empty_legal_actions");
                return -1;
            }
            var message = new StringBuilder(600 + choices.Count * 210);
            message.Append("{\"protocol\":\"duelmind.v1\",\"public_state\":{");
            message.Append("\"turn\":").Append(Duel.Turn).Append(",");
            message.Append("\"phase\":\"").Append(Duel.Phase.ToString().ToLowerInvariant()).Append("\",");
            message.Append("\"going_first\":").Append(Duel.IsFirst ? "true" : "false").Append(",");
            message.Append("\"own_monster_count\":").Append(Bot.GetMonsterCount()).Append(",");
            message.Append("\"opponent_monster_count\":").Append(Enemy.GetMonsterCount()).Append(",");
            message.Append("\"hand_count\":").Append(Bot.Hand.Count).Append(",");
            bool hasField = Bot.HasInSpellZone(C.Observatory, true, true);
            message.Append("\"own_field_spell\":").Append(hasField ? "true" : "false").Append(",");
            // The weather flag is stored inside the Lua Field Spell and is not
            // exposed by WindBot's ClientCard API. Keep it explicit so a future
            // engine adapter can fill it without changing the protocol.
            message.Append("\"weather\":\"unknown\",");
            int lv4Count = 0;
            foreach (var c in Bot.MonsterZone)
                if (c != null && c.IsFaceup() && c.IsMonster() && c.Level == 4)
                    lv4Count++;
            message.Append("\"own_level4_count\":").Append(lv4Count).Append(",");
            message.Append("\"chain_from_opponent\":");
            if (Duel.CurrentChain.Count > 0)
                message.Append(Duel.LastChainPlayer == 1 ? "true" : "false");
            else
                message.Append("null");
            message.Append(",");
            bool chainMonster = Duel.CurrentChain.Count > 0 &&
                Duel.CurrentChain[Duel.CurrentChain.Count - 1] != null &&
                Duel.CurrentChain[Duel.CurrentChain.Count - 1].IsMonster();
            message.Append("\"chain_card_is_monster\":").Append(chainMonster ? "true" : "false").Append(",");
            message.Append("\"opponent_threat\":").Append(
                Duel.CurrentChain.Count > 0 && Duel.LastChainPlayer == 1
                    ? 2 : (Enemy.GetMonsterCount() > 0 ? 1 : 0)).Append(",");
            message.Append("\"hand_ids\":[");
            for (int i = 0; i < Bot.Hand.Count; i++)
            {
                if (i > 0) message.Append(",");
                message.Append(Bot.Hand[i].Id);
            }
            message.Append("],\"grave_ids\":[");
            for (int i = 0; i < Bot.Graveyard.Count; i++)
            {
                if (i > 0) message.Append(",");
                message.Append(Bot.Graveyard[i].Id);
            }
            message.Append("]},\"legal_actions\":[");
            for (int i = 0; i < choices.Count; i++)
            {
                if (i > 0) message.Append(",");
                var choice = choices[i];
                var c = choice.Card;
                message.Append("{\"action_id\":\"").Append(i).Append("\",");
                message.Append("\"kind\":\"").Append(choice.Kind).Append("\",");
                message.Append("\"card_id\":").Append(c == null || (c.Controller != 0 && !c.IsFaceup()) ? 0 : c.Id).Append(",");
                int visibleId = c == null || (c.Controller != 0 && !c.IsFaceup()) ? 0 : c.Id;
                message.Append("\"card_name\":").Append(JsonSerializer.Serialize(CardName(visibleId))).Append(",");
                message.Append("\"location\":\"").Append(c == null ? "" :
                    c.Location.ToString().ToLowerInvariant()).Append("\",");
                message.Append("\"controller\":").Append(c == null ? -1 : c.Controller).Append(",");
                bool visible = c != null && (c.Controller == 0 || c.IsFaceup());
                message.Append("\"target\":{\"is_faceup\":").Append(c != null && c.IsFaceup() ? "true" : "false").Append(",");
                message.Append("\"high_value\":").Append(c != null &&
                    c.Controller == 0 && IsPriorityOwnCard(c.Id) ? "true" : "false").Append(",");
                message.Append("\"attack\":").Append(visible ? c.Attack : 0).Append("}}");
                var evaluation = VerifiedEvaluation(choice);
                if (evaluation != null)
                {
                    // Insert the annotation before the closing object. The
                    // target object above is intentionally kept engine-neutral.
                    string suffix = "}";
                    int end = message.Length - suffix.Length;
                    message.Insert(end, ",\"verified_evaluation\":" + JsonSerializer.Serialize(evaluation));
                }
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
                                    index < 0 || index >= choices.Count)
                                {
                                    TraceDecision(choices, -1, true, "invalid_python_response");
                                    return -1;
                                }
                                Trace("python accepted selected index=" + index);
                                TraceDecision(choices, index, false, "python_strategy");
                                return index;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Trace("python connection failed: " + ex.GetType().Name + " " + ex.Message);
                TraceDecision(choices, -1, true, "python_connection_failed");
                return -1;
            }
        }

        // Called only from our guarded WindBot GameAI patch.
        // Candidates are taken from MainPhase, populated by the EDOPro engine.
        public override MainPhaseAction TryDecideMainPhase(MainPhase main)
        {
            Trace("main phase hook invoked");
            if (main == null)
                return null;
            var choices = new List<DuelmindChoice>();
            for (int i = 0; i < main.ActivableCards.Count; i++)
            {
                var c = main.ActivableCards[i];
                var desc = main.ActivableDescs[i];
                int actionIndex;
                if (c.ActionActivateIndex.TryGetValue(desc, out actionIndex))
                    choices.Add(new DuelmindChoice {
                        Card = c, Kind = "activate",
                        Action = new MainPhaseAction(MainPhaseAction.MainAction.Activate, actionIndex)
                    });
            }
            foreach (var c in main.SpecialSummonableCards)
                choices.Add(new DuelmindChoice {
                    Card = c,
                    Kind = c.Location == CardLocation.Extra ? "xyz_summon" : "special_summon",
                    Action = new MainPhaseAction(MainPhaseAction.MainAction.SpSummon, c.ActionIndex)
                });
            foreach (var c in main.SummonableCards)
                choices.Add(new DuelmindChoice {
                    Card = c, Kind = "normal_summon",
                    Action = new MainPhaseAction(MainPhaseAction.MainAction.Summon, c.ActionIndex)
                });
            foreach (var c in main.SpellSetableCards)
                choices.Add(new DuelmindChoice {
                    Card = c, Kind = "set",
                    Action = new MainPhaseAction(MainPhaseAction.MainAction.SetSpell, c.ActionIndex)
                });
            // Give the decision engine a real opportunity to end the turn
            // or enter battle instead of repeatedly setting/activating cards.
            if (main.CanBattlePhase && Bot.HasAttackingMonster())
                choices.Add(new DuelmindChoice {
                    Card = null, Kind = "battle_phase",
                    Action = new MainPhaseAction(MainPhaseAction.MainAction.ToBattlePhase)
                });
            if (main.CanEndPhase)
                choices.Add(new DuelmindChoice {
                    Card = null, Kind = "end_phase",
                    Action = new MainPhaseAction(MainPhaseAction.MainAction.ToEndPhase)
                });
            if (choices.Count == 0)
            {
                Trace("main phase had no legal choices");
                return null;
            }
            int selected = AskActionChoices(choices);
            if (selected >= 0 && selected < choices.Count)
            {
                Trace("main phase selected index=" + selected + " kind=" + choices[selected].Kind +
                    " card=" + (choices[selected].Card == null ? 0 : choices[selected].Card.Id));
                return choices[selected].Action;
            }
            Trace("main phase decision unavailable; using legal fallback");
            int fallbackIndex = FindFallbackIndex(choices);
            TraceDecision(choices, fallbackIndex, true, "python_unavailable_or_invalid");
            return choices[fallbackIndex].Action;
        }

        private MainPhaseAction FallbackMainPhaseAction(IList<DuelmindChoice> choices)
        {
            return choices[FindFallbackIndex(choices)].Action;
        }

        private int FindFallbackIndex(IList<DuelmindChoice> choices)
        {
            if (choices == null || choices.Count == 0)
                return -1;
            foreach (var choice in choices)
                if (choice.Card != null && choice.Card.Id == C.Observatory && choice.Kind == "activate")
                    return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Card != null && (choice.Card.Id == C.Argen || choice.Card.Id == C.Cirrus) &&
                    (choice.Kind == "normal_summon" || choice.Kind == "special_summon"))
                    return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Card != null && (choice.Card.Id == C.Rain || choice.Card.Id == C.Nova ||
                    choice.Card.Id == C.Zephyr || choice.Card.Id == C.Nimbus) &&
                    (choice.Kind == "special_summon" || choice.Kind == "activate"))
                    return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Kind == "xyz_summon")
                    return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Kind == "battle_phase")
                    return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Kind == "end_phase")
                    return choices.IndexOf(choice);
            return 0;
        }

        // EDOPro provided every chain card in this list. An optional 'pass'
        // is represented as a choice, and never sent to the engine as a card.
        public override int TryDecideChain(IList<ClientCard> cards, bool forced)
        {
            Trace("chain hook invoked; forced=" + forced);
            if (cards == null || cards.Count == 0)
                return -2;
            var choices = new List<DuelmindChoice>();
            for (int i = 0; i < cards.Count; i++)
                choices.Add(new DuelmindChoice {
                    Card = cards[i], Kind = "chain", ChainIndex = i
                });
            if (!forced)
                choices.Add(new DuelmindChoice { Card = null, Kind = "pass", ChainIndex = -1 });
            int index = AskActionChoices(choices);
            return index >= 0 ? choices[index].ChainIndex : -2;
        }

    }
}
