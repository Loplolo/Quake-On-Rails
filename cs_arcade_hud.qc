float last_score;
float popup_amount;
float popup_time;
vector popup_pos;

void(vector screensize, float scoreboard) CSQC_DrawHud {
	HUD_UpdateStats();
	if (intermission || coopdata == -1) return;

	Hud_DrawTint(screensize);
	
	if (cvar("viewsize") > 110)
		return;

	
	float score  = getstatf(STAT_SCORE);
	float health = stat_health;
	float armor  = getstatf(STAT_ARMOR);
	float ammo = getstatf(STAT_AMMO);
	float bottom = screensize_y - 32;

	string kills = strcat("KILLS ",   ftos(getstatf(STAT_MONSTERS)), "/", ftos(getstatf(STAT_TOTALMONSTERS)));
	string secrets = strcat("SECRETS ", ftos(getstatf(STAT_SECRETS)),  "/", ftos(getstatf(STAT_TOTALSECRETS)));
	
	drawstring([(screensize_x - stringwidth(kills, TRUE, '8 8'))/2, 28], kills , '8 8', '1 1 1', 0.7, 0);
	drawstring([(screensize_x - stringwidth(secrets, TRUE, '8 8'))/2 , 38], secrets , '8 8', '1 1 1', 0.7, 0);

	drawstring([14, bottom], "HEALTH", '8 8', '1 1 1', 0.6, 0);
	drawstring([16, bottom + 10], ftos(floor(health)), '16 16',
		(health <= 25) ? '1 0.2 0.2' : '1 1 1', 1, 0);

	if (armor > 0 || (stat_items & IT_INVULNERABILITY))
	{
		drawstring([118, bottom], "ARMOR", '8 8', '1 1 1', 0.6, 0);
		drawstring([120, bottom + 10], ftos(floor(armor)), '16 16', '1 1 0.4', 1, 0);
	}
	if (getstatf(STAT_ACTIVEWEAPON) != IT_AXE)
	{
		string as = ftos(floor(ammo));
		drawstring([screensize_x - 16 - stringwidth("AMMO", TRUE, '8 8'), bottom], "AMMO", '8 8', '1 1 1', 0.6, 0);
		drawstring([screensize_x - 16 - stringwidth(as, TRUE, '16 16'), bottom + 10], as, '16 16',
			(ammo <= 10) ? '1 0.5 0.2' : '1 1 1', 1, 0);
	}

	string ss = strcat("SCORE ", ftos(floor(score)));
	drawstring([screensize_x * 0.5 - stringwidth(ss, TRUE, '16 16') * 0.5, 8], ss, '16 16', '1 1 0.4', 1, 0);

	if (score > last_score)
	{
		popup_amount = score - last_score;
		popup_time = time;
		popup_pos = [screen_width * 0.5 + crosshair_pos_x - 32, screen_height * 0.5  + crosshair_pos_y - 32];
	}
	last_score = score;

	if (time - popup_time < 1)
	{

		string ps = strcat("+", ftos(floor(popup_amount)));
		drawstring(popup_pos,
			ps, '16 16', '1 1 0.3', 1 - (time - popup_time), 0);
	}
};

void(float apilevel, string enginename, float engineversion) CSQC_Init = {
	checkextension("FRIK_FILE");
	checkextension("FTE_STRINGS");
	cvar_set ("cl_crosshair_path", "gfx/crosshair0.tga");
	Hud_Init();
}
