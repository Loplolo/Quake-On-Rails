#define LEADERBOARD_NUM_PLAYERS 15

string lb_names[LEADERBOARD_NUM_PLAYERS];
float lb_skill[LEADERBOARD_NUM_PLAYERS];
float lb_scores[LEADERBOARD_NUM_PLAYERS];
float lb_count;
float lb_added_index;
float lb_state;

void() leaderboard_load =
{
	filestream fh = fopen(strcat("scores/", mapname, ".csv"), FILE_READ);
	

	if (fh < 0)
		{
			dprint(strcat("Failed to load scores for map ", mapname, "\n"));
			return;
		}
	
	local string line;
	lb_count = 0;

	while (lb_count < LEADERBOARD_NUM_PLAYERS)
	{
		line = fgets(fh);
		if (!line)
			break;
		
		if (tokenizebyseparator(line, ",") < 3){
		    continue;
		}

		lb_names[lb_count] = argv(0);
		lb_skill[lb_count] = stof(argv(1));
		lb_scores[lb_count] = stof(argv(2));
		lb_count++;
	}

	fclose(fh);
};

void(string mapn) leaderboard_save =
{
	filestream fh = fopen(strcat("scores/", mapn, ".csv"), FILE_WRITE);
	if (fh < 0)
		return;

	float i;
	for (i = 0; i < lb_count ; i++)
		#pragma target fte_6614
		fputs(fh, strcat(lb_names[i], ",", ftos(lb_skill[i]), ",", ftos(lb_scores[i]), "\n"));

	fclose(fh);
};

float(string pname, float pskill, float pscore) leaderboard_insert =
{
	local float insert_at = -1;
  
	if (lb_count < LEADERBOARD_NUM_PLAYERS)
		insert_at = lb_count;
	else if (pscore > lb_scores[LEADERBOARD_NUM_PLAYERS - 1])
		insert_at = LEADERBOARD_NUM_PLAYERS - 1;

	if (insert_at < 0)
		return -1;

	local float i = insert_at;
	while (i > 0 )
		{
			if (lb_scores[i - 1] >= pscore){
				break;
			}
			lb_names[i] = lb_names[i - 1];
			lb_skill[i] = lb_skill[i - 1];
			lb_scores[i] = lb_scores[i - 1];
			i--;
		}

	lb_names[i] = pname;
	lb_skill[i] = pskill;
	lb_scores[i] = pscore;

	if (lb_count < LEADERBOARD_NUM_PLAYERS )
		lb_count++;

	return i;
};

void(vector pos, vector entry_size) Hud_DrawLeaderboard =
{

	local vector size =  [screen_width/4, 20 + LEADERBOARD_NUM_PLAYERS * (entry_size_y + 2)];
	drawfill(pos, size, '0 0 0', 0.6, 0);
	drawstring(pos + [(size_x - stringwidth("TOP PLAYERS", TRUE, entry_size*1.2)) / 2, 4], "TOP PLAYERS", entry_size*1.2, '1 1 0.4', 1, 0);

	local vector row = pos + '8 18';
	local vector gap = '0 10';
	
	local float i;
	local vector col1_size = [stringwidth("Name  ", TRUE, entry_size), 0] + '26 0' ;
	local vector col2_size = [stringwidth("Difficulty   ", TRUE, entry_size), 0] + col1_size;

	drawstring(row + '16 0', "Name", entry_size, '1 1 1', 1, 0);
	drawstring(row + col1_size,"Difficulty", entry_size, '1 1 1', 1, 0);
	drawstring(row + col2_size , "Score", entry_size,'1 1 1', 1, 0);
	row += gap;

	drawfill(row, [size_x - 16, 1], '1 1 0.4', 0.5, 0);
	row += '0 4';
	for (i = 0; i < lb_count; i++)
	{
		local vector color = (i == lb_added_index) ? '0.4 1 0.4' : '1 1 1';

		local string lb_skill_str;
		if (lb_skill[i] == 0){
			lb_skill_str = "Easy";
		} else if (lb_skill[i] == 1){
			lb_skill_str = "Medium";
		} else if (lb_skill[i] == 2){
			lb_skill_str = "Hard";
		} else if (lb_skill[i] == 3){
			lb_skill_str = "Nightmare";
		} else {
			lb_skill_str = "";
		}

		drawstring(row, strcat(ftos(i + 1), "."), entry_size, color, 1, 0);
		drawstring(row + '16 0', lb_names[i], entry_size, color, 1, 0);
		drawstring(row + col1_size, lb_skill_str, entry_size, color, 1, 0);
		drawstring(row + col2_size, ftos(lb_scores[i]), entry_size, color, 1, 0);

		gap_y = entry_size_y/2 + 5;
		row += gap;
	}
};

void(vector screensize, float showscores) CSQC_DrawScores
{
	HUD_UpdateStats();

	if (!intermission || coopdata == -1)
	{
		lb_state = 0;
		return;
	}

	if (lb_state == 0)
	{
	    leaderboard_load();
		lb_added_index = leaderboard_insert(cvar_string("name"), skill, getstatf(STAT_SCORE));
		if (lb_added_index >= 0)
		    leaderboard_save(mapname);
		lb_state = 1;
	}

	Hud_DrawLeaderboard([max(0, 3*screensize_x/8), max(0, 3*screensize_y /8)], '8 8' );
}
