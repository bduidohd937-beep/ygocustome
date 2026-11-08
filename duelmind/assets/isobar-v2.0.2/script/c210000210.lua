Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_ACTIVATE); e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH); e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH); e1:SetOperation(s.activate); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_IGNITION); e2:SetRange(LOCATION_FZONE); e2:SetCountLimit(1,id); e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return ISOBAR.State(tp)>0 end end); e2:SetOperation(function(e,tp) ISOBAR.Change(tp,ISOBAR.Choose(tp,ISOBAR.State(tp)),e) end); c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c); e3:SetType(EFFECT_TYPE_FIELD); e3:SetCode(EFFECT_UPDATE_ATTACK); e3:SetRange(LOCATION_FZONE); e3:SetTargetRange(LOCATION_MZONE,0); e3:SetCondition(function(e) return ISOBAR.Is(e:GetHandlerPlayer(),ISOBAR.SUN) end); e3:SetTarget(function(e,c) return ISOBAR.Monster(c) end); e3:SetValue(300); c:RegisterEffect(e3)
 local e4=e3:Clone(); e4:SetTargetRange(0,LOCATION_MZONE); e4:SetCondition(function(e) return ISOBAR.Is(e:GetHandlerPlayer(),ISOBAR.RAIN) end); e4:SetTarget(aux.TRUE); e4:SetValue(-300); c:RegisterEffect(e4)
 local e5=Effect.CreateEffect(c); e5:SetType(EFFECT_TYPE_FIELD); e5:SetRange(LOCATION_FZONE); e5:SetCode(EFFECT_CANNOT_ACTIVATE); e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET); e5:SetTargetRange(0,1); e5:SetCondition(function(e) return ISOBAR.Is(e:GetHandlerPlayer(),ISOBAR.STORM) end); e5:SetValue(s.block); c:RegisterEffect(e5)
 local e6=Effect.CreateEffect(c); e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O); e6:SetCode(ISOBAR.EVENT); e6:SetRange(LOCATION_FZONE); e6:SetCountLimit(1,id+1000); e6:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(ISOBAR.Xyz,tp,LOCATION_MZONE,0,1,nil) end); e6:SetTarget(s.settg); e6:SetOperation(s.setop); c:RegisterEffect(e6)
end
s.listed_names={210000213}; s.listed_series={ISOBAR.SET}
function s.filter(c) return ISOBAR.Monster(c) and c:IsAbleToHand() end
function s.activate(e,tp) local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil); if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g) end; ISOBAR.Change(tp,ISOBAR.SUN,e) end
function s.block(e,re,tp) if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or Duel.GetCurrentPhase()~=PHASE_DAMAGE then return false end; local a=Duel.GetAttacker(); local d=Duel.GetAttackTarget(); local p=e:GetHandlerPlayer(); return (a and a:IsControler(p) and ISOBAR.Monster(a)) or (d and d:IsControler(p) and ISOBAR.Monster(d)) end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsCode(210000213) and c:IsSSetable() end,tp,LOCATION_DECK,0,1,nil) end end
function s.setop(e,tp) local g=Duel.SelectMatchingCard(tp,function(c) return c:IsCode(210000213) and c:IsSSetable() end,tp,LOCATION_DECK,0,1,1,nil); if #g>0 then Duel.SSet(g) end end
