Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 Xyz.AddProcedure(c,function(tc) return tc:IsLevel(4) and tc:IsRace(RACE_MACHINE) end,4,2); c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e1:SetProperty(EFFECT_FLAG_DELAY); e1:SetCode(EVENT_SPSUMMON_SUCCESS); e1:SetCountLimit(1,id); e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and ISOBAR.Field(e:GetHandlerPlayer())~=nil end); e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return ISOBAR.State(tp)~=ISOBAR.SUN end end); e1:SetOperation(function(e,tp) ISOBAR.Change(tp,ISOBAR.SUN,e) end); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_IGNITION); e2:SetRange(LOCATION_MZONE); e2:SetCountLimit(1,id+1000); e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON); e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end; e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST) end); e2:SetTarget(s.thtg); e2:SetOperation(s.thop); c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c); e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O); e3:SetProperty(EFFECT_FLAG_DELAY); e3:SetCode(ISOBAR.EVENT); e3:SetRange(LOCATION_MZONE); e3:SetCountLimit(1,id+2000); e3:SetCondition(function(e) return ISOBAR.Field(e:GetHandlerPlayer())~=nil end); e3:SetTarget(s.matg); e3:SetOperation(s.matop); c:RegisterEffect(e3)
end
s.listed_series={ISOBAR.SET}
function s.thfilter(c) return c:IsSetCard(ISOBAR.SET) and c:IsMonster() and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end end
function s.thop(e,tp) local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil); if #g==0 then return end; Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g); local h=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(function(c) return c:IsSetCard(ISOBAR.SET) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,nil); if #h>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then Duel.SpecialSummon(h:Select(tp,1,1,nil),0,tp,tp,false,false,POS_FACEUP) end; ISOBAR.ApplyMachineLock(e:GetHandler(),tp) end
function s.matfilter(c) return c:IsSetCard(ISOBAR.SET) and c:IsMonster() and c:IsCanBeXyzMaterial(e:GetHandler(),REASON_EFFECT) end
function s.matg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(ISOBAR.SET) and c:IsMonster() and c:IsCanBeXyzMaterial(e:GetHandler(),REASON_EFFECT) end,tp,LOCATION_GRAVE,0,1,nil) end end
function s.matop(e,tp) local g=Duel.SelectMatchingCard(tp,function(c) return c:IsSetCard(ISOBAR.SET) and c:IsMonster() and c:IsCanBeXyzMaterial(e:GetHandler(),REASON_EFFECT) end,tp,LOCATION_GRAVE,0,1,1,nil); if #g>0 then Duel.Overlay(e:GetHandler(),g) end end
