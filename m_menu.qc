vector MENU_BG = '0.2 0.3 0.4';
vector MENU_BG_DARK = '0.1 0.15 0.2';
vector MENU_BORDER = '0.3 0.4 0.5';
vector MENU_BUTTON = '0.3 0.4 0.5';
vector MENU_BUTTON_BORDER = '0.35 0.45 0.55';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';

float current_menu;
const float MENU_MAIN = 1;
const float MENU_HELP = 2;
const float MENU_PLAYER = 3;
const float MENU_MAPS = 4;
const float MENU_SETTINGS = 5;

const string CHARSET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!=";
float slot0;
float slot1;
float slot2;
float slot3;

string get_nickname()
{
    string c0 = substring(CHARSET, slot0, 1);
    string c1 = substring(CHARSET, slot1, 1);
    string c2 = substring(CHARSET, slot2, 1);
    string c3 = substring(CHARSET, slot3, 1);
    return strcat(c0, c1, c2, c3);
}


float img_button(string id, vector pos, vector size, string path)
{
    sui_push_frame(pos, size);
    vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.25 : MENU_BUTTON;
    basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
    
    sui_fill([0, 0], size, basecolor, 0.6, 0);
    sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
    
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    float pic_side = (size_x < size_y) ? size_x : size_y;
    sui_pic([0, 0], [pic_side, pic_side], path, [1, 1, 1], 1, 0);
    sui_text([0, 0], MENU_TEXT_SMALL, "", MENU_TEXT_1, 1, 0);
    
    sui_action_element([0, 0], size, id, sui_noop);
    sui_pop_frame();
    
    return sui_is_clicked(id);
}


float(string id, vector pos, vector size, string text) sui_button =
{
    sui_push_frame(pos, size);
    local vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.25 : MENU_BUTTON; 
    basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
    sui_fill([0, 0], size, basecolor, 0.6, 0);
    sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
    
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_text([0, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);    
    sui_action_element([0, 0], size, id, sui_noop);
    sui_pop_frame();
    
    return sui_is_clicked(id);
};

void() map_selection_menu =
{
    local vector pos = [0, 0];
    local vector size = [320, 195];
    
    sui_push_frame(pos, size);
    sui_fill([0, 0], size, MENU_BG, 0.75, 0);
    sui_border_box([0, 0], size, 2, MENU_BORDER, 0.3, 0);
    
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    sui_text([0, 8], MENU_TEXT_MEDIUM, "SELECT LEVEL", MENU_TEXT_1, 1, 0);

    sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
    sui_text([15, 36], MENU_TEXT_SMALL, "DIFFICULTY:", MENU_TEXT_1, 1, 0);

    if (sui_button("skill_0", [15,  54], [65, 20], "Easy"))
        localcmd("skill 0\n");
    if (sui_button("skill_1", [90,  54], [65, 20], "Medium"))
        localcmd("skill 1\n");
    if (sui_button("skill_2", [165, 54], [65, 20], "Hard"))
        localcmd("skill 2\n");
    if (sui_button("skill_3", [240, 54], [65, 20], "Nightmare"))
        localcmd("skill 3\n");
    
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    local float ypos = 90;
    local float btn_w = 200;
    local float btn_h = 24;

    if (sui_button("map_e1m1", [0, ypos], [btn_w, btn_h], "Start (E1M1)"))
    { 
        localcmd(strcat("name ", get_nickname(), "\n"));
        localcmd("map OR_E1M1\n");

		current_menu = MENU_MAIN; 
    }

    sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
    sui_button("map_back", [8, -8], [80, 20], "Back") ? current_menu = MENU_PLAYER : 0;

    if (sui_listen_back())
        current_menu = MENU_PLAYER;

    sui_pop_frame();
};

void() player_setup_menu =
{
    local vector pos = [0, 0];
    local vector size = [320, 195];
    
    sui_push_frame(pos, size);
    sui_fill([0, 0], size, MENU_BG, 0.75, 0);
    sui_border_box([0, 0], size, 2, MENU_BORDER, 0.3, 0);
    
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    sui_text([0, 12], MENU_TEXT_MEDIUM, "ENTER NAME", MENU_TEXT_1, 1, 0);

    sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);

    local float slot_w = 45;
    local float slot_h = 50;
    local float gap = 10;
    local float start_x = 55; // (320 - (4 * 45 + 3 * 10)) / 2 = 55
    local float y_up = 38;
    local float y_box = 60;
    local float y_dn = 112;

    local float x0 = start_x;
    local float x1 = start_x + slot_w + gap;
    local float x2 = start_x + (slot_w + gap) * 2;
    local float x3 = start_x + (slot_w + gap) * 3;

    // Slot 0
    img_button("btn_up_0", [x0, y_up], [slot_w, 20], "up.png") ? slot0 = (slot0 + 35) % 36 : 0;
    sui_push_frame([x0, y_box], [slot_w, slot_h]);
    sui_fill([0, 0], [slot_w, slot_h], MENU_BG_DARK, 0.9, 0);
    sui_border_box([0, 0], [slot_w, slot_h], 1, MENU_BORDER, 0.9, 0);
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_text([0, 0], MENU_TEXT_LARGE, substring(CHARSET, slot0, 1), MENU_TEXT_1, 1, 0);
    sui_pop_frame();
    img_button("btn_dn_0", [x0, y_dn], [slot_w, 20], "down.png") ? slot0 = (slot0 + 1) % 36 : 0;

    // Slot 1
    img_button("btn_up_1", [x1, y_up], [slot_w, 20], "up.png") ? slot1 = (slot1 + 35) % 36 : 0;
    sui_push_frame([x1, y_box], [slot_w, slot_h]);
    sui_fill([0, 0], [slot_w, slot_h], MENU_BG_DARK, 0.9, 0);
    sui_border_box([0, 0], [slot_w, slot_h], 1, MENU_BORDER, 0.9, 0);
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_text([0, 0], MENU_TEXT_LARGE, substring(CHARSET, slot1, 1), MENU_TEXT_1, 1, 0);
    sui_pop_frame();
    img_button("btn_dn_1", [x1, y_dn], [slot_w, 20], "down.png") ? slot1 = (slot1 + 1) % 36 : 0;

    // Slot 2
    img_button("btn_up_2", [x2, y_up], [slot_w, 20], "up.png") ? slot2 = (slot2 + 35) % 36 : 0;
    sui_push_frame([x2, y_box], [slot_w, slot_h]);
    sui_fill([0, 0], [slot_w, slot_h], MENU_BG_DARK, 0.9, 0);
    sui_border_box([0, 0], [slot_w, slot_h], 1, MENU_BORDER, 0.9, 0);
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_text([0, 0], MENU_TEXT_LARGE, substring(CHARSET, slot2, 1), MENU_TEXT_1, 1, 0);
    sui_pop_frame();
    img_button("btn_dn_2", [x2, y_dn], [slot_w, 20], "down.png") ? slot2 = (slot2 + 1) % 36 : 0;

    // Slot 3
    img_button("btn_up_3", [x3, y_up], [slot_w, 20], "up.png") ? slot3 = (slot3 + 35) % 36 : 0;
    sui_push_frame([x3, y_box], [slot_w, slot_h]);
    sui_fill([0, 0], [slot_w, slot_h], MENU_BG_DARK, 0.9, 0);
    sui_border_box([0, 0], [slot_w, slot_h], 1, MENU_BORDER, 0.9, 0);
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_text([0, 0], MENU_TEXT_LARGE, substring(CHARSET, slot3, 1), MENU_TEXT_1, 1, 0);
    sui_pop_frame();
    img_button("btn_dn_3", [x3, y_dn], [slot_w, 20], "down.png") ? slot3 = (slot3 + 1) % 36 : 0;

    // Submit
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
    if (sui_button("submit", [0, -10], [120, 24], "Submit"))
    {
        localcmd(strcat("name ", get_nickname(), "\n"));
        current_menu = MENU_MAPS;
    }

    if (sui_listen_back())
    {
        current_menu = MENU_MAIN;
    }

    sui_pop_frame();
};

void() help_menu =
{
    local vector pos = [0, 0];
    local vector size = [320, 195];
    
    sui_push_frame(pos, size);

    sui_fill([0, 0], size, MENU_BG, 0.75, 0);
    sui_border_box([0, 0], size, 2, MENU_BORDER, 0.3, 0);
    
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    sui_text([0, 4], MENU_TEXT_MEDIUM, "Help", MENU_TEXT_1, 1, 0);
    
    local float xpos = 0;
    local float ypos = 32;
    sui_text([xpos, ypos], MENU_TEXT_SMALL, "Lorem ipsum dolor sit amet", MENU_TEXT_1, 1, 0);
    
    sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
    sui_button("hlp_back", [-8, -8], [80, 20], "Back") ? current_menu = MENU_MAIN : 0;

    if (sui_listen_back())
        current_menu = MENU_MAIN;

    sui_pop_frame();    
};

void(string id, vector pos, vector size, vector minmaxsteps, __inout float value) sui_slider =
{
	sui_push_frame(pos, size);
	
	value = sui_slidercontrol(id, [0, 0], size, minmaxsteps, value, sui_slider_noop);
	local float maxval = minmaxsteps[1];
	local float sliderx = (value / maxval) * size_x;
	sui_fill([0, size_y * 0.25], [size_x, size_y * 0.5], MENU_BG_DARK, 1.0, 0);
	
	local float is_active = sui_is_held(id) || (sui_is_hovered(id) && !sui_click_held());
	local vector slider_ctrl_color = is_active ? MENU_BUTTON + MENU_HIGHLIGHT * 0.2 : MENU_BUTTON;
	sui_fill([sliderx - 2, 0], [4, size_y], slider_ctrl_color, 1.0, 0);
	
	sui_pop_frame();
};

void(vector pos, vector size, vector minmaxsteps, string cvar_s, string name, string format) cvar_slider =
{
	local float current = cvar(cvar_s);
	local float old = current;
	sui_push_frame(pos, [size_x, size_y * 0.5 - 4]);
	sui_text([0, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_START]);
	sui_text([0, 0], MENU_TEXT_SMALL, sprintf(format, current), MENU_TEXT_1, 1, 0);
	sui_pop_frame();
	sui_slider(strcat(cvar_s, "sldr"), [pos_x, pos_y + size_y * 0.5], [size_x, size_y * 0.5], minmaxsteps, current);
	if (current != old) cvar_set(cvar_s, ftos(current));
};

#define NUM_CROSSHAIRS 3

string(float idx) crosshair_path =
{
	switch (idx)
	{
		case 0: return "gfx/crosshair0.tga";
		case 1: return "gfx/crosshair1.tga";
		case 2: return "gfx/crosshair2.tga";
	}
	return "gfx/crosshair0.tga";
};

float(string path) crosshair_index =
{
	local float i;
	for (i = 0; i < NUM_CROSSHAIRS; i++)
		if (strcmp(crosshair_path(i), path) == 0)
			return i;
	return -1;
};

void(float dir) crosshair_cycle =
{
	local float idx = crosshair_index(cvar_string("cl_crosshair_path")) + dir;
	if (idx < 0) idx = NUM_CROSSHAIRS - 1;
	if (idx >= NUM_CROSSHAIRS) idx = 0;
	cvar_set("cl_crosshair_path", crosshair_path(idx));
};

#define RES_COUNT 7
vector(float idx) res_get =
{
	switch (idx)
	{
		case 0: return [ 800,  600];
		case 1: return [1024,  768];
		case 2: return [1280,  720];
		case 3: return [1366,  768];
		case 4: return [1600,  900];
		case 5: return [1920, 1080];
		case 6: return [2560, 1440];
	}
	return [1280, 720];
};

float res_index; 

float() res_current_index =
{
	local float w = cvar("vid_width");
	local float h = cvar("vid_height");
	local float i;
	for (i = 0; i < RES_COUNT; i++)
	{
		local vector r = res_get(i);
		if (r_x == w && r_y == h)
			return i;
	}
	return 3;  
};

void(float dir) res_cycle =
{
	if (res_index < 0) res_index = res_current_index();
	res_index += dir;
	if (res_index < 0)          res_index = RES_COUNT - 1;
	if (res_index >= RES_COUNT) res_index = 0;
};

void() res_apply =
{
	if (res_index < 0) res_index = res_current_index();
	local vector r = res_get(res_index);
	localcmd(sprintf("vid_width %d; vid_height %d; vid_restart\n", r_x, r_y));
};

struct name_command {
	string name;
	string command;
};
vector binds_scroll;
name_command bindlist[] = 
{
	{ "Shoot", "+attack" },
};

void(string id, vector pos, vector size, string name, string command) bind_button =
{
	sui_push_frame(pos, size);
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	string key = sui_binder(id, [0, 0], size, name, command);
	if (sui_is_hovered(id)) sui_fill([0, 0], size, MENU_HIGHLIGHT, 0.1, 0);
	sui_text([6, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
	sui_text([-6, 0], MENU_TEXT_SMALL, key, MENU_TEXT_1, 1, 0);
	
	sui_pop_frame();
};

void(string id, vector pos, vector size, __inout vector scrollofs) bind_list =
{
	sui_fill(pos, size, MENU_BG_DARK, 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, [size_x - 6, 24], bindlist.length, scrollofs, [0, 6]);
	vector listitem_pos = '0 0 0';
	for (float index = sui_list_item(listitem_pos); index > -1; index = sui_list_item(listitem_pos))
	{
		sui_push_frame(listitem_pos, [size_x - 6, 24]);
		bind_button(strcat(id, ftos(index)), [0, 0], [size_x - 6, 24], bindlist[index].name, bindlist[index].command);
		sui_pop_frame();
	}
	sui_list_view_end();	
};

void() settings_menu =
{
	local vector pos = [0, 0];
	local vector size = [360, 280];

	sui_push_frame(pos, size);
	sui_fill([0, 0], size, MENU_BG, 0.75, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 0.3, 0);

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 4], MENU_TEXT_MEDIUM, "Settings", MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);

	local float xpos = 8;
	local float ypos = 32;
	local float width = size_x * 0.5 - 8 * 2;

	cvar_slider([xpos, ypos], [width, 32], [0, 1], "volume", "Volume", "%.2f");
	ypos += 32 + 4;
	cvar_slider([xpos, ypos], [width, 32], [0, 1], "musicvolume", "Music Volume", "%.2f");
	ypos += 32 + 4;

	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Crosshair", MENU_TEXT_1, 1, 0);
	ypos += 16;
	local string ch_pic = cvar_string("cl_crosshair_path");
	if (strlen(ch_pic) < 1)
	{
		ch_pic = crosshair_path(0);
		cvar_set("cl_crosshair_path", ch_pic);
	}
	sui_button("ch_prev", [xpos, ypos], [24, 32], "<") ? crosshair_cycle(-1) : 0;
	sui_fill([xpos + 28, ypos], [32, 32], MENU_BG, 0.5, 0);
	sui_border_box([xpos + 28, ypos], [32, 32], 1, MENU_BORDER, 0.5, 0);
	sui_pic([xpos + 28, ypos], [32, 32], ch_pic, [1, 1, 1], 1, 0);
	sui_button("ch_next", [xpos + 64, ypos], [24, 32], ">") ? crosshair_cycle(1) : 0;
	ypos += 32 + 8;

	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Resolution", MENU_TEXT_1, 1, 0);
	ypos += 16;
	if (res_index < 0) res_index = res_current_index();
	local vector res = res_get(res_index);
	sui_button("res_prev", [xpos, ypos], [24, 20], "<") ? res_cycle(-1) : 0;
	sui_fill([xpos + 28, ypos], [100, 20], MENU_BG, 0.5, 0);
	sui_border_box([xpos + 28, ypos], [88, 20], 1, MENU_BORDER, 0.5, 0);
	sui_text([xpos + 34, ypos + 4], MENU_TEXT_SMALL, sprintf("%d x %d", res_x, res_y), MENU_TEXT_1, 1, 0);
	sui_button("res_next", [xpos + 120, ypos], [24, 20], ">") ? res_cycle(1) : 0;
	ypos += 24;
	sui_button("res_apply", [xpos, ypos], [width, 20], "Apply Resolution") ? res_apply() : 0;

	// right col
	xpos = 8 + width + 8 + 8;
	ypos = 32;

	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Video", MENU_TEXT_1, 1, 0);
	ypos += 16;
	sui_button("fs_btn", [xpos, ypos], [width, 20], "Fullscreen") ? localcmd("vid_fullscreen 2; vid_restart\n") : 0;
	ypos += 24;
	sui_button("wn_btn", [xpos, ypos], [width, 20], "Windowed") ? localcmd("vid_fullscreen 0; vid_width 1024; vid_height 768; vid_restart\n") : 0;
	ypos += 24;

	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Graphics Preset", MENU_TEXT_1, 1, 0);
	ypos += 16;
	sui_button("preset_classic_btn", [xpos, ypos], [width/2 - 4, 20], "Classic") ? 	localcmd("gl_texturemode GL_NEAREST; r_shadows 0; r_particledesc classic; r_nolerp 1; vid_renderscale 1; vid_restart\n") : 0;
	xpos += width/2 + 4;
	sui_button("preset_modern_btn", [xpos, ypos], [width/2 - 4, 20], "Modern") ? localcmd("gl_texturemode GL_LINEAR_MIPMAP_LINEAR; r_shadows 1; r_particledesc modern; r_nolerp 0; vid_renderscale 1; vid_restart\n") : 0;
	ypos += 24;
	xpos -= width/2 + 4;

	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Particles", MENU_TEXT_1, 1, 0);
	ypos += 16;
	sui_button("particles_classic_btn", [xpos, ypos], [width/2 - 4, 20], "Classic") ? localcmd("r_particledesc classic; vid_restart\n") : 0;
	xpos += width/2 + 4;
	sui_button("particles_modern_btn", [xpos, ypos], [width/2 - 4, 20], "Modern") ? localcmd("r_particledesc modern; vid_restart\n") : 0;
	ypos += 24;
	xpos -= width/2 + 4;

	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Controls", MENU_TEXT_1, 1, 0);
	ypos += 16;
	bind_list("bindlist", [xpos, ypos], [width, 64], binds_scroll);
	ypos += 160 + 8;
	
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
	if (sui_button("stg_back", [8, -8], [80, 20], "Back"))
	{
		current_menu = MENU_MAIN;
		res_index = -1;
	}
	sui_set_default_kb_focus("volume");
	if (sui_listen_back())
	{
		current_menu = MENU_MAIN;
		res_index = -1;
	}

	sui_pop_frame();
};

void() main_menu =
{
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    sui_text([0, 36], MENU_TEXT_LARGE, "Quake on Rails", [1, 1, 1], 1, 0);
    
    vector pos = [0, -15];
    vector size = [140, 156];
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
    sui_push_frame(pos, size);
    
    sui_fill([0, 0], size, MENU_BG, 0.3, 0);
    sui_border_box([0, 0], size, 2, MENU_BORDER, 0.2, 0);
    
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    
    float ypos = 10;
    float btn_w = size_x - 16;
    
    sui_button("mm_start",    [0, ypos], [btn_w, 22], "Start Game")  ? current_menu = MENU_PLAYER : 0;
	ypos += 26;
    sui_button("mm_settings", [0, ypos], [btn_w, 22], "Settings")    ? current_menu = MENU_SETTINGS : 0;
    ypos += 26;
    sui_button("mm_help",     [0, ypos], [btn_w, 22], "Help")        ? current_menu = MENU_HELP : 0;

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
    sui_button("mm_quit",     [0, -8],   [btn_w, 22], "Quit")        ? localcmd("quit\n") : 0;
    
    sui_pop_frame();    

    sui_set_default_kb_focus("mm_start");
};

void(vector size) root_menu =
{
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_fill([0, 0], size, '0 0 0', 0.5, 0);
    
    switch (current_menu)
    {
        case MENU_MAIN: main_menu(); break;
        case MENU_HELP: help_menu(); break;
        case MENU_PLAYER: player_setup_menu(); break;
        case MENU_MAPS: map_selection_menu(); break;
        case MENU_SETTINGS: settings_menu(); break;
        default: main_menu(); break;
    }

    
    setcursormode(1, cvar_string("cl_crosshair_path"), '16 16 0', 1);
};
