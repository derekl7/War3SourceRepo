#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

public Plugin:myinfo = 
{
	name = "War3Source - Warcraft Extended - Bash",
	author = "War3Source Team",
	description="Generic bash skill"
};

new PlayerRace[MAXPLAYERSCUSTOM];

public OnPluginStart()
{
	LoadTranslations("w3s.race.human.phrases");
}

public OnWar3EventPostHurt(victim,attacker,damage){
	if(IS_PLAYER(victim)&&IS_PLAYER(attacker)&&victim>0&&attacker>0&&attacker!=victim)
	{
		decl String:weapon[64];
		GetEventString(W3GetVar(SmEvent),"weapon",weapon,63); 
		if(StrEqual(weapon, "crit",false) || StrEqual(weapon, "bash", false) || StrEqual(weapon, "weapon_crit",false) || StrEqual(weapon, "weapon_bash", false))
			return;
		
		new vteam=GetClientTeam(victim);
		new ateam=GetClientTeam(attacker);
		if(vteam!=ateam)
		{
			new Float:percent = W3GetBuffSumFloat(attacker,fBashChance);
			if((percent > 0.0) && !Hexed(attacker) &&!W3HasImmunity(victim,Immunity_Skills)&&W3ChanceModifier(attacker))
			{
				// Bash
				if(War3_Chance(percent) && !W3GetBuffHasTrue(victim,bBashed) && IsPlayerAlive(attacker))
				{
					new race=War3_GetRace(victim);
					PlayerRace[victim] = race;
					War3_SetBuff(victim,bBashed,race,true);
					new newdamage = W3GetBuffSumInt(attacker,iBashDamage);
					if(newdamage>0)
						War3_DealDamage(victim,newdamage,attacker,_,"weapon_bash");
					
					W3FlashScreen(victim,RGBA_COLOR_RED);
					new Float:duration = W3GetBuffSumFloat(attacker,fBashDuration);
					CreateTimer(duration,UnfreezePlayer,victim);
					
					PrintHintText(victim,"%T","RcvdBash",victim);
					PrintHintText(attacker,"%T","Bashed",attacker);
				}
			}
			
		}
	}
}

public Action:UnfreezePlayer(Handle:h,any:victim)
{
	War3_SetBuff(victim,bBashed,PlayerRace[victim],false);
}



