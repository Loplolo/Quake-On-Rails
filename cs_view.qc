float cursor_mode_set;

vector crosshair_pos;
float screen_height, screen_width;

vector prev_crosshair_pos;
float polling_delta;
float old_buttons; 

#define IE_BUTTONPRESS 1
#define IE_MOUSEMOVE 2
#define IE_MOUSEABS 3

float CSQC_InputEvent(float evtype, float scanx, float chary, float devid) {

	if (evtype == IE_MOUSEABS) {
        crosshair_pos_x = scanx - (screen_width * 0.5);
        crosshair_pos_y = chary - (screen_height * 0.5);
        
        float max_x = (screen_width * 0.5);
        float max_y = (screen_height * 0.5);
        
        crosshair_pos_x = bound(-max_x, crosshair_pos_x, max_x);
        crosshair_pos_y = bound(-max_y, crosshair_pos_y, max_y);
        
        return TRUE; 
    }

    return FALSE;
}

void CSQC_Input_Frame(void) {

	// override player input so they can't turn with keyboard keys
    input_angles = getproperty(VF_ANGLES);
    input_movevalues = '0 0 0';

    vector screen_proj = [crosshair_pos_x + screen_width * 0.5, crosshair_pos_y + screen_height * 0.5, 1000];
    vector world_proj = unproject(screen_proj);
    vector ray = normalize(world_proj);    

    if (((input_buttons & IE_BUTTONPRESS) && !(old_buttons & IE_BUTTONPRESS))
        || ((vlen(crosshair_pos - prev_crosshair_pos) > 1) && time > polling_delta)) {
        
        string cmdstr = strcat("cmd sdir ", ftos(ray_x), " ", ftos(ray_y), " ", ftos(ray_z), "\n");
        localcmd(cmdstr);
        
        prev_crosshair_pos = crosshair_pos;
        polling_delta = time + 0.05;
    }
    old_buttons = input_buttons;
}

void CSQC_UpdateView(float vwidth, float vheight, float notmenu) {

	if (!cursor_mode_set) {
        setcursormode(1, cvar_string("cl_crosshair_path"), '16 16 0', 1);
        cursor_mode_set = TRUE;
    }
		
	// do not show background demo or game when paused or in main menu
    if (!notmenu) {
        return;
    }

	clearscene();



	screen_height = vheight;
	screen_width = vwidth;
	setproperty(VF_DRAWCROSSHAIR, 0);
	setproperty(VF_FOV, '90 0 0');

    setproperty(VF_DRAWWORLD, 1);
    addentities(MASK_VIEWMODEL | MASK_ENGINE);
    renderscene();

    float showscores = (intermission != 0);
    CSQC_DrawHud([vwidth, vheight], showscores);
	CSQC_DrawScores([vwidth, vheight], showscores);
}

