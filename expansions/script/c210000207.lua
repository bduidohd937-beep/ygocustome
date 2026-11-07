-- Isobar Xyz: 210000207
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 Xyz.AddProcedure(c,s.matfilter,4,2)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,id)
 e1:SetCondition(s.wxcon)
 e1:SetTarget(s.wxtg)
 e1:SetOperation(s.wxop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,id+1000)
 e2:SetCost(s.thcost)
 e2:SetTarget(s.thtg)
 e2:SetOperation(s.thop)
 c:RegisterEffect(e2)
end
s.listed_series={ISOBAR.SET}
function s.matfilter(c) return c:IsRace(RACE_MACHINE) end
function s.wxcon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and ISOBAR.Field(tp)~=nil
end
function s.wxtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return ISOBAR.State(tp)~=ISOBAR.SUN end
end
function s.wxop(e,tp,eg,ep,ev,re,r,rp) ISOBAR.Change(tp,ISOBAR.SUN,e) end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
 e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thfilter(c)
 return c:IsMonster() and c:IsSetCard(ISOBAR.SET) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.limit(e,c)
 return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_MACHINE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
 if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_FIELD)
 e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
 e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
 e1:SetTargetRange(1,0)
 e1:SetTarget(s.limit)
 e1:SetReset(RESET_PHASE+PHASE_END)
 Duel.RegisterEffect(e1,tp)
end
