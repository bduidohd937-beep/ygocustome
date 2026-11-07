-- 오션 테일 - 영해왕 고래 아르카
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_REMOVE)
 e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and ot.opponentLevi(e:GetHandlerPlayer()) end)
 e1:SetTarget(s.btg)
 e1:SetOperation(s.bop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetType(EFFECT_TYPE_FIELD)
 e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
 e2:SetRange(LOCATION_MZONE)
 e2:SetTargetRange(LOCATION_ONFIELD,0)
 e2:SetCondition(function(e) return ot.opponentLevi(e:GetHandlerPlayer()) end)
 e2:SetTarget(function(e,tc) return ot.archetype(tc) end)
 e2:SetValue(function(e,re,rp) return rp~=e:GetHandlerPlayer() end)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
 e3:SetProperty(EFFECT_FLAG_DELAY)
 e3:SetCode(EVENT_LEAVE_FIELD)
 e3:SetRange(LOCATION_MZONE)
 e3:SetCountLimit(1,{id,3})
 e3:SetCondition(s.fincon)
 e3:SetCost(s.fincost)
 e3:SetOperation(s.finop)
 c:RegisterEffect(e3)
end
s.listed_series={ot.SET}
s.listed_names={ot.LEVIATHAN}
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
 local rg=e:GetHandler():GetMaterial();local ct=rg and #rg or 0
 local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_HAND,nil)
 if chk==0 then return ct>0 and #g>0 end
 e:SetLabel(math.min(ct,#g))
 Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,math.min(ct,#g),1-tp,LOCATION_ONFIELD|LOCATION_HAND)
end
function s.bop(e,tp)
 local ct=e:GetLabel();if ct==0 then return end
 local fg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
 local maxfield=math.min(ct,#fg)
 local sel=Group.CreateGroup()
 if maxfield>0 then
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  sel=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,0,maxfield,nil)
 end
 local need=ct-#sel
 if need>0 then
  local hg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
  while need>0 and #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) do
   local random=hg:RandomSelect(tp,1)
   sel:Merge(random);hg:Sub(random);need=need-1
  end
 end
 if #sel==0 then return end
 if Duel.Remove(sel,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)>0 then
  for tc in aux.Next(sel) do ot.registerTempReturn(tc,tp) end
 end
end
function s.fintf(c)
 return ot.monster(c) and c:IsAbleToRemoveAsCost()
end
function s.fincon(e,tp,eg,ep,ev,re,r,rp)
 return eg:IsExists(function(c) return c:IsCode(ot.LEVIATHAN) and
  c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(1-tp) end,1,nil)
end
function s.fincost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return true end
 local max=Duel.GetMatchingGroupCount(s.fintf,tp,LOCATION_GRAVE,0,nil)
 local g=Duel.SelectMatchingCard(tp,s.fintf,tp,LOCATION_GRAVE,0,0,max,nil)
 e:SetLabel(#g)
 if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_COST) end
end
function s.finop(e,tp)
 local c=e:GetHandler();if not c:IsFaceup() then return end
 local e1=Effect.CreateEffect(c);e1:SetType(EFFECT_TYPE_SINGLE);e1:SetCode(EFFECT_UPDATE_ATTACK)
 e1:SetValue(e:GetLabel()*500);e1:SetReset(RESETS_STANDARD_PHASE_END);c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c);e2:SetType(EFFECT_TYPE_SINGLE);e2:SetCode(EFFECT_EXTRA_ATTACK)
 e2:SetValue(2);e2:SetReset(RESETS_STANDARD_PHASE_END);c:RegisterEffect(e2)
end
