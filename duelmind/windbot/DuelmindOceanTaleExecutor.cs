// DUELMIND Ocean Tale V4.1 — WindBot Executor
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
    [Deck("DuelmindOceanTale", "AI_DuelmindOceanTale")]
    public class DuelmindOceanTaleExecutor : DefaultExecutor
    {
        private const string DeckName = "DuelmindOceanTale";
        private const string DeckProfile = "ocean_tale";
        private static int _traceCount;

        private static void Trace(string detail)
        {
            try
            {
                if (System.Threading.Interlocked.Increment(ref _traceCount) > 300)
                    return;
                File.AppendAllText(Path.Combine(Path.GetTempPath(), "duelmind-windbot.log"),
                    DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ") + " " + detail + Environment.NewLine);
            }
            catch (Exception) { }
        }

        private static class C
        {
            public const int Marina = 210000301;
            public const int Marin = 210000302;
            public const int Belu = 210000303;
            public const int Leviathan = 210000304;
            public const int Barka = 210000305;
            public const int Arca = 210000306;
            public const int Link1 = 210000307;
            public const int Link2 = 210000308;
            public const int Adventure = 210000309;
            public const int Treasure = 210000310;
            public const int CalmWave = 210000311;
            public const int RoughWave = 210000312;
            public const int Battlefield = 210000313;
            public const int AshBlossom = 14558127;
            public const int EffectVeiler = 97268402;
            public const int InfiniteImpermanence = 10045474;
        }

        private static string CardName(int id)
        {
            switch (id)
            {
                case C.Marina: return "오션 테일 - 소녀 마리나";
                case C.Marin: return "오션 테일 - 마린";
                case C.Belu: return "오션 테일 - 고래 벨루";
                case C.Leviathan: return "심해의 적 - 레비아탄";
                case C.Barka: return "오션 테일 - 고대왕 고래 바르카";
                case C.Arca: return "오션 테일 - 영해왕 고래 아르카";
                case C.Link1: return "오션 테일 - 바다와 소녀";
                case C.Link2: return "오션 테일 - 고래와 소녀";
                case C.Adventure: return "오션 테일 - 모험의 시작";
                case C.Treasure: return "오션 테일 - 보물 탐색";
                case C.CalmWave: return "오션 테일 - 잔잔한 파도";
                case C.RoughWave: return "오션 테일 - 거센 파도";
                case C.Battlefield: return "오션 테일 - 결전의 장";
                default: return "알 수 없는 카드";
            }
        }

        public DuelmindOceanTaleExecutor(GameAI ai, Duel duel) : base(ai, duel)
        {
            Trace("DUELMIND Ocean Tale executor activated");
            AddExecutor(ExecutorType.Activate, C.Treasure);
            AddExecutor(ExecutorType.Activate, C.Battlefield);
            AddExecutor(ExecutorType.Activate, C.Adventure);
            AddExecutor(ExecutorType.Activate, C.CalmWave);
            AddExecutor(ExecutorType.Activate, C.RoughWave);
            AddExecutor(ExecutorType.Summon, C.Marina);
            AddExecutor(ExecutorType.Summon, C.Marin);
            AddExecutor(ExecutorType.SpSummon, C.Marin);
            AddExecutor(ExecutorType.SpSummon, C.Belu);
            AddExecutor(ExecutorType.SpSummon, C.Link1);
            AddExecutor(ExecutorType.SpSummon, C.Link2);
            AddExecutor(ExecutorType.SpSummon, C.Barka);
            AddExecutor(ExecutorType.SpSummon, C.Arca);
            AddExecutor(ExecutorType.Activate, C.Marin);
            AddExecutor(ExecutorType.Activate, C.Belu);
            AddExecutor(ExecutorType.Activate, C.Link1);
            AddExecutor(ExecutorType.Activate, C.Link2);
            AddExecutor(ExecutorType.Activate, C.Arca);
            AddExecutor(ExecutorType.Activate, C.AshBlossom, DefaultAshBlossomAndJoyousSpring);
            AddExecutor(ExecutorType.Activate, C.EffectVeiler, DefaultEffectVeiler);
            AddExecutor(ExecutorType.Activate, C.InfiniteImpermanence, DefaultInfiniteImpermanence);
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
            AddExecutor(ExecutorType.SpellSet);
        }

        [DataContract]
        private sealed class Decision
        {
            [DataMember(Name = "action_id")]
            public string ActionId { get; set; }
            [DataMember(Name = "error")]
            public string Error { get; set; }
        }

        private sealed class DuelmindChoice
        {
            public ClientCard Card;
            public string Kind;
            public MainPhaseAction Action;
            public int ChainIndex;
            public long EffectDescription = -1;
            public int ActivationIndex = -1;
            public string EffectProfile = "not_applicable";
        }

        private static bool IsPriorityOwnCard(int id)
        {
            return id == C.Marina || id == C.Marin || id == C.Belu || id == C.Barka ||
                id == C.Arca || id == C.Link1 || id == C.Link2 || id == C.Adventure ||
                id == C.Treasure || id == C.CalmWave || id == C.Battlefield;
        }

        private static string EffectProfile(ClientCard card, string kind, long description)
        {
            if (card == null)
                return "phase_action";
            string location = card.Location.ToString().ToLowerInvariant();
            switch (card.Id)
            {
                case C.Marina: return kind + "_marina_search_spell";
                case C.Marin when kind == "activate" && location == "hand": return "marin_effect_1_special_summon";
                case C.Marin when kind == "activate": return "marin_effect_3_mill_level_up";
                case C.Belu when kind == "activate": return "belu_effect_2_spell_recovery";
                case C.Leviathan: return "leviathan_effect_2_search";
                case C.Barka: return "barka_effect_1_summon_leviathan";
                case C.Arca when kind == "activate": return "arca_effect_3_three_attacks";
                case C.Link1 when kind == "activate": return "link1_effect_2_revive";
                case C.Link2 when kind == "activate": return "link2_effect_description:" + description;
                case C.Adventure: return "adventure_effect_1_ritual_summon";
                case C.Treasure: return "treasure_effect_1_search";
                case C.CalmWave: return "calm_wave_effect_1_deck_special_summon";
                case C.RoughWave: return "rough_wave_effect_1_boost_and_immunity";
                case C.Battlefield: return "battlefield_effect_description:" + description;
                default: return kind + "_description_" + description;
            }
        }

        private static Dictionary<string, int> VerifiedEvaluation(DuelmindChoice choice)
        {
            if (choice == null || choice.Card == null)
                return null;
            var result = new Dictionary<string, int>();
            switch (choice.Card.Id)
            {
                case C.Treasure: result["immediate_gain"] = 45; result["follow_up"] = 50; break;
                case C.Marina: result["immediate_gain"] = 35; result["follow_up"] = 45; break;
                case C.Marin: result["follow_up"] = 45; result["resource_preservation"] = 20; break;
                case C.Belu: result["follow_up"] = 35; result["resource_preservation"] = 30; break;
                case C.Link1: result["follow_up"] = 48; result["resource_preservation"] = 20; break;
                case C.Link2: result["interaction"] = 35; result["follow_up"] = 45; result["board_persistence"] = 30; break;
                case C.Barka: result["interaction"] = 40; result["follow_up"] = 45; break;
                case C.Arca: result["interaction"] = 45; result["win_contribution"] = 50; break;
                case C.Battlefield: result["follow_up"] = 35; result["board_persistence"] = 35; break;
                case C.RoughWave: result["interaction"] = 25; result["board_persistence"] = 25; break;
            }
            return result.Count == 0 ? null : result;
        }

        private void TraceDecision(IList<DuelmindChoice> choices, int selected, bool fallback, string reason)
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
                            ["action_id"] = i.ToString(), ["kind"] = choices[i].Kind,
                            ["card_id"] = id, ["card_name"] = CardName(id),
                            ["effect_description"] = choices[i].EffectDescription,
                            ["activation_index"] = choices[i].ActivationIndex,
                            ["effect_profile"] = choices[i].EffectProfile,
                            ["selected"] = i == selected, ["score"] = null,
                        });
                    }
                }
                var record = new Dictionary<string, object> {
                    ["timestamp"] = DateTime.UtcNow.ToString("o"), ["deck_name"] = DeckName,
                    ["deck_profile"] = DeckProfile, ["turn"] = Duel.Turn,
                    ["phase"] = Duel.Phase.ToString(), ["fallback"] = fallback,
                    ["fallback_reason"] = reason, ["selected_index"] = selected,
                    ["candidates"] = candidates,
                    ["execution_result"] = selected >= 0 ? "action_returned_to_windbot" : "no_action_returned",
                };
                File.AppendAllText(Path.Combine(Path.GetTempPath(), "duelmind-decisions.jsonl"),
                    JsonSerializer.Serialize(record) + Environment.NewLine);
            }
            catch (Exception) { }
        }

        private int AskDuelmind(IList<ClientCard> cards, string kind)
        {
            if (cards == null || cards.Count == 0)
                return -1;
            var options = new List<DuelmindChoice>();
            foreach (var card in cards)
                options.Add(new DuelmindChoice { Card = card, Kind = kind,
                    EffectProfile = kind + "_effect_identifier_unavailable" });
            return AskActionChoices(options);
        }

        public override IList<ClientCard> OnSelectCard(IList<ClientCard> cards, int min, int max, long hint, bool cancelable)
        {
            if (cards == null || cards.Count == 0 || min != 1 || max != 1)
                return base.OnSelectCard(cards, min, max, hint, cancelable);
            int index = AskDuelmind(cards, "select_card");
            return index < 0 ? base.OnSelectCard(cards, min, max, hint, cancelable) : new List<ClientCard> { cards[index] };
        }

        public override ClientCard OnSelectAttacker(IList<ClientCard> attackers, IList<ClientCard> defenders)
        {
            if (attackers == null || attackers.Count == 0)
                return base.OnSelectAttacker(attackers, defenders);
            int index = AskDuelmind(attackers, "select_card");
            return index >= 0 ? attackers[index] : base.OnSelectAttacker(attackers, defenders);
        }

        private int AskActionChoices(IList<DuelmindChoice> choices)
        {
            Trace("ocean tale python decision requested; choices=" + (choices == null ? 0 : choices.Count));
            if (choices == null || choices.Count == 0 || choices.Count > 512)
            {
                TraceDecision(choices, -1, true, "invalid_or_empty_legal_actions");
                return -1;
            }
            var message = new StringBuilder(700 + choices.Count * 220);
            message.Append("{\"protocol\":\"duelmind.v1\",\"deck_name\":\"").Append(DeckName)
                .Append("\",\"deck_profile\":\"").Append(DeckProfile).Append("\",\"public_state\":{");
            message.Append("\"deck_name\":\"").Append(DeckName).Append("\",");
            message.Append("\"deck_profile\":\"").Append(DeckProfile).Append("\",");
            message.Append("\"turn\":").Append(Duel.Turn).Append(",");
            message.Append("\"phase\":\"").Append(Duel.Phase.ToString().ToLowerInvariant()).Append("\",");
            message.Append("\"going_first\":").Append(Duel.IsFirst ? "true" : "false").Append(",");
            message.Append("\"own_monster_count\":").Append(Bot.GetMonsterCount()).Append(",");
            message.Append("\"opponent_monster_count\":").Append(Enemy.GetMonsterCount()).Append(",");
            message.Append("\"opponent_leviathan_count\":").Append(CountOpponentLeviathan()).Append(",");
            message.Append("\"hand_count\":").Append(Bot.Hand.Count).Append(",");
            message.Append("\"own_field_spell\":").Append(Bot.HasInSpellZone(C.Battlefield, true, true) ? "true" : "false").Append(",");
            message.Append("\"weather\":\"unknown\",\"hand_ids\":[");
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
                var choice = choices[i]; var card = choice.Card;
                int id = card == null || (card.Controller != 0 && !card.IsFaceup()) ? 0 : card.Id;
                message.Append("{\"action_id\":\"").Append(i).Append("\",\"kind\":")
                    .Append(JsonSerializer.Serialize(choice.Kind)).Append(",\"card_id\":").Append(id)
                    .Append(",\"card_name\":").Append(JsonSerializer.Serialize(CardName(id)))
                    .Append(",\"effect_description\":").Append(choice.EffectDescription)
                    .Append(",\"activation_index\":").Append(choice.ActivationIndex)
                    .Append(",\"effect_profile\":").Append(JsonSerializer.Serialize(choice.EffectProfile))
                    .Append(",\"location\":").Append(JsonSerializer.Serialize(card == null ? "" : card.Location.ToString().ToLowerInvariant()))
                    .Append(",\"controller\":").Append(card == null ? -1 : card.Controller)
                    .Append(",\"target\":{\"is_faceup\":").Append(card != null && card.IsFaceup() ? "true" : "false")
                    .Append(",\"high_value\":").Append(card != null && card.Controller == 0 && IsPriorityOwnCard(card.Id) ? "true" : "false")
                    .Append(",\"attack\":").Append(card != null && card.IsFaceup() ? card.Attack : 0).Append("}");
                var evaluation = VerifiedEvaluation(choice);
                if (evaluation != null)
                    message.Append(",\"verified_evaluation\":").Append(JsonSerializer.Serialize(evaluation));
                message.Append("}");
            }
            message.Append("]}");
            try
            {
                using (var tcp = new TcpClient())
                {
                    var pending = tcp.BeginConnect("127.0.0.1", 28741, null, null);
                    using (pending.AsyncWaitHandle)
                    {
                        if (!pending.AsyncWaitHandle.WaitOne(150)) return -1;
                    }
                    tcp.EndConnect(pending); tcp.ReceiveTimeout = 200; tcp.SendTimeout = 200;
                    using (var stream = tcp.GetStream())
                    {
                        byte[] request = Encoding.UTF8.GetBytes(message.ToString() + "\n");
                        stream.Write(request, 0, request.Length);
                        using (var reader = new StreamReader(stream, Encoding.UTF8, false, 1024, true))
                        {
                            string response = reader.ReadLine();
                            if (response == null || response.Length > 32768) return -1;
                            using (var input = new MemoryStream(Encoding.UTF8.GetBytes(response)))
                            {
                                var selected = (Decision)new DataContractJsonSerializer(typeof(Decision)).ReadObject(input);
                                int index;
                                if (selected == null || selected.Error != null || !int.TryParse(selected.ActionId, out index) || index < 0 || index >= choices.Count)
                                {
                                    TraceDecision(choices, -1, true, "invalid_python_response"); return -1;
                                }
                                TraceDecision(choices, index, false, "python_strategy"); return index;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Trace("python connection failed: " + ex.GetType().Name + " " + ex.Message);
                TraceDecision(choices, -1, true, "python_connection_failed"); return -1;
            }
        }

        private int CountOpponentLeviathan()
        {
            int count = 0;
            foreach (var card in Enemy.MonsterZone)
                if (card != null && card.IsFaceup() && card.Id == C.Leviathan) count++;
            return count;
        }

        public override MainPhaseAction TryDecideMainPhase(MainPhase main)
        {
            if (main == null) return null;
            var choices = new List<DuelmindChoice>();
            for (int i = 0; i < main.ActivableCards.Count; i++)
            {
                var card = main.ActivableCards[i]; var desc = main.ActivableDescs[i]; int actionIndex;
                if (card.ActionActivateIndex.TryGetValue(desc, out actionIndex))
                    choices.Add(new DuelmindChoice { Card = card, Kind = "activate", Action = new MainPhaseAction(MainPhaseAction.MainAction.Activate, actionIndex), EffectDescription = desc, ActivationIndex = actionIndex, EffectProfile = EffectProfile(card, "activate", desc) });
            }
            foreach (var card in main.SpecialSummonableCards)
                choices.Add(new DuelmindChoice { Card = card, Kind = card.Location == CardLocation.Extra ? "link_summon" : "special_summon", Action = new MainPhaseAction(MainPhaseAction.MainAction.SpSummon, card.ActionIndex), ActivationIndex = card.ActionIndex[1], EffectProfile = EffectProfile(card, "special_summon", -1) });
            foreach (var card in main.SummonableCards)
                choices.Add(new DuelmindChoice { Card = card, Kind = "normal_summon", Action = new MainPhaseAction(MainPhaseAction.MainAction.Summon, card.ActionIndex), ActivationIndex = card.ActionIndex[0], EffectProfile = EffectProfile(card, "normal_summon", -1) });
            foreach (var card in main.SpellSetableCards)
                choices.Add(new DuelmindChoice { Card = card, Kind = "set", Action = new MainPhaseAction(MainPhaseAction.MainAction.SetSpell, card.ActionIndex), ActivationIndex = card.ActionIndex[4], EffectProfile = EffectProfile(card, "set", -1) });
            if (main.CanBattlePhase && Bot.HasAttackingMonster())
                choices.Add(new DuelmindChoice { Card = null, Kind = "battle_phase", Action = new MainPhaseAction(MainPhaseAction.MainAction.ToBattlePhase), EffectProfile = "phase_battle" });
            if (main.CanEndPhase)
                choices.Add(new DuelmindChoice { Card = null, Kind = "end_phase", Action = new MainPhaseAction(MainPhaseAction.MainAction.ToEndPhase), EffectProfile = "phase_end" });
            if (choices.Count == 0) return null;
            int selected = AskActionChoices(choices);
            if (selected >= 0 && selected < choices.Count) return choices[selected].Action;
            int fallback = FindFallbackIndex(choices); TraceDecision(choices, fallback, true, "python_unavailable_or_invalid");
            return choices[fallback].Action;
        }

        private int FindFallbackIndex(IList<DuelmindChoice> choices)
        {
            foreach (var choice in choices)
                if (choice.Card != null && choice.Card.Id == C.Treasure && choice.Kind == "activate") return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Card != null && choice.Card.Id == C.Marina && choice.Kind == "normal_summon") return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Card != null && (choice.Card.Id == C.Marin || choice.Card.Id == C.Belu) && (choice.Kind == "activate" || choice.Kind == "special_summon")) return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Card != null && (choice.Card.Id == C.Link1 || choice.Card.Id == C.Link2 || choice.Card.Id == C.Barka || choice.Card.Id == C.Arca) && choice.Kind == "link_summon") return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Kind == "battle_phase") return choices.IndexOf(choice);
            foreach (var choice in choices)
                if (choice.Kind == "end_phase") return choices.IndexOf(choice);
            return 0;
        }

        public override int TryDecideChain(IList<ClientCard> cards, bool forced)
        {
            if (cards == null || cards.Count == 0) return -2;
            var choices = new List<DuelmindChoice>();
            for (int i = 0; i < cards.Count; i++) choices.Add(new DuelmindChoice { Card = cards[i], Kind = "chain", ChainIndex = i, EffectProfile = "chain_effect_identifier_unavailable" });
            if (!forced) choices.Add(new DuelmindChoice { Card = null, Kind = "pass", ChainIndex = -1, EffectProfile = "chain_pass" });
            int index = AskActionChoices(choices);
            return index >= 0 ? choices[index].ChainIndex : -2;
        }
    }
}
